//*********************************************
//* SDA                              18/10/00 *
//* Eleon                            К+С      *
//* Промежуточный сервер             M-Server *
//*                                  v 1.7    *
//*                                  27/11/00 *
//* Объек обработки строки параметров         *
//*********************************************

unit UStringParam;

interface

Type
    TCMDMode=(cmNone, cmAdd, cmDel);
(*    TSetCompareStringParam=Set of (cspEqual, cspDifferent, cspInt, cspExt);
    TCompareStringParamLevel=(splLogic, splStrict, splAbsolut);
    // для метода
    // сравниваются имеющаяся строка и параметр.
    //   если флаг [cspEqual] или [cspDifferent] один то:
    // [cspEqual] - все совподаетет
    // [cspDifferent] - все разное
    //   Используются только вместе с cspDifferent.
    // [cspInt] - флаг cspDifferent относится к внутреннему значению, т.е. которое установлено через Property StringParam.
    // [csplExt] - флаг cspDifferent относится к внешнему значению aStringParam, которое пришло параметром в CompareStringParam.
    // Возможны варианты:
    // [cspEqual] - все совподаетет
    // [cspDifferent] - все разное
    // [cspDifferent] + [cspInt] - во внутренних есть то чего нет во всешних.
    // [cspDifferent] + [cspExt] - во внешних есть то чего нет во внутренних.
    // [cspDifferent] + [cspInt] + [cspExt] - есть общие параметры и совсем разные.
*)

    TStringParam = Class
    Private
      stFStringParam : AnsiString;
      stFTabCMD, stFAddCMD, stFDelCMD : AnsiString;
      FParamMode : TCMDMode;
      Procedure Set_StringParam(Value:Ansistring);
      Function Get_CountParam : Integer;
    Public
      Constructor Create;
      Destructor Destroy; Override;
      Function GetParam( iNum:Integer ):AnsiString;
(*      // Функция сравнивает "парамеры" двух строк при этом неважен их порядок и повторяемость.
      Function CompareStringParam(aStringParam:AnsiString; aGetParamMode:TCMDMode; aCompareStringParamLevel:TCompareStringParamLevel):TSetCompareStringParam;*)
      Function CheckIncludesStr(aStr:AnsiString):Boolean;
      Property StringParam : AnsiString Read stFStringParam Write Set_StringParam;
      Property CountParam : Integer Read Get_CountParam;
      Property stTabCMD : AnsiString Read stFTabCMD Write stFTabCMD;
      Property stAddCMD : AnsiString Read stFAddCMD Write stFAddCMD;
      Property stDelCMD : AnsiString Read stFDelCMD Write stFDelCMD;
      Property GetParamMode : TCMDMode Read FParamMode Write FParamMode;
    End;

implementation
  uses SysUtils;

Constructor TStringParam.Create;
Begin
 Inherited Create;
 stTabCMD:=',';
 stAddCMD:='+';
 stDelCMD:='-';
 stFStringParam:='';
 FParamMode:=cmNone;
End;

Destructor TStringParam.Destroy;
Begin
 Inherited Destroy;
End;

Function TStringParam.Get_CountParam : Integer;
  var i : Integer ;
begin
  Result:=0;
  if stFStringParam='' Then Exit;
  If (FParamMode=cmNone) Or ((FParamMode=cmAdd) And (stFStringParam[1]=stAddCMD)) Or ((FParamMode=cmDel) And (stFStringParam[1]=stDelCMD)) Then Result:=1;
  For I:=1 To Length(stFStringParam) do
    if stFStringParam[i]=stTabCMD Then
      If (FParamMode=cmNone) Or ( (i<Length(stFStringParam)) {And ((FParamMode=cmAdd) And (stFStringParam[i+1]=stAddCMD)) Or ((FParamMode=cmDel) And (stFStringParam[i+1]=stDelCMD))}) Then
        If (FParamMode=cmNone) Or ((FParamMode=cmAdd) And (stFStringParam[i+1]=stAddCMD)) Or ((FParamMode=cmDel) And (stFStringParam[i+1]=stDelCMD)) Then
          Inc(Result);
end;

Function TStringParam.GetParam( iNum:Integer ):AnsiString;
  var iCur, iCnt : Integer ;
      stRes : AnsiString;
      vlWriting : Boolean ;
