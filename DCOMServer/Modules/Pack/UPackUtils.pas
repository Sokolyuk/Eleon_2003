//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackUtils;

interface
  Uses UPackTypes;

  function VariantToPack(Const aVariant:Variant):IPack;
  function PackToVariant(aIPack:IPack):Variant;
  function PackIDToGUID(aPackID:TPackID; aVer:Integer):TGUID;
  function PackIDToString(aPackID:TPackID):AnsiString;
  {function GUIDToPackID(Const aGUID:TGUID; Out aVer:Integer):TPackID;
  function IsEqualPackGUID(Const aGUID:TGUID; aPackID:TPackID; aVer:Integer):Boolean;}

implementation
  uses UPack, UErrorConsts, SysUtils, UPackConsts, UPackPD, UPackCPT, UPackCPR, UPackMessage{$IFNDEF VER130}, Variants{$ENDIF};

function VariantToPack(Const aVariant:Variant):IPack;
  var tmpPackID:TPackID;
begin
  try
    if Not VarIsArray(aVariant) Then Raise Exception.CreateFmt(cserInternalError, ['aVariant is not array.']);
    tmpPackID:=TPackID(Integer(aVariant[Protocols_ID]));
    Case tmpPackID of
      pciPD:begin
        Result:=TPackPD.Create;
      end;
      pciCPT:begin
        Result:=TPackCPT.Create;
      end;
      pciCPR:begin
        Result:=TPackCPR.Create;
      end;
      pciMessage:begin
        Result:=TPackMessage.Create;
      end;
    else
      Raise Exception.CreateFmt(cserInternalError, ['Unknown PackID='+IntToStr(Integer(tmpPackID))+'.']);
    end;
    if Not Assigned(Result) Then Raise Exception.CreateFmt(cserInternalError, ['Result is not assigned.']);
    try
      Result.AsVariant:=aVariant;
    except
      Result:=Nil;
      raise;
    end;
  except
    On e:exception do Raise Exception.Create('VariantToPack: '+e.message);
  end;
end;

function PackToVariant(aIPack:IPack):Variant;
begin
  Result:=aIPack.AsVariant;
end;

function PackIDToGUID(aPackID:TPackID; aVer:Integer):TGUID;
begin
end;

{function GUIDToPackID(Const aGUID:TGUID; Out aVer:Integer):TPackID;
begin
end;

function IsEqualPackGUID(Const aGUID:TGUID; aPackID:TPackID; aVer:Integer):Boolean;
begin
end;}

function PackIDToString(aPackID:TPackID):AnsiString;
begin
  case aPackID of
    pciNone:result:=csNone;
    pciCPT:result:=csCPT;
    pciCPR:result:=csCPR;
    pciPD:result:=csPD;
    pciMessage:result:=csMessage;
  else
    result:='Unknown_'+IntToStr(Integer(aPackID));
  end;
end;

end.
