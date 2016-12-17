//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UASLFunctionImplement;

interface
  uses UASLSolveStatementTypes;

  function ASLFunctionImplement(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;

implementation
  uses SysUtils, UASLLibraryUtils, UASLFunctionImplementSys, UASLFunctionImplementDS, UASLFunctionImplementCanvas,
       UASLFunctionImplementExcel;

function ASLFunctionImplement(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;
  var tmpNamespace: AnsiString;
      tmpSubFunctionName: AnsiString;
begin
  SubNameToNameSpace(AnsiUpperCase(aFunctionName), tmpNamespace, tmpSubFunctionName);

  if (tmpNamespace = '') or (tmpNamespace = 'SYS') then begin
    result := ASLFunctionImplementSys(aUserData, tmpSubFunctionName, aParams, aOnIsParamOut, aCallerNamespace, aCallerFunctionName);
  end else if tmpNamespace = 'DS' then begin
    result := ASLFunctionImplementDS(aUserData, tmpSubFunctionName, aParams, aOnIsParamOut, aCallerNamespace, aCallerFunctionName);
  end else if tmpNamespace = 'CANVAS' then begin
    result := ASLFunctionImplementCanvas(aUserData, tmpSubFunctionName, aParams, aOnIsParamOut, aCallerNamespace, aCallerFunctionName);
  end else if tmpNamespace = 'EXCEL' then begin
    result := ASLFunctionImplementExcel(aUserData, tmpSubFunctionName, aParams, aOnIsParamOut, aCallerNamespace, aCallerFunctionName);
  end else begin
    raise Exception.create('Unknown SubFunction ''' + aFunctionName + '''');
  end;
end;

end.
