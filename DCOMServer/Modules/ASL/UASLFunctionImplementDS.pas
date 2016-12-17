//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UASLFunctionImplementDS;

interface
  uses UASLSolveStatementTypes;

  function ASLFunctionImplementDS(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;

implementation

function ASLFunctionImplementDS(aUserData:Pointer; const aFunctionName:String; var aParams:Variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace, aCallerFunctionName:String):Variant;
begin

end;

end.
