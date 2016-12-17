// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'UFiscalRegisterAMS100FUtilsTypes.pas' rev: 5.00

#ifndef UFiscalRegisterAMS100FUtilsTypesHPP
#define UFiscalRegisterAMS100FUtilsTypesHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <Windows.hpp>	// Pascal unit
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Ufiscalregisterams100futilstypes
{
//-- type declarations -------------------------------------------------------
typedef void __stdcall (*TAppCheckPrepare)(int Progress);

typedef void __stdcall (*TAppError)(int ErrorCode, char * ErrorMsg);

typedef void __stdcall (*TAppEvent)(void);

typedef void __fastcall (__closure *TOnCheckPrepareEvent)(int aProgress);

typedef void __fastcall (__closure *TOnErrorEvent)(int aErrorCode, char * aErrorMsg);

typedef void __fastcall (__closure *TOnEventEvent)(void);

typedef int __stdcall (*TcbAddBottomLine)(char * Line);

typedef int __stdcall (*TcbAddSale)(char * Name, double Price, double Qty, int Section);

typedef int __stdcall (*TcbAddTitleLine)(char * Line);

typedef int __stdcall (*TcbGetBottomLinesCount)(void);

typedef void __stdcall (*TcbClearBottom)(void);

typedef void __stdcall (*TcbSetCreditMode)(int Mode);

typedef int __stdcall (*TcbGetCreditMode)(void);

typedef void __stdcall (*TcbClearSales)(void);

typedef void __stdcall (*TcbClearTitle)(void);

typedef int __stdcall (*TcbDeleteSale)(int Index);

typedef int __stdcall (*TcbGetBottomLine)(int Index, char * &Line);

typedef int __stdcall (*TcbGetDiscountValue)(void);

typedef int __stdcall (*TcbGetSale)(int Index, char * &Name, double &Price, double &Qty, int &Section
	);

typedef int __stdcall (*TcbGetTitleLine)(int Index, char * &Line);

typedef int __stdcall (*TcbGetSalesCount)(void);

typedef void __stdcall (*TcbSetReturnMode)(int Mode);

typedef int __stdcall (*TcbGetReturnMode)(void);

typedef int __stdcall (*TcbSetCash)(double Value);

typedef double __stdcall (*TcbGetCash)(void);

typedef int __stdcall (*TcbSetDiscountValue)(int Value);

typedef int __stdcall (*TcbSetLinesInSale)(int Value);

typedef int __stdcall (*TcbGetLinesInSale)(void);

typedef double __stdcall (*TcbGetSum)(void);

typedef int __stdcall (*TcbGetTitleLinesCount)(void);

typedef void __stdcall (*TcbSetClearBufMode)(int Mode);

typedef int __stdcall (*TcbGetClearBufMode)(void);

typedef int __stdcall (*TRepeatCheck)(void);

typedef int __stdcall (*TClearIndicator)(void);

typedef int __stdcall (*TConnectKKM)(int Port);

typedef void __stdcall (*TDisconnectKKM)(void);

typedef int __stdcall (*TGetDiscountMode)(void);

typedef int __stdcall (*TGetErrorCode)(void);

typedef char * __stdcall (*TGetErrorMsg)(void);

typedef int __stdcall (*TFeed)(int LineCount);

typedef int __stdcall (*TGetBroughtSum)(double &Sum);

typedef int __stdcall (*TGetCashSum)(double &Sum);

typedef int __stdcall (*TGetKKMNum)(int &KKMNum);

typedef int __stdcall (*TGetKLNum)(int &KLNum);

typedef int __stdcall (*TGetNI)(double &NI);

typedef int __stdcall (*TGetRemovedQty)(int &Qty);

typedef int __stdcall (*TGetRemovedSum)(double &Sum);

typedef int __stdcall (*TGetReturnedSum)(double &Sum);

typedef int __stdcall (*TGetReturnedSumOnSection)(int Section, double &Sum);

typedef int __stdcall (*TGetSaleCountOnSection)(int Section, int &SaleCount);

typedef int __stdcall (*TGetSaleNum)(int &SaleNum);

typedef int __stdcall (*TGetSalesSumOnSection)(int Section, double &Sum);

typedef int __stdcall (*TGetSalesSumWithNDEC)(double &Sum);

typedef int __stdcall (*TGetSalesSumWithoutNDEC)(double &Sum);

typedef int __stdcall (*TGetKKMVers)(void);

typedef int __stdcall (*TLock)(void);

typedef int __stdcall (*TPrintBarCode)(char * Code, int DigitFlag);

typedef int __stdcall (*TReadSaleFromKL)(int SaleNum, int &Section, int &Credit, int &Discount, double 
	&Sum);

typedef void __stdcall (*TStartWaiting)(int StopFlag);

typedef void __stdcall (*TStopWaiting)(void);

typedef void __stdcall (*TSetSupplierCode)(char * Code);

typedef int __stdcall (*TUnLock)(void);

typedef int __stdcall (*TWaitingStatus)(void);

typedef void __stdcall (*TSetChPrepareEvent)(TAppCheckPrepare Ptr);

typedef void __stdcall (*TSetErrorEvent)(TAppError Ptr);

typedef void __stdcall (*TSetQueryEvent)(TAppEvent Ptr);

typedef void __stdcall (*TSetCloseCheckEvent)(TAppEvent Ptr);

typedef int __stdcall (*TKKMPrintStr)(AnsiString aString);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TOnCheckPrepareEvent cnOnCheckPrepare;
extern PACKAGE TOnErrorEvent cnOnError;
extern PACKAGE TOnEventEvent cnOnQuery;
extern PACKAGE TOnEventEvent cnOnCloseCheck;
extern PACKAGE _RTL_CRITICAL_SECTION cnSetAMS100FEvents;

}	/* namespace Ufiscalregisterams100futilstypes */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Ufiscalregisterams100futilstypes;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// UFiscalRegisterAMS100FUtilsTypes
