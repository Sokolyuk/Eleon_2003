//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit ULocalDataBaseUtils;

interface
  uses ADOdb, ADOInt, Provider;

  function GetDBCursor(aRecSet: _Recordset; const aADODS: TADODataSet; var aRecAff: Integer):OleVariant;
  function GetDBCursorFirst(aRecSet: _Recordset; const aADODS: TADODataSet; var aRecAff: Integer):OleVariant;
  function IsMutipleCursor(const aData:OleVariant):boolean;


implementation
  uses Sysutils{$ifndef ver130}, variants{$endif};

function GetDBCursor(aRecSet: _Recordset; const aADODS: TADODataSet; var aRecAff: integer):OleVariant;
  var tmpIntADODS: TADODataSet;
      tmpDSWriter: TDataPacketWriter;
      tmpRecsOut: Integer;
      tmpRecAff: OleVariant;
      tmpMultiRecordSetResult: OleVariant;
      tmpHB: integer;
      tmpIsMultipleResult: boolean;
begin
  try
    if not assigned(aRecSet) then raise exception.create('aRecSet not assigned');

    tmpMultiRecordSetResult := unassigned;
    tmpRecAff := aRecAff;
    tmpHB := 0;
    tmpIsMultipleResult := false;

    while true do begin

      result := unassigned;//чищу

      if aRecSet.State = adStateOpen then begin
        if assigned(aADODS) then begin
          if aADODS.Active then aADODS.Close;
          tmpIntADODS := aADODS;
        end else begin
          tmpIntADODS := TADODataSet.create(nil);
        end;
        try
          tmpIntADODS.Recordset := aRecSet;
          tmpIntADODS.CheckBrowseMode;
          tmpIntADODS.BlockReadSize := -1;
          tmpDSWriter := TDataPacketWriter.Create;
          try
            tmpDSWriter.constraints := True;
            tmpDSWriter.PacketOptions := [grMetaData];
            tmpDSWriter.Options := [poFetchBlobsOnDemand];
            tmpRecsOut := -1;
            try
              tmpDSWriter.GetDataPacket(tmpIntADODS, tmpRecsOut, result);
            except on e:exception do begin
              e.Message:='GetDataPacket: '+e.Message;
              raise;
            end;end;
          finally
            tmpDSWriter.free;
          end;
        finally
          if not assigned(aADODS) then begin
            tmpIntADODS.free;
          end else begin
            tmpIntADODS.first;
          end;
        end;
        aRecAff := tmpRecsOut;
      end;

      //беру следующею выборку
      try
        aRecSet := aRecSet.NextRecordset(tmpRecAff);
      except on e:exception do begin
        //!!!e.message:='NextRecordset: '+e.message;
        //???raise;
        aRecSet := nil;
      end;end;

      if not tmpIsMultipleResult then tmpIsMultipleResult := assigned(aRecSet);

      if (tmpIsMultipleResult) and (not VarIsEmpty(result)) then begin
        //добавл€ю результат
        //данные вз€лись
        if VarIsEmpty(tmpMultiRecordSetResult) then begin
          tmpMultiRecordSetResult := VarArrayCreate([0, 0], varVariant);
          tmpHB := 0;
        end else begin
          VarArrayRedim(tmpMultiRecordSetResult, tmpHB + 1);
          inc(tmpHB);
        end;
        tmpMultiRecordSetResult[tmpHB] := result;
      end;

      //готовлю результат
      if not assigned(aRecSet) then begin
        //больше выборок нет, складываю результат
        if not VarIsEmpty(tmpMultiRecordSetResult) then begin
          result := tmpMultiRecordSetResult;//подставл€ю множественный результат на выход
        end;

        break;
      end;

    end;
  except on e:exception do begin
    e.message:='GetCursors: '+e.message;
    raise;
  end;end;
end;

function GetDBCursorFirst(aRecSet: _Recordset; const aADODS: TADODataSet; var aRecAff: integer):OleVariant;
  var tmpIntADODS:TADODataSet;
      tmpDSWriter:TDataPacketWriter;
      tmpRecsOut: Integer;
      tmpRecAff: OleVariant;
begin
  try
    result := unassigned;
    tmpRecAff := aRecAff;
    while assigned(aRecSet) do begin
      if aRecSet.State = adStateOpen then begin
        if assigned(aADODS) then begin
          tmpIntADODS := aADODS;
        end else begin
          tmpIntADODS := TADODataSet.create(nil);
        end;
        try
          tmpIntADODS.Recordset := aRecSet;
          tmpIntADODS.CheckBrowseMode;
          tmpIntADODS.BlockReadSize:=-1;
          tmpDSWriter := TDataPacketWriter.Create;
          try
            tmpDSWriter.constraints := True;
            tmpDSWriter.PacketOptions := [grMetaData];
            tmpDSWriter.Options := [poFetchBlobsOnDemand];
            tmpRecsOut := -1;
            try
              tmpDSWriter.GetDataPacket(tmpIntADODS, tmpRecsOut, Result);
            except on e:exception do begin
              e.Message:='GetDataPacket: '+e.Message;
              raise;
            end;end;
          finally
            tmpDSWriter.free;
          end;
        finally
          if not assigned(aADODS) then begin
            tmpIntADODS.free;
          end else begin
            tmpIntADODS.first;
          end;  
        end;
        aRecAff := tmpRecsOut;
        break;
      end;
      aRecSet := aRecSet.NextRecordset(tmpRecAff);
    end;
  except on e:exception do begin
    e.message:='GetCursorFirst: '+e.message;
    raise;
  end;end;
end;

function IsMutipleCursor(const aData:OleVariant):boolean;
begin
  result := (VarIsArray(aData)) and (VarType(aData) = (varVariant or varArray));
end;

end.
