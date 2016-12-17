unit UAdmittanceASMEMS;

interface
  uses UAdmittanceASM;
type
  TAdmittanceASMEMS=class(TAdmittanceASM)
  protected
    function InternalGetLoginType(aState:Integer):Integer;override;
    //procedure InternalITAddWishingToCauseDestroy(aObject:TObject);override;
    procedure InternalGetIUnknown(aObject:TObject; out aObj);override;
    procedure InternalSetDisconnectObject(aObject:TObject);override;
  end;

implementation
  uses UAS, Sysutils, Windows, UASMConsts, UErrorConsts;

function TAdmittanceASMEMS.InternalGetLoginType(aState:Integer):Integer;
begin
  result:=0;
  If (msk_rsMServerLogin and aState)=msk_rsMServerLogin Then result:=result or 1;
  If (msk_rsADMLogin and aState)=msk_rsADMLogin Then result:=result or 2;
  If (msk_rsPegasLogin and aState)=msk_rsPegasLogin Then result:=result or 4;
end;

{procedure TAdmittanceASMEMS.InternalITAddWishingToCauseDestroy(aObject:TObject);
begin
  if not(aObject is TEAMServer) Then Raise Exception.Create('aObject is not TEAMServer.');
  TEAMServer(aObject).ITAddWishingToCauseDestroy(GetCurrentThreadId);
end;}

procedure TAdmittanceASMEMS.InternalGetIUnknown(aObject:TObject; out aObj);
begin
  if not((aObject is TEAMServer)and(TEAMServer(aObject).GetInterface(IUnknown, aObj))) then begin
    pointer(aObj):=nil;
    Raise Exception.CreateFmtHelp(cserInternalError, ['aObject is not TEAMServer'], cnerInternalError);
  end;
end;

procedure TAdmittanceASMEMS.InternalSetDisconnectObject(aObject:TObject);
begin
  if aObject is TEAMServer then begin
    TEAMServer(aObject).ITSetDisconnectObject;
  end;
end;

end.
