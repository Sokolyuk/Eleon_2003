unit UServerLockTypes;

interface
type
  IServerLock=interface
  ['{0F1457B4-AE4A-45C7-B6C2-A859368C563C}']
    Function Get_ITServerLockMessage:AnsiString;
    Function Get_ITServerLockUser:AnsiString;
    Function Get_blServerLock:boolean;
    Property ITServerLockMessage:AnsiString read Get_ITServerLockMessage;
    Property ITServerLockUser:AnsiString read Get_ITServerLockUser;
    Property ITblServerLock:boolean read Get_blServerLock;
    Procedure ITServerLock(Const aUser, aMessage:AnsiString);
    Procedure ITServerUnLock;
  end;


implementation

end.
