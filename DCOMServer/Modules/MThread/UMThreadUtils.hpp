// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'UMThreadUtils.pas' rev: 5.00

#ifndef UMThreadUtilsHPP
#define UMThreadUtilsHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Umthreadutils
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
extern PACKAGE bool __fastcall MThreadBreak(bool aRaise);
extern PACKAGE System::TObject* __fastcall MThreadObject(bool aRaise);

}	/* namespace Umthreadutils */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Umthreadutils;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// UMThreadUtils
