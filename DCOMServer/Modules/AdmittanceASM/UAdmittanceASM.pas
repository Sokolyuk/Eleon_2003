//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UAdmittanceASM;

interface
  uses UAdmittanceASMTypes, UITObject, UAppMessageTypes;
type
  TAdmittanceASM=class(TITObject, IAdmittanceASM)
  protected
    FASMArray:Variant;//������ ASM-��
    procedure InternalListAdd(const aData:Variant);//�������� � ������
    function InternalGetLoginType(aState:Integer):Integer;virtual;abstract;
    //procedure InternalITAddWishingToCauseDestroy(aObject:TObject);virtual;abstract;
    procedure InternalGetIUnknown(aObject:TObject; out aObj);virtual;abstract;
    procedure InternalSetDisconnectObject(aObject:TObject);virtual;abstract;
    procedure InternalMessage(const aMessage:AnsiString; aClass:TMessageClass; aStyle:TMessageStyle);virtual;
  public
    constructor create;
    destructor destroy;override;
    function StopAllASMServers:Integer;virtual;//���������� ��� ASM � ������ (� ASM.destroy ���������� ������� GLAdmittanceASM_ListASMDel(Self))
    function StopASMServerOnID(iIDASM:Integer):Integer;virtual;//���������� ASM � ��������� ID
    function StopASMServerOnUser(const stUserASM:AnsiString):Integer;virtual;//���������� ��� ASM, ������� ����������� ���������� User'�.
    procedure ListAdd(const aData:Variant);virtual;//�������� � ������
    function ListDel(aaPntr:Pointer; aaHeedingLock:Boolean):boolean;virtual;//������� �� ������
    function ListUpdate(aaASMNum:Integer; const NewData:Variant):Boolean;virtual;
    function CountOfListASM:Integer;virtual;//���������� �������� � ������
    function GetAddrNextASMAndLock(aAddr:Pointer):Pointer;virtual;//�� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� nil).
    function GetAddrPrevASMAndLock(aAddr:Pointer):Pointer;virtual;//���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
    function GetPntrOnIdAndLock(aASMSenderNum:Integer):Pointer;virtual;
    function GetPntrOnIdAndNoLock(aASMSenderNum:Integer):Pointer;virtual;
    function GetInfoNextASMAndLock(aAddr:Pointer):Variant;virtual;//�� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� nil).
    function GetInfoPrevASMAndLock(aAddr:Pointer):Variant;virtual;//���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
    function GetInfoNextASMAndNoLock(aAddr:Pointer):Variant;virtual;
    function GetInfoPrevASMAndNoLock(aAddr:Pointer):Variant;virtual;
    function GetInfoASMOnPntrAndNoLock(aAddr:Pointer):Variant;virtual;
    function GetInfoASMOnPntrAndLock(aAddr:Pointer):Variant;virtual;
    function GetInfoASMOnIdAndNoLock(aaASMNum:Integer):Variant;virtual;
    function GetInfoASMOnIdAndLock(aaASMNum:Integer):Variant;virtual;
    function Hide(aASMNum:Integer):Boolean;virtual;
    function Show(aASMNum:Integer):Boolean;virtual;
    function Lock(aASMNum:Integer):Integer;overload;virtual;
    function Lock(aPntr:Pointer):Integer;overload;virtual;
    function UnLock(aASMNum:Integer):Integer;overload;virtual;
    function UnLock(aPntr:Pointer):Integer;overload;virtual;
    function LockCount(aPntr:Pointer):Integer;overload;virtual;
    function LockCount(aASMNum:Integer):Integer;overload;virtual;
    procedure ITGetASMServers(out aASMServers, aExtDataASMServers:Variant);virtual;
  end;

implementation
  uses Variants, UAppInfoTypes, UTrayConsts, Comserv, UASMUtils, Sysutils, ActiveX, UASMUtilsConsts, UTypeUtils, UASMConsts;

constructor TAdmittanceASM.create;
begin
  inherited create;
  FASMArray:=unassigned;
end;

destructor TAdmittanceASM.destroy;
begin
  FASMArray:=unassigned;
  inherited destroy;
