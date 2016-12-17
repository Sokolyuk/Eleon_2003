unit UAdmittanceASMPGS;

interface
  uses UAdmittanceASM;
type
  TAdmittanceASMPGS=class(TAdmittanceASM)
  protected
    Function InternalGetLoginType(aState:Integer):Integer;override;
    //Procedure InternalITAddWishingToCauseDestroy(aObject:TObject);override;
    Procedure InternalGetIUnknown(aObject:TObject; out aObj);override;
    Procedure InternalSetDisconnectObject(aObject:TObject);override;
  end;

implementation
  uses UAS, Sysutils, Windows, UASMConsts, UErrorConsts;

Function TAdmittanceASMPGS.InternalGetLoginType(aState:Integer):Integer;
begin
  result:=0;
  If (msk_rsLogin and aState)=msk_rsLogin Then result:=result or 1;
  If (msk_rsADMLogin and aState)=msk_rsADMLogin Then result:=result or 2;
end;

{Procedure TAdmittanceASMPGS.InternalITAddWishingToCauseDestroy(aObject:TObject);
begin
  if not(aObject is TAUPegas) Then Raise Exception.Create('aObject is not TAUPegas.');
  TAUPegas(aObject).ITAddWishingToCauseDestroy(GetCurrentThreadId);
end;}

Procedure TAdmittanceASMPGS.InternalGetIUnknown(aObject:TObject; out aObj);
begin
  if not((aObject is TAUPegas)and(TAUPegas(aObject).GetInterface(IUnknown, aObj))) then begin
    pointer(aObj):=nil;
    Raise Exception.CreateFmtHelp(cserInternalError, ['aObject is not TAUPegas'], cnerInternalError);
  end;
end;

Procedure TAdmittanceASMPGS.InternalSetDisconnectObject(aObject:TObject);
begin
  if aObject is TAUPegas then begin
    TAUPegas(aObject).ITSetDisconnectObject;
  end;
end;

end.
