//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTrayConsts;

interface
  uses UTrayTypes;
  var cnTray:ITray=nil;
      cnTrayCount:Integer=0;

//Можно стереть, только для просмотра ADOC count.
var cnADOCCoutCurrent:integer = 0;
    cnADOCCoutMax:integer = 0;

implementation
initialization
finalization
  cnTray:=nil;//Внимание! Возможна следующая проблема: Если в tray положить TClientDataSet, и открыть в нем курсор
              //то в этом месте будет ошибка по память, т.к. finalization в каком то модуле(Db, DBClient), уже прошел.
              //Решения: 1)делать cnTray:=nil; до end. 2)делать FCDS.active:=false в ITrayInterface.Final;.
end.
