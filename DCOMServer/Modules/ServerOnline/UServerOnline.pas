//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerOnline;

interface
  uses UITObject, UServerOnlineTypes, UCallerTypes;
type
  TServerOnline=class(TITObject, IServerOnline)
  private
    FOnLineStatus:Boolean;
    FOnLineMode:TOnLineMode;{0-Auto check; 1-Manual set}
  protected
    Function ITGetOnLineStatus:Boolean;virtual;
    Function ITGetOnLineMode:TOnLineMode;virtual;
    Procedure ITSetOnLineMode(Value:TOnLineMode);virtual;
  public
    constructor create;
    destructor destroy;override;
    procedure ITSetOnLineStatus(Value:Boolean; aCallerAction:ICallerAction);virtual;
    Property ITOnLineStatus:Boolean read ITGetOnLineStatus;
    Property ITOnLineMode:TOnLineMode read ITGetOnLineMode write ITSetOnLineMode;
  end;

implementation
  uses UThreadsPoolTypes, UTrayConsts, UTTaskTypes, variants;

constructor TServerOnline.create;
begin
  inherited create;
  FOnLineStatus:=True{false};
  FOnLineMode:=olmAuto;{0-Auto check; 1-Manual set}
end;

destructor TServerOnline.destroy;
begin
  inherited destroy;
end;

Function TServerOnline.ITGetOnLineStatus:Boolean;
begin
  InternalLock;
  try
    Result:=FOnLineStatus;
  finally
    InternalUnlock;
  end;
end;

Function TServerOnline.ITGetOnLineMode:TOnLineMode;
begin
  InternalLock;
  try
    Result:=FOnLineMode;
  finally
    InternalUnlock;
  end;
end;

Procedure TServerOnline.ITSetOnLineMode(Value:TOnLineMode);
begin
  InternalLock;
  try
    FOnLineMode:=Value;
  finally
    InternalUnlock;
  end;
end;

procedure TServerOnline.ITSetOnLineStatus(Value:Boolean; aCallerAction:ICallerAction);
begin
  InternalLock;
  try
    If FOnLineStatus<>Value Then begin//Меняется состояние
      FOnLineStatus:=Value;
      If FOnLineStatus Then begin//Установилось Online
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTOnLineSet, Unassigned, aCallerAction);
      end else begin//Установилось Offline
        IThreadsPool(cnTray.Query(IThreadsPool)).ITMTaskAdd(tskMTOffLineSet, Unassigned, aCallerAction);
      end;
    end;
  finally
    InternalUnlock;
  end;
end;

end.
