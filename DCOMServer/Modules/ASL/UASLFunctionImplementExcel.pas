//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UASLFunctionImplementExcel;

interface
  uses UASLSolveStatementTypes;

  function ASLFunctionImplementExcel(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;

implementation
  uses ComObj, SysUtils, UASLFunctionImplementExcelTypes, Graphics;

function ASLFunctionImplementExcel(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;
  var tmpExcel: variant;
begin
  try
    if not assigned(aUserData) then raise exception.create('aUserData not assigned.');
    tmpExcel := PASLFunctionImplementExcelRec(aUserData)^.aExcel;

    if aFunctionName = 'CREATE' then begin//params - none
      tmpExcel := CreateOleObject('Excel.Application');
      tmpExcel.Workbooks.Add;
      PASLFunctionImplementExcelRec(aUserData)^.aExcel := tmpExcel;
    end else if aFunctionName = 'RANGE.SELECT' then begin//params - (x1, y1, x2, y2)
      tmpExcel.Workbooks[1].Worksheets[1].Range[tmpExcel.Cells[aParams[0], aParams[1]], tmpExcel.Cells[aParams[2], aParams[3]]].Select;
    end else if aFunctionName = 'SELECTION.BORDERS.WEIGHT' then begin//(3)
      tmpExcel.Selection.Borders.Weight := aParams[0];
    end else if aFunctionName = 'SELECTION.VALUE' then begin//(value)
      tmpExcel.Selection.Value := aParams[0];
    end else if aFunctionName = 'VISIBLE' then begin//(true)
      tmpExcel.Visible := aParams[0];
    end else if aFunctionName = 'SELECTION.COLUMNWIDTH' then begin//(30)
      tmpExcel.Selection.ColumnWidth := aParams[0];
    end else if aFunctionName = 'SELECTION.ROWHEIGHT' then begin//(30)
      tmpExcel.Selection.RowHeight := aParams[0];
    end else if aFunctionName = 'SELECTION.WRAPTEXT' then begin//(true)
      tmpExcel.Selection.WrapText := aParams[0];
    end else if aFunctionName = 'SELECTION.INTERIOR.COLOR' then begin//(255)
      tmpExcel.Selection.Interior.Color := aParams[0];
    end else if aFunctionName = 'SELECTION.ORIENTATION' then begin//(1)
      tmpExcel.Selection.Orientation := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.NAME' then begin//('Arial')
      tmpExcel.Selection.Font.Name := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.SIZE' then begin//(14)
      tmpExcel.Selection.Font.Size := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.COLOR' then begin//(clGreen)
      tmpExcel.Selection.Font.Color := ColorToRGB(aParams[0]);
    end else if aFunctionName = 'SELECTION.FONT.BOLD' then begin//(1)
      tmpExcel.Selection.Font.Bold := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.ITALIC' then begin//(1)
      tmpExcel.Selection.Font.Italic := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.STRIKETHROUGH' then begin//(1)
      tmpExcel.Selection.Font.Strikethrough := aParams[0];
    end else if aFunctionName = 'SELECTION.FONT.UNDERLINE' then begin
      tmpExcel.Selection.Font.UnderLine := aParams[0];
    end else if aFunctionName = 'SELECTION.HORIZONTALALIGNMENT' then begin//(1)
      tmpExcel.Selection.HorizontalAlignment := aParams[0];
    end else if aFunctionName = 'SELECTION.VERTICALALIGNMENT' then begin//(1)
      tmpExcel.Selection.VerticalAlignment := aParams[0];
    end else raise exception.create('Unknown function: '''+aFunctionName+'''');

  except on e:exception do begin
    e.message := 'ASLFunctionImplementExcel: ' + e.message;
    raise;
  end;end;
end;

end.
