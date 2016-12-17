unit Maria301MTM_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 22.04.2004 15:31:49 from Type Library described below.

// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
// ************************************************************************ //
// Type Lib: E:\Program Files\ArtSoft\Maria301MTM\Maria301MTM.dll (1)
// IID\LCID: {62E3EE36-F803-4A01-9242-ADC43DC91724}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (E:\WINNT\system32\stdole2.tlb)
//   (2) v4.0 StdVCL, (E:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Error creating palette bitmap of (TCoMaria) : Invalid GUID format
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  Maria301MTMMajorVersion = 1;
  Maria301MTMMinorVersion = 0;

  LIBID_Maria301MTM: TGUID = '{62E3EE36-F803-4A01-9242-ADC43DC91724}';

  IID_IMaria: TGUID = '{62E3EE37-F803-4A01-9242-ADC43DC91724}';
  CLASS_CoMaria: TGUID = '{62E3EE38-F803-4A01-9242-ADC43DC91724}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IMaria = interface;
  IMariaDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CoMaria = IMaria;


// *********************************************************************//
// Interface: IMaria
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {62E3EE37-F803-4A01-9242-ADC43DC91724}
// *********************************************************************//
  IMaria = interface(IDispatch)
    ['{62E3EE37-F803-4A01-9242-ADC43DC91724}']
    function  OpenPort(iPortNumber: SYSINT; iBaudRate: SYSINT): SYSINT; stdcall;
    function  ClosePort: SYSINT; stdcall;
    function  CancelCheck: SYSINT; stdcall;
    function  CopyCheck: SYSINT; stdcall;
    function  XReport: SYSINT; stdcall;
    function  ZReport: SYSINT; stdcall;
    function  InOut(lSum: Integer): SYSINT; stdcall;
    function  OpenDrawer: SYSINT; stdcall;
    function  NullCheck: SYSINT; stdcall;
    function  CONf: SYSINT; stdcall;
    function  CNAL: SYSINT; stdcall;
    function  RepByArt: SYSINT; stdcall;
    function  RepByDis: SYSINT; stdcall;
    function  RepByDate(const BegDate: WideString; const EndDate: WideString): SYSINT; stdcall;
    function  RepByDateFull(const BegDate: WideString; const EndDate: WideString): SYSINT; stdcall;
    function  RepByNum(lBegNum: Integer; lEndNum: Integer): SYSINT; stdcall;
    function  RepByNumFull(lBegNum: Integer; lEndNum: Integer): SYSINT; stdcall;
    function  LongName(const Text: WideString): SYSINT; stdcall;
    function  SmenBegin(const Password: WideString; const Name: WideString): SYSINT; stdcall;
    function  OpenCheck(const Department: WideString): SYSINT; stdcall;
    function  Display(ulSum: LongWord): SYSINT; stdcall;
    function  ClearDisplay: SYSINT; stdcall;
    function  ReturnItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                         ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                         iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; iTaxE: SYSINT; 
                         iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; const DisName: WideString; 
                         lDiscount: Integer): SYSINT; stdcall;
    function  RegistrItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                          ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                          iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; 
                          iTaxE: SYSINT; iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; 
                          const DisName: WideString; lDiscount: Integer): SYSINT; stdcall;
    function  CloseCheck(ulOplata: LongWord; ulReturn: LongWord; ulTara: LongWord; 
                         ulCheck: LongWord; ulCredit: LongWord; ulNal: LongWord): SYSINT; stdcall;
    function  SetRetCheckNum(const Number: WideString): SYSINT; stdcall;
    function  TextComment(iTopDown: SYSINT; iPrint: SYSINT; iBold: SYSINT; const Text: WideString): SYSINT; stdcall;
    function  ClearComment: SYSINT; stdcall;
    procedure Debugger(bDebug: WordBool); safecall;
  end;

