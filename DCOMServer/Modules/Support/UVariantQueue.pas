unit UVariantQueue;

interface
  Uses Windows, Classes, UITObject;
Type
  TBufferType=(vbtFIFO, vbtFILO);

  IVariantQueue = Interface
    ['{799496DB-9766-49D4-A717-0DB5A3412140}']
    Function  ITGetCount:Integer;
    procedure ITViewSet(Index:Integer; Value:Variant);
    function  ITViewGet(Index:Integer):Variant;
    procedure ITViewSetOfStrIndex(Index:AnsiString; Value:Variant);
    function  ITViewGetOfStrIndex(Index:AnsiString):Variant;
    procedure ITViewSetOfIntIndex(Index:Integer; Value:Variant);
    function  ITViewGetOfIntIndex(Index:Integer):Variant;
    procedure ITSet_IntIndexAssignable(Value:Boolean);
    function  ITGet_IntIndexAssignable:Boolean;
    procedure ITSet_CheckUniqueIntIndex(Value:Boolean);
    function  ITGet_CheckUniqueIntIndex:Boolean;
    procedure IT_SetCapacityRange(Value:Integer);
    function  IT_GetCapacityRange:Integer;
    // ..
{    Function  ITPushP(Const aData:PVariant):Integer;
    Function  ITPushPO(Const aStrIndex:AnsiString; Const aData:PVariant):Integer;
    Function  ITPushPOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:PVariant):Integer;
    Function  ITPushPOOO(Var aIntIndex:Integer; Const aData:PVariant):Integer;}
    Function  ITPush(Const aData:Variant):Integer;
    Function  ITPushO(Const aStrIndex:AnsiString; Const aData:Variant):Integer;
    Function  ITPushOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:Variant):Integer;
    Function  ITPushOOO(Var aIntIndex:Integer; Const aData:Variant):Integer;
    Function  ITPop:Variant;
    Function  ITPopO(Out aStrIndex:AnsiString):Variant;
    Function  ITPopOO(Out aStrIndex:AnsiString; Out aIntIndex:Integer):Variant;
    Function  ITPopOOO(Out aIntIndex:Integer):Variant;
    Procedure ITClear;
    Procedure ITClearOfIndex(Const aIndex:Integer);
    Procedure ITClearOfIntIndex(Const aIntIndex:Integer);
    Procedure ITClearOfStrIndex(Const aStrIndex:AnsiString);
    Function  ITStrIndexToIndex(Const aStrIndex:AnsiString):Integer;
    Function  ITIndexToStrIndex(Const aIndex:Integer):AnsiString;
    Function  ITIntIndexToIndex(Const aIntIndex:Integer; aRaised:Boolean=True):Integer;
    Function  ITIndexToIntIndex(Const aIndex:Integer):Integer;
    Function  ITIntIndexToStrIndex(Const aIntIndex:Integer):AnsiString;
    Function  ITIntIndexToNextIndex(Const aNext:Boolean; Var aIntIndex:Integer):Integer;
    // Steping
    function  ITViewNextGetOfIntIndex(Var aIntIndex:Integer):Variant;
    procedure ITViewNextSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
    function  ITViewPrevGetOfIntIndex(Var aIntIndex:Integer):Variant;
    procedure ITViewPrevSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
    //Ex
    {procedure ITPushEx(Const aVariantQueueData:IVariantQueueData);
    Function  ITPopEx:IVariantQueueData;
    Function  ITPopWakeupEx:IVariantQueueData;}
    // Property
    Property  ITCount:Integer read ITGetCount;
    Property  ITView[Index:Integer]:Variant read ITViewGet write ITViewSet;
    Property  ITViewOfStrIndex[Index:AnsiString]:Variant read ITViewGetOfStrIndex write ITViewSetOfStrIndex;
    Property  ITViewOfIntIndex[Index:Integer]:Variant read ITViewGetOfIntIndex write ITViewSetOfIntIndex;
    Property  ITIntIndexAssignable:Boolean read ITGet_IntIndexAssignable write ITSet_IntIndexAssignable;
    Property  ITCheckUniqueIntIndex:Boolean read ITGet_CheckUniqueIntIndex write ITSet_CheckUniqueIntIndex;
    //..
    Property  ITCapacityRange:Integer read IT_GetCapacityRange write IT_SetCapacityRange;
  end;

  TVariantData = Class//(IVariantData)
  Public
    Data:Variant;
    IntIndex:Integer;
    StrIndex:AnsiString;
    constructor Create; 
    destructor  Destroy; override;
  end;

  TVariantQueue = class(TITObject, IVariantQueue)
  private
    FBufferType:TBufferType;
    //FivHB:Integer;
    FList:TList;
    FIntIndexAssignable:Boolean;
    FCheckUniqueIntIndex:Boolean;
    FUniqueIntIndex:Integer;
    FCapacityRange:Integer;
    Procedure InternalCreate;
    Procedure InternalCheckCapacity;
  Protected
    Function  ITGetCount:Integer;
    procedure ITViewSet(Index:Integer; Value:Variant);
    function  ITViewGet(Index:Integer):Variant;
    procedure ITViewSetOfStrIndex(Index:AnsiString; Value:Variant);
    function  ITViewGetOfStrIndex(Index:AnsiString):Variant;
    procedure ITViewSetOfIntIndex(Index:Integer; Value:Variant);
    function  ITViewGetOfIntIndex(Index:Integer):Variant;
    procedure ITSet_IntIndexAssignable(Value:Boolean);
    function  ITGet_IntIndexAssignable:Boolean;
    procedure ITSet_CheckUniqueIntIndex(Value:Boolean);
    function  ITGet_CheckUniqueIntIndex:Boolean;
    procedure IT_SetCapacityRange(Value:Integer);
    function  IT_GetCapacityRange:Integer;
  public
    constructor Create; Overload;
    constructor Create(aBufferType:TBufferType); Overload;
    destructor  Destroy; override;
    Function  ITPushP(Const aData:PVariant):Integer;
    Function  ITPushPO(Const aStrIndex:AnsiString; Const aData:PVariant):Integer;
    Function  ITPushPOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:PVariant):Integer;
    Function  ITPushPOOO(Var aIntIndex:Integer; Const aData:PVariant):Integer;
    Function  ITPush(Const aData:Variant):Integer;
    Function  ITPushO(Const aStrIndex:AnsiString; Const aData:Variant):Integer;
    Function  ITPushOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:Variant):Integer;
    Function  ITPushOOO(Var aIntIndex:Integer; Const aData:Variant):Integer;
    Function  ITPop:Variant;
    Function  ITPopO(Out aStrIndex:AnsiString):Variant;
    Function  ITPopOO(Out aStrIndex:AnsiString; Out aIntIndex:Integer):Variant;
    Function  ITPopOOO(Out aIntIndex:Integer):Variant;
    Procedure ITClear;
    Procedure ITClearOfIndex(Const aIndex:Integer);
    Procedure ITClearOfIntIndex(Const aIntIndex:Integer);
    Procedure ITClearOfStrIndex(Const aStrIndex:AnsiString);
    Function  ITStrIndexToIndex(Const aStrIndex:AnsiString):Integer;
    Function  ITIndexToStrIndex(Const aIndex:Integer):AnsiString;
    Function  ITIntIndexToIndex(Const aIntIndex:Integer; aRaised:Boolean=True):Integer;
    Function  ITIndexToIntIndex(Const aIndex:Integer):Integer;
    Function  ITIntIndexToStrIndex(Const aIntIndex:Integer):AnsiString;
    Function  ITIntIndexToNextIndex(Const aNext:Boolean; Var aIntIndex:Integer):Integer;
    // Steping
    function  ITViewNextGetOfIntIndex(Var aIntIndex:Integer):Variant;
    procedure ITViewNextSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
    function  ITViewPrevGetOfIntIndex(Var aIntIndex:Integer):Variant;
    procedure ITViewPrevSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
    // ..
    Property  ITCount:Integer read ITGetCount;
    Property  ITView[Index:Integer]:Variant read ITViewGet write ITViewSet;
    Property  ITViewOfStrIndex[Index:AnsiString]:Variant read ITViewGetOfStrIndex write ITViewSetOfStrIndex;
    Property  ITViewOfIntIndex[Index:Integer]:Variant read ITViewGetOfIntIndex write ITViewSetOfIntIndex;
    Property  ITIntIndexAssignable:Boolean read ITGet_IntIndexAssignable write ITSet_IntIndexAssignable;
    Property  ITCheckUniqueIntIndex:Boolean read ITGet_CheckUniqueIntIndex write ITSet_CheckUniqueIntIndex;
    //..
    Property  ITCapacityRange:Integer read IT_GetCapacityRange write IT_SetCapacityRange;
  end;