begin
  Result:='';
  if stFStringParam='' Then Exit;
  if iNum=0 Then begin
    Result:=stFStringParam;
    Exit;
  end;
  stRes:='';
  If (FParamMode=cmNone) Or ((FParamMode=cmAdd) And (stFStringParam[1]=stAddCMD)) Or ((FParamMode=cmDel) And (stFStringParam[1]=stDelCMD)) Then begin
    If iNum=1 Then begin
      vlWriting := True;
      iCur:=0; {смотрел варнинги ???}
    end else begin
      iCur:=1;
      vlWriting := False;
    end;
  end Else begin
    iCur:=0;
    vlWriting := False; // Для завершения поиска в слове
  end;
  // ..
  For iCnt:=1 To Length(stFStringParam) do
    begin
      if (stFStringParam[iCnt]=stTabCMD) Then begin
        If vlWriting Then Break;
        If (FParamMode=cmNone) Or ( (iCnt<(Length(stFStringParam)-1)) And ((FParamMode=cmAdd) And (stFStringParam[iCnt+1]=stAddCMD)) Or ((FParamMode=cmDel) And (stFStringParam[iCnt+1]=stDelCMD))) Then begin
          Inc(iCur);
          if iCur=iNum Then vlWriting:=True;
        end;
        Continue;
      end;
      If vlWriting {iCur=(iNum-1)} Then Begin
        stRes:=stRes + stFStringParam[iCnt];
      End;
    end;
  // Result
  If FParamMode=cmNone Then
    Result:=stRes
  Else
    Result:=Copy(stRes, 2, Length(stRes));
end;

Procedure TStringParam.Set_StringParam(Value:Ansistring);
Begin
  stFStringParam:=Value;
  FParamMode:=cmNone;
end;

(*Function TStringParam.CompareStringParam(aStringParam:AnsiString; aGetParamMode:TCMDMode; aCompareStringParamLevel:TCompareStringParamLevel):TSetCompareStringParam;
  Var tmpStringParam:TStringParam;
      iI, iJ, iCountParamInt, iCountParamExt:Integer;
      tmpStInt, tmpStExt:AnsiString;
      iFound:Boolean;
      tmpV:Variant;
begin
  // Функция сравнивает "парамеры" двух строк при этом неважен их порядок и повторяемость.
  //cspEqual, cspDifferent, cspInt, cspExt
  tmpStringParam:=TStringParam.create;
  try
    tmpStringParam.GetParamMode:=aGetParamMode;
    tmpStringParam.stTabCMD:=stFTabCMD;
    tmpStringParam.stAddCMD:=stFAddCMD;
    tmpStringParam.stDelCMD:=stFDelCMD;
    tmpStringParam.StringParam:=UpperCase(aStringParam);
    iCountParamInt:=Get_CountParam;
    iCountParamExt:=tmpStringParam.CountParam;
    If iCountParamInt=iCountParamExt then begin
      If iCountParamInt=0 Then begin
        // обе пусты.
        Result:=[cspEqual];
        exit;
      end;
      // проверка > ..
    end else begin
      // проверка > ..
    end;
    Result:=[];
    // создаю массив для Ext. В нем хранятся сходства.
    tmpV:=VarArrayCreate([1, iCountParamExt], varBoolean);
    For iJ:=1 to iCountParamExt do
      tmpV[iJ]:=False; // обняляю массив
    try
      For iI:=1 to iCountParamInt do begin
        iFound:=False;
        Case aCompareStringParamLevel of
          splLogic:begin
            // Важно есть или нет парамера, а кольчество раз сколько он есть не имеет значения. Порядок не важен.
            For iJ:=1 to iCountParamExt do begin
              If UpperCase(GetParam(iI))=tmpStringParam.GetParam(iJ) Then begin
                iFound:=True;
                tmpV[iJ]:=True;
                break;
              end;
            end;
            If iFound then begin
              // нашел
              // > ..
            end else begin
              // не нашел
              Result:=Result-[cspEqual]+[cspDifferent]+[cspExt];
            end;
          end;
          splStrict:begin
            // Важно наличие парамера и кольчество раз сколько он есть. Порядок не важен.
            Raise Exception.Create('Нереализовано.');
          end;
          splAbsolut:begin
            // Важно наличие парамера и кольчество раз сколько он есть. Порядок важен.
            Raise Exception.Create('Нереализовано.');
          end;
        end;
      end;
    finally
      VarClear(tmpV);
    end;
    For iJ:=1 to iCountParamExt do begin
      Case aCompareStringParamLevel of
        splLogic:begin
          // Важно есть или нет парамера, а кольчество раз сколько он есть не имеет значения. Порядок не важен.
          If Not boolean(tmpV[iJ]) then begin
            // не нашел, в Ext есть то чего нет в Int.
            Result:=Result-[cspEqual]+[cspDifferent]+[cspInt];
          end;
        end;
        splStrict:begin
          // Важно наличие парамера и кольчество раз сколько он есть. Порядок не важен.
          Raise Exception.Create('Нереализовано.');
        end;
        splAbsolut:begin
          // Важно наличие парамера и кольчество раз сколько он есть. Порядок важен.
          Raise Exception.Create('Нереализовано.');
        end;
      end;
    end;
    If Result=[] then Result:=[cspEqual];
  finally
    tmpStringParam.free;
    tmpStInt:='';
    tmpStExt:='';
  end;
end;*)

Function TStringParam.CheckIncludesStr(aStr:AnsiString):Boolean;
  Var iI, iCountParam:Integer;
begin
  iCountParam:=Get_CountParam;
  Result:=False;
  aStr:=UpperCase(aStr);
  For iI:=1 to iCountParam do begin
    If UpperCase(GetParam(iI))=aStr Then begin
      Result:=True;
      Break; 
    end;
  end;
end;

end.

