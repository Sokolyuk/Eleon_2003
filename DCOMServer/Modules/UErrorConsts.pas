//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UErrorConsts;

interface
Const
  //Error HelpIndex.
  //0 - unspecified error
  //1 - Internal unexpected error.
  cnerInternalError:Integer=1;
  cnerInvalidValueOf:Integer=2;
  //cnerUnsupportedTask:Integer=3;
  //3..49 - Free
  //50..55 - UnexpectCommand. Неприменимая команда для EM/Pegas сервера или клиента.
  cnerInapplicableCommandForPegasServer:Integer=50;
  cnerInapplicableCommandForEMServer:Integer=51;
  cnerInapplicableCommandForClient:Integer=52;
  cnerInapplicableCommand:Integer=53;
  //56..199 - Free
  //200-249 - Transport errors
  cnerFreeBridgeNotFound:Integer=200;
  cnerBridgeNotFound:Integer=201;
  //250..299 - Free
  //300..349 - Security
  cnerPegasLoginFailed:Integer=300;
  cnerLocalLoginFailed:Integer=301;
  cnerAccessDenied:Integer=302;
  //400..449 - Transfer blobfile errors. See unit UTransferConsts. Диапозон уже занят. Константы описаны в модуле UTransferConsts.
  cnerChecksumError:Integer=401;
  cnerDocNotExists:integer=450;
  //cnerDiffIdBase:Integer=400;
  //cnerChecksumError:Integer=401;
  //cnerInvalidTransferName:Integer=402;
  //cnerTransferNameAlreadyUsed:Integer=403;
  //cnerTransferingBroken:Integer=404;
  //cnerNearOperationTransfer:Integer=405;
  //cnerInvalidIdBase:Integer=406;
  //450..499 - Free
  //500..549 - Sync
  cnerLockedByAnotherUser:Integer=500;
  cnerCreateFile:Integer=550;
  cnerSetFilePointer:Integer=551;
  cnerReadFile:Integer=552;
  cnerWriteFile:Integer=553;
  cnerFileSetDate:Integer=554;
  cnerCopyFile:integer=555;
  //560..??? - Free
//Error messages.
ResourceString
  cserInternalError='Internal error: %s. Contact the developers 728-77-11/8-916-221-77-54.';
  cserLockedByAnotherUser='For LO=%d ''%s'' locked at ''%s'' by ''%s''/LO=%d.';
  cserInapplicableCommandForPegasServer='Command=%s is inapplicable for PegasServer.';
  cserInapplicableCommandForEMServer='Command=%s is inapplicable for EMServer.';
  cserInapplicableCommandForClient='Command=%s is inapplicable for Client.';
  cserInapplicableCommand='Command=%s is inapplicable.';
  cserFreeBridgeNotFound='Free bridge(%d) is not found(%s).';
  cserBridgeNotFound='Bridge(%d) is not found.';
  cserInvalidValueOf='Invalid value of %s.';
  cserAccessDenied='Access denied(%s).';
  cserChecksumError='Checksum error.';
  cserDocNotExists='Doc ''%s'' not exists.';
  //cserUnsupportedTask='Unsupported task(%d).';

implementation

end.