implementation
  Uses SysUtils
{$IFDEF VER140}
  { Borland Delphi 6.0 }
       , Variants
{$ENDIF}
       ;
Const
  VariantQueueCapacityRange=20;

constructor TVariantData.Create;
begin
  Data:=Unassigned;
  IntIndex:=-1;
  StrIndex:='';
  Inherited Create;
end;

destructor  TVariantData.Destroy;
begin
  StrIndex:='';
  VarClear(Data);
  Inherited Destroy;
end;

Procedure TVariantQueue.InternalCreate;
begin
  FList:=TList.Create;
  FCapacityRange:=VariantQueueCapacityRange;
  InternalCheckCapacity;
  //FList.Capacity:=FCapacityRange;
  FBufferType:=vbtFIFO;
  //FivHB:=-1;
  FIntIndexAssignable:=False;        // присваивать внешний индекс нельзя.
  FCheckUniqueIntIndex:=False{True}; // Проверять уникальность индекса не нужно.
  FUniqueIntIndex:=0;
end;

constructor TVariantQueue.Create;
begin
  InternalCreate;
  Inherited Create;
end;

constructor TVariantQueue.Create(aBufferType:TBufferType);
begin
  InternalCreate;
  FBufferType:=aBufferType;
  Inherited Create;
end;

