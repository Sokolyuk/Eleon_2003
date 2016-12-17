//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USQLParserUtils;

interface
  Uses USQLParserTypes;

  Function SQLCommandToStr(aType:TSQLCommandType):AnsiString;
  Function StrToSQLCommand(Const aParamStr:AnsiString):TSQLCommandType;
  Function ParamsStrToSQLCommands(Const aParamsStr:AnsiString):TSetSQLCommandType;
  Function SQLCommandsToParamsStr(Const aSetSQLCommandType:TSetSQLCommandType):AnsiString;

implementation
  Uses SysUtils, USQLParserConsts, UStringUtils, UStringConsts;

ResourceString
  errSQLCommandTypeToStrUnknownType='SQLCommandTypeToStr: Unknown aType=';
  errStrToSQLCommandTypeUnknownParamStr='StrToSQLCommandType: Unknown ParamStr=''%s''';

Function SQLCommandToStr(aType:TSQLCommandType):AnsiString;
Begin
  Case aType of
    sctSelect:Result:=csmSelect;
    sctInsert:Result:=csmInsert;
    sctDelete:Result:=csmDelete;
    sctUpdate:Result:=csmUpdate;
    sctBeginTran:Result:=csmBeginTran;
    sctCommitTran:Result:=csmCommitTran;
    sctRollbackTran:Result:=csmRollbackTran;
    sctExec:Result:=csmExec;
    sctCreate:Result:=csmCreate;
    sctAlter:Result:=csmAlter;
    sctDrop:Result:=csmDrop;
    sctTruncate:Result:=csmTruncate;
  Else
    Raise Exception.Create(errSQLCommandTypeToStrUnknownType+IntToStr(Integer(aType)));
  End;
end;

Function StrToSQLCommand(Const aParamStr:AnsiString):TSQLCommandType;
begin
  If aParamStr=csmSelect Then Result:=sctSelect Else
  If aParamStr=csmInsert Then Result:=sctInsert Else
  If aParamStr=csmDelete Then Result:=sctDelete Else
  If aParamStr=csmUpdate Then Result:=sctUpdate Else
  If aParamStr=csmBeginTran Then Result:=sctBeginTran Else
  If aParamStr=csmCommitTran Then Result:=sctCommitTran Else
  If aParamStr=csmRollbackTran Then Result:=sctRollbackTran Else
  If aParamStr=csmExec Then Result:=sctExec Else
  If aParamStr=csmCreate Then Result:=sctCreate Else
  If aParamStr=csmAlter Then Result:=sctAlter Else
  If aParamStr=csmDrop Then Result:=sctDrop Else
  If aParamStr=csmTruncate Then Result:=sctTruncate Else Raise Exception.CreateFmt(errStrToSQLCommandTypeUnknownParamStr, [aParamStr]);
end;

Function ParamsStrToSQLCommands(Const aParamsStr:AnsiString):TSetSQLCommandType;
  Var tmpCurrentPos:Integer;
      tmpSt:AnsiString;
Begin
  Result:=[];
  tmpCurrentPos:=-1;
  While True do begin
    tmpSt:=GetParamFromParamsStr(tmpCurrentPos, aParamsStr, ';');
    If tmpCurrentPos=-1 Then Break;
    Result:=Result+[StrToSQLCommand(tmpSt)];
  end;
end;

Function SQLCommandsToParamsStr(Const aSetSQLCommandType:TSetSQLCommandType):AnsiString;
begin
  Result:='';
  If sctSelect in aSetSQLCommandType Then Result:=csmSelect+csParamsStrSeparator;
  If sctInsert in aSetSQLCommandType Then Result:=Result+csmInsert+csParamsStrSeparator;
  If sctDelete in aSetSQLCommandType Then Result:=Result+csmDelete+csParamsStrSeparator;
  If sctUpdate in aSetSQLCommandType Then Result:=Result+csmUpdate+csParamsStrSeparator;
  If sctBeginTran in aSetSQLCommandType Then Result:=Result+csmBeginTran+csParamsStrSeparator;
  If sctCommitTran in aSetSQLCommandType Then Result:=Result+csmCommitTran+csParamsStrSeparator;
  If sctRollbackTran in aSetSQLCommandType Then Result:=Result+csmRollbackTran+csParamsStrSeparator;
  If sctExec in aSetSQLCommandType Then Result:=Result+csmExec+csParamsStrSeparator;
  If sctCreate in aSetSQLCommandType Then Result:=Result+csmCreate+csParamsStrSeparator;
  If sctAlter in aSetSQLCommandType Then Result:=Result+csmAlter+csParamsStrSeparator;
  If sctDrop in aSetSQLCommandType Then Result:=Result+csmDrop+csParamsStrSeparator;
  If sctTruncate in aSetSQLCommandType Then Result:=Result+csmTruncate+csParamsStrSeparator;
  //If Result<>'' Then SetLength(Result, Length(Result)-1);
end;

end.
