//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTypes;

interface
  Uses Messages;

Type
  TLoginLevel=({0}llNone{Unknown-Reserved}, {1}llPGS{Base-SQL-Server}, {2}llEMS{Shop-EMS-LDB}, {3}llClient{Client});
  // for RegAppMask
  T64bit = record
    Case Word of
      0:(ofInt64:Int64);   {8 byte}
      1:(ofDouble:Double); {8 byte}
      2:(ofComp:Comp);     {8 byte}
      3:(ofDateTime:TDateTime); {8 byte}
      4:(ofIntLow:Integer; ofIntHigh:Integer); {4+4 byte}
      5:(ofLongWordLow:LongWord; ofLongWordHigh:LongWord); {4+4 byte}
  end;
 T32bit{TIntToLongword}=Record
   Case Integer of
     0:(ofInteger:Integer);    //Signed 32-bit (4-byte)
     1:(ofLongword:Longword);  //Unsigned 32-bit (4-byte)
   End;


Type
  // Result code of procedure 'MateCertainFree'.
  //TCreateMode=({0}crmMate);
  TSTTaskStatus=({0}tssNoTask, {1}tssQueue, {2}tssExecute, {3}tssComplete, {4}tssError, {5}tssCanceled);

  //Function BooleanToStr(aBoolean:Boolean):AnsiString;

implementation

//Function BooleanToStr(aBoolean:Boolean):AnsiString;
//begin
//  If aBoolean Then Result:='True' else Result:='False';
//end;

end.




