//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//24.05.2004

unit UTokenParserTypes;

interface

type
  TPIdToken = ^TIdToken;
  TIdToken = integer;

const
  tknString = 0;
  tknNumber = 1;
  tknFloat = 2;
  tknWord = 3;

implementation

end.
