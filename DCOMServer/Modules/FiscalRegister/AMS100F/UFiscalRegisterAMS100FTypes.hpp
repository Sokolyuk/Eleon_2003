// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'UFiscalRegisterAMS100FTypes.pas' rev: 5.00

#ifndef UFiscalRegisterAMS100FTypesHPP
#define UFiscalRegisterAMS100FTypesHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <UFiscalRegisterAMS100FUtilsTypes.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ufiscalregisterams100ftypes
{
//-- type declarations -------------------------------------------------------
typedef bool __fastcall (__closure *TAddItemAMS100FEvent)(void * aUserData, /* out */ AnsiString &aTradeName
	, /* out */ AnsiString &aArtName, /* out */ AnsiString &aUniStr36, /* out */ double &aSumm, /* out */ 
	double &aCount, /* out */ unsigned &aShopSection);

typedef void __fastcall (__closure *TOnFiscalPrintIsSuccessEvent)(void * aUserData, unsigned aCheckNum
	, unsigned aCheckCount);

typedef void __fastcall (__closure *TOnWaitForFCBBEvent)(void * aUserData, unsigned aCheckNum, unsigned 
	aCheckCount);

#pragma option push -b-
enum TfiscalprintResult { fprPrintedNone, fprPrintedAll, fprPrintedPart };
#pragma option pop

__interface IFiscalRegisterAMS100F;
typedef System::DelphiInterface<IFiscalRegisterAMS100F> _di_IFiscalRegisterAMS100F;
__interface INTERFACE_UUID("{4CCFE692-9D64-486E-88D8-FCDB51AC4E8F}") IFiscalRegisterAMS100F  : public IUnknown 
	
{
	
public:
	virtual Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent __fastcall GetOnCheckPrepare(void) = 0 
		;
	virtual void __fastcall SetOnCheckPrepare(Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent value
		) = 0 ;
	virtual Ufiscalregisterams100futilstypes::TOnErrorEvent __fastcall GetOnError(void) = 0 ;
	virtual void __fastcall SetOnError(Ufiscalregisterams100futilstypes::TOnErrorEvent value) = 0 ;
	virtual Ufiscalregisterams100futilstypes::TOnEventEvent __fastcall GetOnQuery(void) = 0 ;
	virtual void __fastcall SetOnQuery(Ufiscalregisterams100futilstypes::TOnEventEvent value) = 0 ;
	virtual Ufiscalregisterams100futilstypes::TOnEventEvent __fastcall GetOnCloseCheck(void) = 0 ;
	virtual void __fastcall SetOnCloseCheck(Ufiscalregisterams100futilstypes::TOnEventEvent value) = 0 
		;
	virtual TOnWaitForFCBBEvent __fastcall GetOnWaitForFCBB(void) = 0 ;
	virtual void __fastcall SetOnWaitForFCBB(TOnWaitForFCBBEvent value) = 0 ;
	virtual unsigned __fastcall GetSaleRowCount(void) = 0 ;
	virtual void __fastcall SetSaleRowCount(unsigned value) = 0 ;
	__property Ufiscalregisterams100futilstypes::TOnCheckPrepareEvent OnCheckPrepare = {read=GetOnCheckPrepare
		, write=SetOnCheckPrepare};
	__property Ufiscalregisterams100futilstypes::TOnErrorEvent OnError = {read=GetOnError, write=SetOnError
		};
	__property Ufiscalregisterams100futilstypes::TOnEventEvent OnQuery = {read=GetOnQuery, write=SetOnQuery
		};
	__property Ufiscalregisterams100futilstypes::TOnEventEvent OnCloseCheck = {read=GetOnCloseCheck, write=
		SetOnCloseCheck};
	__property TOnWaitForFCBBEvent OnWaitForFCBB = {read=GetOnWaitForFCBB, write=SetOnWaitForFCBB};
	__property unsigned SaleRowCount = {read=GetSaleRowCount, write=SetSaleRowCount};
	virtual bool __fastcall printfiscalCheckConnected(/* out */ AnsiString &aErrorMessage) = 0 ;
	virtual void __fastcall printfiscalAddTitleLine(const AnsiString aTitleLine) = 0 ;
	virtual void __fastcall printfiscalAddBottomLine(const AnsiString aBottomLine) = 0 ;
	virtual TfiscalprintResult __fastcall printfiscalSale(double aSummAllNal, double aSummAllCredit, unsigned 
		aRowCount, void * aUserData, TAddItemAMS100FEvent aOnSaleItem, TOnFiscalPrintIsSuccessEvent aOnFiscalPrintIsSuccess
		) = 0 ;
	virtual TfiscalprintResult __fastcall printfiscalReturn(double aSummAllNal, double aSummAllCredit, 
		unsigned aRowCount, void * aUserData, TAddItemAMS100FEvent aOnReturnItem, TOnFiscalPrintIsSuccessEvent 
		aOnFiscalPrintIsSuccess) = 0 ;
	virtual void __fastcall printfiscalClearIndicator(void) = 0 ;
	virtual void __fastcall printfiscalString(const AnsiString aString) = 0 ;
	virtual void __fastcall printfiscalRepeatCheck(void) = 0 ;
	virtual void __fastcall printfiscalFeed(int aLineCount) = 0 ;
	virtual void __fastcall printfiscalKeyboardLock(void) = 0 ;
	virtual void __fastcall printfiscalKeyboardUnlock(void) = 0 ;
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ufiscalregisterams100ftypes */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Ufiscalregisterams100ftypes;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// UFiscalRegisterAMS100FTypes
