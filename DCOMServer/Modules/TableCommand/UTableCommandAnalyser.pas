unit UTableCommandAnalyser;

interface
  Uses ULocalDataBaseTypes, DbClient, UCallerTypes;
Type
  //Event type.
  TTableCommandIsEmptyEvent=procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}) of object;
  TErrorEvent              =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aMessage:AnsiString) of object;
  TBlockReadyEvent         =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId:Integer; aDateExecute:Variant) of object;
  TCommandReadyOfBlockEvent=procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId, aSQLID:Integer; aSQL:AnsiString) of object;
  TBeforeBlockReadyEvent   =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId:Integer) of object;
  TBlockWaitEvent          =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aBlockId:Integer) of object;
  TListBlockEvent          =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aCompleteState, aBlockId:Integer; aSQLIDList, aDateCreate:Variant; aIdentifier:AnsiString) of object;
  TEndOfListBlockEvent     =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}) of object;
  TBeforeShopReadyEvent    =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop, aSQLID:Integer) of object;
  TShopReadyEvent          =procedure(aTableCommandAnalyser:Pointer{TTableCommandAnalyser}; aIDShop:Integer) of object;
  TSetMode=(smDetete, smUpdate, smLost);
  TTableCommandAnalyser=class(TObject)
  private
    FLocalDataBase:ILocalDataBase;
    FOnTableCommandIsEmpty:TTableCommandIsEmptyEvent;
    FOnError:TErrorEvent;
    FOnBlockReady:TBlockReadyEvent;
    FOnCommandReadyOfBlock:TCommandReadyOfBlockEvent;
    FOnBeforeBlockReady:TBeforeBlockReadyEvent;
    FOnBlockWait:TBlockWaitEvent;
    FOnListBlock:TListBlockEvent;
    FOnEndOfListBlock:TEndOfListBlockEvent;
    FOnBeforeShopReady:TBeforeShopReadyEvent;
    FOnShopReady:TShopReadyEvent;
    FCDS:TClientDataSet;
    FStartTime:TDateTime;
    FBlockCount:Integer; 
    Procedure InternalSetRec(aSQLId, aState, aCPID:Integer; aMode:TSetMode);
    Procedure SetCallerAction(Value:ICallerAction);
    Function GetCallerAction:ICallerAction;
  public
    constructor Create;
    destructor Destroy; override;
    Function Open:Integer; // ��������� �������
    Procedure Close;        // ��������� �������
    Procedure Exec;         // ��������� ����� ��� �������� �� �������. ���������� ������ ������ ������� �� ������� ������������ ����� ��� ������ ListBlock � TTableCommandMaster.ListBlock.
    Procedure ListBlock;    // ��� ����� ������ ���������� ��� ����� � �������, � ������ � TTableCommandMaster.ListBlock � ������� SetRecAsDelete - ������� �� ������� � �� ssTableCommand ������������ �����.
    Procedure SetRecAsDelete(aSQLId:Integer);
    Procedure SetRecAsLost(aSQLId:Integer);
    Procedure SetRecAsSend(aSQLId, aCPID:Integer);
    Procedure LDBBeginTran;
    Procedure LDBCommitTran;
    Procedure LDBRollBackTran;
    //Events
    property OnTableCommandIsEmpty:TTableCommandIsEmptyEvent read FOnTableCommandIsEmpty write FOnTableCommandIsEmpty;
    Property OnError:TErrorEvent read FOnError write FOnError;
    Property OnBlockReady:TBlockReadyEvent read FOnBlockReady write FOnBlockReady;
    Property OnCommandReadyOfBlock:TCommandReadyOfBlockEvent read FOnCommandReadyOfBlock write FOnCommandReadyOfBlock;
    Property OnBeforeBlockReady:TBeforeBlockReadyEvent read FOnBeforeBlockReady write FOnBeforeBlockReady;
    Property OnBlockWait:TBlockWaitEvent read FOnBlockWait write FOnBlockWait;
    Property OnListBlock:TListBlockEvent read FOnListBlock write FOnListBlock;
    Property OnEndOfListBlock:TEndOfListBlockEvent read FOnEndOfListBlock write FOnEndOfListBlock;
    Property OnBeforeShopReady:TBeforeShopReadyEvent read FOnBeforeShopReady write FOnBeforeShopReady;
    Property OnShopReady:TShopReadyEvent read FOnShopReady write FOnShopReady;
    Property CallerAction:ICallerAction read GetCallerAction write SetCallerAction;
    Property BlockCount:Integer read FBlockCount write FBlockCount;
  end;

