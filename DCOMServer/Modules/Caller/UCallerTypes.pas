//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UCallerTypes;

interface
  Uses UADMTypes, UAppMessageTypes;
Type
  ICallerSecurityContext=interface
  ['{1F73AD78-E674-479B-BD3C-44BDBCD0515C}']
    function ITGetUserName:AnsiString;
    function ITGetSecurityContext:Variant;
    procedure ITSetSecurityContext(Const Value:Variant);
    function ITGetAsString:AnsiString;
    procedure ITSetAsString(Const Value:AnsiString);
    property UserName:AnsiString read ITGetUserName;
    property SecurityContext:Variant read ITGetSecurityContext write ITSetSecurityContext;
    property AsString:AnsiString read ITGetAsString write ITSetAsString;
    function Clone:ICallerSecurityContext;
  End;

  ICallerSenderParams=interface
  ['{AE9E326C-0010-415D-A190-156CF1BCF042}']
    function ITGetSenderParams:Variant;
    procedure ITSetSenderParams(Const Value:Variant);
    function ITGetSenderASMNum:Integer;
    procedure ITSetSenderASMNum(Value:Integer);
    function ITGetSenderADMTaskNum:TADMTask;
    procedure ITSetSenderADMTaskNum(Value:TADMTask);
    function ITGetSenderPackCPID:Variant;
    procedure ITSetSenderPackCPID(Const Value:Variant);
    function ITGetSenderPackPD:Variant;
    procedure ITSetSenderPackPD(Const Value:Variant);
    function ITGetSenderRouteParam:Variant;
    procedure ITSetSenderRouteParam(Const Value:Variant);
    property SenderParams:Variant read ITGetSenderParams write ITSetSenderParams;
    property SenderASMNum:Integer read ITGetSenderASMNum write ITSetSenderASMNum;
    property SenderADMTaskNum:TADMTask read ITGetSenderADMTaskNum write ITSetSenderADMTaskNum;
    property SenderPackCPID:Variant read ITGetSenderPackCPID write ITSetSenderPackCPID;
    property SenderPackPD:Variant read ITGetSenderPackPD write ITSetSenderPackPD;
    property SenderRouteParam:Variant read ITGetSenderRouteParam write ITSetSenderRouteParam;
    function Clone:ICallerSenderParams;
  End;

  ICallerAction=Interface
  ['{FC3A7E16-9468-487B-95A9-FB8A9C6D3198}']
    function ITGetActionName:AnsiString;
    procedure ITSetActionName(Const Value:AnsiString);
    function ITGetICallerSecurityContext:ICallerSecurityContext;
    procedure ITSetICallerSecurityContext(Value:ICallerSecurityContext);
    function ITGetICallerSenderParams:ICallerSenderParams;
    procedure ITSetICallerSenderParams(Value:ICallerSenderParams);
    function ITGetSenderParams:Variant;
    procedure ITSetSenderParams(Const Value:Variant);
    function ITGetUserName:AnsiString;
    function ITGetSecurityContext:Variant;
    procedure ITSetSecurityContext(Const Value:Variant);
    procedure ITMessAdd(aStartTime, aEndTime:TDateTime; const aSource, aMess:AnsiString; aMessageClass:TMessageClass; aMessageStyle:TMessageStyle);
    procedure CreateNewActionName(aPrefix:AnsiString);
    function Clone:ICallerAction;
    property UserName:AnsiString read ITGetUserName;
    property SecurityContext:Variant read ITGetSecurityContext write ITSetSecurityContext;
    property SenderParams:Variant read ITGetSenderParams write ITSetSenderParams;
    property ActionName:AnsiString read ITGetActionName Write ITSetActionName;
    property CallerSenderParams:ICallerSenderParams read ITGetICallerSenderParams write ITSetICallerSenderParams;
    property CallerSecurityContext:ICallerSecurityContext read ITGetICallerSecurityContext write ITSetICallerSecurityContext;
  end;

implementation

end.
