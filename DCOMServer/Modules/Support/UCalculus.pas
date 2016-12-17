//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCalculus;

interface

const
   Convert:array[0..127] of Char='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅ¨ÆÇÈÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäå¸æçèêëìíîïğñòóôõö÷øùúûüışÿ'#0;
   cnEnBase=62;
   ConvertCode128B:array[0..96] of Char=' !"#$%&''()*+´-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'#0;

  function ByteToSymSBase(aByte:Byte; aBase:Byte):Char;
  function SymSBaseToByte(aSymS62:Char; aBase:Byte):Byte;
  function Int64ToSBase(aInt64:Int64; aBase:Byte):AnsiString; 
  function SBaseToInt64(Const aSBase:AnsiString; aBase:Byte):Int64;

implementation
  uses Sysutils, Math;

function ByteToSymSBase(aByte:Byte; aBase:Byte):Char;
begin
  if (aByte>aBase)or(aByte>126) Then Raise Exception.Create('aByte to large.');
  Result:=Convert[aByte];
end;

function SymSBaseToByte(aSymS62:Char; aBase:Byte):Byte;
  var tmpPos:Integer;
begin
  if aBase>126 then Raise Exception.Create('Invalid base '+IntToStr(aBase)+'.');
  tmpPos:=Pos(aSymS62, PChar(@Convert[0]));
  If (tmpPos=0)Or(tmpPos>aBase)Or(tmpPos>127) Then Raise Exception.Create(''''+aSymS62+''' not found.');
  Result:=tmpPos-1;
end;

Function Int64ToSBase(aInt64:Int64; aBase:Byte):AnsiString;
  var tmpDouble:Double;
      tmpLength, tmpI, tmpN:Byte;
      tmpInt64:Int64;
begin
  if aInt64=0 then result:=ByteToSymSBase(0, aBase) else begin
    tmpDouble:=LogN(aBase, aInt64);
    tmpLength:=Round(Int(tmpDouble));
    If Frac(tmpDouble)>0 Then inc(tmpLength);
    Result:='';
    for tmpI:=tmpLength downto 0 do begin
      tmpInt64:=Round(Power(aBase, tmpI));
      tmpN:=aInt64 div tmpInt64;
      Result:=Result+ByteToSymSBase(tmpN, aBase);
      if Result='0' Then Result:='';
      aInt64:=aInt64-(tmpN*tmpInt64);
    end;
  end;
end;

function SBaseToInt64(Const aSBase:AnsiString; aBase:Byte):Int64;
  var tmpI, tmpLength:Integer;
begin
  tmpLength:=length(aSBase);
  if tmpLength=0 then Raise Exception.Create('aSBase=''''');
  result:=0;
  for tmpI:=1 to tmpLength do begin
    Result:=Round(Result+SymSBaseToByte(aSBase[tmpLength-tmpI+1], aBase)*Power(aBase, tmpI-1));
  end;
end;


end.
