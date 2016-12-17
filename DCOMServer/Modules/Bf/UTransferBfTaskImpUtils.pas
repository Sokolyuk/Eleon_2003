//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTransferBfTaskImpUtils;
  Модуль нормальный, но технология устарела. см. TransferDoc/TransferDocs/TransferDocManage/TransferBf
interface
  uses UTransferBfsTypes, UCallerTypes, UBfTypes;
  //В этих процедурах написана реализация вызовов с распаковкой/упаковкой параметров.
//- - - ITBeginDownloadBf - - -
  procedure VariantToParamBgDn(const aVariant:Variant; out aBfName:AnsiString);
  function ParamBgDnToVariant(const aBfName:AnsiString):Variant;
  procedure VariantToResultBgDn(const aVariant:Variant; out aTransferName:AnsiString; out aTBfInfoBeginDownload:TTBfInfoBeginDownload);
  function ResultBgDnToVariant(const aTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload):Variant;
  function TBfInfoBeginDownloadToVariant(const aTBfInfoBeginDownload:TTBfInfoBeginDownload):Variant;
  procedure VariantToTBfInfoBeginDownload(const aVariant:Variant; out aTBfInfoBeginDownload:TTBfInfoBeginDownload);
  procedure BfTaskImp_BgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITDownloadBf - - -
  procedure VariantToParamDn(const aVariant:Variant; out aTransferName:AnsiString; out aSequenceNumber:Cardinal; out aBfTransfer:TBfTransfer);
  function ParamDnToVariant(const aTransferName:AnsiString; aSequenceNumber:Cardinal; const aBfTransfer:TBfTransfer):Variant;
  function BfTransferToVariant(const aBfTransfer:TBfTransfer):Variant;
  procedure VariantToBfTransfer(const aVariant:Variant; out aBfTransfer:TBfTransfer);
  function ResultDnToVariant(aSequenceNumber:Cardinal; const aBfTransfer:TBfTransfer; const aData:Variant):Variant;
  procedure VariantToResultDn(const aVariant:Variant; out aSequenceNumber:Cardinal; out aBfTransfer:TBfTransfer; out aData:Variant);
  procedure BfTaskImp_Dn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITEndDownloadBf - - -
  procedure VariantToParamEndDn(const aVariant:Variant; out aTransferName:AnsiString);
  function ParamEndDnToVariant(const aTransferName:AnsiString):Variant;
  procedure BfTaskImp_EndDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
{-$ifndef PegasServer}
//- - - ITReceiveBeginDownloadBf - - -
  procedure BfTaskImp_RcBgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
//- - - ITReceiveDownloadBf - - -
  procedure BfTaskImp_RcDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
{-$endif}
//- - - ITReceiveErrorBeginDownloadBf - - -
  function CPRErrorToVariant(const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer):Variant;
  procedure VariantToCPRError(const aVariant:Variant; out aTransferName, aErrorMessage:AnsiString; out aHelpContext:Integer);
{-$ifndef PegasServer}
  procedure BfTaskImp_RcErBgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
