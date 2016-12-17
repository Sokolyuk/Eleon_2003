//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UMThreadTypes;

interface
type
  TMThreadState=({0}stsReady, {1}stsWait, {2}stsBusy);
  TDataCaseImplementEvent=(dieNewTask, dieWakeupTask);

  IMThread=interface
  ['{816F1E7E-36B4-4224-AACD-54B9432EB44C}']
    function GetIsPerpetualM:boolean;
    property IsPerpetualM:boolean read GetIsPerpetualM;
    function GetBeginTimeOfInactivity:TDateTime;
    property BeginTimeOfInactivity:TDateTime read GetBeginTimeOfInactivity;
    Function GetMNumber:Integer;
    property MNumber:Integer read GetMNumber;
    Function ITGetState:TMThreadState;
    Procedure ITSetState(Value:TMThreadState);
    Property ITState:TMThreadState read ITGetState write ITSetState;
    function GetRegistered:Boolean;
    Procedure SetRegistered(Value:Boolean);
    property Registered:Boolean read GetRegistered write SetRegistered;
    function GetGetThreadID:Cardinal;
    property GetThreadID:Cardinal read GetGetThreadID;
    function GetThreadBreak:Boolean;
    Procedure SetThreadBreak(value:Boolean);
    property ThreadBreak:boolean read GetThreadBreak write SetThreadBreak;
    function GetThreadTerminated:boolean;
    property ThreadTerminated:boolean read GetThreadTerminated;
  end;

implementation

end.
