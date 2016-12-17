//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UStrQueueTypes;

interface
  uses ULocalDataBaseTypes, UCallerTypes;
Type
  //For TStrQueue unit UStrQueue.
  TQueueId=(
           // ������� ��� ����������� ��� ������ �������. ���� ClientQueueId � Sender �� ������������.
           // ������� ������ DataStr ����� �������� � ������� ����������� VariantConverter.exe.
              { 0}qidServerStartUpMTTask, // StartUp ��� MT(���������) ������.
              { 1}qidServerStartUpPTTask, // StartUp ��� PT(ADM) ������.
           // ..
              { 2}qidRESERVED2,
              { 3}qidRESERVED3,
              { 4}qidRESERVED4,
              { 5}qidRESERVED5,
              { 6}qidRESERVED6,
              { 7}qidRESERVED7,
              { 8}qidRESERVED8,
              { 9}qidRESERVED9,
              {10}qidRePD,          // ���������� ������� PD.
              {11}qidRESERVED11,
              {12}qidRESERVED12,
              {13}qidRESERVED13,
              {14}qidRESERVED14,
              {15}qidRESERVED15,
              {16}qidRESERVED16,
              {17}qidRESERVED17,
              {18}qidRESERVED18,
              {19}qidRESERVED19,
              {20}qidClientQueue,    // ������� ���������� ������� � ����� � ������. � StrData ���������� ������ ������.
              {21}qid____________,  // �������� ������� ����������� � ��������� ����, �� ������� ������.
              {22}qidShopResultSale_,// ��������� ������� � ������� ����
              {23}qidRESERVED23,
              {24}qidRESERVED24,
              {25}qidRESERVED25,
              {26}qidRESERVED26,
              {27}qidRESERVED27,
              {28}qidRESERVED28,
              {29}qidRESERVED29
              );
  IStrQueue=interface
  ['{5DD1851D-2253-4A92-8494-528427D42420}']
    Function QueuePush(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Const aClientQueueId, aSender, aStrData, aCommentary:AnsiString; Const aSenderParams, aSecurityContext:Variant; aWakeUp:TDateTime):Integer;
    Function QueuePop(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Out aClientQueueId:AnsiString; Out aSender:AnsiString; Out aStrData:AnsiString; Out aSenderParams:Variant; Out aSecurityContext:Variant):Boolean;
    Function QueueView(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId; Out aClientQueueId:AnsiString; Out aSender:AnsiString; Out aSenderParams:Variant; Out aSecurityContext:Variant; Var aLastssInternalQueueId:Integer):AnsiString;
    Procedure ClearQueue(aLocalDataBase:ILocalDataBase);
    Procedure ClearQueueMentioned(aLocalDataBase:ILocalDataBase; aQueueId:TQueueId);
    Function ClearRePDFromQueueOfClientID(aCallerAction:ICallerAction; aLocalDataBase:ILocalDataBase; Const aClientQueueId:AnsiString; aCheckSecurity:Boolean=True):Integer;
  end;

implementation

end.
 