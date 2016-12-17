unit UServerProceduresEsc;

interface
 uses UServerProcedures;

type
  TServerProceduresEsc=class(TServerProcedures)
    procedure ITReload;override;
  end;

implementation
  uses UVarsetTypes, UVarset, SysUtils, UTypeUtils, UServerProcedure, UServerProcedureTypes, {$IFDEF VER140}, Variants{$ENDIF},
       UServerActionConsts, UMachineNameConsts;

procedure TServerProceduresEsc.ITReload;
  Var tmpI:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIServerProcedure:IServerProcedure;
      tmpServerProcedures:IVarset;
      tmpSt:AnsiString;
      tmpServerProcedureAss:TServerProcedureAss;
      tmpOldFormat:Boolean;
begin

Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Eleon\ServerProc]

[HKEY_LOCAL_MACHINE\SOFTWARE\Eleon\ServerProc\lpu_TransferBf]
"Guid"="{701CA4E9-A294-436A-886A-A129EE8163E8}"
"Machine"="~"
"Method"="DownloadBf"
"LoadParams"="~"
"Commentary"="TransferBfProc"


  try
    if not Assigned(aLocalDataBase) then raise exception.create('TServerProcedures.ITReload: LocalDataBase is not assigned.');
    Result:='';
    try
      aLocalDataBase.OpenSQL('SELECT RegName,IASMServer,IDataCase,ILocalDataBase,[Guid],[Machine],[Method],LoadParams FROM ssServerProc');
      tmpOldFormat:=False;
    except
      aLocalDataBase.OpenSQL('SELECT RegName,IASMServer,IDataCase,ILocalDataBase,[Guid],[Machine],[Method] FROM ssServerProc');
      tmpOldFormat:=True;
    end;
    FServerProcedures.ITSetAllChecked(True);
    tmpServerProcedures:=Nil;
    if aLocalDataBase.DataSet.RecordCount>0 then begin
      aLocalDataBase.DataSet.First;
      while not aLocalDataBase.DataSet.Eof do begin
        try
          tmpServerProcedureAss.RegName:=aLocalDataBase.DataSet.FieldByName('RegName').AsString;
          tmpServerProcedureAss.RequireASMServer:=aLocalDataBase.DataSet.FieldByName('IASMServer').AsInteger<>0;
          tmpServerProcedureAss.RequireDataCase:=aLocalDataBase.DataSet.FieldByName('IDataCase').AsInteger<>0;
          tmpServerProcedureAss.RequireLocalDataBase:=aLocalDataBase.DataSet.FieldByName('ILocalDataBase').AsInteger<>0;
          tmpServerProcedureAss.GUID:=glStringToGUID(aLocalDataBase.DataSet.FieldByName('GUID').AsString);
          tmpServerProcedureAss.Machine:=aLocalDataBase.DataSet.FieldByName('Machine').AsString;
          if (tmpServerProcedureAss.Machine='~')Or(UpperCase(tmpServerProcedureAss.Machine)='LOCALHOST') Then tmpServerProcedureAss.Machine:=cnMachineName;
          tmpServerProcedureAss.Method:=aLocalDataBase.DataSet.FieldByName('Method').AsString;
          If tmpOldFormat Then begin
            tmpServerProcedureAss.LoadParams:=Unassigned;
          end else begin
            tmpSt:=aLocalDataBase.DataSet.FieldByName('LoadParams').AsString;
            If tmpSt='' Then tmpServerProcedureAss.LoadParams:=Unassigned Else tmpServerProcedureAss.LoadParams:=glStringToVarArray(tmpSt);
          end;
          //..
          tmpI:=-1;
          While true do begin
            tmpIVarsetDataView:=FServerProcedures.ITViewNextGetOfIntIndex(tmpI);
            If tmpI=-1 Then Break;
            tmpIUnknown:=tmpIVarsetDataView.ITData;
            If IServerProcedure(tmpIUnknown).ITCheckEqualP(@tmpServerProcedureAss) then begin
              tmpIVarsetDataView.ITChecked:=False;
              Break;
            end;
          end;
          tmpIUnknown:=Nil;
          tmpIVarsetDataView:=Nil;
          //..
          If tmpI=-1 Then begin
            If Not Assigned(tmpServerProcedures) Then begin
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
        Except On E:Exception do begin
          Result:=Result+''''+e.message+''';';
        end;end;
        aLocalDataBase.DataSet.Next;
        tmpServerProcedureAss.RegName:='';
        tmpServerProcedureAss.Machine:='';
        tmpServerProcedureAss.Method:='';
        tmpServerProcedureAss.LoadParams:=Unassigned;
      end;
    end;
    FServerProcedures.ITAppendAndClearChecked(tmpServerProcedures, True, True);
    aLocalDataBase:=Nil;
    tmpServerProcedures:=Nil;
  except
    on e:exception do begin
      Raise Exception.Create('TServerProcedures.ITReload: '+e.Message);
    end;
  end;
end;

end.
