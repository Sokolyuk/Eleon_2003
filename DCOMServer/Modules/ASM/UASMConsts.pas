unit UASMConsts;

interface

Const
  msk_rsTransaction:Integer=$01;
  msk_rsLogin:Integer=1 shl 1; //$02;                       // only for Pegas
  msk_rsADMLogin:Integer=1 shl 2; //$04;
  msk_rsInitialization:Integer=1 shl 3; //$08;                       // only for Pegas
  msk_rsNoSQL:Integer=1 shl 4; //$10;                   // only for EMSrv
  msk_rsNoCDS:Integer=1 shl 5; //$20;                   // only for EMSrv
  msk_rsNoCache:Integer=1 shl 6; //$40;                   // only for EMSrv
  msk_rsKeepConnection:Integer=1 shl 7; //$80;                   // only for EMSrv
  msk_rsNoConnection:Integer=1 shl 8; //$100;                  // only for EMSrv
  msk_rsRollBackOnEClose:Integer=1 shl 9; //$200;                  // only for EMSrv
  msk_rsMServerLogin:Integer=1 shl 10; //$400;                 // only for EMSrv
  msk_rsPegasLogin:Integer=1 shl 11; //$800;                 // only for EMSrv
  msk_rsMServerOnLine:Integer=1 shl 12; //$1000;                // only for EMSrv
  msk_rsOpen:Integer=1 shl 13; //$2000;                // only for EMSrv
  msk_rsCheckRecordsAffectedOnApplyUpdates:Integer=1 shl 14; //$4000; // only for EMSrv
  msk_rsReliableClient:Integer=1 shl 15; // $8000                // only fo Pegas
  msk_rsBridge:Integer=1 shl 16; // $10000
  msk_rsKeepLocalConnection:Integer=1 shl 17; // $20000               // only for EMSrv
  msk_rsBridgeReliable:Integer=1 shl 18; // $40000               // only for EMSrv

Const//String const
  stssAdminLogin:AnsiString='ADMLogin';
  stssTransaction:AnsiString='Transaction';
  stssPegasLogin:AnsiString='PegasLogin';
  stssBridge:AnsiString='Bridge';
  stssBridgeReliable:AnsiString='BridgeReliable';
  stssKeepLocalConnection:AnsiString='KeepLocalConnection';
  stssRequiredForRelogin:AnsiString='RequiredForRelogin';
  stssKeepConnection:AnsiString='KeepConnection';
{$IFDEF PegasServer}
  stssInitialization:AnsiString='Initialization';
  stssReliableClient:AnsiString='ReliableClient';
{$endif}
{$IFDEF EAMServer}
  stssNoSQL:AnsiString='NoSQL';
  stssNoCDS:AnsiString='NoCDS';
  stssNoCache:AnsiString='NoCache';
  stssNoConnection:AnsiString='NoConnection';
  stssRollBackOnEClose:AnsiString='RollBackOnEClose';
  stssMServerLogin:AnsiString='MServerLogin';
  stssMServerOnLine:AnsiString='MServerOnLine';
  stssOpen:AnsiString='Open';
  stssCheckRecordsAffectedOnApplyUpdates:AnsiString='CheckRecordsAffectedOnApplyUpdates';
{$ENDIF}
const
  stTabCMD:Char=',';
  stAddCMD:Char='+';
  stDelCMD:Char='-';

implementation

end.
