//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBaseTriggerUtils;

interface
  Uses ULocalDataBaseTriggerTypes;

  Function ParamStrToTriggerType(Const aParamStr:AnsiString):TTriggerType;
  Function ParamsStrToSetTriggerType(Const aParamsStr:AnsiString):TSetTriggerType;

implementation
  Uses SysUtils, UStringUtils;

ResourceString
  errParamStrToTriggerTypeUnknownParamStr='ParamStrToTriggerType: Unknown ParamStr=''%s''';

Function ParamStrToTriggerType(Const aParamStr:AnsiString):TTriggerType;
begin
  If aParamStr='AFTER' Then Result:=cftAfter Else
  If aParamStr='BEFORE' Then Result:=cftBefore Else Raise Exception.CreateFmt(errParamStrToTriggerTypeUnknownParamStr, [aParamStr]);
end;

Function ParamsStrToSetTriggerType(Const aParamsStr:AnsiString):TSetTriggerType;
  Var tmpCurrentPos:Integer;
      tmpSt:AnsiString;
Begin
  Result:=[];
  tmpCurrentPos:=-1;
  While True do begin
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aParamsStr, ';');
    If tmpCurrentPos=-1 Then Break;
    Result:=Result+[ParamStrToTriggerType(tmpSt)];
  end;
end;


end.
