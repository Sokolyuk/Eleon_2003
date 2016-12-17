unit UMThreadUtils;

interface
  function MThreadBreak(aRaise:boolean=true):boolean;
  function MThreadObject(aRaise:boolean=true):TObject;
  
implementation
  uses UMThreadConsts, windows, Sysutils;

function MThreadBreak(aRaise:boolean=true):boolean;
{$ifdef ver130}
  type PBoolean=^Boolean;
{$endif}
  var tmpPBoolean:PBoolean;
      tmpLastError:Integer;
begin
  result:=false;
  if cnTlsThreadBreak=cnTlsNoIndex then exit;
  tmpPBoolean:=TlsGetValue(cnTlsThreadBreak);
  if assigned(tmpPBoolean) then result:=tmpPBoolean^ else begin
    tmpLastError:=GetLastError;
    if aRaise and(tmpLastError<>0) then Raise Exception.Create('MThreadBreak: TlsGetValue: '+SysErrorMessage(tmpLastError));
  end;
end;

function MThreadObject(aRaise:boolean=true):TObject;
  var tmpLastError:Integer;
begin
  try
    if cnTlsMThreadObject=cnTlsNoIndex then begin
      if aRaise then raise exception.create('cnTlsMThreadObject=cnTlsNoIndex.');
      result:=nil;
      exit;
    end;
    result:=TlsGetValue(cnTlsMThreadObject);
    if not assigned(result) then begin
      if aRaise then begin
        tmpLastError:=GetLastError;
        if tmpLastError<>0 then raise exception.create('TlsGetValue: '+SysErrorMessage(tmpLastError)) else raise exception.create('Not assigned.');
      end;
    end;
  except on e:exception do begin
    e.message:='MThreadObject: '+e.message;
    raise;
  end;end;  
end;

end.
