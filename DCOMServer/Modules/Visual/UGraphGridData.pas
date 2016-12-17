//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UGraphGridData;

interface
  Uses Windows, Messages, SysUtils, Classes, UGraphGrid, Graphics;

type
  PDataDesc=^TDataDesc;
  TDataDesc=record
    Value:Integer;
    Text:AnsiString;
  end;

  PDataArray=^TDataArray;
  TDataArray=Array[0..999] of TDataDesc;

  TDataModifyValueObjectEvent=Procedure(Var Value:Integer) of object;
  TDataModifyValueTextObjectEvent=Procedure(Var Value:Integer; Var Text:AnsiString) of object;


  TGraphGridData=class(TComponent)
  private
    FData:TDataArray;
    FBeginData, FDataMaxCount, FDataCount:Integer;
    FColorLine:TColor;
    FGraphGrid:TGraphGrid;
    FVScale:Double;
  protected
    procedure Set_GraphGrid(Value:TGraphGrid);
    procedure Set_ColorLine(Value:TColor);
    procedure Set_VScale(Value:Double);
    Procedure InternalRecalcVScale(Var Value:Integer);
    function GetPData:PDataArray;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    Procedure DataAdd(Value:Integer); Overload;
    Procedure DataAdd(Value:Integer; Const aText:AnsiString); Overload;
    Procedure DataModifyValue(aModify:TDataModifyValueObjectEvent);
    Procedure DataModifyValueText(aModify:TDataModifyValueTextObjectEvent);
    Procedure DataClear;
    property DataCount:Integer read FDataCount{ write FDataCount};
    property BeginData:Integer read FBeginData{ write FBeginData};
    property DataMaxCount:Integer read FDataMaxCount{ write FDataMaxCount};
    property Data:TDataArray read FData{ write FData};
    property PData:PDataArray read GetPData{ write FData};
  published
    property ColorLine:TColor read FColorLine write Set_ColorLine;
    property GraphGrid:TGraphGrid read FGraphGrid write Set_GraphGrid;
    property VScale:Double read FVScale write Set_VScale;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('ELEON', [TGraphGridData]);
end;

constructor TGraphGridData.Create(AOwner: TComponent);
begin
  FColorLine:=clLime;
  FillChar(FData, SizeOf(FData), 0);
  FBeginData:=0;
  FDataCount:=0;
  FDataMaxCount:=SizeOf(FData) div SizeOf(TDataDesc);
  FGraphGrid:=Nil;
  FVScale:=1;
  Inherited Create(AOwner);
end;

destructor TGraphGridData.Destroy;
begin
  If Assigned(FGraphGrid) Then begin
    FGraphGrid.UnregisterDataGrid(Self);
    FGraphGrid:=Nil;
  end;
  Inherited Destroy;
end;

Procedure TGraphGridData.Set_ColorLine(Value:TColor);
begin
  FColorLine:=Value;
  If Assigned(FGraphGrid) Then FGraphGrid.RePaint;
end;

Procedure TGraphGridData.DataAdd(Value:Integer; Const aText:AnsiString);
  Var tmpI:Integer;
begin
  InternalRecalcVScale(Value);
  Inc(FDataCount);
  If FDataCount>FDataMaxCount then begin
    FDataCount:=FDataMaxCount;
    Inc(FBeginData);
    If FBeginData>FDataMaxCount-1 then begin
      FBeginData:=0;
      FData[FDataMaxCount-1].Value:=Value;
      FData[FDataMaxCount-1].Text:=aText;
    end else begin
      FData[FBeginData-1].Value:=Value;
      FData[FBeginData-1].Text:=aText;
    end;
  end else begin
    tmpI:=FBeginData+FDataCount-1;
    If tmpI>FDataMaxCount-1 then begin
      tmpI:=tmpI-FDataMaxCount;
    end;
    FData[tmpI].Value:=Value;
    FData[tmpI].Text:=aText;
  end;
  If Assigned(FGraphGrid) Then FGraphGrid.RePaint;
end;

Procedure TGraphGridData.DataAdd(Value:Integer);
begin
  DataAdd(Value, '');
end;

Procedure TGraphGridData.DataClear;
begin
  FillChar(FData, SizeOf(FData), 0);
  FBeginData:=0;
  FDataCount:=0;
  If Assigned(FGraphGrid) Then FGraphGrid.RePaint;
end;

procedure TGraphGridData.DataModifyValue(aModify:TDataModifyValueObjectEvent);//Показывает чере Callback содержимое массива
  var tmpBeginData, tmpI:Integer;
      tmpPDataDesc:PDataDesc;
begin
  If Assigned(aModify)And(DataCount>0) Then begin
    tmpBeginData:=BeginData+DataCount-1;
    For tmpI:=0 to DataCount-1 do begin
      If tmpBeginData>DataMaxCount-1 Then begin
        tmpPDataDesc:=@FData[tmpBeginData-DataMaxCount];
      end else begin
        tmpPDataDesc:=@FData[tmpBeginData];
      end;
      aModify(tmpPDataDesc^.Value);
      Dec(tmpBeginData);
    end;
  end;
end;

Procedure TGraphGridData.DataModifyValueText(aModify:TDataModifyValueTextObjectEvent);
  Var tmpBeginData, tmpI:Integer;
      tmpPDataDesc:PDataDesc;
begin
  If Assigned(aModify)And(DataCount>0) Then begin
    tmpBeginData:=BeginData+DataCount-1;
    For tmpI:=0 to DataCount-1 do begin
      If tmpBeginData>DataMaxCount-1 Then begin
        tmpPDataDesc:=@FData[tmpBeginData-DataMaxCount];
      end else begin
        tmpPDataDesc:=@FData[tmpBeginData];
      end;
      aModify(tmpPDataDesc^.Value, tmpPDataDesc^.Text);
      Dec(tmpBeginData);
    end;
  end;
end;

procedure TGraphGridData.Set_VScale(Value:Double);
begin
  If FVScale<>Value Then begin
    If (Value=0)Or(Value<0) Then Raise Exception.Create('Invalid value VScale.');
    FVScale:=Value/FVScale;
    DataModifyValue(InternalRecalcVScale);
    FVScale:=Value;
    If Assigned(FGraphGrid) Then FGraphGrid.RePaint;
  end;  
end;

Procedure TGraphGridData.InternalRecalcVScale(Var Value:Integer);
  Var tmpDouble:Double;
begin
  tmpDouble:=Value*FVScale;
  Value:=Integer(Round(tmpDouble));
end;

procedure TGraphGridData.Set_GraphGrid(Value:TGraphGrid);
begin
  If Assigned(FGraphGrid) Then FGraphGrid.UnregisterDataGrid(Self);
  FGraphGrid:=Value;
  If Assigned(FGraphGrid) Then FGraphGrid.RegisterDataGrid(Self);
end;

function TGraphGridData.GetPData:PDataArray;
begin
  result:=@FData;
end;

end.
