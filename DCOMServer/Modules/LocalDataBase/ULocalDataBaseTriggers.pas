//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit ULocalDataBaseTriggers;
interface
  Uses ULocalDataBaseTriggersTypes, UTrayInterface, ULocalDataBaseTriggerTypes, UVarsetTypes, ULocalDataBaseTypes,
       UCallerTypes, UTrayInterfaceTypes, UServerProceduresTypes;
Type
  TLocalDataBaseTriggers=Class(TTrayInterface, ILocalDataBaseTriggers)
  Private
    FTriggers:IVarset;
    FServerProcedures:IServerProcedures;
  Protected
    function InternalGetIServerProcedures:IServerProcedures;virtual;
    Procedure InternalExecServerProcTrigger(Const aTriggerRegName:AnsiString; Const aTriggerParam:Variant; aTriggerData:PTriggerData; aLocalDataBase:ILocalDataBase; aCallerAction:ICallerAction);virtual;
    procedure InternalInit;override;
  Public
    Constructor Create;
    Destructor Destroy; Override;
    Function ITCheck(aTriggerType:TTriggerType; Const aTables:Variant):Boolean;virtual;
    Function ITExec(aGetTriggerLocalDataBaseEvent:TGetTriggerLocalDataBaseEvent; aTriggerData:PTriggerData; Const aTables:Variant; aCallerAction:ICallerAction):Integer;virtual;
    Function ITReloadTriggers(aLocalDataBase:ILocalDataBase):AnsiString;virtual;
  End;

implementation
  Uses SysUtils, UVarset, ULocalDataBaseTrigger, USQLParserTypes, USQLParserUtils, ULocalDataBaseTriggerUtils,
       ULocalDataBaseTriggerConsts, USQLParserConsts, UServerProcUtils, UExternalDataCase, UExternalLocalDataBase,
       UStringUtils, UTypeUtils, UExternalTypes, ULocalDataBase, UServerProcTypes, Variants,
       UServerActionConsts, UTrayConsts;

Constructor TLocalDataBaseTriggers.Create;
begin
  FTriggers:=TVarset.Create;
  FTriggers.ITConfigIntIndexAssignable:=False;
  FTriggers.ITConfigCheckUniqueIntIndex:=False;
  FTriggers.ITConfigCheckUniqueStrIndex:=False;
  FTriggers.ITConfigNoFoundException:=True;
  Inherited Create;
end;

Destructor TLocalDataBaseTriggers.Destroy;
begin
  FTriggers:=Nil;
  Inherited Destroy;
end;

Function TLocalDataBaseTriggers.ITCheck(aTriggerType:TTriggerType; Const aTables:Variant):Boolean;
  Var tmpI, tmpIntIndex:Integer;
      tmpSQLCommandType:TSQLCommandType;
      tmpTable:AnsiString;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  Result:=False;
  If VarIsArray(aTables) Then begin
    For tmpI:=VarArrayLowBound(aTables, 1) to VarArrayHighBound(aTables, 1) do begin
      tmpSQLCommandType:=TSQLCommandType(aTables[tmpI][0]);
      tmpTable:=VarToStr(aTables[tmpI][1]);
      tmpIntIndex:=-1;
      While True do begin
        tmpIVarsetDataView:=FTriggers.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        If ILocalDataBaseTrigger(tmpIUnknown).ITCheckInclude(aTriggerType, tmpSQLCommandType, tmpTable) Then begin
          Result:=True;
          Break;
        end;
      end;
      If Result Then Break;
    end;
  end;
end;

Procedure TLocalDataBaseTriggers.InternalExecServerProcTrigger(Const aTriggerRegName:AnsiString; Const aTriggerParam:Variant; aTriggerData:PTriggerData; aLocalDataBase:ILocalDataBase; aCallerAction:ICallerAction);
  Var tmpV:Variant;
      tmpServerProcExecParams:TServerProcExecParams;
begin
  tmpV:=aTriggerParam;
  fillchar(tmpServerProcExecParams, Sizeof(tmpServerProcExecParams), 0);
  tmpServerProcExecParams.aServerProcedures:=InternalGetIServerProcedures;
  tmpServerProcExecParams.aShowMessage:=true;
  tmpServerProcExecParams.aLocalDataBase:=aLocalDataBase;
  tmpServerProcExecParams.aLocalDataBaseTriggerData:=aTriggerData;
  ServerProcExec(aCallerAction, aTriggerRegName, tmpV, @tmpServerProcExecParams);
  tmpServerProcExecParams.aServerProcedures:=nil;
