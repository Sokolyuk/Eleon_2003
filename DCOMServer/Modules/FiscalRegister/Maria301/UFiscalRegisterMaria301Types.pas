//Copyright � 2000-2004 by Dmitry A. Sokolyuk
unit UFiscalRegisterMaria301Types;

interface

type
  TAddItemEvent = function (aUserData:Pointer; out aArtCode:Cardinal; out aTradeName:AnsiString; out aLongName:AnsiString; out aPrice, aCount:Cardinal; out aReductionName:AnsiString; out aDiscount:integer):boolean of object;//result true - out data is set, false - no set out data.
  //!!!�������� ���� tmpDiscount < 0 - ��� ������; ����� ��������.

  IFiscalRegisterMaria301 = interface ['{4A1EBF7A-C54A-4085-9F92-6813A195DF8E}']
    function GetIMaria:IUnknown;
    property IMaria:IUnknown read GetIMaria;
    procedure printfiscalZReport();
    procedure printfiscalXReport();
    procedure printfiscalEncashment(aSumm:cardinal);//����������
    procedure printfiscalReplenishment(aSumm:cardinal);//����������
    procedure printfiscalOpenDrawer();
    procedure printfiscalNullCheck();
    procedure printfiscalSale(aSummAllNal, aSummAllCredit:cardinal; aUserData:Pointer; aOnSaleItem:TAddItemEvent);//!!!�������� ���� tmpDiscount < 0 - ��� ������; ����� ��������.
    procedure printfiscalReturn(aSummAllNal:cardinal; aSummAllCredit:cardinal; aUserData:Pointer; aOnReturnItem:TAddItemEvent);
  end;

implementation

end.
