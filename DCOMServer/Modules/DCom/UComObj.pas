unit UComObj;

interface

  Procedure CoInitialize;
  Procedure CoUninitialize;
  //
{  procedure OleCheck(Result:HResult);
  Procedure glCreateComObject(const ClassID:TGUID; out pv);
  function glCreateRemoteComObject(const MachineName:WideString; const ClassID:TGUID):IUnknown;}

implementation
  Uses SysUtils, ActiveX, Windows, ComConst;

Procedure CoInitialize;
  Var tmpHResult:HResult;
begin
  tmpHResult:=ActiveX.CoInitializeEx(nil, COINIT_MULTITHREADED);
  If Not Succeeded(tmpHResult) then begin
    Raise Exception.Create('CoInitializeEx: '+SysErrorMessage(HResultCode(tmpHResult)));
  end;
end;

Procedure CoUninitialize;
Begin
  ActiveX.CoUninitialize;
end;

(*procedure OleCheck(Result:HResult);
begin
  if not Succeeded(Result) then Raise Exception.Create(SysErrorMessage(Result));
end;


Procedure glCreateComObject(const ClassID:TGUID; out pv);
begin
  OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, pv));
end;

{function glCreateComObject(const ClassID:TGUID):IUnknown;
begin
  OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, Result));
  Result._AddRef;
end;}

function glCreateRemoteComObject(const MachineName:WideString; const ClassID:TGUID):IUnknown;
const
  LocalFlags = CLSCTX_LOCAL_SERVER or CLSCTX_REMOTE_SERVER or CLSCTX_INPROC_SERVER;
  RemoteFlags = CLSCTX_REMOTE_SERVER;
var
  MQI: TMultiQI;
  ServerInfo: TCoServerInfo;
  IID_IUnknown: TGuid;
  Flags, Size: DWORD;
  LocalMachine: array [0..MAX_COMPUTERNAME_LENGTH] of char;
begin
  if @CoCreateInstanceEx = nil then
    raise Exception.CreateRes(@SDCOMNotInstalled);
  FillChar(ServerInfo, sizeof(ServerInfo), 0);
  ServerInfo.pwszName := PWideChar(MachineName);
  IID_IUnknown := IUnknown;
  MQI.IID := @IID_IUnknown;
  MQI.itf := nil;
  MQI.hr := 0;
  { If a MachineName is specified check to see if it the local machine.
    If it isn't, do not allow LocalServers to be used. }
  if Length(MachineName) > 0 then
  begin
    Size := Sizeof(LocalMachine);  // Win95 is hypersensitive to size
    if GetComputerName(LocalMachine, Size) and
       (AnsiCompareText(LocalMachine, MachineName) = 0) then
      Flags := LocalFlags else
      Flags := RemoteFlags;
  end else
    Flags := LocalFlags;
  OleCheck(CoCreateInstanceEx(ClassID, nil, Flags, @ServerInfo, 1, @MQI));
  OleCheck(MQI.HR);
  Result := MQI.itf;
end;*)


Initialization
Finalization
end.
