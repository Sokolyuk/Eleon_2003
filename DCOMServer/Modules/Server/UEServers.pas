unit UEServers;

interface
  Uses UTrayInterfaceBase, UEServersListTypes, Registry, Classes, UEServersTypes, UEServerInfoTypes;
Type
  TEServers=class(TTrayInterfaceBase, IEServers)
  private
    FEServersList:IEServersList;
    FReg:TRegistry;
    FStringList:TStringList;
  protected
    Procedure InternalCheck;
    Procedure InternalSetServerInfo(aEServerInfo:IEServerInfo);
    Function IT_GetEServersList:IEServersList;
  public
    constructor Create;
    destructor Destroy; override;
    Procedure ITCheck;
    Property ITEServersList:IEServersList Read IT_GetEServersList;
  end;

implementation
  Uses Variants, SysUtils, Windows, UTypes, UProjectUtils, UEServersList, UVarsetTypes, UEServerInfo{,
       UProcessesList, UProcessesListTypes};

constructor TEServers.Create;
Begin
  FEServersList:=TEServersList.Create;
  Inherited Create;
  FReg:=TRegistry.Create(KEY_READ);
  FReg.RootKey:=HKEY_LOCAL_MACHINE;
  FStringList:=TStringList.Create;
End;

destructor TEServers.Destroy;
Begin
  FEServersList:=Nil;
  FreeAndNil(FReg);
  FreeAndNil(FStringList);
  Inherited Destroy;
End;

Function TEServers.IT_GetEServersList:IEServersList;
begin
  InternalLock;
  try
    Result:=FEServersList;
  finally
    InternalUnlock;
  end;
end;

Procedure TEServers.ITCheck;
Begin
  InternalLock;
  try
    InternalCheck;
  finally
    InternalUnLock;
  end;
End;

Procedure TEServers.InternalSetServerInfo(aEServerInfo:IEServerInfo);
  Var tmpK:Integer;
      tmpStringListPID:TStringList;
      tmpV1:Variant;
      tmpPID:Cardinal;
      tmpIVarsetDataView:IVarsetDataView;
      tmpErrorKey, tmpErrorMessage:AnsiString;
