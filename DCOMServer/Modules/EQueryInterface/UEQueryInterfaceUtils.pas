//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UEQueryInterfaceUtils;

interface
  function EQueryInterface(const aSecurityContext:Variant; const aGuid:TGuid):IDispatch;
  function EQueryInterfaceByLevel(const aSecurityContext:Variant; aLevel:Integer; const aGuid:TGuid):IDispatch;
  function EQueryInterfaceByNodeName(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:TGuid):IDispatch;

implementation
  uses UCaller, UTaskImplementTypes, UTrayTypes, UTrayConsts, Sysutils, UTTaskTypes, UTaskImplementEQueryInterfaceUtilsUtils
       {$IFNDEF VER130}, Variants{$ENDIF}, UErrorConsts;

function InternalGetITray:ITray;
begin
  result:=cnTray;
  if not assigned(result) then raise exception.create('cnTray not assigned.');
end;

function EQueryInterface(const aSecurityContext:Variant; const aGuid:TGuid):IDispatch;
  var tmpTaskContext:TTaskContext;
      tmpResult:Variant;
begin
  tmpTaskContext:=cnDefTaskContext;
  tmpTaskContext.aManualResultSet:=true;
  tmpTaskContext.aResult:=@tmpResult;
  ITaskImplement(InternalGetITray.Query(ITaskImplement)).TasksImplements(TCallerAction.CreateNewAction(aSecurityContext){FCallerAction}, tskMTEQueryInterface, EQueryInterfaceParamToVariant(aGuid), @tmpTaskContext);
  if (not tmpTaskContext.aSetResult)or((VarType(tmpResult)<>varDispatch)and(VarType(tmpResult)<>varUnknown)) then raise exception.createFmtHelp(cserInternalError, ['No set correct result'], cnerInternalError);
  Result:=tmpResult;
end;

function EQueryInterfaceByLevel(const aSecurityContext:Variant; aLevel:Integer; const aGuid:TGuid):IDispatch;
  var tmpTaskContext:TTaskContext;
      tmpResult:Variant;
begin
  tmpTaskContext:=cnDefTaskContext;
  tmpTaskContext.aManualResultSet:=true;
  tmpTaskContext.aResult:=@tmpResult;
  ITaskImplement(InternalGetITray.Query(ITaskImplement)).TasksImplements(TCallerAction.CreateNewAction(aSecurityContext){FCallerAction}, tskMTEQueryInterfaceByLevel, EQueryInterfaceByLevelParamToVariant(aLevel, aGuid), @tmpTaskContext);
  if (not tmpTaskContext.aSetResult)or((VarType(tmpResult)<>varDispatch)and(VarType(tmpResult)<>varUnknown)) then raise exception.createFmtHelp(cserInternalError, ['No set correct result'], cnerInternalError);
  Result:=tmpResult;
end;

function EQueryInterfaceByNodeName(const aSecurityContext:Variant; const aNodeName:AnsiString; const aGuid:TGuid):IDispatch;
  var tmpTaskContext:TTaskContext;
      tmpResult:Variant;
begin
  tmpTaskContext:=cnDefTaskContext;
  tmpTaskContext.aManualResultSet:=true;
  tmpTaskContext.aResult:=@tmpResult;
  ITaskImplement(InternalGetITray.Query(ITaskImplement)).TasksImplements(TCallerAction.CreateNewAction(aSecurityContext){FCallerAction}, tskMTEQueryInterfaceByNodeName, EQueryInterfaceByNodeNameParamToVariant(aNodeName, aGuid), @tmpTaskContext);
  if (not tmpTaskContext.aSetResult)or((VarType(tmpResult)<>varDispatch)and(VarType(tmpResult)<>varUnknown)) then raise exception.createFmtHelp(cserInternalError, ['No set correct result'], cnerInternalError);
  Result:=tmpResult;
end;

end.
