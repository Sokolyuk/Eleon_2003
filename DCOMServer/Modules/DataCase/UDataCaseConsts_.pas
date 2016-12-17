unit UDataCaseConsts;
устарел. см. UTray
interface
  Uses UDataCaseTypes;

Var
  GL_DataCase:IBasicDataCase=Nil;
  glDataCase:IDataCase=Nil;

Const
  vlMaxTaskNum        :Integer = 300{750}{1500};
  vlMaxSleepTaskNum   :Integer = 7000{750}{1500};
  vlMateAddTaskNum    :Integer = 1{5};
  vlMaxMateAmountOfInactivity:Integer=55000; {ms} // сколько мили сек может быть неактивным slave
  GL_vlMateMinCount   :Integer = 3;
  GL_vlMateMaxCount   :Integer = 250;
  // константы для задания номера в списке результотов
  rstSTQueueNumNone   :Integer = -1;
  cnInactivity:Cardinal=45000{45sec};
  cnTaskThreadMinCount:Word=3;
  cnNoSuspendPerpetualCount:Word=1;
  cnTaskThreadMaxCount:Word=250{150};
  cnMaxTaskCountInTaskStorage:Word=1{5};
implementation

Initialization
Finalization
  GL_DataCase:=Nil;
  glDataCase:=Nil;
end.
