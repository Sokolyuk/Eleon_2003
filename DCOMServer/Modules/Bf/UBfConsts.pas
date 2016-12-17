unit UBfConsts;

interface
const
  cnTransferBfsMaxCount:Cardinal=5000;//подключений на download/upload, одновременно.
  cnTransferBfMaxSize:Cardinal=512000000;//Размер файла на upload не должен превышать 500Mb.
  csBfCacheSubDir:AnsiString='Bf\';
  csRegValueCacheDirBf:AnsiString='CacheDirBf';
//  csUploadTempDir:AnsiString='UploadTempDir\';

implementation

end.