destructor TVariantQueue.Destroy;
begin
  ITClear;
  FreeAndNil(FList);
  Inherited Destroy;
end;

Procedure TVariantQueue.ITClear;
begin
  InternalLock;
  try
    While FList.Count>0 do begin
      ITClearOfIndex(FList.Count-1);
    end;
  finally
    InternalUnLock;
  end;
end;

Procedure TVariantQueue.InternalCheckCapacity;
begin
  If (FList.Count<(FList.Capacity-FCapacityRange*2))Or(FList.Count>=FList.Capacity) Then
    FList.Capacity:=FList.Count+FCapacityRange;
end;

Procedure TVariantQueue.ITClearOfIndex(Const aIndex:Integer);
  Var tmpVariantData:TVariantData;
begin
  InternalLock;
  try
    If (FList.Count<1)Or(aIndex<0)Or(aIndex>(FList.Count-1)) then begin
      // Список пустой
      Raise Exception.Create('Index='+IntToStr(aIndex)+' is not exist.');
    end else begin
      // список не пустой
      try
        tmpVariantData:=FList.Items[aIndex];
        tmpVariantData.Free;
      except end;
      FList.Items[aIndex]:=Nil;
      FList.Delete(aIndex);
      InternalCheckCapacity;
    end;
  finally
    InternalUnLock;
  end;
end;

Procedure TVariantQueue.ITClearOfIntIndex(Const aIntIndex:Integer);
begin
  InternalLock;
  try
    ITClearOfIndex(ITIntIndexToIndex(aIntIndex));
  finally
    InternalUnLock;
  end;
end;

Procedure TVariantQueue.ITClearOfStrIndex(Const aStrIndex:AnsiString);
begin
  InternalLock;
  try
    ITClearOfIndex(ITStrIndexToIndex(aStrIndex));
  finally
    InternalUnLock;
  end;
end;

Function TVariantQueue.ITPushP(Const aData:PVariant):Integer;
  Var iI:Integer;
begin
  InternalLock;
  try
    iI:=-1;
    Result:=ITPushPOO('', iI, aData);
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushPO(Const aStrIndex:AnsiString; Const aData:PVariant):Integer;
  Var iI:Integer;
begin
  InternalLock;
  try
    iI:=-1;
    Result:=ITPushPOO(aStrIndex, iI, aData);
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushPOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:PVariant):Integer;
  Var tmpVariantData:TVariantData;
      iI:Integer;
      tmpContinue:Boolean;
