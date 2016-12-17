//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UGraphGrid;

interface
  Uses Controls, Classes, Graphics, Windows;

type
  PGraphGridList=^TGraphGridList;
  TGraphGridList=Record
    GraphGridData:TObject;
    Next:PGraphGridList;
  End;

  TGraphGrid=class(TGraphicControl)
  private
    FPGraphGridList:PGraphGridList;
    FOnPaint: TNotifyEvent;
    FColorBack:TColor;
    FColorGrid:TColor;
    FGridHInterval, FGridVInterval:Word;
    FZeroCoordinateVOffset:Integer;
    Function InternalGetLastGraphGridListElement:PGraphGridList;
  protected
    procedure Paint; Override;
    Procedure Set_ColorBack(Value:TColor);
    Procedure Set_ColorGrid(Value:TColor);
    Procedure Set_GridHInterval(Value:Word);
    Procedure Set_GridVInterval(Value:Word);
    Procedure Set_ZeroCoordinateVOffset(Value:Integer);
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    Procedure UnregisterDataGrid(Value:TObject);
    Procedure RegisterDataGrid(Value:TObject);
    property Canvas;
  published
    property Align;
    property Anchors;
    property Visible;
    property ColorBack:TColor read FColorBack write Set_ColorBack;
    property ColorGrid:TColor read FColorGrid write Set_ColorGrid;
    property GridHInterval:Word read FGridHInterval write Set_GridHInterval;
    property GridVInterval:Word read FGridVInterval write Set_GridVInterval;
    property ZeroCoordinateVOffset:Integer read FZeroCoordinateVOffset write Set_ZeroCoordinateVOffset;
    property Font;
  end;

procedure Register;

implementation
  Uses SysUtils, UGraphGridData;

procedure Register;
begin
  RegisterComponents('ELEON', [TGraphGrid]);
end;

constructor TGraphGrid.Create(AOwner: TComponent);
begin
  FGridHInterval:=10;
  FGridVInterval:=10;
  FColorBack:=clBlack;
  FColorGrid:=clGreen;
  FPGraphGridList:=Nil;
  ZeroCoordinateVOffset:=-1;
  Inherited Create(AOwner);
end;

destructor TGraphGrid.Destroy;
begin
  While Assigned(FPGraphGridList) do begin
    TGraphGridData(FPGraphGridList^.GraphGridData).GraphGrid:=Nil;
  end;
  Inherited Destroy;
end;

Procedure TGraphGrid.Set_GridHInterval(Value:Word);
begin
  FGridHInterval:=Value;
  Repaint;
end;

Procedure TGraphGrid.Set_GridVInterval(Value:Word);
begin
  FGridVInterval:=Value;
  Repaint;
end;

Procedure TGraphGrid.Set_ColorBack(Value:TColor);
begin
  FColorBack:=Value;
  RePaint;
end;

Procedure TGraphGrid.Set_ColorGrid(Value:TColor);
begin
  FColorGrid:=Value;
  RePaint;
end;

Procedure TGraphGrid.Set_ZeroCoordinateVOffset(Value:Integer);
begin
  FZeroCoordinateVOffset:=Value;
  RePaint;
end;

procedure TGraphGrid.Paint;
  Var tmpRect:TRect;
      tmpBeginData, tmpI:Integer;
      tmpTPoint:TPoint;
      tmpPGraphGridList:PGraphGridList;
      tmpGraphGridData:TGraphGridData;
      tmpPDataDesc:PDataDesc;
      tmpX, tmpY:Integer;
