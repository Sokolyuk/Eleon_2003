//Copyright � 2000-2003 by Dmitry A. Sokolyuk
unit UTrayConsts;

interface
  uses UTrayTypes;
  var cnTray:ITray=nil;
      cnTrayCount:Integer=0;

//����� �������, ������ ��� ��������� ADOC count.
var cnADOCCoutCurrent:integer = 0;
    cnADOCCoutMax:integer = 0;

implementation
initialization
finalization
  cnTray:=nil;//��������! �������� ��������� ��������: ���� � tray �������� TClientDataSet, � ������� � ��� ������
              //�� � ���� ����� ����� ������ �� ������, �.�. finalization � ����� �� ������(Db, DBClient), ��� ������.
              //�������: 1)������ cnTray:=nil; �� end. 2)������ FCDS.active:=false � ITrayInterface.Final;.
end.
