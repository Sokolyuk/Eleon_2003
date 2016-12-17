unit UBitTypes;

interface
type
  T64bit=record
    Case Word of
      0:(ofInt64:Int64);{8 byte}
      1:(ofDouble:Double);{8 byte}
      2:(ofIntLow:Integer; ofIntHigh:Integer);{4+4 byte}
      3:(ofLongWordLow:LongWord; ofLongWordHigh:LongWord);{4+4 byte}
      4:(ofWordLowLow:Word;ofWordLowHigh:Word;ofWordHighLow:Word;ofWordHighHigh:Word);
      5:(ofByte0:Byte;ofByte1:Byte;ofByte2:Byte;ofByte3:Byte;ofByte4:Byte;ofByte5:Byte;ofByte6:Byte;ofByte7:Byte);
  end;
 T32bit=Record
   Case Integer of
     0:(ofInteger:Integer);    //Signed 32-bit (4-byte)
     1:(ofLongword:Longword);  //Unsigned 32-bit (4-byte)
   End;

implementation

end.
