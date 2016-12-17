//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UTaskImplementEQueryInterfaceUtilsUtils;

interface
  uses UCallerTypes;
  function EQueryInterfaceParamToVariant(const aGuid:TGuid):Variant;
  procedure VariantToEQueryInterfaceParam(const aParam:Variant; out aGuid:TGuid);
  function EQueryInterfaceByLevelParamToVariant(aLevel:Integer; const aGuid:TGuid):Variant;
  procedure VariantToEQueryInterfaceByLevelParam(const aParam:Variant; out aLevel:Integer; out aGuid:TGuid);
  function EQueryInterfaceByNodeNameParamToVariant(const aNodeName:AnsiString; const aGuid:TGuid):Variant;
  procedure VariantToEQueryInterfaceByNodeNameParam(const aParam:Variant; out aNodeName:AnsiString; out aGuid:TGuid);
  //..
  procedure UpEQueryInterfaceViaBridge(aCallerAction:ICallerAction; aGuid:TGUID; out aInterface:IDispatch);
  procedure UpEQueryInterfaceByLevelViaBridge(aCallerAction:ICallerAction; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
  procedure UpEQueryInterfaceByNodeNameViaBridge(aCallerAction:ICallerAction; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
  procedure UpEQueryInterfaceViaAsm(aCallerAction:ICallerAction; aASM:Integer; aGuid:TGUID; out aInterface:IDispatch);
  procedure UpEQueryInterfaceByLevelViaAsm(aCallerAction:ICallerAction; aASM:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
  procedure UpEQueryInterfaceByNodeNameViaAsm(aCallerAction:ICallerAction; aASM:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceViaBridge(aCallerAction:ICallerAction; aBridge:Integer; aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceByLevelViaBridge(aCallerAction:ICallerAction; aBridge:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceByNodeNameViaBridge(aCallerAction:ICallerAction; aBridge:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceViaASM(aCallerAction:ICallerAction; aASM:Integer; aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceByLevelViaASM(aCallerAction:ICallerAction; aASM:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
  procedure DnEQueryInterfaceByNodeNameViaASM(aCallerAction:ICallerAction; aASM:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);

implementation
  uses UTypeUtils{$IFNDEF VER130}, Variants{$ENDIF}{$Ifndef ESClient}, UAdmittanceAsmTypes, UAS, UAsmConsts{$endif}, UTrayConsts,
       Sysutils, UErrorConsts, UEQueryInterfaceCnnTypes{$Ifdef ESClient}, UEServerConnectionsTypes{$endif}, UTrayTypes;

function EQueryInterfaceParamToVariant(const aGuid:TGuid):Variant;
begin
  result:=GuidToVariant(aGuid);
end;

procedure VariantToEQueryInterfaceParam(const aParam:Variant; out aGuid:TGuid);
begin
  aGuid:=VariantToGuid(aParam);
end;

function EQueryInterfaceByLevelParamToVariant(aLevel:Integer; const aGuid:TGuid):Variant;
begin
  result:=VarArrayOf([aLevel, GuidToVariant(aGuid)]);
end;

procedure VariantToEQueryInterfaceByLevelParam(const aParam:Variant; out aLevel:Integer; out aGuid:TGuid);
begin
  aLevel:=aParam[0];
  aGuid:=VariantToGuid(aParam[1]);
end;

function EQueryInterfaceByNodeNameParamToVariant(const aNodeName:AnsiString; const aGuid:TGuid):Variant;
begin
  result:=VarArrayOf([aNodeName, GuidToVariant(aGuid)]);
end;

procedure VariantToEQueryInterfaceByNodeNameParam(const aParam:Variant; out aNodeName:AnsiString; out aGuid:TGuid);
begin
  aNodeName:=aParam[0];
  aGuid:=VariantToGuid(aParam[1]);
end;

function InternalGetITray:ITray;
begin
  result:=cnTray;
  if not assigned(result) then raise exception.create('cnTray not assigned.');
end;

procedure UpEQueryInterfaceViaBridge(aCallerAction:ICallerAction; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnn(aCallerAction, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceViaBridge'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['UpEQueryInterfaceViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure UpEQueryInterfaceByLevelViaBridge(aCallerAction:ICallerAction; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnnByLevel(aCallerAction, aLevel, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found for level='+IntToStr(aLevel)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceByLevelViaBridge'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['UpEQueryInterfaceByLevelViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure UpEQueryInterfaceByNodeNameViaBridge(aCallerAction:ICallerAction; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnnByNodeName(aCallerAction, aNodeName, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found for NodeName='''+aNodeName+'''.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceByNodeNameViaBridge'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['UpEQueryInterfaceByNodeNameViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure UpEQueryInterfaceViaAsm(aCallerAction:ICallerAction; aASM:Integer; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if (Integer(tmpV[0])=aASM)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnn(aCallerAction, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found for ASM='+IntToStr(aAsm)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceViaAsm'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  IEServerConnections(InternalGetITray.Query(IEServerConnections)).View.EQueryInterface(aGuid, aInterface);
{$endif}
end;

procedure UpEQueryInterfaceByLevelViaAsm(aCallerAction:ICallerAction; aASM:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if (Integer(tmpV[0])=aASM)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnnByLevel(aCallerAction, aLevel, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found for ASM='+IntToStr(aASM)+', Level='+IntToStr(aLevel)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceByLevelViaAsm'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  IEServerConnections(InternalGetITray.Query(IEServerConnections)).View.EQueryInterfaceByLevel(aLevel, aGuid, aInterface);
{$endif}
end;

procedure UpEQueryInterfaceByNodeNameViaAsm(aCallerAction:ICallerAction; aASM:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
{$IFDEF EAMServer}
  var tmpV:Variant;
      {$IFDEF EAMServer}tmpAsm:TEAMServer;{$ENDIF}
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if (Integer(tmpV[0])=aASM)and(assigned(tmpIUnknown)) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITUpEQueryInterfaceCnnByNodeName(aCallerAction, aNodeName, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Up) no found for ASM='+IntToStr(aASM)+', NodeName='''+aNodeName+'''.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForPegasServer, ['UpEQueryInterfaceByNodeNameViaAsm'], cnerInapplicableCommandForPegasServer);
{$ENDIF}
{$ELSE}
begin
  IEServerConnections(InternalGetITray.Query(IEServerConnections)).View.EQueryInterfaceByNodeName(aNodeName, aGuid, aInterface);
{$endif}
end;

procedure DnEQueryInterfaceViaBridge(aCallerAction:ICallerAction; aBridge:Integer; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and((Integer(tmpV[7]))=aBridge) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnn(aCallerAction, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Dn)='+IntToStr(aBridge)+' no found.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure DnEQueryInterfaceByLevelViaBridge(aCallerAction:ICallerAction; aBridge:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and((Integer(tmpV[7]))=aBridge) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnnByLevel(aCallerAction, aLevel, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Dn)='+IntToStr(aBridge)+' no found for Level='+IntToStr(aLevel)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceByLevelViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure DnEQueryInterfaceByNodeNameViaBridge(aCallerAction:ICallerAction; aBridge:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if ((Integer(tmpV[4]) and msk_rsBridge)=msk_rsBridge)and((Integer(tmpV[7]))=aBridge) then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnnByNodeName(aCallerAction, aNodeName, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Bridge(Dn)='+IntToStr(aBridge)+' no found for NodeName='''+aNodeName+'''.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceByNodeNameViaBridge'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure DnEQueryInterfaceViaASM(aCallerAction:ICallerAction; aASM:Integer; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if Integer(tmpV[0])=aASM then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnn(aCallerAction, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Asm(Dn)='+IntToStr(aAsm)+' no found for ASM='+IntToStr(aASM)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceViaASM'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure DnEQueryInterfaceByLevelViaASM(aCallerAction:ICallerAction; aASM:Integer; aLevel:Integer; const aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if Integer(tmpV[0])=aASM then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnnByLevel(aCallerAction, aLevel, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Asm(Dn)='+IntToStr(aAsm)+' no found for Level='+IntToStr(aLevel)+'.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceByLevelViaASM'], cnerInapplicableCommandForClient);
{$endif}
end;

procedure DnEQueryInterfaceByNodeNameViaASM(aCallerAction:ICallerAction; aASM:Integer; const aNodeName:WideString; aGuid:TGUID; out aInterface:IDispatch);
{$Ifndef ESClient}
  var tmpAdmittanceAsm:IAdmittanceAsm;
  function localGetAdmittanceAsm:IAdmittanceAsm; begin
    if not assigned(tmpAdmittanceAsm) then InternalGetITray.Query(IAdmittanceAsm, tmpAdmittanceAsm);
    result:=tmpAdmittanceAsm;
  end;
  var tmpV:Variant;
      tmpAsm:{$IFDEF EAMServer}TEAMServer{$ELSE}TAUPegas{$ENDIF};
      tmpIUnknown:IUnknown;
      tmpEQueryInterfaceCnn:IEQueryInterfaceCnn;
begin
  tmpV:=Unassigned;
  repeat
    if VarIsArray(tmpV) then tmpAsm:=Pointer(Integer(tmpV[5])) else tmpAsm:=nil;
    tmpV:=localGetAdmittanceASM.GetInfoNextASMAndLock(tmpAsm);//Проверяю что взялось
    if VarIsArray(tmpV) then begin//если что то взялось значит и залочилось
      try
        tmpAsm:=Pointer(Integer(tmpV[5]));
        tmpIUnknown:=tmpAsm;
        if Integer(tmpV[0])=aASM then begin
          if tmpIUnknown.QueryInterface(IEQueryInterfaceCnn, tmpEQueryInterfaceCnn)<>S_OK then raise exception.create('IEQueryInterfaceCnn no found.');
          tmpEQueryInterfaceCnn.ITDnEQueryInterfaceCnnByNodeName(aCallerAction, aNodeName, aGuid, aInterface);
          break;
        end;
      finally
        localGetAdmittanceASM.UnLock(tmpAsm);
      end;
    end else raise exception.create('Asm(Dn)='+IntToStr(aAsm)+' no found for NodeName='''+aNodeName+'''.');//ASM Кончились
  until False;
{$ELSE}
begin
  raise exception.createFmtHelp(cserInapplicableCommandForClient, ['DnEQueryInterfaceByNodeNameViaASM'], cnerInapplicableCommandForClient);
{$endif}
end;

end.
