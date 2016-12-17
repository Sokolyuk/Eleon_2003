//Copyright © 2000-2004 by Dmitry A. Sokolyuk

//21.05.2004
//Application script laguage

unit UASLSolveSubFunctionTypes;

interface
  uses UASLSolveStatementTypes;
type
  TSubFunctionRowResult = (sfrrOkay, sfrrBreak, sfrrContinue, sfrrReturn, sfrrThrow);

const
  tknReturn = 32;
  tknDeclare = 33;
  tknWhile = 34;
  tknBreak = 35;
  tknContinue = 36;
  tknTry = 37;
  tknFinally = 38;
  tknCatch = 39;
  tknThrow = 40;
  tknException = 41;

implementation

end.