end;

// ������ � ������ ASM �������� ________________________________________________
procedure TAdmittanceASM.InternalListAdd(const aData:Variant);                // �������� � ������
begin
  //                 [0]                     [1]                            [2][0]            [2][1]                   [2][2]                [2][3]                     [2][4]             [2][5]               [2][6]  [2][7]
  //  (varInteger:(LockCount); varInteger:(0-Show 1-hide); varArray:(varInteger:(FUASNum); varOleStr(stASMUSER); ?varData(StartDateTime); ?varBoolean:(blEvent); ?varInteger:(vlASMState); varInteger:(self)));
  If not VarIsArray(FASMArray) then begin
    // ������ ������ Slave
    FASMArray:=VarArrayCreate([0,0], varVariant);
    //                        LockCount   ASM Show   ASM Info
    FASMArray[0]:=VarArrayOf([Integer(0), Integer(0), aData]);
  end else begin
    //�������� � ������������
    VarArrayRedim(FASMArray, VarArrayHighBound(FASMArray, 1)+1);
    FASMArray[VarArrayHighBound(FASMArray, 1)]:=VarArrayOf([Integer(0), Integer(0), aData]);
  end;
end;

procedure TAdmittanceASM.ListAdd(const aData:Variant);                      // �������� � ������
begin
  Internallock;
  Try
    InternalListAdd(aData);
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.ListDel(aaPntr:Pointer; aaHeedingLock:Boolean):boolean;      // !! ������ ������ �������� �� ����� ������ ���� �� �� ������� !!
  Var iI, ivLB, ivHB:Integer;                                              // ������� �� ������
begin
  Internallock;
  Try
    Result:=False;
    If VarIsEmpty(FASMArray) then Exit;
    ivLB:=VarArrayLowBound(FASMArray, 1);
    ivHB:=VarArrayHighBound(FASMArray, 1);
    For iI:=ivLB to ivHB do begin
      If Pointer(Integer(FASMArray[iI][2][5]))=aaPntr then begin
        //�������� Lock
        If aaHeedingLock then begin
          If FASMArray[iI][0]>0 Then
            //ASM �������
            Break;//result=false
        end;
        //�����
        Result:=True;
        If ivHB=iI then begin
          //���� ��� ��������� ������
          If ivLB=iI then begin
            //���� ��� ������������ ������
            FASMArray:=Unassigned;
          end else begin
            //���� ��� �� ������������ ������
            FASMArray[iI]:=unassigned;
            VarArrayRedim(FASMArray, ivHB-1);
          end;
        end else begin
          //���� ��� �� ��������� � �� ������������ ������
          FASMArray[iI]:=FASMArray[ivHB];//������ ��������� �� ����� ��������
          FASMArray[ivHB]:=unassigned;
          VarArrayRedim(FASMArray, ivHB-1);
        end;
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.CountOfListASM:Integer;                               //���������� �������� � ������
begin
  Internallock;
  try
    result:=-1;
    if VarIsEmpty(FASMArray) then begin
      exit;
    end else if VarIsArray(FASMArray) then begin
      Result:=VarArrayHighBound(FASMArray, 1)-VarArrayLowBound(FASMArray, 1)+1;
    end else Raise Exception.Create('Invalid type FASMArray: '''+glVarArrayToString(FASMArray)+'''.');
  finally
    Internalunlock;
  end;
end;

procedure TAdmittanceASM.InternalMessage(const aMessage:AnsiString; aClass:TMessageClass; aStyle:TMessageStyle);
begin
  //IAppMessage(cnTray.Query(IAppMessage)).ITMessAdd(now, now, '', 'AASM', 'AdmittanceASM: '+aMessage, aClass, aStyle);
end;

function TAdmittanceASM.GetAddrNextASMAndLock(aAddr:Pointer):Pointer;//�� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� nil).
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=nil;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin//���
      If aAddr=nil then begin//��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin//Hide, ���������
          Continue;
        end else begin//Show//����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);//��������� ���������
          Result:=Pointer(Integer(FASMArray[iI][2][5]));
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin//�����
        If FASMArray[iI][1]<>0 then begin//Hide, ������ �.�. ����� � ����� ���������
          Break;
        end else begin//Show
          If iI+1>VarArrayHighBound(FASMArray, 1) then begin//��� ���������
            Continue;//������ ���� �������������
          end else begin//��� �� ���������//����
            InternalMessage('ASM#'+IntToStr(FASMArray[iI+1][2][0])+' +Lock='+IntToStr(FASMArray[iI+1][0]+1), mecApp, mesWarning);
            FASMArray[iI+1]:=VarArrayOf([FASMArray[iI+1][0]+1, FASMArray[iI+1][1], FASMArray[iI+1][2]]);//��������� ���������
            Result:=Pointer(Integer(FASMArray[iI+1][2][5]));
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetAddrPrevASMAndLock(aAddr:Pointer):Pointer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=nil;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayHighBound(FASMArray, 1) DownTo VarArrayLowBound(FASMArray, 1) do begin
      //��� � �����
      If aAddr=nil then begin
        //��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin
          //Hide
          continue;
        end else begin
          //Show
          //����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          //��������� ���������
          Result:=Pointer(Integer(FASMArray[iI][2][5]));
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          If iI-1<VarArrayLowBound(FASMArray, 1) then begin
            //��� ���������
            Continue;  // ������ ���� �������������
          end else begin
            //��� �� ���������
            //����
            InternalMessage('ASM#'+IntToStr(FASMArray[iI-1][2][0])+' +Lock='+IntToStr(FASMArray[iI-1][0]+1), mecApp, mesWarning);
            FASMArray[iI-1]:=VarArrayOf([FASMArray[iI-1][0]+1, FASMArray[iI-1][1], FASMArray[iI-1][2]]);
            //��������� ���������
            Result:=Pointer(Integer(FASMArray[iI-1][2][5]));
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetPntrOnIdAndLock(aASMSenderNum:Integer):Pointer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=nil;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMSenderNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          //��������� ���������
          Result:=Pointer(Integer(FASMArray[iI][2][5]));
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetPntrOnIdAndNoLock(aASMSenderNum:Integer):Pointer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=nil;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMSenderNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //��������� ���������
          Result:=Pointer(Integer(FASMArray[iI][2][5]));
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.ListUpdate(aaASMNum:Integer; const NewData:Variant):Boolean;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=False;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aaASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        FASMArray[iI]:=VarArrayOf([FASMArray[iI][0], FASMArray[iI][1], NewData]);
        Result:=True;
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoNextASMAndLock(aAddr:Pointer):Variant;      // �� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� nil).
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aAddr=nil then begin
        //��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Continue;
        end else begin
          //Show
          //����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          //��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          If iI+1>VarArrayHighBound(FASMArray, 1) then begin
            //��� ���������
            Continue;//������ ���� �������������
          end else begin
            //��� �� ���������
            //����
            InternalMessage('ASM#'+IntToStr(FASMArray[iI+1][2][0])+' +Lock='+IntToStr(FASMArray[iI+1][0]+1), mecApp, mesWarning);
            FASMArray[iI+1]:=VarArrayOf([FASMArray[iI+1][0]+1, FASMArray[iI+1][1], FASMArray[iI+1][2]]);
            //��������� ���������
            Result:=FASMArray[iI+1][2];
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoPrevASMAndLock(aAddr:Pointer):Variant;//���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
  Var iI:Integer;
Begin
  Internallock;
  Try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayHighBound(FASMArray, 1) DownTo VarArrayLowBound(FASMArray, 1) do begin//��� � �����
      If aAddr=nil then begin//��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin//Hide
          Continue;
        end else begin//Show//����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);//��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin//�����
        If FASMArray[iI][1]<>0 then begin//Hide
          Break;
        end else begin//Show
          If iI-1<VarArrayLowBound(FASMArray, 1) then begin//��� ���������
            Continue;//������ ���� �������������
          end else begin//��� �� ���������//����
            InternalMessage('ASM#'+IntToStr(FASMArray[iI-1][2][0])+' +Lock='+IntToStr(FASMArray[iI-1][0]+1), mecApp, mesWarning);
            FASMArray[iI-1]:=VarArrayOf([FASMArray[iI-1][0]+1, FASMArray[iI-1][1], FASMArray[iI-1][2]]);//��������� ���������
            Result:=FASMArray[iI-1][2];
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoNextASMAndNoLock(aAddr:Pointer):Variant;      // �� ����� ����� �������� ASM �� ������ ����� ���������� ASM (��� ��������� ������ ������� ASM �� ���� nil).
  Var iI:Integer;
begin
  Internallock;
  try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    for iI:=VarArrayLowBound(FASMArray, 1) to VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aAddr=nil then begin
        //��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Continue;
        end else begin
          //Show
          //�� ����
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          If iI+1>VarArrayHighBound(FASMArray, 1) then begin
            //��� ���������
            Continue;//������ ���� �������������
          end else begin
            //��� �� ���������
            //�� ����
            Result:=FASMArray[iI+1][2];
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoPrevASMAndNoLock(aAddr:Pointer):Variant;      // ���������� GLAdmittanceASM_GetAddrNextASM, �� ������ � �����.
  Var iI:Integer;
Begin
  Internallock;
  Try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayHighBound(FASMArray, 1) DownTo VarArrayLowBound(FASMArray, 1) do begin
      //��� � �����
      If aAddr=nil then begin
        //��������� ������ �� ASM
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Continue;
        end else begin
          //Show
          //�� ����
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          If iI-1<VarArrayLowBound(FASMArray, 1) then begin
            //��� ���������
            Continue;//������ ���� �������������
          end else begin
            //��� �� ���������
            //�� ����
            Result:=FASMArray[iI-1][2];
            break;
          end;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoASMOnPntrAndLock(aAddr:Pointer):Variant;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=Unassigned;
    If aAddr=nil then Exit;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          //��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoASMOnPntrAndNoLock(aAddr:Pointer):Variant;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=Unassigned;
    If aAddr=nil then Exit;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aAddr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //�� ����
          //��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoASMOnIdAndNoLock(aaASMNum:Integer):Variant;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aaASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //�� ����
          //��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.GetInfoASMOnIdAndLock(aaASMNum:Integer):Variant;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=Unassigned;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aaASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          //����
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          //��������� ���������
          Result:=FASMArray[iI][2];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

//Lock/UnLock
function TAdmittanceASM.Lock(aASMNum:Integer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          Result:=FASMArray[iI][0];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.UnLock(aASMNum:Integer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        If FASMArray[iI][0]>0 Then begin
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Unlock='+IntToStr(FASMArray[iI][0]-1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]-1, FASMArray[iI][1], FASMArray[iI][2]]);
        end;
        Result:=FASMArray[iI][0];
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.Lock(aPntr:Pointer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aPntr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][1]<>0 then begin
          //Hide
          Break;
        end else begin
          //Show
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Lock='+IntToStr(FASMArray[iI][0]+1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]+1, FASMArray[iI][1], FASMArray[iI][2]]);
          Result:=FASMArray[iI][0];
          break;
        end;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.UnLock(aPntr:Pointer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aPntr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        If FASMArray[iI][0]>0 Then begin
          InternalMessage('ASM#'+IntToStr(FASMArray[iI][2][0])+' +Unlock='+IntToStr(FASMArray[iI][0]-1), mecApp, mesWarning);
          FASMArray[iI]:=VarArrayOf([FASMArray[iI][0]-1, FASMArray[iI][1], FASMArray[iI][2]]);
        end;
        Result:=FASMArray[iI][0];
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.LockCount(aPntr:Pointer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aPntr=Pointer(Integer(FASMArray[iI][2][5])) then begin
        //�����
        Result:=FASMArray[iI][0];
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.LockCount(aASMNum:Integer):Integer;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=-1;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        Result:=FASMArray[iI][0];
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.Hide(aASMNum:Integer):Boolean;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=false;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        FASMArray[iI]:=VarArrayOf([FASMArray[iI][0], Integer(1), FASMArray[iI][2]]);
        Result:=True;
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.Show(aASMNum:Integer):Boolean;
  Var iI:Integer;
begin
  Internallock;
  Try
    Result:=false;
    If VarIsEmpty(FASMArray) then Exit;
    For iI:=VarArrayLowBound(FASMArray, 1) To VarArrayHighBound(FASMArray, 1) do begin
      //���
      If aASMNum=Integer(FASMArray[iI][2][0]) then begin
        //�����
        FASMArray[iI]:=VarArrayOf([FASMArray[iI][0], Integer(0), FASMArray[iI][2]]);
        Result:=True;
        break;
      end;
    end;
  Finally
    Internalunlock;
  end;
end;

procedure TAdmittanceASM.ITGetASMServers(out aASMServers, aExtDataASMServers:Variant);
  var tmpI:Integer;
      tmpLB, tmpHB:Integer;
      tmpStateInt:Integer;
begin
  Internallock;
  try
    try
      aExtDataASMServers:=VarArrayOf([IAppInfo(cnTray.Query(IAppInfo)).StartTime, ComServer.ObjectCount, vlASMStartNum]);//Fill extended data
      if VarIsArray(FASMArray) then begin//Create&Fill ASM List
        tmpLB:=VarArrayLowBound(FASMArray, 1);
        tmpHB:=VarArrayHighBound(FASMArray, 1);
        aASMServers:=VarArrayCreate([tmpLB, tmpHB], varVariant);
        for tmpI:=tmpLB to tmpHB do begin
          tmpStateInt:=FASMArray[tmpI][2][4];
          aASMServers[tmpI]:=VarArrayOf([false{this}, FASMArray[tmpI][2][2]{StartDateTime}, FASMArray[tmpI][2][0]{Num}, FASMArray[tmpI][2][1]{User}, ASMStateToString(IntegerToASMState(tmpStateInt)){State}, InternalGetLoginType(tmpStateInt){LoginType}, FASMArray[tmpI][2][3]{Event}]);
        end;
      end else aASMServers:=unassigned;
    except on e:exception do begin
      e.message:='GetASMServers: '+e.message;
      raise;
    end;end;
  finally
    Internalunlock;
  end;
end;
{ var tmpV:Variant;
      tmpI:Integer;
      tmpVarArrCreated:boolean;
  procedure AddASMToVariant(aablThis:boolean; aaStartDateTime:TDateTime; aaNum:Integer; const aaUser, aaState :AnsiString; aaLoginType:Integer; aaEvent:Boolean);begin
    if not tmpVarArrCreated then begin
      tmpV:=VarArrayCreate([VarArrayLowBound(FASMArray, 1), VarArrayHighBound(FASMArray, 1)], varVariant);
      tmpI:=0;
      tmpVarArrCreated:=true;
    end;
    tmplV[tmpI]:=VarArrayOf([aablThis, aaStartDateTime, aaNum, aaUser, aaState, aaLoginType, aaEvent]);
    inc(tmpI);
  end;
  var tmpPntr:Pointer;
      iiNum:Integer;
      iiUser:AnsiString;
      iiStartDateTime:TDateTime;
      iiStateInt:Integer;
      blThis, blEvent:boolean;
      vASMInfo:Variant;
//--
       tmpPntr:=nil;
      tmpVarArrCreated:=false;
      tmpI:=0;
      repeat
        vASMInfo:=GetInfoNextASMAndNoLock(tmpPntr);
        If VarType(vASMInfo)<>varEmpty then begin
          //���� ������� Info
          tmpPntr:=Pointer(Integer(vASMInfo[5]));  // ���������� ��������� �� ASM �� ����� Info
          iiNum:=vASMInfo[0];
          iiUser:=vASMInfo[1];
          iiStartDateTime:=vASMInfo[2];
          blEvent:=vASMInfo[3];
          iiStateInt:=Integer(vASMInfo[4]);
          blThis:=FALSE;//!!Boolean(tmpPntr=Pointer(Self));
          AddASMToVariant(tmpV, blThis, iiStartDateTime, iiNum, iiUser, ASMStateToString(IntegerToASMState(iiStateInt)), InternalGetLoginType(iiStateInt), blEvent);
        end else begin
          // �������� ������
          tmpPntr:=nil;
        end;
      Until tmpPntr=nil;
      vlASMServers:=tmpV;
{}
function TAdmittanceASM.StopAllASMServers:Integer;// ���������� ��� ASM � ������ (� ASM.destroy ���������� ������� GLAdmittanceASM_ListASMDel(Self))
  Var tmpI:Integer;
      tmpPtr:Pointer;
      tmpIUnknown:IUnknown;
Begin
  Internallock;
  try
    Result:=0;
    if not VarIsArray(FASMArray) then Exit;
    for tmpI:=VarArrayHighBound(FASMArray, 1) downto VarArrayLowBound(FASMArray, 1) do begin//��� � �����
      tmpPtr:=Pointer(Integer(FASMArray[tmpI][2][5]));
      //InternalITAddWishingToCauseDestroy(tmpPtr);
      InternalGetIUnknown(TObject(tmpPtr), tmpIUnknown);
      InternalSetDisconnectObject(TObject(tmpPtr));
      CoDisconnectObject(tmpIUnknown, 0);//��������� ASM object
      {//!!!}if ((integer(FASMArray[tmpI][2][4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then tmpIUnknown._Release;
      tmpIUnknown:=nil;
      Inc(Result);
    end;
  finally
    Internalunlock;
  end;
end;

function TAdmittanceASM.StopASMServerOnID(iIDASM:Integer):Integer;//���������� ASM � ��������� ID
  var tmpPtr:Pointer;
      tmpV:Variant;
      tmpIUnknown:IUnknown;
begin
  result:=0;
  {tmpPtr}tmpV:={GetPntrOnIdAndLock}{GetPntrOnIdAndNoLock}GetInfoASMOnIdAndNoLock(iIDASM){4};
  if VarIsEmpty(tmpV) then tmpPtr:=nil else tmpPtr:=pointer(integer(tmpV[5]));
  if assigned(tmpPtr) then begin
    //try
      //InternalITAddWishingToCauseDestroy(tmpPtr);
      InternalGetIUnknown(TObject(tmpPtr), tmpIUnknown);
      InternalSetDisconnectObject(TObject(tmpPtr));
      CoDisconnectObject(tmpIUnknown, 0);//��������� ASM object
      {//!!!}if ((integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then tmpIUnknown._Release;
      tmpIUnknown:=nil;
    //finally
    //  UnLock(tmpPtr){4};
    //end;
    Inc(Result);
  end;
end;

function TAdmittanceASM.StopASMServerOnUser(const stUserASM:AnsiString):Integer; // ���������� ��� ASM, ������� ����������� ���������� User'�.
  Var tmpPtr:Pointer;
      tmpV:Variant;
      blFlagl:boolean;
      tmpIUnknown:IUnknown;
begin
    tmpPtr:=nil;
    Result:=0;
    repeat
      blFlagl:=false;
      tmpV:={GetInfoPrevASMAndLock}GetInfoPrevASMAndNoLock(tmpPtr);
      if not VarIsEmpty(tmpV) then begin
        //try
          tmpPtr:=Pointer(Integer(tmpV[5]));//��� ������ ����������
          If AnsiUpperCase(tmpV[1])=AnsiUpperCase(stUserASM) then begin
            //InternalITAddWishingToCauseDestroy(tmpPtr);
            InternalGetIUnknown(TObject(tmpPtr), tmpIUnknown);
            InternalSetDisconnectObject(TObject(tmpPtr));
            CoDisconnectObject(tmpIUnknown, 0);//��������� ASM object
            {//!!!}if ((integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then tmpIUnknown._Release;
            tmpIUnknown:=nil;
            Inc(Result);
            blFlagl:=True;
            tmpPtr:=nil;
          end;
        //finally
        //  UnLock(tmpPtr);
        //end;
      end;
    until (tmpPtr=nil)and(blFlagl=false);
end;

end.