// *********************************************************************//
// DispIntf:  IMariaDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {62E3EE37-F803-4A01-9242-ADC43DC91724}
// *********************************************************************//
  IMariaDisp = dispinterface
    ['{62E3EE37-F803-4A01-9242-ADC43DC91724}']
    function  OpenPort(iPortNumber: SYSINT; iBaudRate: SYSINT): SYSINT; dispid 1;
    function  ClosePort: SYSINT; dispid 2;
    function  CancelCheck: SYSINT; dispid 3;
    function  CopyCheck: SYSINT; dispid 4;
    function  XReport: SYSINT; dispid 5;
    function  ZReport: SYSINT; dispid 6;
    function  InOut(lSum: Integer): SYSINT; dispid 7;
    function  OpenDrawer: SYSINT; dispid 1610743815;
    function  NullCheck: SYSINT; dispid 8;
    function  CONf: SYSINT; dispid 9;
    function  CNAL: SYSINT; dispid 10;
    function  RepByArt: SYSINT; dispid 11;
    function  RepByDis: SYSINT; dispid 12;
    function  RepByDate(const BegDate: WideString; const EndDate: WideString): SYSINT; dispid 13;
    function  RepByDateFull(const BegDate: WideString; const EndDate: WideString): SYSINT; dispid 27;
    function  RepByNum(lBegNum: Integer; lEndNum: Integer): SYSINT; dispid 14;
    function  RepByNumFull(lBegNum: Integer; lEndNum: Integer): SYSINT; dispid 28;
    function  LongName(const Text: WideString): SYSINT; dispid 15;
    function  SmenBegin(const Password: WideString; const Name: WideString): SYSINT; dispid 16;
    function  OpenCheck(const Department: WideString): SYSINT; dispid 17;
    function  Display(ulSum: LongWord): SYSINT; dispid 18;
    function  ClearDisplay: SYSINT; dispid 19;
    function  ReturnItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                         ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                         iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; iTaxE: SYSINT; 
                         iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; const DisName: WideString; 
                         lDiscount: Integer): SYSINT; dispid 20;
    function  RegistrItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                          ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                          iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; 
                          iTaxE: SYSINT; iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; 
                          const DisName: WideString; lDiscount: Integer): SYSINT; dispid 21;
    function  CloseCheck(ulOplata: LongWord; ulReturn: LongWord; ulTara: LongWord; 
                         ulCheck: LongWord; ulCredit: LongWord; ulNal: LongWord): SYSINT; dispid 22;
    function  SetRetCheckNum(const Number: WideString): SYSINT; dispid 23;
    function  TextComment(iTopDown: SYSINT; iPrint: SYSINT; iBold: SYSINT; const Text: WideString): SYSINT; dispid 24;
    function  ClearComment: SYSINT; dispid 25;
    procedure Debugger(bDebug: WordBool); dispid 26;
  end;

// *********************************************************************//
// The Class CoCoMaria provides a Create and CreateRemote method to          
// create instances of the default interface IMaria exposed by              
// the CoClass CoMaria. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCoMaria = class
    class function Create: IMaria;
    class function CreateRemote(const MachineName: string): IMaria;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCoMaria
