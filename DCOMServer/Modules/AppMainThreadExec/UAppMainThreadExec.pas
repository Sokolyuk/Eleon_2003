unit UAppMainThreadExec;

interface
  uses UIObject, UAppMainThreadExecTypes, UExecMethodTypes, Messages, Windows;
type
  TAppMainThreadExec=class(TIObject, IAppMainThreadExec)
  protected
    FWindowHandle:HWND;
    procedure WndProc(var aMsg:TMessage);virtual;
    procedure InternalAppMainThreadExec(aExecMethod:IExecMethod; aUserData:Pointer);virtual;
  public
    constructor create;
    destructor destroy;override;
  public
    procedure AppMainThreadExec(aExecMethod:IExecMethod; aUserData:Pointer);virtual;
  end;

implementation
  uses SysUtils, UErrorConsts, Classes, Forms;

constructor TAppMainThreadExec.create;
begin
  inherited create;
  FWindowHandle:={$IFDEF VER130}Forms{$ENDIF}{$IFDEF VER140}Classes{$ENDIF}{$IFDEF VER150}Classes{$ENDIF}.AllocateHWnd(WndProc);
end;

destructor TAppMainThreadExec.destroy;
begin
  {$IFDEF VER130}Forms{$ENDIF}{$IFDEF VER140}Classes{$ENDIF}{$IFDEF VER150}Classes{$ENDIF}.DeallocateHWnd(FWindowHandle);
  inherited destroy;
end;

procedure TAppMainThreadExec.AppMainThreadExec(aExecMethod:IExecMethod; aUserData:Pointer);
begin
  if not assigned(aExecMethod) then raise exception.createFmtHelp(cserInternalError, ['aExecMethod not assigned'], cnerInternalError);
  if GetCurrentThreadID=MainThreadID then begin
    InternalAppMainThreadExec(aExecMethod, aUserData);
  end else begin
    aExecMethod._AddRef;
    PostMessage(FWindowHandle, WM_USER, WPARAM(pointer(aExecMethod)), LPARAM(aUserData));
  end;
end;

procedure TAppMainThreadExec.InternalAppMainThreadExec(aExecMethod:IExecMethod; aUserData:Pointer);
begin
  aExecMethod.ExecMethod(aUserData);
end;

procedure TAppMainThreadExec.WndProc(var aMsg:TMessage);
  var tmpExecMethod:IExecMethod;
      tmpUserData:Pointer;
begin
  with aMsg do begin
    if Msg=WM_USER then
      try
        if GetCurrentThreadID<>MainThreadID then raise exception.createFmtHelp(cserInternalError, ['TAppMainThreadExec: WM_USER:GetCurrentThreadID('+IntToStr(GetCurrentThreadID)+')<>MainThreadID('+IntToStr(MainThreadID)+')'], cnerInternalError);
        tmpExecMethod:=IExecMethod(pointer(wParam));
        if not assigned(tmpExecMethod) then raise exception.createFmtHelp(cserInternalError, ['aExecMethod not assigned'], cnerInternalError);
        tmpExecMethod._Release;
        tmpUserData:=pointer(lParam);
        InternalAppMainThreadExec(tmpExecMethod, tmpUserData);
      except
        Application.HandleException(Self);
      end
    else Result:=DefWindowProc(FWindowHandle, Msg, wParam, lParam);
  end;  
end;

end.
