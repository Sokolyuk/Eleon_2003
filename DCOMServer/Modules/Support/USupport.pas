unit USupport;
{$i ServerType.inc}
{$Define MyDebug_MessToBasicLog}
{$Ifndef ServerType}
   ServerType.inc не найден
{$endif}
{$Ifndef PegasServer}
  {$Ifndef EAMServer}
    Неназначены Defines EAMServer или PegasServer.
  {$endif}
{$endif}
{$Ifdef PegasServer}
  {$Ifdef EAMServer}
    Назначены Defines EAMServer и PegasServer.
  {$endif}
{$endif}

interface

Uses UStringParam, UASMConsts;

Type
  TASMSupport=Class(TObject)
    Function ParamToASMState(MyStringParam:TStringParam):TASMState;
    Function IntegerToASMState(myInt:Integer):TASMState;
    Function ASMStateToInteger(myASMState:TASMState):Integer;
    Function ASMStateToString(myASMState:TASMState):AnsiString;
  end;

implementation
  Uses Sysutils, UStringParamConsts;

// Internal support
Function TASMSupport.ASMStateToString(myASMState:TASMState):AnsiString;
begin
  Result:='';
  If rsTransaction in myASMState Then Result:=Result+stssTransaction+stTabCMD;
  If rsADMLogin in myASMState Then Result:=Result+stssAdminLogin+stTabCMD;
  If rsBridge in myASMState Then Result:=Result+stssBridge+stTabCMD;
{$IFDEF EAMServer}
  If rsNoSQL in myASMState Then Result:=Result+stssNoSQL+stTabCMD;
  If rsNoCDS in myASMState Then Result:=Result+stssNoCDS+stTabCMD;
  If rsNoCache in myASMState Then Result:=Result+stssNoCache+stTabCMD;
  If rsKeepConnection in myASMState Then Result:=Result+stssKeepConnection+stTabCMD;
  If rsNoConnection in myASMState Then Result:=Result+stssNoConnection+stTabCMD;
  If rsRollBackOnEClose in myASMState Then Result:=Result+stssRollBackOnEClose+stTabCMD;
  If rsMServerLogin in myASMState Then Result:=Result+stssMServerLogin+stTabCMD;
  If rsPegasLogin in myASMState Then Result:=Result+stssPegasLogin+stTabCMD;
  If rsMServerOnLine in myASMState Then Result:=Result+stssMServerOnLine+stTabCMD;
  If rsOpen in myASMState Then Result:=Result+stssOpen+stTabCMD;
  If rsCheckRecordsAffectedOnApplyUpdates in myASMState Then Result:=Result+stssCheckRecordsAffectedOnApplyUpdates+stTabCMD;
  If rsKeepLocalConnection in myASMState Then Result:=Result+stssKeepLocalConnection+stTabCMD;
  If rsBridgeReliable in myASMState Then Result:=Result+stssBridgeReliable+stTabCMD;
{$EndIf}
{$IFDEF PegasServer}
  If rsLogin in myASMState Then Result:=Result+stssPegasLogin+stTabCMD;
  If rsInitialization in myASMState Then Result:=Result+stssInitialization+stTabCMD;
  If rsReliableClient in myASMState Then Result:=Result+stssReliableClient+stTabCMD;
{$EndIf}
  If(Result<>'')And(Copy(Result, Length(Result)-Length(stTabCMD)+1, Length(Result))=stTabCMD)Then SetLength(Result, Length(Result)-Length(stTabCMD)); //Result:=Copy(Result, 1, Length(Result)-Length(stTabCMD)); // возможно не очень правильно написана команда Copy.
end;

Function  TASMSupport.ASMStateToInteger(myASMState:TASMState):Integer;
begin
  Result:=0;
  If rsTransaction in myASMState Then Result:=Result or msk_rsTransaction;
  If rsADMLogin in myASMState Then Result:=Result or msk_rsADMLogin;
  If rsBridge in myASMState Then Result:=Result or msk_rsBridge;
{$IFDEF EAMServer}
  If rsNoSQL in myASMState Then Result:=Result or msk_rsNoSQL;
  If rsNoCDS in myASMState Then Result:=Result or msk_rsNoCDS;
  If rsNoCache in myASMState Then Result:=Result or msk_rsNoCache;
  If rsKeepConnection in myASMState Then Result:=Result or msk_rsKeepConnection;
  If rsNoConnection in myASMState Then Result:=Result or msk_rsNoConnection;
  If rsRollBackOnEClose in myASMState Then Result:=Result or msk_rsRollBackOnEClose;
  If rsMServerLogin in myASMState Then Result:=Result or msk_rsMServerLogin;
  If rsPegasLogin in myASMState Then Result:=Result or msk_rsPegasLogin;
  If rsMServerOnLine in myASMState Then Result:=Result or msk_rsMServerOnLine;
  If rsOpen in myASMState Then Result:=Result or msk_rsOpen;
  If rsCheckRecordsAffectedOnApplyUpdates in myASMState Then Result:=Result or msk_rsCheckRecordsAffectedOnApplyUpdates;
  If rsKeepLocalConnection in myASMState Then Result:=Result or msk_rsKeepLocalConnection;
  If rsBridgeReliable in myASMState Then Result:=Result or msk_rsBridgeReliable;
{$EndIf}
{$IFDEF PegasServer}
  If rsLogin in myASMState Then Result:=Result or msk_rsLogin;
  If rsInitialization in myASMState Then Result:=Result or msk_rsInitialization;
  If rsReliableClient in myASMState Then Result:=Result or msk_rsReliableClient;
{$EndIf}
end;

