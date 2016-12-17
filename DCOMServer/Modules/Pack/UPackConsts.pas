//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UPackConsts;

interface

const
  // ѕараметризаци€ пакетов
  Protocols_ID=0;
  Protocols_Ver=1;
  // протоколы
  Protocols_CPT=1;  // CPT - command pack with task
    Protocols_CPT_Count_Ver1=7;
    Protocols_CPT_Count_Ver2=8;
  Protocols_CPR=2;  // CPR - command pack with result
    Protocols_CPR_Count_Ver1=8;
    Protocols_CPR_Count_Ver2=9;
  Protocols_PD=3;  // PR - place result
    Protocols_PD_Count=9;
  Protocols_Message=4;
    Protocols_Message_Count=8;
  //неподключенные протоколы
    // ..
  // протокол CPT
  Protocols_CPT_Options=2;
    Protocols_CPT_Options_ReturnParamsIfError=1;
//    Protocols_CPT_Options_NoError= 2;
  Protocols_CPT_CPID=3;
  Protocols_CPT_Tsk=4;
  Protocols_CPT_Params=5;
  Protocols_CPT_BlockID=6;      //  Protocols_CPT_PR= 7;
  Protocols_CPT_RouteParams=7;
  // протокол CPR
  Protocols_CPR_Options=2;
  Protocols_CPR_CPID=3;
  Protocols_CPR_Tsk=4;
  Protocols_CPR_Params=5;
  Protocols_CPR_BlockID=6;       //  Protocols_CPR_PR= 7;
  Protocols_CPR_Errors=7;
  Protocols_CPR_RouteParams=8;
  // протокол PD
  Protocols_PD_Options= 2;
    Protocols_PD_Options_NoTransform= 1; //(1)-во врем€ прохождени€ PD.Place не трансформаруетс€(OnUser, OnAll->OnId)
    Protocols_PD_Options_WithNotificationOfError= 2; //(1)-требуетс€ уведомление о ошибках во врем€ прохождени€ пакета;
    Protocols_PD_Options_WithNotificationOfDelivery= 4; //(1)-требуетс€ уведомление о доставке пакета по адресу
    Protocols_PD_Options_WithCheckOfPassing= 8; //(1)-есть контроль(проверка) прохождени€(извещение о прохождении пакета через узел);
    Protocols_PD_Options_NoResult=16; //(1)-не доставл€ет обратно(игнорирует) результат выполнени€(CPR)
    Protocols_PD_Options_ReturnDataIfTransportError=32; //(1)-возвращать данные в случае транспортной ошибки
    Protocols_PD_Options_NoPutOnReSending=64; //(1)-не ставить на переотправку. Ёто значит если будет транспортна€ ошибка, пакет вернетс€ с ней к отправителю.
  Protocols_PD_CurrNum=3;
  Protocols_PD_Place=4;
  Protocols_PD_PlaceData=5;
  Protocols_PD_Data=6;
  Protocols_PD_PDID=7;
  Protocols_PD_Error=8;
  // протокол Message
  Protocols_Message_Message=2;
  Protocols_Message_Subject=3;
  Protocols_Message_Priority=4;
  Protocols_Message_MsgType=5;
  Protocols_Message_Attachments=6;
  Protocols_Message_DateCreate=7;

  // ѕоротокол PD дл€ пакет с ошибками. (*кагбы UDP)
  popError:Integer=Protocols_PD_Options_NoTransform Or Protocols_PD_Options_NoResult;
  popTask:Integer=Protocols_PD_Options_WithNotificationOfError;

  csNone:AnsiString='None';
  csCPT:AnsiString='CPT';
  csCPR:AnsiString='CPR';
  csPD:AnsiString='PD';
  csMessage:AnsiString='Message';
implementation

end.
