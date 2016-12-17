//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UNodeNameStrUtils;

interface
  uses UNodeNameTypes{$IFDEF VER130}, UVer130Types{$ENDIF}, UNodeTypes;

  function NodeToken(aNext:Boolean; Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
  function NextNodeToken(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
  function PrevNodeToken(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
  procedure Node(aNext:Boolean; Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
  procedure NextNode(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
  procedure PrevNode(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
  //..
  function NodeNameToNodeWhere(Const aNodeName:AnsiString):TNodeType;
  //PNodeWhere

implementation
  uses UNodeNameConsts, Sysutils, UErrorConsts;

function NodeToken(aNext:Boolean; Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
  procedure localSetResult(alPos:Integer); begin
    If (alPos>1)And(aNodeStr[alPos-1]=csValueDelimiter) Then begin//Это Value
      Result:=nntValue;
    end else begin//во всех др. случаях это Name
      Result:=nntName;
    end;
  end;
  Var tmpPos:Integer;
      tmpLength:Integer;
begin
  result:=nntNone;
  If (Assigned(aLength))And(aLength^>=0) Then tmpLength:=aLength^ else begin
    tmpLength:=Length(aNodeStr);
    If Assigned(aLength) Then aLength^:=tmpLength;
  end;
  If aNext Then begin
    If aCurPos<1 Then aCurPos:=1 else Inc(aCurPos){Перескакиваю разделитель};
    If (tmpLength=0)Or(aCurPos>tmpLength) Then begin
      aCurPos:=-1;
      aNodeToken:='';
      Exit;
    end;
    For tmpPos:=aCurPos To tmpLength do begin
      if aNodeStr[tmpPos] in cnNodeDelimiter then Break;
    end;
    If tmpPos>tmpLength Then begin
      localSetResult(aCurPos);
      aNodeToken:=Copy(aNodeStr, aCurPos, tmpLength-aCurPos+1);
    end else begin
      localSetResult(aCurPos);
      aNodeToken:=Copy(aNodeStr, aCurPos, tmpPos-aCurPos);
    end;
  end else begin//Prev
    If aCurPos<0 Then aCurPos:=tmpLength else Dec(aCurPos){Перескакиваю разделитель};
    If (tmpLength=0)Or(aCurPos>tmpLength)Or(aCurPos=0) Then begin
      aCurPos:=-1;
      aNodeToken:='';
      Exit;
    end;
    For tmpPos:=aCurPos Downto 1 do begin
      if aNodeStr[tmpPos] in cnNodeDelimiter then Break;
    end;
    If tmpPos<1 Then begin
      localSetResult(tmpPos);
      aNodeToken:=Copy(aNodeStr, 1, aCurPos);//aCurPos, tmpLength-aCurPos+1);
    end else begin
      //Inc(tmpPos);
      localSetResult(tmpPos+1);
      aNodeToken:=Copy(aNodeStr, tmpPos+1, aCurPos-tmpPos);
    end;
  end;
  aCurPos:=tmpPos;
end;

function NextNodeToken(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
begin
  Result:=NodeToken(True{aNext}, aCurPos, aNodeStr, aLength, aNodeToken);
end;

function PrevNodeToken(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeToken:AnsiString):TNodeToken;
begin
  Result:=NodeToken(False{aNext}, aCurPos, aNodeStr, aLength, aNodeToken);
end;

Procedure Node(aNext:Boolean; Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
  Var tmpStr:AnsiString;
      tmpCurPos:Integer;
begin
  aNodeName:='';
  aNodeValue:='';
  tmpCurPos:=aCurPos;
  If aNext Then begin
    Case NextNodeToken(tmpCurPos, aNodeStr, aLength, tmpStr) of
      nntName:aNodeName:=tmpStr;
      nntNone:;
    else
      Raise Exception.CreateFmtHelp(cserInternalError, ['NodeToken '''+tmpStr+''' is unexpected'], cnerInternalError);
    end;
    //пробую найти Value
    aCurPos:=tmpCurPos;
    if (tmpCurPos<>-1{Строка не кончилась})And(NextNodeToken(tmpCurPos, aNodeStr, aLength, tmpStr)=nntValue) then begin
      aNodeValue:=tmpStr;{Нашел значение}
      aCurPos:=tmpCurPos;
    end;
  end else begin
    Case PrevNodeToken(tmpCurPos, aNodeStr, aLength, tmpStr) of
      nntName:aNodeName:=tmpStr;
      nntValue:begin
        aNodeValue:=tmpStr;
        If PrevNodeToken(tmpCurPos, aNodeStr, aLength, tmpStr)<>nntName Then Raise Exception.CreateFmtHelp(cserInternalError, ['NodeToken '''+tmpStr+''' is unexpected'], cnerInternalError);
        aNodeName:=tmpStr;
      end;
      nntNone:;
    else
      Raise Exception.CreateFmtHelp(cserInternalError, ['NodeToken '''+tmpStr+''' is unexpected'], cnerInternalError);
    end;
    aCurPos:=tmpCurPos;
  end;
end;


Procedure NextNode(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
begin
  Node(True{aNext}, aCurPos, aNodeStr, aLength, aNodeName, aNodeValue);
end;

Procedure PrevNode(Var aCurPos:Integer; Const aNodeStr:AnsiString; aLength:PInteger; out aNodeName:AnsiString; out aNodeValue:AnsiString);
begin
  Node(False{aNext}, aCurPos, aNodeStr, aLength, aNodeName, aNodeValue);
end;

function NodeNameToNodeWhere(Const aNodeName:AnsiString):TNodeType;
begin
  If AnsiUpperCase(aNodeName)=csNodePGS then result:=nodPGS else
  If AnsiUpperCase(aNodeName)=csNodeEMS then result:=nodEMS else
  If AnsiUpperCase(aNodeName)=csNodeESC then result:=nodESC else Raise Exception.CreateFmtHelp(cserInvalidValueOf, ['aNodeName'], cnerInvalidValueOf);
end;


end.