implementation
  Uses SysUtils, ULocalDataBase, UTypeUtils, UAppMessageTypes, UTrayConsts, Variants, UStringUtils;

Constructor TTableCommandAnalyser.Create;
begin
  FLocalDataBase:=TLocalDataBase.Create;
  FOnTableCommandIsEmpty:=Nil;
  FOnError:=Nil;
  FOnBlockReady:=Nil;
  FOnCommandReadyOfBlock:=Nil;
  FOnBeforeBlockReady:=Nil;
  FOnBlockWait:=Nil;
  FOnListBlock:=Nil;
  FOnEndOfListBlock:=Nil;
  FOnBeforeShopReady:=Nil;
  FOnShopReady:=Nil;
  FCDS:=TClientDataSet.Create(Nil);
  FStartTime:=Now;
  FBlockCount:=150;
  Inherited Create;
end;

destructor TTableCommandAnalyser.Destroy;
begin
  FCDS.Free;
  FLocalDataBase:=Nil;
  Inherited Destroy;
end;

Procedure TTableCommandAnalyser.SetCallerAction(Value:ICallerAction);
begin
  FLocalDataBase.CallerAction:=Value;
end;

Function  TTableCommandAnalyser.GetCallerAction:ICallerAction;
begin
  Result:=FLocalDataBase.CallerAction;
end;

Function TTableCommandAnalyser.Open:Integer;
  Var tmpSt:AnsiString;
begin
  //����� �������, ������� �� �������� ����� � ��������� "������������" � "������� ��������".
  //������� ������� �����: "-1 ����������", "-2 ����������� �� ������� ������������ ������", "2 ��� ��������, �� � �������", "3 ��� ����������, �� ���������� ��������", "4 ������ ������ ����������"
  //��� ����� ����������� ����������� ������������, �� DateCreate � Identifier, � �� ���������� ����� ���������.
  //� �� �������� ���� ������ ����� � CompleteState<0, �.�. -1 ��� -2.
  If FBlockCount<1 Then begin
    tmpSt:='SELECT TOP 100 IdssTableCommand,IdShop,SQLString,BlockId,NumInBlock,DateCreate,DateSend,DateExecute,Identifier,CompleteState FROM ssTableCommand WITH(NOLOCK) WHERE';
    tmpSt:=tmpSt+' (CompleteState<0)AND((DateSend<{fn NOW()})OR(DateSend is NULL)) ORDER BY IdShop,BlockId,NumInBlock';
  end Else begin
    tmpSt:='SELECT TOP '+IntToStr(FBlockCount)+' IdssTableCommand,IdShop,SQLString,BlockId,NumInBlock,DateCreate,DateSend,DateExecute,Identifier,CompleteState FROM ssTableCommand WITH(NOLOCK) ';
    tmpSt:=tmpSt+'WHERE (CompleteState<0)AND((DateSend<{fn NOW()})OR(DateSend is NULL)) ORDER BY IdShop,BlockId,NumInBlock';
  end;
  FCDS.Data:=FLocalDataBase.OpenSQL(tmpSt);
  Result:=FCDS.RecordCount;
  If Result>0 Then CallerAction.ITMessAdd(Now, Now, 'TTableCommandAnalyser', 'Open: RA='+IntToStr(Result)+'.', mecDebug, mesInformation);
end;

Procedure TTableCommandAnalyser.Close;
begin
  FCDS.Active:=False;
end;

type
  TCompTime=record
    Case Word of
      0:(ofComp:Comp);     {8 byte}
      1:(ofInt64:Int64);   {8 byte}
      2:(ofLongWordLow:LongWord; ofLongWordHigh:LongWord); {4+4 byte}
      3:(ofIntLow:Integer; ofIntHigh:Integer);             {4+4 byte}
  end;

procedure TTableCommandAnalyser.Exec;
  Var tmpIDShop, tmpBlockId, tmpSQLID:Integer;
      tmpV:Variant;
      tmpDateSend:TCompTime;
      tmpSQLString:AnsiString;
      tmpOverWind:Integer;// �� ������������
