//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementEQueryInterfaceUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes;

  function TaskImplementEQueryInterface(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses Sysutils, UErrorConsts, UTTaskUtils, UTrayConsts, UTaskImplementEQueryInterfaceUtilsUtils, ComObj, UPackTypes, UNodeNameUtils,
       UTrayTypes, UEPointPropertiesTypes, UServerProcConfigureTypes, UAppMessageTypes, Windows;

function TaskImplementEQueryInterface(aCallerAction:ICallerAction; aTask:TTask; const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  function localGetITray:ITray; begin
    result:=cnTray;
    if not assigned(result) then raise exception.create('cnTray not assigned.');
  end;
  function localGetIEPointProperties:IEPointProperties;begin
    localGetITray.Query(IEPointProperties, result);
  end;
  var tmpIUnknown:IUnknown;
      tmpGuid:TGuid;
      tmpDispatch:IDispatch;
      tmpLevel:Integer;
      tmpPlace:TPlace;
      tmpPlaceData:Variant;
      tmpNodeName:AnsiString;
      tmpServerProcConfigure:IServerProcConfigure;
      tmpStart:TDateTime;
begin
  if assigned(aTaskContext) then aTaskContext^.aSetResult:=false else raise exception.create('aTaskContext not assigned.');
  result:=true;
  case aTask of
    tskMTEQueryInterface:begin
      tmpStart:=now;
      VariantToEQueryInterfaceParam(aParams, tmpGuid);
      tmpIUnknown:=CreateComObject(tmpGuid);
      if not assigned(tmpIUnknown) then raise exception.create('CreateComObject: result not assigned.');
      if (tmpIUnknown.QueryInterface(IServerProcConfigure, tmpServerProcConfigure)=S_OK)and(assigned(tmpServerProcConfigure))and(tmpServerProcConfigure.GetVersion=2) then begin
        tmpServerProcConfigure.SetCallerAction(aCallerAction);
        tmpServerProcConfigure.SetTray(localGetITray);
        if assigned(aCallerAction) then aCallerAction.ITMessAdd(tmpStart, now, 'EQueryInterface', 'CreateComObject('+GuidToString(tmpGuid)+')', mecApp, mesInformation);
      end else begin
        if assigned(aCallerAction) then aCallerAction.ITMessAdd(tmpStart, now, 'EQueryInterface', 'CreateComObject('+GuidToString(tmpGuid)+'). IServerProcConfigure no supported.', mecApp, mesWarning);
      end;
      if (tmpIUnknown.QueryInterface(IDispatch, tmpDispatch)<>S_OK)or(not assigned(tmpDispatch)) then raise exception.create('IDispatch no found.');
      if assigned(aTaskContext^.aResult) then begin
        aTaskContext^.aResult^:=tmpDispatch;
        aTaskContext^.aSetResult:=true;
      end;
    end;
    tskMTEQueryInterfaceByLevel:begin
      VariantToEQueryInterfaceByLevelParam(aParams, tmpLevel, tmpGuid);
      if tmpLevel=0 then result:=TaskImplementEQueryInterface(aCallerAction, tskMTEQueryInterface, EQueryInterfaceParamToVariant(tmpGuid), aTaskContext, aRaise) else
        if tmpLevel<0 then raise exception.create('EQueryInterfaceByLevel not support aLevel<0, use EQueryInterfaceByNodeName.') else begin
          UpEQueryInterfaceByLevelViaBridge(aCallerAction, tmpLevel-1, tmpGuid, tmpDispatch);
          if assigned(aTaskContext^.aResult) then begin
            aTaskContext^.aResult^:=tmpDispatch;
            aTaskContext^.aSetResult:=true;
          end;
        end;
    end;
    tskMTEQueryInterfaceByNodeName:begin
      VariantToEQueryInterfaceByNodeNameParam(aParams, tmpNodeName, tmpGuid);
      TwoNodeNameToPlace(localGetIEPointProperties.NodeName[nil]{FromNodeName}, tmpNodeName{ToNodeName}, tmpPlace, tmpPlaceData);
      case tmpPlace of
        pdsNone:begin
          result:=TaskImplementEQueryInterface(aCallerAction, tskMTEQueryInterface, EQueryInterfaceParamToVariant(tmpGuid), aTaskContext, aRaise);
        end;
        pdsEventOnID:begin
          DnEQueryInterfaceByNodeNameViaASM(aCallerAction, tmpPlaceData, tmpNodeName, tmpGuid, tmpDispatch);
          if assigned(aTaskContext^.aResult) then begin
            aTaskContext^.aResult^:=tmpDispatch;
            aTaskContext^.aSetResult:=true;
          end;
        end;
        pdsEventOnBridge:begin
          DnEQueryInterfaceByNodeNameViaBridge(aCallerAction, tmpPlaceData, tmpNodeName, tmpGuid, tmpDispatch);
          if assigned(aTaskContext^.aResult) then begin
            aTaskContext^.aResult^:=tmpDispatch;
            aTaskContext^.aSetResult:=true;
          end;
        end;
        pdsCommandOnID:begin
          UpEQueryInterfaceByNodeNameViaASM(aCallerAction, tmpPlaceData, tmpNodeName, tmpGuid, tmpDispatch);
          if assigned(aTaskContext^.aResult) then begin
            aTaskContext^.aResult^:=tmpDispatch;
            aTaskContext^.aSetResult:=true;
          end;
        end;
        pdsCommandOnBridge:begin
          UpEQueryInterfaceByNodeNameViaBridge(aCallerAction, tmpNodeName, tmpGuid, tmpDispatch);
          if assigned(aTaskContext^.aResult) then begin
            aTaskContext^.aResult^:=tmpDispatch;
            aTaskContext^.aSetResult:=true;
          end;
        end;
        pdsEventOnUser, pdsEventOnAll, pdsCommandOnUser, pdsCommandOnAll, pdsEventOnMask, pdsCommandOnMask,
        pdsEventOnNameMask, pdsCommandOnNameMask:begin
          raise exception.createFmtHelp(cserInternalError, ['Unexpected place'], cnerInternalError);
        end;
      else
        raise exception.createFmtHelp(cserInternalError, ['Invalid place'], cnerInternalError);
      end;
    end;
  else
    if aRaise then raise exception.CreateFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
