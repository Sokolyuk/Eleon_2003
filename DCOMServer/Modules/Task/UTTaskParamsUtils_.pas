unit UTTaskParamsUtils;
см. UTransferBfTaskImpUtils
interface
  uses UBfTypes;

  function BfAddTransferDownloadToParams(aIDBase:Integer; Const aTransferName:AnsiString; aTransferAuto, aTransferProcessToSender:Boolean; aTransferFrom:TTransferFrom; aFileDate:TDateTime):Variant;
  procedure ParamsToBfAddTransferDownload(Const aParams:Variant; Out aIDBase:Integer; Out aTransferName:AnsiString; Out aTransferAuto, aTransferProcessToSender:Boolean; Out aTransferFrom:TTransferFrom; Out aFileDate:TDateTime);

implementation
  Uses Variants, Sysutils;

function BfAddTransferDownloadToParams(aIDBase:Integer; Const aTransferName:AnsiString; aTransferAuto, aTransferProcessToSender:Boolean; aTransferFrom:TTransferFrom; aFileDate:TDateTime):Variant;
begin
  //[0]-varInteger(ID);
  //[1]-varOleStr:(aTransferName);
  //[2]-varBoolean:(TransferAuto);
  //[3]-varBoolean:(TransferProcessToSender);
  //[4]-varInteger:(TransferFrom);
  //[5]-varDate:(FileDate{для докачки})
  Result:=VarArrayOf([aIDBase, aTransferName, aTransferAuto, aTransferProcessToSender, aTransferFrom, aFileDate]);
end;

procedure ParamsToBfAddTransferDownload(Const aParams:Variant; Out aIDBase:Integer; Out aTransferName:AnsiString; Out aTransferAuto, aTransferProcessToSender:Boolean; Out aTransferFrom:TTransferFrom; Out aFileDate:TDateTime);
begin
  if not VarIsArray(aParams) Then begin
    If VarType(aParams)<>varInteger then Raise Exception.Create('Incorrect params type.');
    aIDBase:=aParams;//IdBase
    aTransferName:='';//DownloadBfName
    aTransferAuto:=False;//TransferAuto
    aTransferProcessToSender:=True;//TransferProcessToSender
    aTransferFrom:=trfFarServer;//TransferFrom
    aFileDate:=0;//FileDate
  end else begin
    If VarArrayHighBound(aParams, 1)<>5 Then Raise Exception.Create('Incorrect params count.');
    aIDBase:=aParams[0];//IdBase
    aTransferName:=aParams[1];//DownloadBfName
    aTransferAuto:=aParams[2];//TransferAuto
    aTransferProcessToSender:=aParams[3];//TransferProcessToSender
    aTransferFrom:=TTransferFrom(Integer(aParams[4]));//TransferFrom
    aFileDate:=aParams[5];//FileDate
  end;
end;

end.
 