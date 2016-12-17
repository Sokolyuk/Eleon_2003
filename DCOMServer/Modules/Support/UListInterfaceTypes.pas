unit UListInterfaceTypes;

interface
Type
  IListInterface=Interface
  ['{9E18D8E7-767D-4C27-8213-7528AB3C0DD4}']
    Function Clear:Boolean;
    Function ClearOfIntIndex(aIntIndex:Integer):Boolean;
    Function Clone:IListInterface;
    Procedure Assign(aIListInterface:IListInterface);
    Procedure Append(aIListInterface:IListInterface);
    //..
    Procedure Push(aIUnknown:IUnknown); Overload;
    Procedure Push(Out aIntIndex:Integer; aIUnknown:IUnknown); Overload;
    Function Pop:IUnknown; Overload;
    Function Pop(Out aIntIndex:Integer):IUnknown; Overload;
    Procedure PushOfIntIndex(aIntIndex:Integer; aIUnknown:IUnknown);
    Function PopOfIntIndex(aIntIndex:Integer):IUnknown;
    Function ViewNextOfIntIndex(Var aIntIndex:Integer):IUnknown;
    Function ViewPrevOfIntIndex(Var aIntIndex:Integer):IUnknown;
    Function ExistIntIndex(aIntIndex:Integer):Boolean;
    //..
    Function Get_Count:Integer;
    function Get_View(Index:Integer):IUnknown;
    Function Get_ConfigCheckUniqueIntIndex:Boolean;
    Procedure Set_ConfigCheckUniqueIntIndex(Value:Boolean);
    Function Get_ConfigMaxCount:Cardinal;
    Procedure Set_ConfigMaxCount(Value:Cardinal);
    Function Get_ConfigNoFoundException:Boolean;
    Procedure Set_ConfigNoFoundException(Value:Boolean);
    //..
    Property Count:Integer read Get_Count;
    Property View[Index:Integer]:IUnknown read Get_View;
    Property ConfigCheckUniqueIntIndex:Boolean read Get_ConfigCheckUniqueIntIndex write Set_ConfigCheckUniqueIntIndex;
    Property ConfigMaxCount:Cardinal read Get_ConfigMaxCount write Set_ConfigMaxCount;
    Property ConfigNoFoundException:Boolean read Get_ConfigNoFoundException write Set_ConfigNoFoundException;
  end;

implementation

end.