begin
//��������� ����� ��� �������� �� �������. ���������� ������ ������ ������� �� �������
//  ������������ ����� ��� ������ ListBlock � TTableCommandMaster.ListBlock.
  Try
    If Not FCDS.Active Then Raise Exception.Create('LocalDataBase is closed.');
    FCDS.First;
    If FCDS.RecordCount>0 Then begin
      // ���� �������
      While FCDS.Eof=false do begin
        tmpIDShop:=FCDS.FieldByName('IdShop').AsInteger;
{Evn}   If Assigned(FOnBeforeShopReady) Then FOnBeforeShopReady(Self, tmpIDShop, FCDS.FieldByName('IdssTableCommand').AsInteger);
        Try
          While (FCDS.Eof=false) And (tmpIDShop=FCDS.FieldByName('IdShop').AsInteger) do begin
            // �������� ����� �� ����� ����������
            tmpBlockId  :=FCDS.FieldByName('BlockId').AsInteger;
            tmpV:=FCDS.FieldByName('DateSend').AsVariant;
            If (VarIsEmpty(tmpV)=True) Or (VarIsNull(tmpV)=True) Then begin
              // ���� �������� �� �������, �.�. ��������� ����������
            end else begin
              // ���� ����������� �������
              tmpDateSend.ofComp:=TimeStampToMSecs(DateTimeToTimeStamp(VarToDateTime(tmpV)));
              If TimeStampToMSecs(DateTimeToTimeStamp(Now))>=tmpDateSend.ofComp Then begin
                //������ ����� ����������
              end else begin
                //����� ���������� �� ���������, �.�. ��������� ����
                //��������� ����
                While (FCDS.Eof=false) And (FCDS.FieldByName('IdShop').AsInteger=tmpIDShop) And (FCDS.FieldByName('BlockId').AsInteger=tmpBlockId) do begin
                  FCDS.Next;
                  If tmpBlockId=-1 then break;
                end;
{Evn}           If Assigned(FOnBlockWait) Then FOnBlockWait(Self, tmpIDShop, tmpBlockId);
                Continue; //�������� ��������� ���� � ������
              end;
            end;
            tmpV:=FCDS.FieldByName('DateExecute').AsVariant;
{Evn}       If Assigned(FOnBeforeBlockReady) Then FOnBeforeBlockReady(self, tmpIDShop, tmpBlockId);
            tmpOverWind:=0; // �� ������������
            While (FCDS.Eof=false) And (FCDS.FieldByName('IdShop').AsInteger=tmpIDShop) And (FCDS.FieldByName('BlockId').AsInteger=tmpBlockId) do begin
              // ���� ��������� ������ �������� �����
              tmpSQLString:=FCDS.FieldByName('SQLString').AsString;
              // ������ ��� ���������� ��� �������� �����
              tmpSQLID:=FCDS.FieldByName('IdssTableCommand').AsInteger;
{Evn}         If Assigned(FOnCommandReadyOfBlock) Then FOnCommandReadyOfBlock(Self, tmpIDShop, tmpBlockId, tmpSQLID, tmpSQLString);
              // ��������! � ������� ssTableCommand �������� ���� IdssTableCommand ������ ���� ����������.
              // � ��������� ������ ����� ������������.
              If (tmpSQLID=FCDS.FieldByName('IdssTableCommand').AsInteger)Or(FCDS.Eof)Or(FCDS.RecordCount=0) Then begin
                FCDS.Next;
                tmpOverWind:=0;// �� ������������
              end else begin
                // �� ������������
                If tmpOverWind>10000 Then Raise Exception.Create('������������. � ������� ssTableCommand �������� ���� IdssTableCommand ������ ���� ����������(tmpOverWind>10000). ���������� � ������������.');
                Inc(tmpOverWind);
              end;
              If tmpBlockId=-1 Then Break;
            end;
{Evn}       If Assigned(FOnBlockReady) Then FOnBlockReady(Self, tmpIDShop, tmpBlockId, tmpV{DateExecute});
          end;
        Except
          On E:Exception Do Begin
            Raise Exception.Create(E.Message+'(IDShop='+IntToStr(tmpIDShop)+').');
          End;
        End;
{Evn}   If Assigned(FOnShopReady) Then FOnShopReady(Self, tmpIDShop);
      End;
    end else begin
      // ��� ������
{Evn} If Assigned(FOnTableCommandIsEmpty) Then FOnTableCommandIsEmpty(Self);
    end;
  Except
    On E:Exception Do Begin
{Evn} If Assigned(FOnError) Then FOnError(Self, 'TTableCommandAnalyser.Exec: '+E.Message) else
        Raise Exception.Create('TTableCommandAnalyser.Exec: '+E.Message);
    End;
  End;
