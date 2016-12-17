//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementExecPackESCUtils;

interface
  uses UTTaskTypes, UCallerTypes, UTaskImplementTypes{$IFDEF VER140}, Variants{$ENDIF}, UTTaskUtils{$IFDEF VER150}, Variants{$ENDIF};

  function TaskImplementExecPackESC(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;

implementation
  uses UTrayConsts, UTrayTypes, UEServerConnectionsTypes, Sysutils, UErrorConsts, UPackPDTypes, UPackPDPlaceTypes, UPackTypes{$IFDEF VER130}, windows{$ENDIF};

function TaskImplementExecPackESC(aCallerAction:ICallerAction; aTask:TTask; Const aParams:Variant; aTaskContext:PTaskContext; aRaise:boolean=true):boolean;
  function localGetTray:ITray;begin
    result:=cnTray;
    if not assigned(result) then raise exception.createFmtHelp(cserInternalError, ['cnTray not assigned'], cnerInternalError);
  end;
  var tmpIUnknown:IUnknown;
      tmpIPackPD, tmpClonePackPD:IPackPD;
      tmpIntIndex:Integer;
      tmpIPackPDPlace:IPackPDPlace;
begin
  result:=true;
  case aTask of
    tskMTPDConnectionName:begin//In aParams: [0]:varOleStr(ConnectionName); [1]varVariant(PackPDAsIPack)
      tmpIUnknown:=aParams[1];
      if (not assigned(tmpIUnknown))or(tmpIUnknown.QueryInterface(IPackPD, tmpIPackPD)<>S_OK)or(not assigned(tmpIPackPD)) then raise exception.createFmtHelp(cserInternalError, ['IPackPD no found'], cnerInternalError);
      tmpIntIndex:=-1;
      tmpIPackPDPlace:=tmpIPackPD.Places.ViewNextPackPDPlaceOfIntIndex(tmpIntIndex);
      if tmpIntIndex=-1 then raise exception.createFmtHelp(cserInternalError, ['tmpIntIndex=-1'], cnerInternalError);
      case tmpIPackPDPlace.Place of
        pdsCommandOnUser, pdsCommandOnID, pdsCommandOnAll, pdsCommandOnMask, pdsCommandOnNameMask:;
      else
        raise exception.createFmtHelp(cserInternalError, ['tmpIPackPDPlace.Place='+IntToStr(Integer(tmpIPackPDPlace.Place))], cnerInternalError);
      end;
      if tmpIPackPD.Places.CurrNum<>0 then raise exception.createFmtHelp(cserInternalError, ['tmpIPackPD.Places.CurrNum='+IntToStr(tmpIPackPD.Places.CurrNum)], cnerInternalError);
      tmpClonePackPD:=tmpIPackPD.ClonePackPD;
      tmpClonePackPD.Places.CurrNum:=1;//¬нимание. измен€€ это значение, измен€етс€ сам пакет 
      IEServerConnections(localGetTray.Query(IEServerConnections)).ViewOfName(VarToStr(aParams[0]){ConnectionName}).EPackASync(tmpClonePackPD.AsVariant);
    end;
  else
    if aRaise then raise exception.createFmtHelp(cserInternalError, ['Unsupported for '+MTaskToStr(aTask)], cnerInternalError) else result:=false;
  end;
end;

end.