// Help String      : 
// Default Interface: IMaria
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TCoMariaProperties= class;
{$ENDIF}
  TCoMaria = class(TOleServer)
  private
    FIntf:        IMaria;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TCoMariaProperties;
    function      GetServerProperties: TCoMariaProperties;
{$ENDIF}
    function      GetDefaultInterface: IMaria;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IMaria);
    procedure Disconnect; override;
    function  OpenPort(iPortNumber: SYSINT; iBaudRate: SYSINT): SYSINT;
    function  ClosePort: SYSINT;
    function  CancelCheck: SYSINT;
    function  CopyCheck: SYSINT;
    function  XReport: SYSINT;
    function  ZReport: SYSINT;
    function  InOut(lSum: Integer): SYSINT;
    function  OpenDrawer: SYSINT;
    function  NullCheck: SYSINT;
    function  CONf: SYSINT;
    function  CNAL: SYSINT;
    function  RepByArt: SYSINT;
    function  RepByDis: SYSINT;
    function  RepByDate(const BegDate: WideString; const EndDate: WideString): SYSINT;
    function  RepByDateFull(const BegDate: WideString; const EndDate: WideString): SYSINT;
    function  RepByNum(lBegNum: Integer; lEndNum: Integer): SYSINT;
    function  RepByNumFull(lBegNum: Integer; lEndNum: Integer): SYSINT;
    function  LongName(const Text: WideString): SYSINT;
    function  SmenBegin(const Password: WideString; const Name: WideString): SYSINT;
    function  OpenCheck(const Department: WideString): SYSINT;
    function  Display(ulSum: LongWord): SYSINT;
    function  ClearDisplay: SYSINT;
    function  ReturnItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                         ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                         iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; iTaxE: SYSINT; 
                         iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; const DisName: WideString; 
                         lDiscount: Integer): SYSINT;
    function  RegistrItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                          ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                          iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; 
                          iTaxE: SYSINT; iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; 
                          const DisName: WideString; lDiscount: Integer): SYSINT;
    function  CloseCheck(ulOplata: LongWord; ulReturn: LongWord; ulTara: LongWord; 
                         ulCheck: LongWord; ulCredit: LongWord; ulNal: LongWord): SYSINT;
    function  SetRetCheckNum(const Number: WideString): SYSINT;
    function  TextComment(iTopDown: SYSINT; iPrint: SYSINT; iBold: SYSINT; const Text: WideString): SYSINT;
    function  ClearComment: SYSINT;
    procedure Debugger(bDebug: WordBool);
    property  DefaultInterface: IMaria read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TCoMariaProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TCoMaria
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TCoMariaProperties = class(TPersistent)
  private
    FServer:    TCoMaria;
    function    GetDefaultInterface: IMaria;
    constructor Create(AServer: TCoMaria);
  protected
  public
    property DefaultInterface: IMaria read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

implementation

uses ComObj;

class function CoCoMaria.Create: IMaria;
begin
  Result := CreateComObject(CLASS_CoMaria) as IMaria;
end;

class function CoCoMaria.CreateRemote(const MachineName: string): IMaria;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CoMaria) as IMaria;
end;

procedure TCoMaria.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{62E3EE38-F803-4A01-9242-ADC43DC91724}';
    IntfIID:   '{62E3EE37-F803-4A01-9242-ADC43DC91724}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCoMaria.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IMaria;
  end;
end;

procedure TCoMaria.ConnectTo(svrIntf: IMaria);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TCoMaria.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TCoMaria.GetDefaultInterface: IMaria;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TCoMaria.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TCoMariaProperties.Create(Self);
{$ENDIF}
end;

destructor TCoMaria.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TCoMaria.GetServerProperties: TCoMariaProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function  TCoMaria.OpenPort(iPortNumber: SYSINT; iBaudRate: SYSINT): SYSINT;
begin
  Result := DefaultInterface.OpenPort(iPortNumber, iBaudRate);
end;

function  TCoMaria.ClosePort: SYSINT;
begin
  Result := DefaultInterface.ClosePort;
end;

function  TCoMaria.CancelCheck: SYSINT;
begin
  Result := DefaultInterface.CancelCheck;
end;

function  TCoMaria.CopyCheck: SYSINT;
begin
  Result := DefaultInterface.CopyCheck;
end;

function  TCoMaria.XReport: SYSINT;
begin
  Result := DefaultInterface.XReport;
end;

function  TCoMaria.ZReport: SYSINT;
begin
  Result := DefaultInterface.ZReport;
end;

function  TCoMaria.InOut(lSum: Integer): SYSINT;
begin
  Result := DefaultInterface.InOut(lSum);
end;

function  TCoMaria.OpenDrawer: SYSINT;
begin
  Result := DefaultInterface.OpenDrawer;
end;

function  TCoMaria.NullCheck: SYSINT;
begin
  Result := DefaultInterface.NullCheck;
end;

function  TCoMaria.CONf: SYSINT;
begin
  Result := DefaultInterface.CONf;
end;

function  TCoMaria.CNAL: SYSINT;
begin
  Result := DefaultInterface.CNAL;
end;

function  TCoMaria.RepByArt: SYSINT;
begin
  Result := DefaultInterface.RepByArt;
end;

function  TCoMaria.RepByDis: SYSINT;
begin
  Result := DefaultInterface.RepByDis;
end;

function  TCoMaria.RepByDate(const BegDate: WideString; const EndDate: WideString): SYSINT;
begin
  Result := DefaultInterface.RepByDate(BegDate, EndDate);