begin
  tmpRect.Top:=0;
  tmpRect.Left:=0;
  tmpRect.Right:=Width;
  tmpRect.Bottom:=Height;
  Canvas.Brush.Color:=FColorBack;
  Canvas.FillRect(tmpRect);
  Canvas.Pen.Color:=FColorGrid;
  //Вертикальная сетка
  tmpI:=Width-FGridHInterval;
  While tmpI>0 do begin
    tmpTPoint.X:=tmpI;
    tmpTPoint.Y:=0;
    Canvas.PenPos:=tmpTPoint;
    Canvas.LineTo(tmpI, Height);
    tmpI:=tmpI-FGridHInterval;
  end;
  //Горизонтальная сетка
  tmpI:=Height{-FGridVInterval}+FZeroCoordinateVOffset;
  While tmpI>0 do begin
    tmpTPoint.X:=0;
    tmpTPoint.Y:=tmpI+FZeroCoordinateVOffset;
    Canvas.PenPos:=tmpTPoint;
    Canvas.LineTo(Width, tmpI+FZeroCoordinateVOffset);
    tmpI:=tmpI-FGridVInterval;
  end;
  if Assigned(FOnPaint) then FOnPaint(Self);
  //рисую графики
  tmpPGraphGridList:=FPGraphGridList;
  While Assigned(tmpPGraphGridList) do begin
    tmpGraphGridData:=TGraphGridData(tmpPGraphGridList^.GraphGridData);
    If tmpGraphGridData.DataCount>0 Then begin
      Canvas.Pen.Color:=tmpGraphGridData.ColorLine;
      Canvas.Font:=Font;
      Canvas.Font.Color:=tmpGraphGridData.ColorLine;
      tmpTPoint.X:=Width;
      tmpTPoint.Y:=Height+FZeroCoordinateVOffset;
      Canvas.PenPos:=tmpTPoint;
      tmpBeginData:=tmpGraphGridData.BeginData+tmpGraphGridData.DataCount-1;
      For tmpI:=0 to tmpGraphGridData.DataCount-1 do begin
        If tmpBeginData>tmpGraphGridData.DataMaxCount-1 Then begin
          tmpPDataDesc:=@tmpGraphGridData.Data[tmpBeginData-tmpGraphGridData.DataMaxCount];
        end else begin
          tmpPDataDesc:=@tmpGraphGridData.Data[tmpBeginData];
        end;
        tmpX:=Width-tmpI;
        tmpY:=Height-tmpPDataDesc^.Value+FZeroCoordinateVOffset;
        Canvas.LineTo(tmpX, tmpY);
        If tmpPDataDesc^.Text<>'' Then begin
          tmpTPoint:=Canvas.PenPos;
          Canvas.TextOut(tmpX, tmpY, tmpPDataDesc^.Text);
          Canvas.PenPos:=tmpTPoint;
        end;
        Dec(tmpBeginData);
      end;
    end;
    tmpPGraphGridList:=tmpPGraphGridList^.Next;
  end;
end;


{  if csDesigning in ComponentState then with Canvas do begin
    Pen.Style:=psSolid;
    Brush.Style:=bsClear;
    Rectangle(0, 0, Width, Height);
  end;}
Procedure TGraphGrid.UnregisterDataGrid(Value:TObject);
  Var tmpGraphGridList, tmpGraphGridListPrev:PGraphGridList;
begin
  tmpGraphGridListPrev:=Nil;
  tmpGraphGridList:=FPGraphGridList;
  While tmpGraphGridList<>Nil do begin  
    If Pointer(tmpGraphGridList^.GraphGridData)=Pointer(Value) Then begin
      If Assigned(tmpGraphGridListPrev) Then begin
        tmpGraphGridListPrev^.Next:=tmpGraphGridList^.Next;
        Dispose(tmpGraphGridList);
        //tmpGraphGridList:=tmpGraphGridListPrev^.Next;
        Break;
      end else begin
        FPGraphGridList:=tmpGraphGridList^.Next;
        Dispose(tmpGraphGridList);
        //tmpGraphGridList:=FPGraphGridList;
        Break;
      end;
    end;
    tmpGraphGridListPrev:=tmpGraphGridList;
    tmpGraphGridList:=tmpGraphGridList^.Next;
  end;
end;

Function TGraphGrid.InternalGetLastGraphGridListElement:PGraphGridList;
begin
  Result:=FPGraphGridList;
  If Assigned(Result) Then begin
    While Result^.Next<>Nil do begin
      Result:=Result^.Next;
    end;
  end;
end;

Procedure TGraphGrid.RegisterDataGrid(Value:TObject);
  Var tmpGraphGridList:PGraphGridList;
begin
  If Assigned(FPGraphGridList) Then begin
    tmpGraphGridList:=InternalGetLastGraphGridListElement;
    New(tmpGraphGridList^.Next);
    tmpGraphGridList:=tmpGraphGridList^.Next;
  end else begin
    New(FPGraphGridList);
    tmpGraphGridList:=FPGraphGridList;
  end;
  tmpGraphGridList^.Next:=Nil;
  tmpGraphGridList^.GraphGridData:=Value;
end;


end.