Function  TASMSupport.IntegerToASMState(myInt:Integer):TASMState;
begin
  Result:=[];
  If (msk_rsTransaction and myInt)=msk_rsTransaction Then Result:=Result + [rsTransaction];
  If (msk_rsADMLogin and myInt)=msk_rsADMLogin Then Result:=Result + [rsADMLogin];
  If (msk_rsBridge and myInt)=msk_rsBridge Then Result:=Result+[rsBridge];
{$IFDEF EAMServer}
  If (msk_rsNoSQL and myInt)=msk_rsNoSQL Then Result:=Result + [rsNoSQL];
  If (msk_rsNoCDS and myInt)=msk_rsNoCDS Then Result:=Result + [rsNoCDS];
  If (msk_rsNoCache and myInt)=msk_rsNoCache Then Result:=Result + [rsNoCache];
  If (msk_rsKeepConnection and myInt)=msk_rsKeepConnection Then Result:=Result + [rsKeepConnection];
  If (msk_rsNoConnection and myInt)=msk_rsNoConnection Then Result:=Result + [rsNoConnection];
  If (msk_rsRollBackOnEClose and myInt)=msk_rsRollBackOnEClose Then Result:=Result + [rsRollBackOnEClose];
  If (msk_rsMServerLogin and myInt)=msk_rsMServerLogin Then Result:=Result + [rsMServerLogin];
  If (msk_rsPegasLogin and myInt)=msk_rsPegasLogin Then Result:=Result + [rsPegasLogin];
  If (msk_rsMServerOnLine and myInt)=msk_rsMServerOnLine Then Result:=Result + [rsMServerOnLine];
  If (msk_rsOpen and myInt)=msk_rsOpen Then Result:=Result + [rsOpen];
  If (msk_rsCheckRecordsAffectedOnApplyUpdates and myInt)=msk_rsCheckRecordsAffectedOnApplyUpdates Then Result:=Result + [rsCheckRecordsAffectedOnApplyUpdates];
  If (msk_rsKeepLocalConnection and myInt)=msk_rsKeepLocalConnection Then Result:=Result+[rsKeepLocalConnection];
  If (msk_rsBridgeReliable and myInt)=msk_rsBridgeReliable Then Result:=Result+[rsBridgeReliable];
{$EndIf}
{$IFDEF PegasServer}
  If (msk_rsLogin and myInt)=msk_rsLogin Then Result:=Result+[rsLogin];
  If (msk_rsInitialization and myInt)=msk_rsInitialization Then Result:=Result+[rsInitialization];
  If (msk_rsReliableClient and myInt)=msk_rsReliableClient Then Result:=Result+[rsReliableClient];
{$EndIf}
end;

Function TASMSupport.ParamToASMState(MyStringParam:TStringParam):TASMState;
 Var iI : Integer ; stTmp : AnsiString;
  begin
    If MyStringParam=Nil Then Raise Exception.Create('MyStringParam не создан.');
    Result:=[];
    For iI:=1 To MyStringParam.CountParam Do begin
      stTmp:=MyStringParam.GetParam(iI);
      If stTmp=stssTransaction Then Result:=Result+[rsTransaction] else
      If stTmp=stssAdminLogin Then Result:=Result+[rsADMLogin] else
      If stTmp=stssBridge Then Result:=Result+[rsBridge] else
{$IFDEF EAMServer}
      If stTmp=stssNoSQL Then Result:=Result+[rsNoSQL] else
      If stTmp=stssNoCDS Then Result:=Result+[rsNoCDS] else
      If stTmp=stssNoCache Then Result:=Result+[rsNoCache] else
      If stTmp=stssKeepConnection Then Result:=Result+[rsKeepConnection] else
      If stTmp=stssNoConnection Then Result:=Result+[rsNoConnection] else
      If stTmp=stssRollBackOnEClose Then Result:=Result+[rsRollBackOnEClose] else
      If stTmp=stssMServerLogin Then Result:=Result+[rsMServerLogin] else
      If stTmp=stssPegasLogin Then Result:=Result+[rsPegasLogin] else
      If stTmp=stssMServerOnLine Then Result:=Result+[rsMServerOnLine] else
      If stTmp=stssOpen Then Result:=Result+[rsOpen] else
      If stTmp=stssCheckRecordsAffectedOnApplyUpdates Then Result:=Result+[rsCheckRecordsAffectedOnApplyUpdates] else
      If stTmp=stssKeepLocalConnection Then Result:=Result+[rsKeepLocalConnection] else
      If stTmp=stssBridgeReliable Then Result:=Result+[rsBridgeReliable] else
{$EndIf}
{$IFDEF PegasServer}
      If stTmp=stssPegasLogin Then Result:=Result+[rsLogin] else
      If stTmp=stssInitialization Then Result:=Result+[rsInitialization] else
      If stTmp=stssReliableClient Then Result:=Result+[rsReliableClient] else
{$EndIf}
        Raise Exception.Create('Нет в списке допустимых значений. Флаг '''+stTmp+''' Позиция='+IntToStr(iI));
  end;
End;

end.
