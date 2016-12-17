// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'UFiscalRegisterAMS100F.pas' rev: 5.00

#ifndef UFiscalRegisterAMS100FHPP
#define UFiscalRegisterAMS100FHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <UFiscalRegisterAMS100FUtilsTypes.hpp>	// Pascal unit
#include <UFiscalRegisterAMS100FUtils.hpp>	// Pascal unit
#include <UFiscalRegisterAMS100FTypes.hpp>	// Pascal unit
#include <UIObject.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ufiscalregisterams100f
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TFiscalRegisterAMS100F;
class PASCALIMPLEMENTATION TFiscalRegisterAMS100F : public Uiobject::TIObject 
{
	typedef Uiobject::TIObject inherited;
	
protected:
	unsigned FLibraryHandle;
	AnsiString FSupplierCode;
	Byte FComPortNum;
	bool FCheckIsPrinted;
	AnsiString FErrorMessage;
	unsigned FSaleRowCountMax;
	unsigned FSaleRowCount;
	Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent FOldOnCheckPrepare;
	Ufiscalregisterams100futilstypes::TOnErrorEvent FOldOnError;
	Ufiscalregisterams100futilstypes::TOnEventEvent FOldOnQuery;
	Ufiscalregisterams100futilstypes::TOnEventEvent FOldOnCloseCheck;
	Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent FOnCheckPrepare;
	Ufiscalregisterams100futilstypes::TOnErrorEvent FOnError;
	Ufiscalregisterams100futilstypes::TOnEventEvent FOnQuery;
	Ufiscalregisterams100futilstypes::TOnEventEvent FOnCloseCheck;
	Ufiscalregisterams100ftypes::TOnWaitForFCBBEvent FOnWaitForFCBB;
	virtual void __fastcall InternalConnect(void);
	virtual void __fastcall InternalDisconnect(void);
	virtual void __fastcall InternalInit(void);
	virtual void __fastcall InternalFiscalPrint(void * aUserData, unsigned aCheckNum, unsigned aCheckCount
		);
	virtual void __fastcall InternalInitEvents(void);
	virtual void __fastcall InternalFinalEvents(void);
	virtual void __fastcall InternalOnCheckPrepare(int aProgress);
	virtual void __fastcall InternalOnError(int aErrorCode, char * aErrorMsg);
	virtual void __fastcall InternalOnQuery(void);
	virtual void __fastcall InternalOnCloseCheck(void);
	virtual Ufiscalregisterams100ftypes::TfiscalprintResult __fastcall InternalprintfiscalCheck(bool aSale
		, double aSummAllNal, double aSummAllCredit, unsigned aSaleRowCount, void * aUserData, Ufiscalregisterams100ftypes::TAddItemAMS100FEvent 
		aOnGetItem, Ufiscalregisterams100ftypes::TOnFiscalPrintIsSuccessEvent aOnSetFiscalPrintIsSuccess);
		
	virtual Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent __fastcall GetOnCheckPrepare(void);
	virtual void __fastcall SetOnCheckPrepare(Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent value
		);
	virtual Ufiscalregisterams100futilstypes::TOnErrorEvent __fastcall GetOnError(void);
	virtual void __fastcall SetOnError(Ufiscalregisterams100futilstypes::TOnErrorEvent value);
	virtual Ufiscalregisterams100futilstypes::TOnEventEvent __fastcall GetOnQuery(void);
	virtual void __fastcall SetOnQuery(Ufiscalregisterams100futilstypes::TOnEventEvent value);
	virtual Ufiscalregisterams100futilstypes::TOnEventEvent __fastcall GetOnCloseCheck(void);
	virtual void __fastcall SetOnCloseCheck(Ufiscalregisterams100futilstypes::TOnEventEvent value);
	virtual Ufiscalregisterams100ftypes::TOnWaitForFCBBEvent __fastcall GetOnWaitForFCBB(void);
	virtual void __fastcall SetOnWaitForFCBB(Ufiscalregisterams100ftypes::TOnWaitForFCBBEvent value);
	virtual unsigned __fastcall GetSaleRowCount(void);
	virtual void __fastcall SetSaleRowCount(unsigned value);
	
public:
	__fastcall TFiscalRegisterAMS100F(const AnsiString aSupplierCode, Byte aComPortNum);
	__fastcall virtual ~TFiscalRegisterAMS100F(void);
	virtual bool __fastcall printfiscalCheckConnected(/* out */ AnsiString &aErrorMessage);
	virtual void __fastcall printfiscalAddTitleLine(const AnsiString aTitleLine);
	virtual void __fastcall printfiscalAddBottomLine(const AnsiString aBottomLine);
	virtual Ufiscalregisterams100ftypes::TfiscalprintResult __fastcall printfiscalSale(double aSummAllNal
		, double aSummAllCredit, unsigned aRowCount, void * aUserData, Ufiscalregisterams100ftypes::TAddItemAMS100FEvent 
		aOnSaleItem, Ufiscalregisterams100ftypes::TOnFiscalPrintIsSuccessEvent aOnFiscalPrintIsSuccess);
	virtual Ufiscalregisterams100ftypes::TfiscalprintResult __fastcall printfiscalReturn(double aSummAllNal
		, double aSummAllCredit, unsigned aRowCount, void * aUserData, Ufiscalregisterams100ftypes::TAddItemAMS100FEvent 
		aOnReturnItem, Ufiscalregisterams100ftypes::TOnFiscalPrintIsSuccessEvent aOnFiscalPrintIsSuccess);
		
	virtual void __fastcall printfiscalClearIndicator(void);
	virtual void __fastcall printfiscalString(const AnsiString aString);
	virtual void __fastcall printfiscalRepeatCheck(void);
	virtual void __fastcall printfiscalFeed(int aLineCount);
	virtual void __fastcall printfiscalKeyboardLock(void);
	virtual void __fastcall printfiscalKeyboardUnlock(void);
	__property Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent OnCheckPrepare = {read=GetOnCheckPrepare
		, write=SetOnCheckPrepare};
	__property Ufiscalregisterams100futilstypes::TOnErrorEvent OnError = {read=GetOnError, write=SetOnError
		};
	__property Ufiscalregisterams100futilstypes::TOnEventEvent OnQuery = {read=GetOnQuery, write=SetOnQuery
		};
	__property Ufiscalregisterams100futilstypes::TOnEventEvent OnCloseCheck = {read=GetOnCloseCheck, write=
		SetOnCloseCheck};
	__property Ufiscalregisterams100ftypes::TOnWaitForFCBBEvent OnWaitForFCBB = {read=GetOnWaitForFCBB, 
		write=SetOnWaitForFCBB};
	__property unsigned SaleRowCount = {read=GetSaleRowCount, write=SetSaleRowCount, nodefault};
private:
		
	void *__IFiscalRegisterAMS100F;	/* Ufiscalregisterams100ftypes::IFiscalRegisterAMS100F */
	
public:
	operator IFiscalRegisterAMS100F*(void) { return (IFiscalRegisterAMS100F*)&__IFiscalRegisterAMS100F; }
		
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ufiscalregisterams100f */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Ufiscalregisterams100f;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// UFiscalRegisterAMS100F
