// Borland C++ Builder
// Copyright (c) 1995, 1999 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'UMThreadConsts.pas' rev: 5.00

#ifndef UMThreadConstsHPP
#define UMThreadConstsHPP

#pragma delphiheader begin
#pragma option push -w-
#pragma option push -Vx
#include <SysInit.hpp>	// Pascal unit
#include <System.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Umthreadconsts
{
//-- type declarations -------------------------------------------------------
//-- var, const, procedure ---------------------------------------------------
static const unsigned cnTlsNoIndex = 0xffffffff;
extern PACKAGE unsigned cnTlsThreadBreak;
extern PACKAGE unsigned cnTlsMThreadObject;
extern PACKAGE int cnMThreadCount;
extern PACKAGE int cnMThreadCreatedCount;

}	/* namespace Umthreadconsts */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Umthreadconsts;
#endif
#pragma option pop	// -w-
#pragma option pop	// -Vx

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// UMThreadConsts