begin
  InternalLock;
  try
    Result:=-1;
    try
      // Назначаемость индекса
      If Not FIntIndexAssignable Then begin
        // Генерируется уникальный индекс
        While True do begin
          Inc(FUniqueIntIndex);
          aIntIndex:=FUniqueIntIndex;
          tmpContinue:=False;
          // Уникальность индекса
          If FCheckUniqueIntIndex Then begin
            // Требуется проверка унпкальности ключа
             For iI:=0 to FList.Count-1 do begin
                tmpVariantData:=FList.Items[iI];
                If tmpVariantData.IntIndex=aIntIndex Then begin
                  tmpContinue:=True;
                  Break;
                end;
             end;
          end;
          If Not tmpContinue Then Break;
        end;
      end else begin
        // Уникальность индекса
        If FCheckUniqueIntIndex Then begin
          // Требуется проверка унпкальности ключа
          For iI:=0 to FList.Count-1 do begin
            tmpVariantData:=FList.Items[iI];
            If tmpVariantData.IntIndex=aIntIndex Then begin
              Raise Exception.Create('Duplication of a unique IntIndex='+IntToStr(aIntIndex)+'.');
            end;
          end;
        end;
      end;
      tmpVariantData:=TVariantData.Create;
      try
        tmpVariantData.Data:=aData^;
        tmpVariantData.IntIndex:=aIntIndex;
        tmpVariantData.StrIndex:=aStrIndex;
        Result:=FList.Add(tmpVariantData);
      except
        tmpVariantData.Free;
        raise;
      end;
    Except
      on e:exception do
        Raise Exception.Create('ITPushPOO: '+e.Message);
    End;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushPOOO(Var aIntIndex:Integer; Const aData:PVariant):Integer;
begin
  InternalLock;
  try
    Result:=ITPushPOO('', aIntIndex, aData);
  finally
    InternalUnLock;
  end;
end;

Function TVariantQueue.ITPush(Const aData:Variant):Integer;
begin
  InternalLock;
  try
    Result:=ITPushP(Addr(aData));
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushO(Const aStrIndex:AnsiString; Const aData:Variant):Integer;
begin
  InternalLock;
  try
    Result:=ITPushPO(aStrIndex, Addr(aData));
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushOO(Const aStrIndex:AnsiString; Var aIntIndex:Integer; Const aData:Variant):Integer;
begin
  InternalLock;
  try
    Result:=ITPushPOO(aStrIndex, aIntIndex, Addr(aData));
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPushOOO(Var aIntIndex:Integer; Const aData:Variant):Integer;
begin
  InternalLock;
  try
    Result:=ITPushPOO('', aIntIndex, Addr(aData));
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPop:Variant;
  Var tmpSt:ansiString;
begin
  InternalLock;
  try
    Result:=ITPopO(tmpSt);
    tmpSt:='';
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPopO(Out aStrIndex:AnsiString):Variant;
  Var tmpI:Integer;
begin
  InternalLock;
  try
    Result:=ITPopOO(aStrIndex, tmpI);
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPopOO(Out aStrIndex:AnsiString; Out aIntIndex:Integer):Variant;
  Var tmpI:Integer;
      tmpVariantData:TVariantData;
begin
  InternalLock;
  try
    try
      If FList.Count<1 then begin
        Result:=Unassigned;
        Exit;
      end;
      If FBufferType=vbtFIFO then tmpI:=0
                             else tmpI:=FList.Count-1;
      tmpVariantData:=FList.Items[tmpI];
      try
        try
          aStrIndex:=tmpVariantData.StrIndex;
          aIntIndex:=tmpVariantData.IntIndex;
          Result:=tmpVariantData.Data;
        finally
          tmpVariantData.Free;// Для возможности хранить интерфейсы.
        end;
      finally
        FList.Delete(tmpI);
        InternalCheckCapacity;//FList.Capacity:=FList.Count;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITPopOO: '+e.Message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITPopOOO(Out aIntIndex:Integer):Variant;
  Var aStrIndex:AnsiString;
begin
  InternalLock;
  try
    Result:=ITPopOO(aStrIndex, aIntIndex);
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.ITViewGet(Index: Integer):Variant;
begin
  InternalLock;
  try
    try
      If (FList.Count<1)Or(Index<0)Or(Index>(FList.Count-1)) then begin
        // Список пустой
        Result:=Unassigned;
      end else begin
        // список не пустой
        Result:=TVariantData(FList.Items[Index]).Data;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewGet: '+e.Message);
    end;
  finally
    InternalUnLock;
  end;
end;


