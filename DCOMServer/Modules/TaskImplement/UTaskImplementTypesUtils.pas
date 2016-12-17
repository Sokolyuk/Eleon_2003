//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementTypesUtils;

interface
  uses UTaskImplementTypes;
  function EndTaskEventToVariant(aEndTaskEvent:PEndTaskEvent):Variant;
  procedure VariantToEndTaskEvent(const aVariant:Variant; aEndTaskEvent:PEndTaskEvent);

implementation
  {$IFNDEF VER130}uses Variants;{$ENDIF}
type
  PlocalEndTaskEvent=^TlocalEndTaskEvent;
  TlocalEndTaskEvent=record
    aOnComplete:integer;
    aOnError:integer;
    aOnCanceled:integer;
  end;

function EndTaskEventToVariant(aEndTaskEvent:PEndTaskEvent):Variant;
begin
  if assigned(aEndTaskEvent) then begin
    result:=VarArrayCreate([0, 2], varInteger);
    result[0]:=PlocalEndTaskEvent(aEndTaskEvent)^.aOnComplete;
    result[1]:=PlocalEndTaskEvent(aEndTaskEvent)^.aOnError;
    result[2]:=PlocalEndTaskEvent(aEndTaskEvent)^.aOnCanceled;
  end else result:=unassigned;
end;

procedure VariantToEndTaskEvent(const aVariant:Variant; aEndTaskEvent:PEndTaskEvent);
begin
  if assigned(aEndTaskEvent) then begin
    if VarIsArray(aVariant) then begin
      PlocalEndTaskEvent(aEndTaskEvent)^.aOnComplete:=aVariant[0];
      PlocalEndTaskEvent(aEndTaskEvent)^.aOnError:=aVariant[1];
      PlocalEndTaskEvent(aEndTaskEvent)^.aOnCanceled:=aVariant[2];
    end else begin
      aEndTaskEvent^.aOnComplete:=nil;
      aEndTaskEvent^.aOnError:=nil;
      aEndTaskEvent^.aOnCanceled:=nil;
    end;
    //result:=(assigned(aEndTaskEvent^.aOnComplete))or(assigned(aEndTaskEvent^.aOnError))or(assigned(aEndTaskEvent^.aOnCanceled));
  end{ else result:=false};
end;

end.