End;

Procedure   TTableCommandAnalyser.ListBlock;
  Var tmpIDShop, tmpBlockId, tmpCompleteState:Integer;
      tmpVDateCreate, tmpSQLIDList:Variant;
      tmpIdentifier:AnsiString;
      ivHB:Integer;
begin
// ��� ����� ������ ���������� ��� ����� � �������, � ������ � TTableCommandMaster.ListBlock
//  � ������� SetRecAsDelete - ������� �� ������� � �� ssTableCommand ������������ �����.
  try
    If Not FCDS.Active Then Raise Exception.Create('LocalDataBase is closed.');
    ivHB:=-1; // �� ���������
    FCDS.First;
    If FCDS.RecordCount>0 Then begin
      // ���� �������
      While FCDS.Eof=false do begin
        tmpIDShop:=FCDS.FieldByName('IdShop').AsInteger;
        Try
          While (FCDS.Eof=false) And (tmpIDShop=FCDS.FieldByName('IdShop').AsInteger) do begin
            // ������ ����
            // ���� ���������� � ���
            tmpBlockId  :=FCDS.FieldByName('BlockId').AsInteger;
            tmpIdentifier:=UpperCase(FCDS.FieldByName('Identifier').AsString);
            tmpCompleteState:=FCDS.FieldByName('CompleteState').AsInteger;
            tmpVDateCreate:=FCDS.FieldByName('DateCreate').AsVariant;
            tmpSQLIDList:=Unassigned;
            // ������ tmpSQLIDList(������ ID, ������� ���������� ���� ����)
            While (FCDS.Eof=false) And (FCDS.FieldByName('IdShop').AsInteger=tmpIDShop) And (FCDS.FieldByName('BlockId').AsInteger=tmpBlockId) do begin
              // ������ ��� ���������� ��� �������� �����
              if VarIsEmpty(tmpSQLIDList) then begin
                tmpSQLIDList:=VarArrayCreate([0,0], varInteger);
                ivHB:=0;
              end else begin
                VarArrayRedim(tmpSQLIDList, ivHB+1);
                Inc(ivHB);
              end;
              tmpSQLIDList[ivHB]:=Integer(FCDS.FieldByName('IdssTableCommand').AsInteger);
              FCDS.Next;
              If tmpBlockId=-1 Then Break;
            end;
            // ������ ������ ������ ID(tmpSQLIDList) �� ������ ����� � ��������
{Evn}       If Assigned(FOnListBlock) Then FOnListBlock(Self, tmpIDShop, tmpCompleteState, tmpBlockId, tmpSQLIDList, tmpVDateCreate, tmpIdentifier);
          end;
{Evn}       If Assigned(FOnEndOfListBlock) Then FOnEndOfListBlock(Self);
        Except
          On E:Exception Do Begin
            Raise Exception.Create(E.Message+'(IDShop='+IntToStr(tmpIDShop)+').');
          End;
        End;
      End;
    end else begin
      // ��� ������
{Evn} If Assigned(FOnTableCommandIsEmpty) Then FOnTableCommandIsEmpty(Self);
    end;
  Except
    On E:Exception Do Begin
{Evn} If Assigned(FOnError) Then FOnError(Self, 'TTableCommandAnalyser.ListBlock: '+E.Message) else
        Raise Exception.Create('TTableCommandAnalyser.ListBlock: '+E.Message);
    End;
  End;
end;

Procedure   TTableCommandAnalyser.InternalSetRec(aSQLId, aState, aCPID:Integer; aMode:TSetMode);
  Var tmpOldSQLId:Integer;
      tmpEOF:Boolean;