end;

Function TLocalDataBaseTriggers.ITExec(aGetTriggerLocalDataBaseEvent:TGetTriggerLocalDataBaseEvent; aTriggerData:PTriggerData; Const aTables:Variant; aCallerAction:ICallerAction):Integer;
  Var tmpI, tmpIntIndex:Integer;
      tmpSQLCommandType:TSQLCommandType;
      tmpTable:AnsiString;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpTriggerRegNames, tmpTriggerRegName:AnsiString;
      tmpTriggerRegNamesPos, tmpTriggerRegNamesLength:Integer;
      tmpLocalDataBase:ILocalDataBase;
begin
  Result:=0;
  If VarIsArray(aTables) Then begin
    If Not Assigned(aGetTriggerLocalDataBaseEvent) Then Raise Exception.Create('GetTriggerLocalDataBaseEvent is not assigned.');
    For tmpI:=VarArrayLowBound(aTables, 1) to VarArrayHighBound(aTables, 1) do begin
      tmpSQLCommandType:=TSQLCommandType(aTables[tmpI][0]);
      tmpTable:=AnsiUpperCase(VarToStr(aTables[tmpI][1]));
      tmpIntIndex:=-1;
      While True do begin
        tmpIVarsetDataView:=FTriggers.ITViewNextGetOfIntIndex(tmpIntIndex);
        If tmpIntIndex=-1 then break;
        tmpIUnknown:=tmpIVarsetDataView.ITData;
        tmpTriggerRegNames:=ILocalDataBaseTrigger(tmpIUnknown).ITGetTriggerRegNames(aTriggerData^.TriggerType, tmpSQLCommandType, tmpTable);
        tmpTriggerRegNamesLength:=Length(tmpTriggerRegNames);
        If tmpTriggerRegNamesLength<>0 Then begin
          tmpTriggerRegNamesPos:=-1;
          While True do begin
            tmpTriggerRegName:=GetParamFromParamsStr(tmpTriggerRegNamesPos, tmpTriggerRegNames, ';');
            If tmpTriggerRegNamesPos=-1 Then break;
            If Not Assigned(tmpLocalDataBase) Then begin
              tmpLocalDataBase:=aGetTriggerLocalDataBaseEvent;
            end;
            InternalExecServerProcTrigger(tmpTriggerRegName, ILocalDataBaseTrigger(tmpIUnknown).ITServerProcParam, aTriggerData, tmpLocalDataBase, aCallerAction);
            Inc(Result);
          end;
        end;
      end;
    end;
    tmpLocalDataBase:=Nil;
    tmpIUnknown:=Nil;
  end;
end;

Function TLocalDataBaseTriggers.ITReloadTriggers(aLocalDataBase:ILocalDataBase):AnsiString;
  Var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpServerProcRegNames, tmpTables:AnsiString;
      tmpServerProcParam:Variant;
      tmpSQLCommands:TSetSQLCommandType;
      tmpTriggerTypes:TSetTriggerType;
      tmpFound:Boolean;
      tmpILocalDataBaseTrigger:ILocalDataBaseTrigger;
      tmpTriggers:IVarset;
      tmpSt:AnsiString;