end;

function  TCoMaria.RepByDateFull(const BegDate: WideString; const EndDate: WideString): SYSINT;
begin
  Result := DefaultInterface.RepByDateFull(BegDate, EndDate);
end;

function  TCoMaria.RepByNum(lBegNum: Integer; lEndNum: Integer): SYSINT;
begin
  Result := DefaultInterface.RepByNum(lBegNum, lEndNum);
end;

function  TCoMaria.RepByNumFull(lBegNum: Integer; lEndNum: Integer): SYSINT;
begin
  Result := DefaultInterface.RepByNumFull(lBegNum, lEndNum);
end;

function  TCoMaria.LongName(const Text: WideString): SYSINT;
begin
  Result := DefaultInterface.LongName(Text);
end;

function  TCoMaria.SmenBegin(const Password: WideString; const Name: WideString): SYSINT;
begin
  Result := DefaultInterface.SmenBegin(Password, Name);
end;

function  TCoMaria.OpenCheck(const Department: WideString): SYSINT;
begin
  Result := DefaultInterface.OpenCheck(Department);
end;

function  TCoMaria.Display(ulSum: LongWord): SYSINT;
begin
  Result := DefaultInterface.Display(ulSum);
end;

function  TCoMaria.ClearDisplay: SYSINT;
begin
  Result := DefaultInterface.ClearDisplay;
end;

function  TCoMaria.ReturnItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                              ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                              iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; 
                              iTaxE: SYSINT; iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; 
                              const DisName: WideString; lDiscount: Integer): SYSINT;
begin
  Result := DefaultInterface.ReturnItem(Name, ulSum, ulPrice, ulQnty, iWeight, iRound, iTaxA, 
                                        iTaxB, iTaxV, iTaxG, iTaxD, iTaxE, iTaxJ, iTaxZ, ulCode, 
                                        DisName, lDiscount);
end;

function  TCoMaria.RegistrItem(const Name: WideString; ulSum: LongWord; ulPrice: LongWord; 
                               ulQnty: LongWord; iWeight: SYSINT; iRound: SYSINT; iTaxA: SYSINT; 
                               iTaxB: SYSINT; iTaxV: SYSINT; iTaxG: SYSINT; iTaxD: SYSINT; 
                               iTaxE: SYSINT; iTaxJ: SYSINT; iTaxZ: SYSINT; ulCode: LongWord; 
                               const DisName: WideString; lDiscount: Integer): SYSINT;
begin
  Result := DefaultInterface.RegistrItem(Name, ulSum, ulPrice, ulQnty, iWeight, iRound, iTaxA, 
                                         iTaxB, iTaxV, iTaxG, iTaxD, iTaxE, iTaxJ, iTaxZ, ulCode, 
                                         DisName, lDiscount);
end;

function  TCoMaria.CloseCheck(ulOplata: LongWord; ulReturn: LongWord; ulTara: LongWord; 
                              ulCheck: LongWord; ulCredit: LongWord; ulNal: LongWord): SYSINT;
begin
  Result := DefaultInterface.CloseCheck(ulOplata, ulReturn, ulTara, ulCheck, ulCredit, ulNal);
end;

function  TCoMaria.SetRetCheckNum(const Number: WideString): SYSINT;
begin
  Result := DefaultInterface.SetRetCheckNum(Number);
end;

function  TCoMaria.TextComment(iTopDown: SYSINT; iPrint: SYSINT; iBold: SYSINT; 
                               const Text: WideString): SYSINT;
begin
  Result := DefaultInterface.TextComment(iTopDown, iPrint, iBold, Text);
end;

function  TCoMaria.ClearComment: SYSINT;
begin
  Result := DefaultInterface.ClearComment;
end;

procedure TCoMaria.Debugger(bDebug: WordBool);
begin
  DefaultInterface.Debugger(bDebug);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TCoMariaProperties.Create(AServer: TCoMaria);
begin
  inherited Create;
  FServer := AServer;
end;

function TCoMariaProperties.GetDefaultInterface: IMaria;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents('ActiveX',[TCoMaria]);
end;

end.
