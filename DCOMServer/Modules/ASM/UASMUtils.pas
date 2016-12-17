unit UASMUtils;

interface
  Uses UStringParam, UASMTypes, UASMConsts;

  function ParamToASMState(aStringParam:TStringParam):TASMState;
  function IntegerToASMState(aInteger:Integer):TASMState;
  function ASMStateToInteger(aASMState:TASMState):Integer;
  function ASMStateToString(aASMState:TASMState):AnsiString;

implementation
  Uses Sysutils;

function ASMStateToString(aASMState:TASMState):AnsiString;
begin
  Result:='';
{$IfDef EAMServer}
  If rsNoSQL in aASMState Then Result:=Result+stssNoSQL+stTabCMD;
  If rsNoCDS in aASMState Then Result:=Result+stssNoCDS+stTabCMD;
  If rsNoCache in aASMState Then Result:=Result+stssNoCache+stTabCMD;
  If rsNoConnection in aASMState Then Result:=Result+stssNoConnection+stTabCMD;
  If rsRollBackOnEClose in aASMState Then Result:=Result+stssRollBackOnEClose+stTabCMD;
  If rsMServerLogin in aASMState Then Result:=Result+stssMServerLogin+stTabCMD;
  If rsPegasLogin in aASMState Then Result:=Result+stssPegasLogin+stTabCMD;
  If rsMServerOnLine in aASMState Then Result:=Result+stssMServerOnLine+stTabCMD;
  If rsOpen in aASMState Then Result:=Result+stssOpen+stTabCMD;
  If rsCheckRecordsAffectedOnApplyUpdates in aASMState Then Result:=Result+stssCheckRecordsAffectedOnApplyUpdates+stTabCMD;
  If rsKeepLocalConnection in aASMState Then Result:=Result+stssKeepLocalConnection+stTabCMD;
{$endif}
  If rsKeepConnection in aASMState Then Result:=Result+stssKeepConnection+stTabCMD;
  If rsTransaction in aASMState Then Result:=Result+stssTransaction+stTabCMD;
{$IFDEF PegasServer}
  If rsLogin in aASMState Then Result:=Result+stssPegasLogin+stTabCMD;
  If rsInitialization in aASMState Then Result:=Result+stssInitialization+stTabCMD;
  If rsReliableClient in aASMState Then Result:=Result+stssReliableClient+stTabCMD;
{$endif}
  If rsADMLogin in aASMState Then Result:=Result+stssAdminLogin+stTabCMD;
  If rsBridge in aASMState Then Result:=Result+stssBridge+stTabCMD;
  If (Result<>'') And (Copy(Result, Length(Result)-Length(stTabCMD)+1, Length(Result))=stTabCMD) Then Result:=Copy(Result, 1, Length(Result)-Length(stTabCMD));
end;

function ASMStateToInteger(aASMState:TASMState):Integer;
begin
  Result:=0;
{$IfDef EAMServer}
  If rsNoSQL in aASMState Then Result:=Result or msk_rsNoSQL;
  If rsNoCDS in aASMState Then Result:=Result or msk_rsNoCDS;
  If rsNoCache in aASMState Then Result:=Result or msk_rsNoCache;
  If rsNoConnection in aASMState Then Result:=Result or msk_rsNoConnection;
  If rsRollBackOnEClose in aASMState Then Result:=Result or msk_rsRollBackOnEClose;
  If rsMServerLogin in aASMState Then Result:=Result or msk_rsMServerLogin;
  If rsPegasLogin in aASMState Then Result:=Result or msk_rsPegasLogin;
  If rsMServerOnLine in aASMState Then Result:=Result or msk_rsMServerOnLine;
  If rsOpen in aASMState Then Result:=Result or msk_rsOpen;
  If rsCheckRecordsAffectedOnApplyUpdates in aASMState Then Result:=Result or msk_rsCheckRecordsAffectedOnApplyUpdates;
  If rsKeepLocalConnection in aASMState Then Result:=Result or msk_rsKeepLocalConnection;
{$endif}
  If rsKeepConnection in aASMState Then Result:=Result or msk_rsKeepConnection;
  If rsTransaction in aASMState Then Result:=Result or msk_rsTransaction;
{$IFDEF PegasServer}
  If rsLogin in aASMState Then Result:=Result or msk_rsLogin;
  If rsInitialization in aASMState Then Result:=Result or msk_rsInitialization;
  If rsReliableClient in aASMState Then Result:=Result or msk_rsReliableClient;
{$endif}
  If rsADMLogin in aASMState Then Result:=Result or msk_rsADMLogin;
  If rsBridge in aASMState Then Result:=Result or msk_rsBridge;
end;

