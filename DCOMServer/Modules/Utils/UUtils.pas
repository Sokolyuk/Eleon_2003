unit UUtils;

interface
  function DateTimeToTransferSpeed(aStartTime, aEndTime:TDateTime; aBytesTransferred:Cardinal):Double;
  function TransferSpeedToString(aSpeed:Double):AnsiString;
  
implementation
  Uses UDateTimeUtils, SysUtils;

function DateTimeToTransferSpeed(aStartTime, aEndTime:TDateTime; aBytesTransferred:Cardinal):Double;
  var tmpHour, tmpMin, tmpSec, tmpMSec:Word;
      tmpDouble:Double;
begin
  DecodeTime(MSecsToDateTime(MSecsBetweenDateTime(aStartTime, aEndTime)+DateDeltaMSecs), tmpHour, tmpMin, tmpSec, tmpMSec);
  tmpDouble:=tmpMSec/1000;
  tmpDouble:=tmpDouble+tmpSec;
  tmpDouble:=tmpDouble+tmpMin*60;
  tmpDouble:=tmpDouble+tmpHour*3600;
  If tmpDouble>0 Then begin
    Result:=(aBytesTransferred/tmpDouble)*8;
  end else begin
    Result:=-1;
  end;
end;

function TransferSpeedToString(aSpeed:Double):AnsiString;
begin
  If aSpeed>1000000 Then begin
    //MBit
    Result:=Format('%1.2f', [aSpeed/1000000])+' MBit';
  end else If aSpeed>1000 Then begin
    //KBit
    Result:=Format('%1.2f', [aSpeed/1000])+' KBit';
  end else If aSpeed<0 Then begin
    //Infinity
    Result:='Infinity';
  end else begin
    //KBit
    Result:=Format('%1.2f', [aSpeed])+' Bit';
  end;  
end;

end.