begin
  If not assigned(aEServerInfo) Then exit;
  If aEServerInfo.ITRegName='' Then begin
    aEServerInfo.ITValid:=False;
    Exit;
  end;
  if FReg.OpenKey('\Software\Eleon\Server\List'+'\'+aEServerInfo.ITRegName, False) then Begin
    Try
      tmpErrorMessage:='';
      tmpErrorKey:='';
      try
        aEServerInfo.ITType:=FReg.ReadInteger('Type');
      except
        on e:exception do begin
          aEServerInfo.ITType:=-1;
          tmpErrorKey:=tmpErrorKey+'Type,';
          If tmpErrorMessage='' Then tmpErrorMessage:=e.Message;
        end;
      end;
      try
        aEServerInfo.ITGUID:=FReg.ReadString('GUID');
      except
        on e:exception do begin
          aEServerInfo.ITGUID:='';
          tmpErrorKey:=tmpErrorKey+'GUID,';
          If tmpErrorMessage='' Then tmpErrorMessage:=e.Message;
        end;
      end;
      try
        aEServerInfo.ITPathEXE:=FReg.ReadString('PathEXE');
      except
        on e:exception do begin
          aEServerInfo.ITPathEXE:='';
          tmpErrorKey:=tmpErrorKey+'PathEXE,';
          If tmpErrorMessage='' Then tmpErrorMessage:=e.Message;
        end;
      end;
      try
        aEServerInfo.ITMasterGUID:=FReg.ReadString('MasterGUID');
      except
        on e:exception do begin
          aEServerInfo.ITMasterGUID:='';
          tmpErrorKey:=tmpErrorKey+'MasterGUID,';
          If tmpErrorMessage='' Then tmpErrorMessage:=e.Message;
        end;
      end;
      try
        aEServerInfo.ITAutorestartNormal:=FReg.ReadInteger('AutorestartNormal');
      except
        aEServerInfo.ITAutorestartNormal:=0;
      end;
      try
        aEServerInfo.IT_SetAutorestartNornalPeriod(FReg.ReadString('AutorestartNornalPeriod'));
      except
        aEServerInfo.IT_SetAutorestartNornalPeriod('');
      end;
      try
        aEServerInfo.ITAutorestartCritical:=FReg.ReadInteger('AutorestartCritical');
      except
        aEServerInfo.ITAutorestartCritical:=0;
      end;
      try
        aEServerInfo.ITAutoKeepStarted:=FReg.ReadBool('AutoKeepStarted');
      except
        aEServerInfo.ITAutoKeepStarted:=False;
      end;
      try
        aEServerInfo.ITAutorestartMessage:=FReg.ReadString('AutorestartMessage');
      except
        aEServerInfo.ITAutorestartMessage:='';
      end;
      If tmpErrorMessage<>'' Then begin
        SetLength(tmpErrorKey, Length(tmpErrorKey)-1);
        raise exception.Create('('+tmpErrorKey+'): '+tmpErrorMessage);
      end;
      If (aEServerInfo.ITGUID='')Or((aEServerInfo.ITType<>1)And(aEServerInfo.ITType<>2))Or(aEServerInfo.ITPathEXE='')Or(aEServerInfo.ITMasterGUID='') Then begin
        //Invalid
        aEServerInfo.ITValid:=False;
      end else begin
        //Valid
        If FReg.OpenKey('\Software\Eleon\Server\List'+'\'+aEServerInfo.ITRegName+'\Started',False) then Begin
          tmpStringListPID:=TStringList.Create;
          try
            //Valid - Started or terminated
            FReg.GetValueNames(tmpStringListPID);
            aEServerInfo.ITPIDList.ITSetAllChecked(True);
            If glCheckStartedServerOfRegName(aEServerInfo.ITRegName, 0) then begin
              //сервер запущен
              For tmpK:=0 to tmpStringListPID.Count-1 do begin
                try
                  tmpPID:=StrToInt64(tmpStringListPID.Strings[tmpK]);
                  If glCheckStartedServerOfPID(aEServerInfo.ITRegName, tmpPID, 0) Then begin
                    tmpIVarsetDataView:=aEServerInfo.ITPIDUpdate(tmpPID, essStarted);
                  end else begin
                    tmpIVarsetDataView:=aEServerInfo.ITPIDUpdate(tmpPID, essTerminated);
                  end;
                  tmpIVarsetDataView.ITChecked:=False;
                  tmpIVarsetDataView:=Nil;
                except end;
              end;
            end else begin
              //сервер не запущен
              For tmpK:=0 to tmpStringListPID.Count-1 do begin
                try
                  tmpPID:=StrToInt64(tmpStringListPID.Strings[tmpK]);
                  tmpIVarsetDataView:=aEServerInfo.ITPIDUpdate(tmpPID, essTerminated);
                  tmpIVarsetDataView.ITChecked:=False;
                  tmpIVarsetDataView:=Nil;
                except end;
              end;
            end;
            aEServerInfo.ITPIDList.ITClearChecked;
          finally
            FreeAndNil(tmpStringListPID);
            Try VarClear(tmpV1) except end;
          end;
        end else begin
          //Valid - Stoped
          aEServerInfo.ITPIDList.ITClear;
        end;
        aEServerInfo.ITValid:=True;
      end;
    except
      //Invalid
      aEServerInfo.ITValid:=False;
    end;
  end else begin
    //Invalid
    aEServerInfo.ITValid:=False;
  end;
  If aEServerInfo.ITValid Then begin
    If aEServerInfo.ITStarted Then aEServerInfo.ITProcessInfo.ITRefresh else aEServerInfo.ITProcessInfo.ITPID:=0;
  end;  
end;

procedure TEServers.InternalCheck;
  Var tmpIVarset:IVarset;
      tmpFind:Boolean;
      tmpIntIndex:Integer;
      tmpJ:Integer;
      tmpIVarsetDataView:IVarsetDataView;
      tmpIUnknown:IUnknown;
      tmpIEServerInfo:IEServerInfo;
begin
  InternalLock;
  try
    tmpIVarset:=FEServersList.ITList;
    If Not Assigned(tmpIVarset) Then raise exception.Create('EServerList is not assigned.');
    tmpIVarset.ITSetAllChecked(True);
    Try
      try
        If FReg.OpenKey('\Software\Eleon\Server\List',False) then Begin
          FReg.GetKeyNames(FStringList);
          For tmpJ:=0 to FStringList.Count-1 do begin
            tmpFind:=False;
            tmpIntIndex:=-1;
            while true do begin
              tmpIVarsetDataView:=tmpIVarset.ITViewNextGetOfIntIndex(tmpIntIndex);
              if tmpIntIndex=-1 then break;
              tmpIUnknown:=tmpIVarsetDataView.ITData;
              If AnsiUpperCase(IEServerInfo(tmpIUnknown).ITRegName)=AnsiUpperCase(FStringList.Strings[tmpJ]) Then begin
                //Нашел-обновляю
                InternalSetServerInfo(IEServerInfo(tmpIUnknown));
                tmpIVarsetDataView.ITChecked:=False;//не надо удалять
                tmpFind:=True;
                Break;
              end;
              tmpIVarsetDataView:=Nil;
            end;
            If Not tmpFind Then begin
              //Не нашел- добавляю
              tmpIEServerInfo:=TEServerInfo.Create;
              tmpIEServerInfo.ITRegName:=FStringList.Strings[tmpJ];
              InternalSetServerInfo(tmpIEServerInfo);
              FEServersList.ITListAdd(tmpIEServerInfo);
              tmpIEServerInfo:=Nil;
            end;
          end;
        end else begin
          tmpIVarset.ITClear;
        end;
      except
        tmpIVarset.ITSetAllChecked(False);//не надо удалять
        raise;
      end;
    Finally
      tmpIVarset.ITClearChecked;//удаляю все помеченные
      tmpIVarset:=Nil;
    End;
  finally
    InternalUnLock;
  end;
end;


end.
