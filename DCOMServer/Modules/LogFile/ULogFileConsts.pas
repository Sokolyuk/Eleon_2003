unit ULogFileConsts;

interface
  Uses ULogFileTypes;

Var
  cnLogFile:ILogFile=Nil;

Implementation

Initialization
Finalization
  Try
    cnLogFile:=Nil;
  Except end;
end.
