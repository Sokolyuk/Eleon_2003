//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UFiscalRegisterMaria301;

interface
  uses UIObject, Maria301MTM_TLB, UFiscalRegisterMaria301Types;

type
  TFiscalRegisterMaria301 = class(TIObject, IFiscalRegisterMaria301)
  protected
    FIMaria: IMaria;
    FOpenPort: boolean;
  protected
    FShopName:AnsiString;
    FCashierName:AnsiString;
    FPortNumber:integer;
  public
    constructor create(const aShopName:AnsiString; const aCashierName:AnsiString; aPortNumber:byte);
    destructor destroy;override;
  protected
    function GetIMaria:IUnknown;virtual;
  public
    property IMaria:IUnknown read GetIMaria;
    procedure printfiscalZReport();virtual;
    procedure printfiscalXReport();virtual;
    procedure printfiscalEncashment(aSumm:cardinal);virtual;//Инкассация
    procedure printfiscalReplenishment(aSumm:cardinal);virtual;//Пополнение
    procedure printfiscalOpenDrawer();virtual;
    procedure printfiscalNullCheck();virtual;
    procedure printfiscalSale(aSummAllNal, aSummAllCredit:cardinal; aUserData:Pointer; aOnSaleItem:TAddItemEvent);virtual;//!!!ВНИМАНИЕ если tmpDiscount < 0 - это скидка; иначе надбавка.
    procedure printfiscalReturn(aSummAllNal:cardinal; aSummAllCredit:cardinal; aUserData:Pointer; aOnReturnItem:TAddItemEvent);virtual;
  end;


implementation
  uses ComObj, sysutils, UFiscalRegisterMaria301Utils;

constructor TFiscalRegisterMaria301.create(const aShopName:AnsiString; const aCashierName:AnsiString; aPortNumber:byte);
  var tmpIUnknown:IUnknown;
