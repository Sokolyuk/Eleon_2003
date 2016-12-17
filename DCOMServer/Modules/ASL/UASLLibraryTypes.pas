//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//25.05.2004
//Application script laguage

unit UASLLibraryTypes;

interface
  uses UASLSolveStatementTypes;

type
  TOnLibGetPropertyEvent = function(aUserData:pointer; const aCallerNamespace:AnsiString; const aCallerFunctionName:AnsiString; const aName:AnsiString; const aIndex:variant):variant of object;
  TOnLibSetPropertyEvent = procedure(aUserData:pointer; const aCallerNamespace:AnsiString; const aCallerFunctionName:AnsiString; const aName:AnsiString; const aIndex:variant; const aValue:variant) of object;
  TOnLibFunctionEvent = function(aUserData:pointer; const aFunctionName:AnsiString; var aParams:variant; aOnIsParamOut:TOnIsParamOutEvent; const aCallerNamespace:AnsiString; const aCallerFunctionName:AnsiString):variant of object;

const
  tknFunction = 42;
  tknNamespace = 43;

implementation

end.
