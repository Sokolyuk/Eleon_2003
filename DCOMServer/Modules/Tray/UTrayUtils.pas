unit UTrayUtils;

interface
  uses UTrayInterfaceTypes;
  procedure SetExceptStateAsTray(aStateAsTray:TStateAsTray);
  function StateAsTrayToStr(aStateAsTray:TStateAsTray):AnsiString;

implementation
  uses Sysutils;

function StateAsTrayToStr(aStateAsTray:TStateAsTray):AnsiString;
begin
  case aStateAsTray of
    tpsNone:result:='None';
    tpsInit:result:='Init';
    tpsWork:result:='Work';
    tpsPendingInit:result:='PendingInit';
    tpsPendingStart:result:='PendingStart';
    tpsPendingStop:result:='PendingStop';
    tpsPendingFinal:result:='PendingFinal';
  else
    result:='Unknown';
  end;
end;

procedure SetExceptStateAsTray(aStateAsTray:TStateAsTray);
begin
  Raise Exception.Create('StateAsTray is '+StateAsTrayToStr(aStateAsTray));
end;

end.
