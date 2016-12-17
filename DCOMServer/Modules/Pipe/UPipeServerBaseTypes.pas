unit UPipeServerBaseTypes;

interface
type
  INamedPipe=interface
  ['{D3B403B4-68B5-4C28-B736-BC3DD2EF27C1}']
    function GetPipe:THandle;
    function GetEventWait:THandle;
    property Pipe:THandle read GetPipe;
    property EventWait:THandle read GetEventWait;
  end;

implementation

end.
