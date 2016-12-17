//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UNodeNameTypes;

interface
type
  TNodeToken=(nntNone, nntName, nntValue{, nntNodeDelimiter, nntValueDelimiter});
  TNodeDelimiter=Set of Char;

implementation

end.
