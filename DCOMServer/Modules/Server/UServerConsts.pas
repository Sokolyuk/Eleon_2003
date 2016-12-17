//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UServerConsts;

interface
  uses Comobj;
Var
  //AppStartDateTime:TDateTime=0;
{$IFDEF EAMServer}
  cnEComputerName:AnsiString='';
  cnEComputerGUID:AnsiString='';
{$ENDIF}
  //cnRegPath:AnsiString='';
  //cnCacheDir:AnsiString='';
{$IFDEF PegasServer}
  cnConnectionString:AnsiString='';//Имя компьютера с Pegasom
{$Endif}
  cnLocalDataBaseConnectionString:AnsiString='';//Ado-connection to LDB
  //cnLog:Boolean=False;//Разрешение на ведение логов
  cnShowErrors:Boolean=False;//Разрешить выводить на экран окна или работать в режиме "сервер без вопросов"
  cnDataBaseNamePicture:AnsiString='';
  cnDataBaseNamePictureExt:AnsiString='';
  cnDataBaseNamePictureDate:AnsiString='';
  cnThreadingModel:TThreadingModel=tmFree;//Потокова модель приложения
  cnSQLServerSecurityContext:Variant;
  //ldb
  cnLocalDataBaseName:AnsiString='';//Bde
  cnLocalDataType:Integer=0;//0-Ado, 1-Bde.
  cnCheckSecuretyLDB:Boolean=false;
  cnIgnoreErrorsInSQLParser:Boolean=False;
  cnCheckForTriggers:Boolean=false;
Const
  cnMaxRecursionDepth:Integer=25;
Var
  cnTableAutoLock:Boolean={$IFDEF PegasServer}False{$endif}{$IFDEF EAMServer}True{$ENDIF};
{$IFDEF PegasServer}
Const
  cnFieldNameGroupName:AnsiString='GroupName';
{$ENDIF}
Var cnServerRegName:AnsiString='';
    GL_AOF_ASM:TAutoObjectFactory=nil;
    GL_AOF_EDC:TAutoObjectFactory=nil;
    GL_AOF_ELDB:TAutoObjectFactory=nil;
    cnProcessID:LongWord=0;
    cnIsEMSClient:boolean=false;
implementation
end.
