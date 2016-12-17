//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UDispatchSilencer; 

interface

{ TDispatchSilencer }

type
  TMyDispatchSilencer = class(TInterfacedObject, IUnknown, IDispatch)
  private
    Dispatch: IDispatch;
    DispIntfIID: TGUID;
  public
    constructor Create(ADispatch: IUnknown; const ADispIntfIID: TGUID);
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  end;

implementation
Uses ComObj, Windows, ActiveX;

constructor TMyDispatchSilencer.Create(ADispatch: IUnknown;
  const ADispIntfIID: TGUID);
begin
  inherited Create;
  DispIntfIID := ADispIntfIID;
  OleCheck(ADispatch.QueryInterface(ADispIntfIID, Dispatch));
end;

function TMyDispatchSilencer.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
  if Result = E_NOINTERFACE then
    if IsEqualGUID(IID, DispIntfIID) then
    begin
      IDispatch(Obj) := Self;
      Result := S_OK;
    end
    else
      Result := Dispatch.QueryInterface(IID, Obj);
end;

function TMyDispatchSilencer.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := Dispatch.GetTypeInfoCount(Count);
end;

function TMyDispatchSilencer.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Result := Dispatch.GetTypeInfo(Index, LocaleID, TypeInfo);
end;

function TMyDispatchSilencer.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := Dispatch.GetIDsOfNames(IID, Names, NameCount, LocaleID, DispIDs);
end;

function TMyDispatchSilencer.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
//  { Ignore error since some containers, such as Internet Explorer 3.0x, will
//    return error when the method was not handled, or scripting errors occur }
  Result :=Dispatch.Invoke(DispID, IID, LocaleID, Flags, Params, VarResult, ExcepInfo,
    ArgErr);
//  Result := S_OK;
end;


end.
 