begin
  inherited create;

  FOpenPort := false;

  try
    if Length(aShopName) > 15 then raise exception.create('aShopName('''+aShopName+''') too long(max 15 symbols).');
    if Length(aCashierName) > 9 then raise exception.create('aCashierName('''+aCashierName+''') too long(max 9 symbols).');

    FPortNumber := aPortNumber;
    FShopName := aShopName;
    FCashierName := aCashierName;

    try
      tmpIUnknown := CreateComObject(CLASS_CoMaria);
    except on e:exception do begin
      e.message := 'Создание управляющей компоненты: ' + e.message;
      raise;
    end;end;

    OleCheck(tmpIUnknown.QueryInterface(IID_IMaria, FIMaria));
    if not assigned(FIMaria) then raise exception.create('IMaria no found');
  except
    //до этого места порт не открывался, а создавались только объекты, поэтому их сразу забиваю, а вот порт после, и закроется он в destroy-е
    FIMaria := nil;
    raise;
  end;

  FiscalRegisterResultCheck('OpenPort', FIMaria.OpenPort(FPortNumber, 57600));
  FOpenPort := true;

  FiscalRegisterResultCheck('SmenBegin', FIMaria.SmenBegin('1111111111', FCashierName));
end;

destructor TFiscalRegisterMaria301.destroy;
begin
  if assigned(FIMaria) then begin
    if FOpenPort then FIMaria.ClosePort();
    FIMaria := nil;
  end;
  
  inherited destroy;
end;

function TFiscalRegisterMaria301.GetIMaria:IUnknown;
begin
  OleCheck(FIMaria.QueryInterface(IUnknown, result));
end;

procedure TFiscalRegisterMaria301.printfiscalZReport;
begin
  FiscalRegisterResultCheck('ZReport', FIMaria.ZReport);
end;

procedure TFiscalRegisterMaria301.printfiscalXReport;
begin
  FiscalRegisterResultCheck('XReport', FIMaria.XReport);
end;

procedure TFiscalRegisterMaria301.printfiscalEncashment(aSumm:cardinal);//Инкассация
begin
  FiscalRegisterResultCheck('InOut.encash', FIMaria.InOut((-1)*(integer(aSumm))));
end;

procedure TFiscalRegisterMaria301.printfiscalReplenishment(aSumm:cardinal);//Пополнение
begin
  FiscalRegisterResultCheck('InOut.repl', FIMaria.InOut(aSumm));
end;

(*procedure TFiscalRegisterMaria301.printfiscalInOut(aSumm:integer);
  var tmpResult:integer;
begin
  tmpResult := FIMaria.InOut(aSumm);
  if tmpResult <> aSumm then raise exception.create('InOut('+IntToStr(aSumm)+') <> '+IntToStr(tmpResult));
end;*)

procedure TFiscalRegisterMaria301.printfiscalOpenDrawer();
begin
  FiscalRegisterResultCheck('OpenDrawer', FIMaria.OpenDrawer);
end;

procedure TFiscalRegisterMaria301.printfiscalNullCheck();
begin
  FiscalRegisterResultCheck('NullCheck', FIMaria.NullCheck);
end;

function LocalGetTradeArtName(aTradeName:AnsiString; aSymbols:cardinal):AnsiString;
begin
  result := aTradeName;
  result := copy(result, 1, aSymbols);
end;

procedure TFiscalRegisterMaria301.printfiscalSale(aSummAllNal, aSummAllCredit:cardinal; aUserData:Pointer; aOnSaleItem:TAddItemEvent);
  var tmpTradeName, tmpTradeArtName, tmpLongName, tmpReductionName, tmpDiscountName:AnsiString;
      tmpPrice, tmpCount, tmpArtCode:cardinal;
      tmpDiscount:integer;
begin
  try
    if not assigned(aOnSaleItem) then raise exception.create('aOnSaleItem not assigned');

    FiscalRegisterResultCheck('Display', FIMaria.Display(aSummAllNal + aSummAllCredit));

    FiscalRegisterResultCheck('OpenCheck', FIMaria.OpenCheck(FShopName));
    try

      while true do begin
        if not aOnSaleItem(aUserData, tmpArtCode, tmpTradeName, tmpLongName, tmpPrice, tmpCount, tmpReductionName, tmpDiscount) then break;

        if tmpLongName <> '' then begin
          tmpLongName := copy(tmpLongName, 1, 72);//обрезаю до 72 символов
          FiscalRegisterResultCheck('LongName', FIMaria.LongName(tmpLongName));
        end;  

        tmpTradeArtName := LocalGetTradeArtName(tmpTradeName, 36);//обрезаю до 36 символов
        tmpDiscountName := copy(tmpDiscountName, 1, 13);//обрезаю до 13 символов

        FiscalRegisterResultCheck('RegistrItem', FIMaria.RegistrItem(tmpTradeArtName,
          tmpPrice*tmpCount,//unsigned_long ulSum/*[in]*/,
          tmpPrice,//unsigned_long ulPrice/*[in]*/,
          tmpCount,//unsigned_long ulQnty/*[in]*/,
          1,//int iWeight/*[in]*/,
          2,//int iRound/*[in]*/,
          1,//int iTaxA/*[in]*/, //1 - НДС
          0,//int iTaxB/*[in]*/,
          0,//int iTaxV/*[in]*/,
          0,//int iTaxG/*[in]*/,
          0,//int iTaxD/*[in]*/,
          0,//int iTaxE/*[in]*/,
          0,//int iTaxJ/*[in]*/,
          0,//int iTaxZ/*[in]*/,
          tmpArtCode,//unsigned_long ulCode/*[in]*/,
          tmpReductionName,//BSTR DisName/*[in]*/,
          tmpDiscount)//long lDiscount/*[in]*/) = 0; // [21]
        );
      end;

      FiscalRegisterResultCheck('CloseCheck', FIMaria.CloseCheck(
        aSummAllNal + aSummAllCredit,//unsigned_long ulOplata/*[in]*/,
        0,//unsigned_long ulReturn/*[in]*/,
        0,//unsigned_long ulTara/*[in]*/,
        0,//unsigned_long ulCheck/*[in]*/,
        aSummAllCredit,//unsigned_long ulCredit/*[in]*/,
        aSummAllNal//unsigned_long ulNal/*[in]*/
      ));
    except
      FIMaria.CancelCheck();
      raise;
    end;  
  except on e:exception do begin
    e.message := 'printfiscalSale: ' + e.message;
    raise;
  end;end;
end;

procedure TFiscalRegisterMaria301.printfiscalReturn(aSummAllNal:cardinal; aSummAllCredit:cardinal; aUserData:Pointer; aOnReturnItem:TAddItemEvent);
  var tmpTradeName, tmpTradeArtName, tmpLongName, tmpReductionName, tmpDiscountName:AnsiString;
      tmpPrice, tmpCount, tmpArtCode:cardinal;
      tmpDiscount:integer;
begin
  try
    if not assigned(aOnReturnItem) then raise exception.create('aOnReturnItem not assigned');

    FiscalRegisterResultCheck('Display', FIMaria.Display(aSummAllNal + aSummAllCredit));//FiscalRegisterResultCheck('Display', FIMaria.Display(aSummAll));

    FiscalRegisterResultCheck('OpenCheck', FIMaria.OpenCheck(FShopName));
    try
      while true do begin
        if not aOnReturnItem(aUserData, tmpArtCode, tmpTradeName, tmpLongName, tmpPrice, tmpCount, tmpReductionName, tmpDiscount) then break;

        if tmpLongName <> '' then begin
          tmpLongName := copy(tmpLongName, 1, 72);//обрезаю до 72 символов
          FiscalRegisterResultCheck('LongName', FIMaria.LongName(tmpLongName));
        end;  

        tmpTradeArtName := LocalGetTradeArtName(tmpTradeName, 36);//обрезаю до 36 символов
        tmpDiscountName := copy(tmpDiscountName, 1, 13);//обрезаю до 13 символов

        FiscalRegisterResultCheck('ReturnItem', FIMaria.ReturnItem(tmpTradeArtName,
          tmpPrice*tmpCount,//unsigned_long ulSum/*[in]*/,
          tmpPrice,//unsigned_long ulPrice/*[in]*/,
          tmpCount,//unsigned_long ulQnty/*[in]*/,
          1,//int iWeight/*[in]*/,
          2,//int iRound/*[in]*/,
          1,//int iTaxA/*[in]*/, // 0 - НДС
          0,//int iTaxB/*[in]*/,
          0,//int iTaxV/*[in]*/,
          0,//int iTaxG/*[in]*/,
          0,//int iTaxD/*[in]*/,
          0,//int iTaxE/*[in]*/,
          0,//int iTaxJ/*[in]*/,
          0,//int iTaxZ/*[in]*/,
          tmpArtCode,//unsigned_long ulCode/*[in]*/,
          tmpReductionName,//BSTR DisName/*[in]*/,
          tmpDiscount)//long lDiscount/*[in]*/) = 0; // [21] - !!!ВНИМАНИЕ если tmpDiscount < 0 - это скидка; иначе надбавка.
        );
      end;

      FiscalRegisterResultCheck('CloseCheck', FIMaria.CloseCheck(
        0,//unsigned_long ulOplata/*[in]*/,
        aSummAllNal+aSummAllCredit,//unsigned_long ulReturn/*[in]*/,
        0,//unsigned_long ulTara/*[in]*/,
        0,//unsigned_long ulCheck/*[in]*/,
   {???}aSummAllCredit,//работало так: 0,//unsigned_long ulCredit/*[in]*/,
        0//unsigned_long ulNal/*[in]*/
      ));
    except
      FIMaria.CancelCheck();
      raise;
    end;
  except on e:exception do begin
    e.message := 'printfiscalReturn: ' + e.message;
    raise;
  end;end;
end;





end.
