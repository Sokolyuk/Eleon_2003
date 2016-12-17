unit UMThreadTypesUtils;

interface
  uses UMThreadTypes;
  function MThreadStateToString(aMThreadState:TMThreadState):AnsiString;

implementation

function MThreadStateToString(aMThreadState:TMThreadState):AnsiString;
begin
  case aMThreadState of
    stsReady:result:='Ready';
    stsWait:result:='Wait';
    stsBusy:result:='Busy';
  else
    result:='Unknown';
  end;  
end;

end.
