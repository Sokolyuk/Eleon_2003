//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UDateTimeUtils;

interface

function DateTimeToMSecs(const aValue:TDateTime):Int64;
function MSecsToDateTime(const aValue:Int64; aPascalTimeCorrection:Boolean=True):TDateTime;
function MSecsBetweenDateTime(const aValue1, aValue2:TDateTime):Int64;
Function MSecsToDurationStr(aValue:Int64; aShortString:Boolean=True):AnsiString;
Function TwoMSecsToDurationStr(Const aValue1, aValue2:Int64; aShortString:Boolean=True):AnsiString;
Function TwoDateTimeToDurationStr(Const aValue1, aValue2:TDateTime; aShortString:Boolean=True):AnsiString;

Const
  DateDelta=693594;
  DateDeltaMSecs=59926521600000;{1899-12-30 00:00:00.000}
  MSecsPerDay=86400000;
  MSecsPerHour=3600000;
  MSecsPerMin=60000;
  MSecsPerSec=1000;

implementation
  uses SysUtils;

//отщет фактически идет от 00:00:00.000 31-12-00, а не от 00:00:00.000 01-01-01(или 00-00-00)
function DateTimeToMSecs(const aValue:TDateTime):Int64;
begin
  Result:=Round((aValue*MSecsPerDay))+DateDeltaMSecs;
end;

function MSecsToDateTime(const aValue:Int64; aPascalTimeCorrection:Boolean=True):TDateTime;
  Var tmpDateTime:TDateTime;
begin
  If aPascalTimeCorrection Then begin
    //Из-за кривизны Паскалевского расчета времени 0(Р.Х.).
    tmpDateTime:=aValue/MSecsPerDay;
    If tmpDateTime<1 Then begin
      Result:=-tmpDateTime-DateDelta;
    end else begin
      Result:=tmpDateTime-DateDelta;
    end;
  end else begin
    Result:=(aValue/MSecsPerDay)-DateDelta;
  end;
end;

function MSecsBetweenDateTime(const aValue1, aValue2:TDateTime):Int64;
begin
  If AValue2>AValue1 Then Result:=DateTimeToMSecs(aValue2-aValue1-DateDelta) else Result:=DateTimeToMSecs(aValue1-aValue2-DateDelta);
end;

Function MSecsToDurationStr(aValue:Int64; aShortString:Boolean=True):AnsiString;
  Var Days:Int64;
      Hours, Mins, Secs, MSecs:Word;
begin
  Days:=aValue Div MSecsPerDay;
  aValue:=aValue Mod MSecsPerDay;
  Hours:=aValue Div MSecsPerHour;
  aValue:=aValue Mod MSecsPerHour;
  Mins:=aValue Div MSecsPerMin;
  aValue:=aValue Mod MSecsPerMin;
  Secs:=aValue Div MSecsPerSec;
  MSecs:=aValue Mod MSecsPerSec;
  If Days>0 Then Result:=IntToStr(Days)+'дн ' else Result:='';
  If aShortString Then begin
    If Hours>0 Then begin
      Result:=Result+IntToStr(Hours)+'ч'+IntToStr(Mins)+'м'+IntToStr(Secs)+'с'+IntToStr(MSecs)+'мс';
    end else begin
      If Mins>0 Then begin
        Result:=Result+IntToStr(Mins)+'м'+IntToStr(Secs)+'с'+IntToStr(MSecs)+'мс';
      end else begin
        If Secs>0 Then begin
          Result:=Result+IntToStr(Secs)+'с'+IntToStr(MSecs)+'мс';
        end else begin
          Result:=Result+IntToStr(MSecs)+'мс';
        end;
      end;
    end;
  end else begin
    Result:=Result+IntToStr(Hours)+'час '+IntToStr(Mins)+'мин '+IntToStr(Secs)+'сек '+IntToStr(MSecs)+'мсек';
  end;
end;

Function TwoMSecsToDurationStr(Const aValue1, aValue2:Int64; aShortString:Boolean=True):AnsiString;
begin
  If aValue2>aValue1 then Result:=MSecsToDurationStr(aValue2-aValue1) Else Result:=MSecsToDurationStr(aValue1-aValue2, aShortString);
end;

Function TwoDateTimeToDurationStr(Const aValue1, aValue2:TDateTime; aShortString:Boolean=True):AnsiString;
begin
  Result:=MSecsToDurationStr(MSecsBetweenDateTime(aValue1, aValue2), aShortString);
end;

end.
