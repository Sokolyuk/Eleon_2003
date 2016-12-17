//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerProceduresSrv;

interface
 uses UServerProcedures;

type
  TServerProceduresSrv=class(TServerProcedures)
    procedure ITReload;override;
  end;

implementation
  uses UVarsetTypes, UVarset, SysUtils, UTypeUtils, UServerProcedure, UServerProcedureTypes, ULocalDataBase, ULocalDataBaseTypes
       , Variants, UServerActionConsts, UMachineNameConsts;
       
procedure TServerProceduresSrv.ITReload;
  Var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIServerProcedure:IServerProcedure;
      tmpServerProcedures:IVarset;
      tmpSt:AnsiString;
      tmpServerProcedureAss:TServerProcedureAss;
      tmpOldFormat:Boolean;
      tmpLocalDataBase:ILocalDataBase;
begin
  tmpLocalDataBase:=TLocalDataBase.Create;
  tmpLocalDataBase.CallerAction:=cnServerAction;
  tmpLocalDataBase.CheckSecuretyLDB:=False;
  tmpLocalDataBase.CheckForTriggers:=False;
  try
    if not Assigned(tmpLocalDataBase) then raise exception.create('TServerProceduresSrv.ITReload: LocalDataBase is not assigned.');
    //Result:='';
    try
      tmpLocalDataBase.OpenSQL('SELECT RegName,IASMServer,IDataCase,ILocalDataBase,[Guid],[Machine],[Method],LoadParams FROM ssServerProc');
      tmpOldFormat:=False;
    except
      tmpLocalDataBase.OpenSQL('SELECT RegName,IASMServer,IDataCase,ILocalDataBase,[Guid],[Machine],[Method] FROM ssServerProc');
      tmpOldFormat:=True;
    end;
    FServerProcedures.ITSetAllChecked(True);
    tmpServerProcedures:=nil;
    if tmpLocalDataBase.DataSet.RecordCount>0 then begin
      tmpLocalDataBase.DataSet.First;
      while not tmpLocalDataBase.DataSet.Eof do begin
        try
          tmpServerProcedureAss.RegName:=tmpLocalDataBase.DataSet.FieldByName('RegName').AsString;
          tmpServerProcedureAss.RequireASMServer:=tmpLocalDataBase.DataSet.FieldByName('IASMServer').AsInteger<>0;
          tmpServerProcedureAss.RequireDataCase:=tmpLocalDataBase.DataSet.FieldByName('IDataCase').AsInteger<>0;
          tmpServerProcedureAss.RequireLocalDataBase:=tmpLocalDataBase.DataSet.FieldByName('ILocalDataBase').AsInteger<>0;
          tmpServerProcedureAss.GUID:=glStringToGUID(tmpLocalDataBase.DataSet.FieldByName('GUID').AsString);
          tmpServerProcedureAss.Machine:=tmpLocalDataBase.DataSet.FieldByName('Machine').AsString;
          if (tmpServerProcedureAss.Machine='~')Or(UpperCase(tmpServerProcedureAss.Machine)='LOCALHOST') Then tmpServerProcedureAss.Machine:=cnMachineName;
          tmpServerProcedureAss.Method:=tmpLocalDataBase.DataSet.FieldByName('Method').AsString;
          if tmpOldFormat then begin
            tmpServerProcedureAss.LoadParams:=Unassigned;
          end else begin
            tmpSt:=tmpLocalDataBase.DataSet.FieldByName('LoadParams').AsString;
            if tmpSt='' then tmpServerProcedureAss.LoadParams:=Unassigned Else tmpServerProcedureAss.LoadParams:=glStringToVarArray(tmpSt);
          end;
          //..
          tmpI:=-1;
          while true do begin
            tmpIVarsetDataView:=FServerProcedures.ITViewNextGetOfIntIndex(tmpI);
            if tmpI=-1 Then Break;
            tmpIUnknown:=tmpIVarsetDataView.ITData;
            if IServerProcedure(tmpIUnknown).ITCheckEqualP(@tmpServerProcedureAss) then begin
              tmpIVarsetDataView.ITChecked:=False;
              Break;
            end;
          end;
          tmpIUnknown:=nil;
          tmpIVarsetDataView:=nil;
          //..
          if tmpI=-1 then begin
            if not Assigned(tmpServerProcedures) Then begin
              tmpServerProcedures:=TVarset.Create;
              tmpServerProcedures.ITConfigIntIndexAssignable:=False;
              tmpServerProcedures.ITConfigCheckUniqueIntIndex:=False;
              tmpServerProcedures.ITConfigCheckUniqueStrIndex:=False;
              tmpServerProcedures.ITConfigNoFoundException:=True;
            end;
            tmpIServerProcedure:=TServerProcedure.Create;
            tmpIServerProcedure.ITSetAssP(@tmpServerProcedureAss);
            tmpServerProcedures.ITPushV(tmpIServerProcedure);
            tmpIServerProcedure:=Nil;
          end;
        except on e:exception do begin
          //Result:=Result+''''+e.message+''';';
        end;end;
        tmpLocalDataBase.DataSet.Next;
        tmpServerProcedureAss.RegName:='';
        tmpServerProcedureAss.Machine:='';
        tmpServerProcedureAss.Method:='';
        tmpServerProcedureAss.LoadParams:=Unassigned;
      end;
    end;
    FServerProcedures.ITAppendAndClearChecked(tmpServerProcedures, True, True);
    tmpLocalDataBase:=Nil;
    tmpServerProcedures:=Nil;
  except on e:exception do begin
    raise exception.create('TServerProceduresSrv.ITReload: '+e.Message);
  end;end;
end;

end.
