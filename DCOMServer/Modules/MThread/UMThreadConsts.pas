unit UMThreadConsts;

interface
const
  cnTlsNoIndex=$FFFFFFFF{def неправильный index};
var
  cnTlsThreadBreak:Cardinal=cnTlsNoIndex;
  cnTlsMThreadObject:Cardinal=cnTlsNoIndex;
  cnMThreadCount:Integer=0;
  cnMThreadCreatedCount:Integer=0;

implementation

end.