//- - - ITReceiveErrorDownloadBf - - -
  procedure BfTaskImp_RcErDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
{-$endif}
//- - - ITAddTransferDownload - - -
  procedure VariantToParamAddDn(const aParams:Variant; out aBfName:AnsiString; out aTransferParam:TTransferParam);
  function ParamAddDnToVariant(const aBfName:AnsiString; const aTransferParam:TTransferParam):Variant;
  procedure VariantToResultAddDn(const aParams:Variant; out aTransferName:AnsiString{; out aTransferFrom:TTransferFrom});
  function ResultAddDnToVariant(const aTransferName:AnsiString{; aTransferFrom:TTransferFrom}):Variant;
  procedure VariantToTransferParam(const aParams:Variant; out aTransferParam:TTransferParam);
  function TransferParamToVariant(const aTransferParam:TTransferParam):Variant;
{-$ifndef PegasServer}
  procedure BfTaskImp_AddDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
{-$endif}
//- - - ITTransferCancel - - -
  function ParamTransferCancelToVariant(const aTransferName:AnsiString; const aCancelResponder:Boolean):Variant;
  procedure VariantToParamTransferCancel(const aParams:Variant; out aTransferName:AnsiString; out aCancelResponder:Boolean);
  function ResultTransferCancelToVariant(aCanceled:Boolean):Variant;
  procedure VariantToResultTransferCancel(const aParams:Variant; out aCanceled:Boolean);
  procedure BfTaskImp_TransferCancel(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITReceiveTransferCanceled - - -
  function ResultTransferCanceledToVariant(const aTransferName:AnsiString):Variant;
  procedure VariantToResultTransferCanceled(const aParams:Variant; out aTransferName:AnsiString);
  procedure BfTaskImp_RcTransferCanceled(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
//- - - ITTransferTerminate - - -
  function ParamTransferTerminateToVariant(const aTransferName:AnsiString):Variant;
  procedure VariantToParamTransferTerminate(const aParams:Variant; out aTransferName:AnsiString);
  function ResultTransferTerminateToVariant(aTerminated:Boolean):Variant;
  procedure VariantToResultTransferTerminate(const aParams:Variant; out aTerminated:Boolean);
  procedure BfTaskImp_TransferTerminate(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITReceiveTransferTerminated - - -
  function ResultTransferTerminatedToVariant(const {aTransferName, }aTerminatorSysName:AnsiString):Variant;
  procedure VariantToResultTransferTerminated(const aParams:Variant; out {aTransferName, }aTerminatorSysName:AnsiString);
  procedure BfTaskImp_RcTransferTerminated(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
//- - - ITBfLocalExists - - -
  function ParamLocalExistsToVariant(const aBfName:AnsiString):Variant;
  procedure VariantToParamLocalExists(const aParams:Variant; out aBfName:AnsiString);
  function ResultLocalExistsToVariant(aExists, aTransfering:Boolean):Variant;
  procedure VariantToResultLocalExists(const aParams:Variant; out aExists, aTransfering:Boolean);
  procedure BfTaskImp_LocalExists(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITBfLocalDelete - - -
  function ParamLocalDeleteToVariant(const aBfName:AnsiString):Variant;
  procedure VariantToParamLocalDelete(const aParams:Variant; out aBfName:AnsiString);
  function ResultLocalDeleteToVariant(aDelete:Boolean):Variant;
  procedure VariantToResultLocalDelete(const aParams:Variant; out aDelete:Boolean);
  procedure BfTaskImp_LocalDelete(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
//- - - ITBfTransferTerminateByBfName - - -
  function ParamTransferTerminateByBfNameToVariant(const aBfName:AnsiString):Variant;
  procedure VariantToParamTransferTerminateByBfName(const aParams:Variant; out aBfName:AnsiString);
  function ResultTransferTerminateByBfNameToVariant(aDelete:Boolean):Variant;
  procedure VariantToResultTransferTerminateByBfName(const aParams:Variant; out aDelete:Boolean);
  procedure BfTaskImp_TransferTerminateByBfName(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);

implementation
  Uses Sysutils, UErrorConsts{$IFDEF VER140}, Variants{$ENDIF};

procedure VariantToParamBgDn(const aVariant:Variant; out aBfName:AnsiString);
begin
  aBfName:=aVariant;
end;

function ParamBgDnToVariant(const aBfName:AnsiString):Variant;
begin
  Result:=aBfName;
end;

procedure VariantToResultBgDn(const aVariant:Variant; out aTransferName:AnsiString; out aTBfInfoBeginDownload:TTBfInfoBeginDownload);
begin
  aTransferName:=aVariant[0];
  VariantToTBfInfoBeginDownload(aVariant[1], aTBfInfoBeginDownload);
end;

function ResultBgDnToVariant(const aTransferName:AnsiString; const aTBfInfoBeginDownload:TTBfInfoBeginDownload):Variant;
begin
  Result:=VarArrayOf([aTransferName, TBfInfoBeginDownloadToVariant(aTBfInfoBeginDownload)]);
end;

function TBfInfoBeginDownloadToVariant(const aTBfInfoBeginDownload:TTBfInfoBeginDownload):Variant;
begin//                                             0     1         2         3             4       5                 6                             7
  with aTBfInfoBeginDownload do Result:=VarArrayOf([Path, Filename, Checksum, ChecksumDate, BfType, TransferSchedule, Integer(Cardinal(TotalSize)), Commentary]);
end;

procedure VariantToTBfInfoBeginDownload(const aVariant:Variant; out aTBfInfoBeginDownload:TTBfInfoBeginDownload);
begin
  aTBfInfoBeginDownload.Path:=aVariant[0];
  aTBfInfoBeginDownload.Filename:=aVariant[1];
  aTBfInfoBeginDownload.Checksum:=aVariant[2];
  aTBfInfoBeginDownload.ChecksumDate:=aVariant[3];
  aTBfInfoBeginDownload.BfType:=aVariant[4];
  aTBfInfoBeginDownload.TransferSchedule:=aVariant[5];
  aTBfInfoBeginDownload.TotalSize:=Cardinal(Integer(aVariant[6]));
  aTBfInfoBeginDownload.Commentary:=aVariant[7];
end;

procedure BfTaskImp_BgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpTBfInfoBeginDownload:TTBfInfoBeginDownload;
      tmpBfName:AnsiString;
      tmpTransferName:AnsiString;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  //Можно не обнулять tmpTBfInfoBeginDownload, т.к. он обнулится в ITBeginDownloadBf.
  VariantToParamBgDn(aParams, tmpBfName);
  tmpTransferName:=aTransferBfs.ITBeginDownload(tmpBfName, aCallerAction, tmpTBfInfoBeginDownload{, Nil});
  if assigned(aPResult) then aPResult^:=ResultBgDnToVariant(tmpTransferName, tmpTBfInfoBeginDownload);
  aSetResult:=True;
end;
//- - - ITDownload - - -
function ParamDnToVariant(const aTransferName:AnsiString; aSequenceNumber:Cardinal; const aBfTransfer:TBfTransfer):Variant;
begin
  Result:=VarArrayOf([aTransferName, Integer(aSequenceNumber), BfTransferToVariant(aBfTransfer)]);
end;

procedure VariantToParamDn(const aVariant:Variant; out aTransferName:AnsiString; out aSequenceNumber:Cardinal; out aBfTransfer:TBfTransfer);
begin
  aTransferName:=aVariant[0];
  aSequenceNumber:=Cardinal(Integer(aVariant[1]));
  VariantToBfTransfer(aVariant[2], aBfTransfer);
end;

function ResultDnToVariant(aSequenceNumber:Cardinal; const aBfTransfer:TBfTransfer; const aData:Variant):Variant;
begin
  Result:=VarArrayOf([Integer(aSequenceNumber), BfTransferToVariant(aBfTransfer), aData]);
end;

procedure VariantToResultDn(const aVariant:Variant; out aSequenceNumber:Cardinal; out aBfTransfer:TBfTransfer; out aData:Variant);
begin
  aSequenceNumber:=Cardinal(aVariant[0]);
  VariantToBfTransfer(aVariant[1], aBfTransfer);
  aData:=aVariant[2];
end;

function BfTransferToVariant(const aBfTransfer:TBfTransfer):Variant;
begin
  With aBfTransfer do Result:=VarArrayOf([Integer(Pos), Integer(TransferSize), CheckSum]);
end;

procedure VariantToBfTransfer(const aVariant:Variant; out aBfTransfer:TBfTransfer);
begin
  If Not VarIsArray(aVariant) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aVariant'], cnerInvalidValueOf);
  aBfTransfer.Pos:=Cardinal(Integer(aVariant[0]));
  aBfTransfer.TransferSize:=Cardinal(Integer(aVariant[1]));
  aBfTransfer.CheckSum:=aVariant[2];
end;

procedure BfTaskImp_Dn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpTransferName:AnsiString;
      tmpSequenceNumber:Cardinal;
      tmpBfTransfer:TBfTransfer;
      tmpData:Variant;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  VariantToParamDn(aParams, tmpTransferName, tmpSequenceNumber, tmpBfTransfer);
  aTransferBfs.ITDownload(aCallerAction, tmpTransferName, tmpSequenceNumber, tmpBfTransfer, tmpData);
  if assigned(aPResult) then aPResult^:=ResultDnToVariant(tmpSequenceNumber, tmpBfTransfer, tmpData);
  aSetResult:=True;
end;
//- - - ITEndDownload - - -
procedure VariantToParamEndDn(const aVariant:Variant; out aTransferName:AnsiString);
begin
  aTransferName:=aVariant;
end;

function ParamEndDnToVariant(const aTransferName:AnsiString):Variant;
begin
  Result:=aTransferName;
end;

procedure BfTaskImp_EndDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  var tmpTransferName:AnsiString;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  VariantToParamEndDn(aParams, tmpTransferName);
  aTransferBfs.ITEndDownload(aCallerAction, tmpTransferName);
  aSetResult:=False;
end;
{-$ifndef PegasServer}
//- - - ITReceiveBeginDownload - - -
procedure BfTaskImp_RcBgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName:AnsiString;
      tmpResponderTransferName:AnsiString;
      tmpTBfInfoBeginDownload:TTBfInfoBeginDownload;
begin
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  tmpTransferName:=aParams[0];
  VariantToResultBgDn(aParams[1], tmpResponderTransferName, tmpTBfInfoBeginDownload);
  aTransferBfs.ITReceiveBeginDownload(aCallerAction, tmpTransferName, tmpResponderTransferName, tmpTBfInfoBeginDownload{, Nil});
end;
//- - - ITReceiveDownload - - -
procedure BfTaskImp_RcDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName:AnsiString;
      tmpSequenceNumber:Cardinal;
      tmpData:Variant;
      tmpBfTransfer:TBfTransfer;
begin
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  tmpTransferName:=aParams[0];
  VariantToResultDn(aParams[1], tmpSequenceNumber, tmpBfTransfer, tmpData);
  aTransferBfs.ITReceiveDownload(aCallerAction, tmpTransferName, tmpSequenceNumber, tmpBfTransfer, tmpData{, Nil});
end;
{-$endif}
//- - - ITReceiveErrorBeginDownload - - -
function CPRErrorToVariant(const aTransferName, aErrorMessage:AnsiString; aHelpContext:Integer):Variant;
begin
  Result:=VarArrayOf([aTransferName, aErrorMessage, aHelpContext]);
end;

procedure VariantToCPRError(const aVariant:Variant; out aTransferName, aErrorMessage:AnsiString; out aHelpContext:Integer);
begin
  aTransferName:=aVariant[0];
  aErrorMessage:=aVariant[1];
  aHelpContext:=aVariant[2];
end;

{-$ifndef PegasServer}
procedure BfTaskImp_RcErBgDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName:AnsiString;
      tmpErrorMessage:AnsiString;
      tmpHelpContext:Integer;
begin
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  VariantToCPRError(aParams, tmpTransferName, tmpErrorMessage, tmpHelpContext);
  aTransferBfs.ITReceiveErrorBeginDownload(aCallerAction, tmpTransferName, tmpErrorMessage, tmpHelpContext);
end;
//- - - ITReceiveErrorDownload - - -
procedure BfTaskImp_RcErDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName:AnsiString;
      tmpErrorMessage:AnsiString;
      tmpHelpContext:Integer;
begin
  If (Not Assigned(aTransferBfs)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs'], cnerInvalidValueOf);
  VariantToCPRError(aParams, tmpTransferName, tmpErrorMessage, tmpHelpContext);
  aTransferBfs.ITReceiveErrorDownload(aCallerAction, tmpTransferName, tmpErrorMessage, tmpHelpContext);
end;
{-$endif}
//- - - ITAddTransferDownload - - -
procedure VariantToParamAddDn(const aParams:Variant; out aBfName:AnsiString; out aTransferParam:TTransferParam);
begin
  if VarIsArray(aParams) then begin
    aBfName:=VarToStr(aParams[0]);
    VariantToTransferParam(aParams[1], aTransferParam);
  end else begin
    aBfName:=aParams;
    aTransferParam:=cnTransferParam;
  end;
end;

function ParamAddDnToVariant(const aBfName:AnsiString; const aTransferParam:TTransferParam):Variant;
  var tmpTransferParam:Variant;
begin
  tmpTransferParam:=TransferParamToVariant(aTransferParam);
  if VarIsEmpty(tmpTransferParam) then begin
    Result:=aBfName;
  end else begin
    Result:=VarArrayOf([aBfName, tmpTransferParam]);
  end;
end;

function ResultAddDnToVariant(const aTransferName:AnsiString{; aTransferFrom:TTransferFrom}):Variant;
begin
  Result:={VarArrayOf([}aTransferName{, Integer(aTransferFrom)}{]);}
end;

procedure VariantToResultAddDn(const aParams:Variant; out aTransferName:AnsiString{; out aTransferFrom:TTransferFrom});
begin
  aTransferName:=aParams{[0]};
  //aTransferFrom:=TTransferFrom(Integer(aParams[1]));
end;

function TransferParamToVariant(const aTransferParam:TTransferParam):Variant;
begin
  If (aTransferParam.TransferAuto=cnTransferParam.TransferAuto)And
      (aTransferParam.TransferProcessToSender=cnTransferParam.TransferProcessToSender)And
      {(aTransferParam.TransferFrom=cnTransferParam.TransferFrom)And}(aTransferParam.Path=cnTransferParam.Path)And
      (aTransferParam.FileName=cnTransferParam.FileName) then begin
    Result:=Unassigned;
  end else begin
    with aTransferParam do Result:=VarArrayOf([TransferAuto, TransferProcessToSender, {Integer(TransferFrom),} Path, FileName]);
  end;
end;

procedure VariantToTransferParam(const aParams:Variant; out aTransferParam:TTransferParam);
begin
  If VarIsEmpty(aParams) Then begin
    aTransferParam:=cnTransferParam;//Переменная не назначена, ставлю значения по умолчанию
  end else begin
    with aTransferParam do begin
      TransferAuto:=aParams[0];
      TransferProcessToSender:=aParams[1];
      //TransferFrom:=TTransferFrom(Integer(aParams[2]));
      Path:=aParams[2{3}];
      FileName:=aParams[3{4}];
    end;
  end;
end;

{function SendPackAddTransferDownloadToVariant(aBfName:Integer; aTransferFrom:TTransferFrom; const aNewDownloadName, aOldDownloadName:AnsiString):Variant;
begin               //0                        1        2              3                         4
  Result:=VarArrayOf([integer(srsAddDownload), aBfName, aTransferFrom, aNewDownloadName, aOldDownloadName]);
end;

procedure VariantToSendPackAddTransferDownload(const aVariant:Variant; out aBfName:Integer; out aTransferFrom:TTransferFrom; out aNewDownloadName, aOldDownloadName:AnsiString);
begin
  aIdBase:=aVariant[1];
  aTransferFrom:=TTransferFrom(Integer(aVariant[2]));
  aNewDownloadName:=aVariant[3];
  aOldDownloadName:=aVariant[4];
end;}
{-$ifndef PegasServer}
procedure BfTaskImp_AddDn(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpBfName:AnsiString;
      tmpTransferParam:TTransferParam;
      tmpTransferName:AnsiString;
      //tmpTransferFrom:TTransferFrom;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  //Можно не обнулять tmpTransferParam, т.к. он обнулится.
  VariantToParamAddDn(aParams, tmpBfName, tmpTransferParam);
  tmpTransferName:=aTransferBfs.ITAddTransferDownload(tmpBfName, aCallerAction, aConnectionName, @tmpTransferParam, Nil{, Nil});
  //tmpTransferFrom:={-$ifdef EAMServer}trfFarServer{-$else}{-$ifdef ESClient}trfLocalServer{-$else}Неправильные директивы{-$endif}{-$endif};
  if assigned(aPResult) then aPResult^:=ResultAddDnToVariant(tmpTransferName{, tmpTransferFrom});
  aSetResult:=True;
end;
{-$endif$}
//- - - ITTransferCancel - - -
function ParamTransferCancelToVariant(const aTransferName:AnsiString; const aCancelResponder:Boolean):Variant;
begin
  If aCancelResponder then begin
    Result:=aTransferName;
  end else begin
    Result:=VarArrayOf([aTransferName, aCancelResponder]);
  end;
end;

procedure VariantToParamTransferCancel(const aParams:Variant; out aTransferName:AnsiString; out aCancelResponder:Boolean);
begin
  If VarIsArray(aParams) Then begin
    aTransferName:=aParams[0];
    aCancelResponder:=aParams[1];
  end else begin
    aTransferName:=aParams;
    aCancelResponder:=True;
  end;
end;

function ResultTransferCancelToVariant(aCanceled:Boolean):Variant;
begin
  Result:=aCanceled;
end;

procedure VariantToResultTransferCancel(const aParams:Variant; out aCanceled:Boolean);
begin
  aCanceled:=aParams;
end;

procedure BfTaskImp_TransferCancel(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpTransferName:AnsiString;
      tmpCancelResponder:Boolean;
      tmpBoolean:Boolean;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  VariantToParamTransferCancel(aParams, tmpTransferName, tmpCancelResponder);
  tmpBoolean:=aTransferBfs.ITTransferCancel(tmpTransferName, aCallerAction, aConnectionName, tmpCancelResponder);
  if assigned(aPResult) then aPResult^:=ResultTransferCancelToVariant(tmpBoolean);
  aSetResult:=True;
end;
//- - - ITBfLocalExists - - -
function ParamLocalExistsToVariant(const aBfName:AnsiString):Variant;
begin
  Result:=aBfName;
end;

procedure VariantToParamLocalExists(const aParams:Variant; out aBfName:AnsiString);
begin
  aBfName:=aParams;
end;

function ResultLocalExistsToVariant(aExists, aTransfering:Boolean):Variant;
begin
  Result:=VarArrayOf([aExists, aTransfering]);
end;

procedure VariantToResultLocalExists(const aParams:Variant; out aExists, aTransfering:Boolean);
begin
  if VarIsArray(aParams) then begin
    aExists:=aParams[0];
    aTransfering:=aParams[1];
  end else begin
    aExists:=aParams;
    aTransfering:=false;
  end;
end;

procedure BfTaskImp_LocalExists(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpBfName:AnsiString;
      tmpBoolean:Boolean;
      tmpInfo:TTableBfInfo;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  VariantToParamLocalExists(aParams, tmpBfName);
  tmpBoolean:=aTransferBfs.ITBfLocalExists(tmpBfName, aCallerAction, @tmpInfo, Nil, aConnectionName);
  if assigned(aPResult) then aPResult^:=ResultLocalExistsToVariant(tmpBoolean, tmpInfo.Transfering);
  aSetResult:=True;
end;
//- - - ITBfLocalDelete - - -
function ParamLocalDeleteToVariant(const aBfName:AnsiString):Variant;
begin
  Result:=aBfName;
end;

procedure VariantToParamLocalDelete(const aParams:Variant; out aBfName:AnsiString);
begin
  aBfName:=aParams;
end;

function ResultLocalDeleteToVariant(aDelete:Boolean):Variant;
begin
  Result:=aDelete;
end;

procedure VariantToResultLocalDelete(const aParams:Variant; out aDelete:Boolean);
begin
  aDelete:=aParams;
end;

procedure BfTaskImp_LocalDelete(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpBfName:AnsiString;
      tmpBoolean:Boolean;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  VariantToParamLocalDelete(aParams, tmpBfName);
  tmpBoolean:=aTransferBfs.ITBfLocalDelete(tmpBfName, aCallerAction, aConnectionName);
  if assigned(aPResult) then aPResult^:=ResultLocalDeleteToVariant(tmpBoolean);
  aSetResult:=True;
end;

//- - - ITBfTransferTerminateByBfName - - -
function ParamTransferTerminateByBfNameToVariant(const aBfName:AnsiString):Variant;
begin
  Result:=aBfName;
end;

procedure VariantToParamTransferTerminateByBfName(const aParams:Variant; out aBfName:AnsiString);
begin
  aBfName:=aParams;
end;

function ResultTransferTerminateByBfNameToVariant(aDelete:Boolean):Variant;
begin
  Result:=aDelete;
end;

procedure VariantToResultTransferTerminateByBfName(const aParams:Variant; out aDelete:Boolean);
begin
  aDelete:=aParams;
end;

procedure BfTaskImp_TransferTerminateByBfName(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  var tmpBfName:AnsiString;
      tmpBoolean:Boolean;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  if (not Assigned(aTransferBfs))or(not assigned(aCallerAction)) then raise exception.createFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  VariantToParamTransferTerminateByBfName(aParams, tmpBfName);
  tmpBoolean:=aTransferBfs.ITTransferTerminateByBfName(tmpBfName, aCallerAction, aConnectionName);
  if assigned(aPResult) then aPResult^:=ResultTransferTerminateByBfNameToVariant(tmpBoolean);
  aSetResult:=True;
end;

//- - - ITReceiveTransferCanceled - - -
function ResultTransferCanceledToVariant(const aTransferName:AnsiString):Variant;
begin
  result:=aTransferName;
end;

procedure VariantToResultTransferCanceled(const aParams:Variant; out aTransferName:AnsiString);
begin
  aTransferName:=aParams;
end;

procedure BfTaskImp_RcTransferCanceled(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName:AnsiString;
begin
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  //tmpTransferName:=aParams[0]; - Содержит хороший трансфернэйм для случая отправка Пегас->ЕМС или ЕМС->Клиент, для обратного случая там ResponderTransferName, поэтому игнорирую этот параметр
  VariantToResultTransferCanceled(aParams[0], tmpTransferName);//и пользуюсь aParams[1].
  aTransferBfs.ITReceiveTransferCanceled(aCallerAction, tmpTransferName);
end;
//- - - ITTransferTerminate - - -
function ParamTransferTerminateToVariant(const aTransferName:AnsiString):Variant;
begin
  Result:=aTransferName;
end;

procedure VariantToParamTransferTerminate(const aParams:Variant; out aTransferName:AnsiString);
begin
  aTransferName:=aParams;
end;

function ResultTransferTerminateToVariant(aTerminated:Boolean):Variant;
begin
  result:=aTerminated;
end;

procedure VariantToResultTransferTerminate(const aParams:Variant; out aTerminated:Boolean);
begin
  aTerminated:=aParams;
end;

procedure BfTaskImp_TransferTerminate(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aConnectionName:AnsiString; const aParams:Variant; out aSetResult:Boolean; aPResult:PVariant);
  Var tmpTransferName:AnsiString;
      tmpBoolean:Boolean;
begin
  if assigned(aPResult) then aPResult^:=Unassigned;
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  VariantToParamTransferTerminate(aParams, tmpTransferName);
  tmpBoolean:=aTransferBfs.ITTransferTerminate(tmpTransferName, aCallerAction, aConnectionName);
  if assigned(aPResult) then aPResult^:=ResultTransferTerminateToVariant(tmpBoolean);
  aSetResult:=True;
end;
//- - - ITReceiveTransferTerminated - - -
function ResultTransferTerminatedToVariant(const {aTransferName, }aTerminatorSysName:AnsiString):Variant;
begin
  result:={VarArrayOf([aTransferName, }aTerminatorSysName{])};
end;

procedure VariantToResultTransferTerminated(const aParams:Variant; out {aTransferName, }aTerminatorSysName:AnsiString);
begin
  //aTransferName:=aParams[0];
  aTerminatorSysName:=aParams{[1]};
end;

procedure BfTaskImp_RcTransferTerminated(aTransferBfs:ITransferBfs; aCallerAction:ICallerAction; const aParams:Variant);
  Var tmpTransferName, tmpTerminatorSysName:AnsiString;
begin
  If (Not Assigned(aTransferBfs))Or(Not Assigned(aCallerAction)) Then Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aTransferBfs/aCallerAction'], cnerInvalidValueOf);
  tmpTransferName:=aParams[0];
  VariantToResultTransferTerminated(aParams[1], {tmpTransferName, }tmpTerminatorSysName);
  aTransferBfs.ITReceiveTransferTerminated(aCallerAction, tmpTransferName, tmpTerminatorSysName);
end;

end.
