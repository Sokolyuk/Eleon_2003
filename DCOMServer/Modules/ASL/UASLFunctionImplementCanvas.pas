//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UASLFunctionImplementCanvas;

interface
  uses UASLSolveStatementTypes;

  function ASLFunctionImplementCanvas(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;

implementation

function ASLFunctionImplementCanvas(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;
begin

end;

end.
