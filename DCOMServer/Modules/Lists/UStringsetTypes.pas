unit UStringsetTypes;

interface
Type
  PStringCell=^TStringCell;
  TStringCell=Record
    Str:AnsiString;
    Cnt:Integer;
    Next:PStringCell;
  End;

  IStringset=Interface
  ['{BE257106-A80F-426E-BBEC-8A7A6317F972}']
    function IT_GetConfigureCheckUnique:boolean;
    procedure IT_SetConfigureCheckUnique(Value:boolean);
    function IT_GetConfigCaseSensitive:boolean;
    procedure IT_SetConfigCaseSensitive(Value:boolean);
    function IT_GetAsParamStr:AnsiString;
    //..
    Procedure ITPush(Const aStr:AnsiString);
    function ITPushR(Const aStr:AnsiString):Boolean;
    Function ITClear:Boolean;
    Function ITClearOfStr(Const aStr:AnsiString):Boolean;
    function ITExist(Const aStr:AnsiString):boolean;
    Property ITConfigureCheckUnique:boolean read IT_GetConfigureCheckUnique write IT_SetConfigureCheckUnique;
    Property ITConfigCaseSensitive:Boolean read IT_GetConfigCaseSensitive write IT_SetConfigCaseSensitive;
    Property ITAsParamStr:AnsiString read IT_GetAsParamStr;
  End;


implementation

end.
