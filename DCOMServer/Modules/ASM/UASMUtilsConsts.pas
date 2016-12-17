unit UASMUtilsConsts;

interface

Var
  vlASMStartNum:Integer=-1;//Количество запусков ASM сервера для присоения номера ASM и для статистики.
  vlASMCanStarting:Boolean=False;//Управление ASM
  vlASMCreateTimeOut:Integer=50000{мсек};//Ожидание запуска основной формы из ASM
  vlStopListASMTimeOut:Integer=60000{мсек};//Ожидание остановки серверов ASM
  vlWiatForUnLockSendEvent:Integer=5500;{3.5 sec}//tskMTSendEvent
  vlSendEventInterval:Integer=1000;{5 sec}
  vlSendEventAttempt:Integer=7;{(5+1.5)x5, т.е. 32,5 sec}

implementation

end.
 