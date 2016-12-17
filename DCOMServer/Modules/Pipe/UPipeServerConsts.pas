unit UPipeServerConsts;
interface
  uses windows;
const
  cnNamedPipeMaxCount:Cardinal=10{MAXIMUM_WAIT_OBJECTS}-1;
var
  cnPipeMultiServerCount:Integer=0;
  csPipeName:AnsiString='\\.\pipe\SQLServerToPegasServer';
implementation
end.
