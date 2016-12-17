//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UASLFunctionImplementSys;

interface
  uses UASLSolveStatementTypes;

  function ASLFunctionImplementSys(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;

implementation

function ASLFunctionImplementSys(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;
begin

end;

end.
