unit UDataCase;

interface
  Uses UITObject, UDataCaseTypes, UDataCaseImplementTypes, UTaskStorageTypes, UCallerTypes, UVarsetTypes;

Type
  TDataCase=class(TITObject, IDataCase)
  private
    FDataCaseImplement:IDataCaseImplement;
    FDataCaseStarted:Boolean;
    FOwnerCallerAction:ICallerAction;
  protected
    Function IT_GetITaskStorage:ITaskStorage;
    Function IT_GetITaskThreads:IVarset;
    Function IT_GetOwnerCallerAction:ICallerAction;
    procedure IT_SetOwnerCallerAction(Value:ICallerAction);
  public
    constructor Create;
    destructor Destroy; override;
    {..}
    Procedure ITResumeTaskThreads;
    Procedure ITDataCaseStop;
    Procedure ITDataCaseStart;
    Property ITITaskStorage:ITaskStorage read IT_GetITaskStorage;
    Property ITITaskThreads:IVarset read IT_GetITaskThreads;
    Property ITOwnerCallerAction:ICallerAction read IT_GetOwnerCallerAction write IT_SetOwnerCallerAction;
  end;

implementation
  Uses UObjectsTypes, UDataCaseImplement, UTaskImplement, UTaskStorage, UDataCaseConsts, UVarset,
       Sysutils, UTaskThreadTypes, UTaskTypes;

constructor TDataCase.Create;
begin
  //ObjectType:=otTDataCase;
  Inherited Create;
  FDataCaseStarted:=False;
end;

destructor TDataCase.Destroy;
begin
  Try
    ITDataCaseStop;
  Except end;
  FOwnerCallerAction:=Nil;
  Inherited Destroy;
end;

Function TDataCase.IT_GetOwnerCallerAction:ICallerAction;
begin
  InternalLock;
  Try
    Result:=FOwnerCallerAction;
  finally
    InternalUnlock;
  end;
end;

procedure TDataCase.IT_SetOwnerCallerAction(Value:ICallerAction);
begin
  InternalLock;
  Try
    FOwnerCallerAction:=Value;
  finally
    InternalUnlock;
  end;
end;

Procedure TDataCase.ITDataCaseStart;
  Var tmpITaskStorage:ITaskStorage;
      tmpIVarset:IVarset;
      tmpI:Integer;
      tmpITaskThread:ITaskThread;
      tmpNoSuspendPerpetualCount:Cardinal;
begin
  InternalLock;
  Try
    If FDataCaseStarted Then exit;
    Try
      //Создаю DataCaseImplement
      FDataCaseImplement:=TDataCaseImplement.Create;
      FDataCaseImplement.ITOwnerCallerAction:=FOwnerCallerAction;
      //Создаю TaskImplement
      FDataCaseImplement.ITITaskImplement:=TTaskImplement.Create;
      //Создаю TaskStorage
      tmpITaskStorage:=TTaskStorage.Create;
      tmpITaskStorage.ITMaxTaskCount:=vlMaxTaskNum;
      tmpITaskStorage.ITMaxSuspendTaskCount:=vlMaxSleepTaskNum;
      tmpITaskStorage.ITOnTaskPush:=FDataCaseImplement.ITIOnTaskStorageTaskPush;
      FDataCaseImplement.ITITaskStorage:=tmpITaskStorage;
      tmpITaskStorage:=Nil;
      //Создаю TaskThreads
      tmpIVarset:=TVarset.Create;
      tmpIVarset.ITConfigCaseSensitive:=False;
      tmpIVarset.ITConfigNoFoundException:=True;
      tmpIVarset.ITConfigCheckUniqueStrIndex:=False;
      tmpIVarset.ITConfigCheckUniqueIntIndex:=False;
      tmpIVarset.ITConfigIntIndexAssignable:=False;
      FDataCaseImplement.ITITaskThreads:=tmpIVarset;
      If cnNoSuspendPerpetualCount>0 Then tmpNoSuspendPerpetualCount:=cnNoSuspendPerpetualCount else tmpNoSuspendPerpetualCount:=0;
      For tmpI:=0 to cnTaskThreadMinCount-1 do begin
        tmpITaskThread:=FDataCaseImplement.ITCreateTaskThread;
        If tmpNoSuspendPerpetualCount>0 then begin
          tmpITaskThread.ITNoSuspend:=True;
          Dec(tmpNoSuspendPerpetualCount);
        end;
        FDataCaseImplement.ITPushTaskThread(tmpITaskThread, True);
      end;
      ITResumeTaskThreads;
    Except
      try
        tmpITaskStorage:=Nil;
        tmpIVarset:=Nil;
      except end;
      try ITDataCaseStop; except end;
      FDataCaseStarted:=False;
      Raise;
    End;
    //Ставлю что создан
    FDataCaseStarted:=True;
  finally
    InternalUnlock;
  end;