begin
  Try
    If Not Assigned(aLocalDataBase) Then Raise Exception.Create('LDBTriggers.ITReloadTriggers: LocalDataBase is not assigned.');
    Result:='';
    aLocalDataBase.OpenSQL('Select [Disabled],[ServerProcRegNames],[ServerProcParam],[Types],[Tables],[Commands] From ssInternalTrigger');
    FTriggers.ITSetAllChecked(True);
    tmpTriggers:=Nil;
    If aLocalDataBase.DataSet.RecordCount>0 Then begin
      aLocalDataBase.DataSet.First;
      While Not aLocalDataBase.DataSet.Eof do begin
        try
          If aLocalDataBase.DataSet.FieldByName('Disabled').AsInteger=0 Then begin
            tmpServerProcRegNames:=AnsiUpperCase(aLocalDataBase.DataSet.FieldByName('ServerProcRegNames').AsString);
            If tmpServerProcRegNames='' Then Raise Exception.Create('ServerProcRegNames must be assigned.');
            tmpSt:=aLocalDataBase.DataSet.FieldByName('ServerProcParam').AsString;
            If tmpSt='' Then tmpServerProcParam:=Unassigned Else tmpServerProcParam:=glStringToVarArray(tmpSt);
            tmpTables:=AnsiUpperCase(aLocalDataBase.DataSet.FieldByName('Tables').AsString);
            tmpSt:=aLocalDataBase.DataSet.FieldByName('Types').AsString;
            If tmpSt='' Then tmpTriggerTypes:=cnAllTriggerTypes else tmpTriggerTypes:=ParamsStrToSetTriggerType(AnsiUpperCase(tmpSt));
            tmpSt:=aLocalDataBase.DataSet.FieldByName('Commands').AsString;
            If tmpSt='' Then tmpSQLCommands:=cnAllSQLCommands Else tmpSQLCommands:=ParamsStrToSQLCommands(AnsiUpperCase(tmpSt));
            //..
            tmpFound:=False;
            tmpI:=-1;
            While true do begin
              tmpIVarsetDataView:=FTriggers.ITViewNextGetOfIntIndex(tmpI);
              If tmpI=-1 Then Break;
              tmpIUnknown:=tmpIVarsetDataView.ITData;
              If ILocalDataBaseTrigger(tmpIUnknown).ITCheckEqual(tmpServerProcRegNames, tmpServerProcParam, tmpTables, tmpTriggerTypes, tmpSQLCommands) then begin
                tmpIVarsetDataView.ITChecked:=False;
                tmpFound:=True;
                Break;
              end;
            end;
            tmpIUnknown:=Nil;
            tmpIVarsetDataView:=Nil;
            //..
            If Not tmpFound Then begin
              If Not Assigned(tmpTriggers) Then begin
                tmpTriggers:=TVarset.Create;
                tmpTriggers.ITConfigIntIndexAssignable:=False;
                tmpTriggers.ITConfigCheckUniqueIntIndex:=False;
                tmpTriggers.ITConfigCheckUniqueStrIndex:=False;
                tmpTriggers.ITConfigNoFoundException:=True;
              end;
              tmpILocalDataBaseTrigger:=TLocalDataBaseTrigger.Create;
              tmpILocalDataBaseTrigger.ITServerProcRegNames:=tmpServerProcRegNames;
              tmpILocalDataBaseTrigger.ITTypes:=tmpTriggerTypes;
              tmpILocalDataBaseTrigger.ITTables:=tmpTables;
              tmpILocalDataBaseTrigger.ITSQLCommands:=tmpSQLCommands;
              tmpILocalDataBaseTrigger.ITServerProcParam:=tmpServerProcParam;
              tmpTriggers.ITPushV(tmpILocalDataBaseTrigger);
              tmpILocalDataBaseTrigger:=Nil;
            end;
          end;
        Except On E:Exception do begin
          Result:=Result+''''+e.message+''';';
        end;End;
        aLocalDataBase.DataSet.Next;
        tmpTriggerTypes:=[];
        tmpTables:='';
        tmpSQLCommands:=[];
        tmpServerProcRegNames:='';
      end;
    end;
    FTriggers.ITAppendAndClearChecked(tmpTriggers, True, True);
    aLocalDataBase:=Nil;
    tmpTriggers:=Nil;
  except on e:exception do begin
    e.Message:='ITReloadTriggers: '+e.Message;
    Raise;
  end;end;
end;

procedure TLocalDataBaseTriggers.InternalInit;
  Var tmpLocalDataBase:ILocalDataBase;
begin
  tmpLocalDataBase:=TLocalDataBase.Create;
  tmpLocalDataBase.CallerAction:=cnServerAction;
  tmpLocalDataBase.CheckSecuretyLDB:=False;
  tmpLocalDataBase.CheckForTriggers:=False;
  ITReloadTriggers(tmpLocalDataBase);
end;

function TLocalDataBaseTriggers.InternalGetIServerProcedures:IServerProcedures;
begin
  if not assigned(FServerProcedures) then cnTray.Query(IServerProcedures, FServerProcedures);
  result:=FServerProcedures;
end;

end.
