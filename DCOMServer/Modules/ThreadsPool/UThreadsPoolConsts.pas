unit UThreadsPoolConsts;

interface
const
  cnMaxTaskNum:Integer=1500;
  cnMaxSleepTaskNum:Integer=5000;
  cnMMinCount:Integer=1;
  cnMMaxCount:Integer=250;
  cnMaxMAmountOfInactivity:Integer=240000{4min}{90000};//сколько мили сек может быть неактивным slave
implementation

end.
 