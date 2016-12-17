unit USendSQLServerEvent;
не нужен
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  ComObj, ActiveX, Pegas_TLB, StdVcl;

type
  TSendSQLServerEvent=class(TAutoObject, ISendSQLServerEvent)
  public
    procedure Initialize; override;
    Destructor Destroy; Override;
  protected
    procedure Exec; safecall;
    {Protected declarations}
  end;

implementation
  uses ComServ, UASMListTypes, UASMList, SysUtils;
Var glTASMList:IASMList=Nil;

procedure TSendSQLServerEvent.Initialize;
begin
  inherited Initialize;
  glTASMList.ITASMAdd(Self);
end;

Destructor TSendSQLServerEvent.Destroy;
begin
  try glTASMList.ITASMDelOfAddr(Self); except end;
  Inherited Destroy;
end;

procedure TSendSQLServerEvent.Exec;
//Var tmpDataCase:IDataCase;
//      tmpPackPD:IPackPD;
begin
  Raise Exception.Create('unused.');
(*  tmpDataCase:=GL_DataCase;
  If not Assigned(tmpDataCase) Then Raise Exception.Create('DataCase not assigned.');
  try
    If aBridge=0 Then begin//сообщение для всех магазинов
      1
    end else begin//сообщение для указанного магазина
      1
    end;
  finally
    tmpDataCase:=Nil;
  end;*)
end;

initialization
  //TAutoObjectFactory.Create(ComServer, TSendSQLServerEvent, Class_SendSQLServerEvent, ciMultiInstance, tmFree);
  glTASMList:=TASMList.Create;
finalization
  glTASMList.ITASMDisconnectAll;
  glTASMList:=Nil;
end.