begin
  // ��������� �������� � ���������� �������.
  If Not FCDS.Active Then Raise Exception.Create('LocalDataBase is closed.');
  If FCDS.RecordCount>0 Then begin
    // �������� ������ �������
    tmpEOF:=FCDS.Eof;
    tmpOldSQLID:=FCDS.FieldByName('IdssTableCommand').AsInteger;
    // ��� ��������� ������
    FCDS.First;
    try
      While True Do begin
        If FCDS.Eof then begin
          Raise Exception.Create('SQLId='+IntToStr(aSQLId)+' �� ������ � �������.');
        end;
        If FCDS.FieldByName('IdssTableCommand').AsInteger=aSQLID Then begin
          Case aMode of
            smDetete:begin
              If FLocalDataBase.ExecSQL('DELETE FROM ssTableCommand WHERE IdssTableCommand='+IntToStr(aSQLID))<0 then begin
                FLocalDataBase.ExecSQL('Insert into ssTableCommandlog (LogMessage, aSQL)VALUES(''RecAff=0'', '''+
                  StrToSQL('DELETE FROM ssTableCommand WHERE IdssTableCommand='+IntToStr(aSQLID))
                  +''')');
                  try
                    CallerAction.ITMessAdd(Now, FStartTime, 'TTableCommandAnalyser', 'InternalSetRec: smDetete: RecAff=0 ��� IdssTableCommand='+IntToStr(aSQLID), mecApp, mesError);
                  except end;
              end;
            end;
            smUpdate:begin
              if FLocalDataBase.ExecSQL('UPDATE ssTableCommand SET CompleteState='+IntToStr(aState)+', CPID='+IntToStr(aCPID)+' WHERE IdssTableCommand='+IntToStr(aSQLID))<0 then begin
                FLocalDataBase.ExecSQL('Insert into ssTableCommandlog (LogMessage, aSQL)VALUES(''RecAff=0'', '''+
                  StrToSQL('UPDATE ssTableCommand SET CompleteState='+IntToStr(aState)+', CPID='+IntToStr(aCPID)+' WHERE IdssTableCommand='+IntToStr(aSQLID))
                  +''')');
                  try
                    CallerAction.ITMessAdd(Now, FStartTime, 'TTableCommandAnalyser', 'InternalSetRec: smUpdate: RecAff=0 ��� IdssTableCommand='+IntToStr(aSQLID), mecApp, mesError);
                  except end;
              end;
            end;
            smLost:begin
              try
                CallerAction.ITMessAdd(Now, FStartTime, 'TTableCommandAnalyser', 'InternalSetRec: smLost: IdssTableCommand='+IntToStr(aSQLID), mecApp, mesInformation);
              except end;
            end;
          end;
          FCDS.Edit;
          FCDS.Delete;
          Break;
        end;
        FCDS.Next;
      end;
    finally
      // ������������ �� ������� �����                                  
      If aSQLId=tmpOldSQLID then begin
        // ������
      end else begin
        // ��� ������� ������
        FCDS.First;
        While True do begin
          If FCDS.Eof then begin
            Raise Exception.Create('���������� ����. tmpOldSQLID='+IntToStr(tmpOldSQLID)+' �� ������ � �������.');
          end;
          If FCDS.FieldByName('IdssTableCommand').AsInteger=tmpOldSQLID then break;
          FCDS.Next;
        end;
      end;
      // �������������� Eof.
      If tmpEOF Then begin
        If FCDS.RecordCount<>0 then begin
          If FCDS.RecNo<>FCDS.RecordCount Then begin
            Raise Exception.Create('���������� ����. �� ������� ������������ FCDS.Eof.');
          end else begin
            FCDS.Next;
          end;
        end;
      end;
    end;
  end;
end;

Procedure   TTableCommandAnalyser.SetRecAsDelete(aSQLId:Integer);
begin
  InternalSetRec(aSQLId, -1{Unused}, -1{Unused}, smDetete);
end;

Procedure   TTableCommandAnalyser.SetRecAsLost(aSQLId:Integer);
begin
  InternalSetRec(aSQLId, -1{Unused}, -1{Unused}, smLost);
end;

Procedure   TTableCommandAnalyser.SetRecAsSend(aSQLId, aCPID:Integer);
begin
  InternalSetRec(aSQLId, 0, aCPID, smUpdate);
end;

Procedure   TTableCommandAnalyser.LDBBeginTran;
begin
  FLocalDataBase.ExecSQL('BEGIN TRANSACTION');
end;

Procedure   TTableCommandAnalyser.LDBCommitTran;
begin
  FLocalDataBase.ExecSQL('COMMIT TRANSACTION');
end;

Procedure   TTableCommandAnalyser.LDBRollBackTran;
begin
  FLocalDataBase.ExecSQL('ROLLBACK TRANSACTION');
end;

end.