function IntegerToASMState(aInteger:Integer):TASMState;
begin
  Result:=[];
{$IfDef EAMServer}
  If (msk_rsNoSQL and aInteger)=msk_rsNoSQL Then Result:=Result+[rsNoSQL];
  If (msk_rsNoCDS and aInteger)=msk_rsNoCDS Then Result:=Result+[rsNoCDS];
  If (msk_rsNoCache and aInteger)=msk_rsNoCache Then Result:=Result+[rsNoCache];
  If (msk_rsNoConnection and aInteger)=msk_rsNoConnection Then Result:=Result+[rsNoConnection];
  If (msk_rsRollBackOnEClose and aInteger)=msk_rsRollBackOnEClose Then Result:=Result+[rsRollBackOnEClose];
  If (msk_rsMServerLogin and aInteger)=msk_rsMServerLogin Then Result:=Result+[rsMServerLogin];
  If (msk_rsPegasLogin and aInteger)=msk_rsPegasLogin Then Result:=Result+[rsPegasLogin];
  If (msk_rsMServerOnLine and aInteger)=msk_rsMServerOnLine Then Result:=Result+[rsMServerOnLine];
  If (msk_rsOpen and aInteger)=msk_rsOpen Then Result:=Result+[rsOpen];
  If (msk_rsCheckRecordsAffectedOnApplyUpdates and aInteger)=msk_rsCheckRecordsAffectedOnApplyUpdates Then Result:=Result+[rsCheckRecordsAffectedOnApplyUpdates];
  If (msk_rsKeepLocalConnection and aInteger)=msk_rsKeepLocalConnection Then Result:=Result+[rsKeepLocalConnection];
{$endif}
  If (msk_rsKeepConnection and aInteger)=msk_rsKeepConnection Then Result:=Result+[rsKeepConnection];
  If (msk_rsTransaction and aInteger)=msk_rsTransaction Then Result:=Result+[rsTransaction];
{$IFDEF PegasServer}
  If (msk_rsLogin and aInteger)=msk_rsLogin Then Result:=Result+[rsLogin];
  If (msk_rsInitialization and aInteger)=msk_rsInitialization Then Result:=Result+[rsInitialization];
  If (msk_rsReliableClient and aInteger)=msk_rsReliableClient Then Result:=Result+[rsReliableClient];
{$endif}
  If (msk_rsADMLogin and aInteger)=msk_rsADMLogin Then Result:=Result+[rsADMLogin];
  If (msk_rsBridge and aInteger)=msk_rsBridge Then Result:=Result+[rsBridge];
end;

function ParamToASMState(aStringParam:TStringParam):TASMState;
 Var iI:Integer; stTmp:AnsiString;
  begin
    If aStringParam=Nil Then Raise Exception.Create('Внутренняя ошибка. aStringParam не создан.');
    Result:=[];
    For iI:=1 To aStringParam.CountParam Do begin
      stTmp:=aStringParam.GetParam(iI);
{$IfDef EAMServer}
      If stTmp=stssNoSQL Then Result:=Result+[rsNoSQL] else
      If stTmp=stssNoCDS Then Result:=Result+[rsNoCDS] else
      If stTmp=stssNoCache Then Result:=Result+[rsNoCache] else
      If stTmp=stssNoConnection Then Result:=Result+[rsNoConnection] else
      If stTmp=stssRollBackOnEClose Then Result:=Result+[rsRollBackOnEClose] else
      If stTmp=stssMServerLogin Then Result:=Result+[rsMServerLogin] else
      If stTmp=stssPegasLogin Then Result:=Result+[rsPegasLogin] else
      If stTmp=stssMServerOnLine Then Result:=Result+[rsMServerOnLine] else
      If stTmp=stssOpen Then Result:=Result+[rsOpen] else
      If stTmp=stssCheckRecordsAffectedOnApplyUpdates Then Result:=Result+[rsCheckRecordsAffectedOnApplyUpdates] else
      If stTmp=stssKeepLocalConnection Then Result:=Result+[rsKeepLocalConnection] else
{$endif}
      If stTmp=stssKeepConnection Then Result:=Result+[rsKeepConnection] else
      If stTmp=stssTransaction Then Result:=Result+[rsTransaction] else
{$IFDEF PegasServer}
      If stTmp=stssPegasLogin Then Result:=Result+[rsLogin] else
      If stTmp=stssInitialization Then Result:=Result+[rsInitialization] else
      If stTmp=stssReliableClient Then Result:=Result+[rsReliableClient] else
{$endif}
      If stTmp=stssAdminLogin Then Result:=Result+[rsADMLogin] else
      If stTmp=stssBridge Then Result:=Result+[rsBridge] else
          Raise Exception.Create('Нет в списке допустимых значений. Флаг '''+stTmp+''' Позиция='+IntToStr(iI));
  end;
End;

end.
