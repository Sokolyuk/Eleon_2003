unit UASMUtilsConsts;

interface

Var
  vlASMStartNum:Integer=-1;//���������� �������� ASM ������� ��� ��������� ������ ASM � ��� ����������.
  vlASMCanStarting:Boolean=False;//���������� ASM
  vlASMCreateTimeOut:Integer=50000{����};//�������� ������� �������� ����� �� ASM
  vlStopListASMTimeOut:Integer=60000{����};//�������� ��������� �������� ASM
  vlWiatForUnLockSendEvent:Integer=5500;{3.5 sec}//tskMTSendEvent
  vlSendEventInterval:Integer=1000;{5 sec}
  vlSendEventAttempt:Integer=7;{(5+1.5)x5, �.�. 32,5 sec}

implementation

end.
 