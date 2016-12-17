//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit USolveStatementTypes;

interface
type
  TOnPropertyEvent = function(const aName:AnsiString):variant of object;
  TOnFunctionEvent = function(const aName:AnsiString; const aParams:variant):variant of object;
  TOnPropertyRegularEvent = function(aUserDataRegular:pointer; const aName:AnsiString):variant;
  TOnFunctionRegularEvent = function(aUserDataRegular:pointer; const aName:AnsiString; const aParams:variant):variant;

  TOnGetValue = record
    aOnProperty:TOnPropertyEvent;
    aOnFunction:TOnFunctionEvent;
    aUserDataRegular:pointer;
    aOnPropertyRegular:TOnPropertyRegularEvent;
    aOnFunctionRegular:TOnFunctionRegularEvent;
  end;

implementation

end.