procedure TVariantQueue.ITViewSet(Index:Integer; Value:Variant);
begin
  InternalLock;
  try
    try
      If (FList.Count<1)Or(Index<0)Or(Index>(FList.Count-1)) then begin
        // Список пустой
        Raise Exception.Create('Index='+IntToStr(Index)+' is not exist.');
      end else begin
        // список не пустой
        TVariantData(FList.Items[Index]).Data:=Value;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewSet: '+e.Message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function TVariantQueue.ITGetCount:Integer;
begin
  InternalLock;
  try
    Result:=-1;
    try
      Result:=FList.Count;
    except
      on e:exception do
        Raise Exception.Create('ITGetCount: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITStrIndexToIndex(Const aStrIndex:AnsiString):Integer;
  Var iI:Integer;
begin
  InternalLock;
  try
    Result:=-1;
    try
      if FList.Count>0 Then begin
        // список не пустой
        For iI:=0 to FList.Count-1 do begin
          If TVariantData(FList.Items[iI]).StrIndex=aStrIndex Then begin
            Result:=iI;
            Break;
          end;
        end;
      end;
      If Result<0 Then Raise Exception.Create('Index='''+aStrIndex+''' is not exist.');
    except
      on e:exception do
        Raise Exception.Create('ITStrIndexToIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITIndexToStrIndex(Const aIndex:Integer):AnsiString;
begin
  InternalLock;
  try
    try
      If (FList.Count<1)Or(aIndex<0)Or(aIndex>(FList.Count-1)) then begin
        // Список пустой
        Raise Exception.Create('Index='+IntToStr(aIndex)+' is not exist.');
      end else begin
        // список не пустой
        Result:=TVariantData(FList.Items[aIndex]).StrIndex;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITIndexToStrIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITIntIndexToIndex(Const aIntIndex:Integer; aRaised:Boolean=True):Integer;
  Var iI:Integer;
begin
  InternalLock;
  try
    Result:=-1;
    try
      if FList.Count>0 Then begin
        // список не пустой
        For iI:=0 to FList.Count-1 do begin
          If TVariantData(FList.Items[iI]).IntIndex=aIntIndex Then begin
            Result:=iI;
            Break;
          end;
        end;
      end;
      If aRaised And(Result<0) Then Raise Exception.Create('IntIndex='+IntToStr(aIntIndex)+' is not exist.');
    except
      on e:exception do
        Raise Exception.Create('ITIntIndexToIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITIntIndexToStrIndex(Const aIntIndex:Integer):AnsiString;
begin
  InternalLock;
  try
    Result:=ITIndexToStrIndex(ITIntIndexToIndex(aIntIndex));
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITIndexToIntIndex(Const aIndex:Integer):Integer;
begin
  InternalLock;
  try
    Result:=-1;
    try
      If (FList.Count<1)Or(aIndex<0)Or(aIndex>(FList.Count-1)) then begin
        // Список пустой
        Raise Exception.Create('Index='+IntToStr(aIndex)+' is not exist.');
      end else begin
        // список не пустой
        Result:=TVariantData(FList.Items[aIndex]).IntIndex;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITIndexToStrIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.ITViewGetOfStrIndex(Index:AnsiString):Variant;
begin
  InternalLock;
  try
    try
      Result:=ITViewGet(ITStrIndexToIndex(Index));
    except
      on e:exception do
        Raise Exception.Create('ITViewGetOfStrIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

procedure TVariantQueue.ITViewSetOfStrIndex(Index:AnsiString; Value:Variant);
begin
  InternalLock;
  try
    try
      ITViewSet(ITStrIndexToIndex(Index), Value);
    except
      on e:exception do
        Raise Exception.Create('ITViewSetOfStrIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

procedure TVariantQueue.ITViewSetOfIntIndex(Index:Integer; Value:Variant);
begin
  InternalLock;
  try
    try
      ITViewSet(ITIntIndexToIndex(Index), Value);
    except
      on e:exception do
        Raise Exception.Create('ITViewSetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.ITViewGetOfIntIndex(Index:Integer):Variant;
begin
  InternalLock;
  try
    try
      Result:=ITViewGet(ITIntIndexToIndex(Index));
    except
      on e:exception do
        Raise Exception.Create('ITViewGetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Procedure TVariantQueue.ITSet_IntIndexAssignable(Value:Boolean);
begin
  InternalLock;
  try
    try
      FIntIndexAssignable:=Value;
    except
      on e:exception do
        Raise Exception.Create('ITSet_IntIndexAssignable: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITGet_IntIndexAssignable:Boolean;
begin
  InternalLock;
  try
    Result:=FIntIndexAssignable;
  finally
    InternalUnLock;
  end;
end;

Procedure TVariantQueue.ITSet_CheckUniqueIntIndex(Value:Boolean);
begin
  InternalLock;
  try
    try
      FCheckUniqueIntIndex:=Value;
    except
      on e:exception do
        Raise Exception.Create('ITSet_CheckUniqueIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

Function  TVariantQueue.ITGet_CheckUniqueIntIndex:Boolean;
begin
  InternalLock;
  try
    Result:=FCheckUniqueIntIndex;
  finally
    InternalUnLock;
  end;
end;

procedure TVariantQueue.IT_SetCapacityRange(Value:Integer);
begin
  InternalLock;
  try
    If Value<1 Then Raise Exception.Create('Invalid CapacityRange(value='+IntToStr(Value)+').'); 
    FCapacityRange:=Value;
    FList.Capacity:=FList.Count;
    InternalCheckCapacity;
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.IT_GetCapacityRange:Integer;
begin
  InternalLock;
  try
    Result:=FCapacityRange;
  finally
    InternalUnLock;
  end;
end;


// Поиск элемента в списке
Function  TVariantQueue.ITIntIndexToNextIndex(Const aNext:Boolean; Var aIntIndex:Integer):Integer;
  Var iI:Integer;
begin
  InternalLock;
  try
    Result:=Unassigned;
    try
      If aIntIndex<0 then begin
        // Указан не действительный индекс. Возвращаю первый элемент.
        If FList.Count<1 Then begin
          // Список пуст.
          Result:=-1;
        end else begin
          // Список не пуст
          If aNext Then begin
            Result:=0;
          end else begin
            Result:=FList.Count-1;
          end;
        end;
      end else begin
        // Указан действительный индекс. Возвращаю следующий элемент.
        iI:=ITIntIndexToIndex(aIntIndex, False);
        If aNext Then begin
          If iI<(FList.Count-1) Then begin
            // Меньше самого последнего элемента
            Result:=iI+1;
          end else begin
            // Самый последний элемент, а нужен следующий
            Result:=-1;
          end;
        end else begin
          If iI>0 Then begin
            // больше первого элемента
            Result:=iI-1;
          end else begin
            // Первый, а нужен перед первым
            Result:=-1;
          end;
        end;
      end;
      If Result<0 Then begin
        aIntIndex:=-1;
      end else begin
        aIntIndex:=TVariantData(FList.Items[Result]).IntIndex;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITIntIndexToNextIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.ITViewNextGetOfIntIndex(Var aIntIndex:Integer):Variant;
  Var iI:Integer;
begin
  InternalLock;
  try
    try
      iI:=ITIntIndexToNextIndex(True, aIntIndex);
      If iI<0 Then begin
        Result:=Unassigned;
      end else begin
        Result:=ITView[iI];
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewNextGetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

procedure TVariantQueue.ITViewNextSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
  Var iI:Integer;
begin
  InternalLock;
  try
    try
      iI:=ITIntIndexToNextIndex(True, aIntIndex);
      If iI<0 Then begin
        // None
      end else begin
        ITView[iI]:=Value;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewNextSetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

function  TVariantQueue.ITViewPrevGetOfIntIndex(Var aIntIndex:Integer):Variant;
  Var iI:Integer;
begin
  InternalLock;
  try
    try
      iI:=ITIntIndexToNextIndex(False, aIntIndex);
      If iI<0 Then begin
        Result:=Unassigned;
      end else begin
        Result:=ITView[iI];
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewPrevGetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

procedure TVariantQueue.ITViewPrevSetOfIntIndex(Var aIntIndex:Integer; Value:Variant);
  Var iI:Integer;
begin
  InternalLock;
  try
    try
      iI:=ITIntIndexToNextIndex(False, aIntIndex);
      If iI<0 Then begin
        // None
      end else begin
        ITView[iI]:=Value;
      end;
    except
      on e:exception do
        Raise Exception.Create('ITViewPrevSetOfIntIndex: '+e.message);
    end;
  finally
    InternalUnLock;
  end;
end;

end.