end;

Procedure TDataCase.ITDataCaseStop;
  Var tmpTaskThreads:IVarset;
      tmpIUnknown:IUnknown;
      tmpITaskStorage:ITaskStorage;
begin
  InternalLock;
  Try
    //If Not FDataCaseStarted Then Exit;
    If Not Assigned(FDataCaseImplement) Then Raise Exception.Create('DataCaseImplement is not assigned.');
    //Разбираю TaskThreads
    tmpTaskThreads:=FDataCaseImplement.ITITaskThreads;
    If Assigned(tmpTaskThreads) Then begin
      While tmpTaskThreads.ITCount>0 Do begin
        tmpIUnknown:=tmpTaskThreads.ITPopV;
        FDataCaseImplement.ITDestroyTaskThread(ITaskThread(tmpIUnknown));
      end;
      tmpIUnknown:=Nil;
      tmpTaskThreads:=Nil;
      FDataCaseImplement.ITITaskThreads:=Nil;
    end;
    //Разбираю TaskImplement
    FDataCaseImplement.ITITaskImplement:=Nil;
    //Разбираю TaskStorage
    tmpITaskStorage:=FDataCaseImplement.ITITaskStorage;
    If Assigned(tmpITaskStorage) Then begin
      tmpITaskStorage.ITOnTaskPush:=Nil;
      tmpITaskStorage:=Nil;
      FDataCaseImplement.ITITaskStorage:=Nil;
    end;
    //Разбираю OwnerCallerAction
    FDataCaseImplement.ITOwnerCallerAction:=Nil;
    //Разбираю DataCaseImplement
    FDataCaseImplement:=Nil;
  Finally
    InternalUnlock;
  End;
end;

Function TDataCase.IT_GetITaskStorage:ITaskStorage;
  Var tmpIDataCaseImplement:IDataCaseImplement;
begin
  tmpIDataCaseImplement:=FDataCaseImplement;
  If Not Assigned(tmpIDataCaseImplement) Then Raise Exception.Create('DataCaseImplement is not assigned.');
  Result:=tmpIDataCaseImplement.ITITaskStorage;
  tmpIDataCaseImplement:=Nil;
  //If Not Assigned(Result) Then Raise Exception.Create('TaskStorage is not assigned.');
end;

Function TDataCase.IT_GetITaskThreads:IVarset;
  Var tmpIDataCaseImplement:IDataCaseImplement;
begin
  tmpIDataCaseImplement:=FDataCaseImplement;
  If Not Assigned(tmpIDataCaseImplement) Then Raise Exception.Create('DataCaseImplement is not assigned.');
  Result:=tmpIDataCaseImplement.ITITaskThreads;
  tmpIDataCaseImplement:=Nil;
  //If Not Assigned(Result) Then Raise Exception.Create('TaskThreads is not assigned.');
end;

Procedure TDataCase.ITResumeTaskThreads;
  Var tmpIDataCaseImplement:IDataCaseImplement;
      tmpIntIndex:Integer;
      tmpITaskThreads:IVarset;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
begin
  tmpIDataCaseImplement:=FDataCaseImplement;
  If Not Assigned(tmpIDataCaseImplement) Then Raise Exception.Create('DataCaseImplement is not assigned.');
  tmpITaskThreads:=tmpIDataCaseImplement.ITITaskThreads;
  If Not Assigned(tmpITaskThreads) Then Raise Exception.Create('TaskThreads is not assigned.');
  tmpIntIndex:=-1;
  While True do begin
    tmpIVarsetDataView:=tmpITaskThreads.ITViewNextGetOfIntIndex(tmpIntIndex);
    If tmpIntIndex=-1 Then break;
    tmpIUnknown:=tmpIVarsetDataView.ITData;
    ITaskThread(tmpIUnknown).ITResume;
    tmpIUnknown:=Nil;
    tmpIVarsetDataView:=Nil;
  end;
  tmpIDataCaseImplement:=Nil;
  tmpITaskThreads:=Nil;
end;

end.
