//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UObjectConsts;
{-$Define DebugObject}

interface
{$IfDef DebugObject}
  Uses USimpleVarsetTypes, ULogFileTypes;
{$Endif}

Var
  cnITObjectCreated:Integer=0;//������� ��������
  cnObjectUniqueId:Integer=0;//��� ���������� ����������� ������ IT-�������.

{$IfDef DebugObject}
Var
  glObjectsList:ISimpleVarset=Nil;
  glObjectsListLogFile:ILogFile=Nil;
{$Endif}

implementation
{$IfDef DebugObject}
  Uses USimpleVarset, ULogFile, SysUtils, UObjectsTypes;

Var tmpIntIndex:Integer;
    tmpSt:AnsiString;
{$Endif}

Initialization
{$IfDef DebugObject}
  try
    glObjectsList:=TSimpleVarset.Create;
    glObjectsListLogFile:=TLogFile.Create(ExtractFilePath(ParamStr(0))+'DebugObjectsListLogFile.log');
    glObjectsListLogFile.ITErrorToRaise:=False;
    glObjectsListLogFile.ITCountMessToAutoChangeFileName:=250000;
    glObjectsListLogFile.ITAddToFileNameCurrentDataTimeAtOpen:=True;
    glObjectsListLogFile.ITOpenLog;
  except
    glObjectsList:=Nil;
    glObjectsListLogFile:=Nil;
  end;
{$Endif}
Finalization
{$IfDef DebugObject}
  try
    If Assigned(glObjectsListLogFile) Then begin
      If glObjectsList.ITCount>0 Then begin
        glObjectsListLogFile.ITWriteLnToLog('F_i_n_a_l_i_z_a_t_i_o_n');
      end;
      While glObjectsList.ITCount>0 do begin
        tmpSt:=glObjectsList.ITPop(tmpIntIndex);
        glObjectsListLogFile.ITWriteLnToLog('NO DEST: ID='+IntToStr(tmpIntIndex)+#9'ClassName='''+tmpSt+'''', False);
      end;
    end;
    glObjectsList:=Nil;
    //..
    If Assigned(glObjectsListLogFile) Then begin
      glObjectsListLogFile.ITCloseLog;
      glObjectsListLogFile:=Nil;
    end;
  except end;
{$Endif}
end.



