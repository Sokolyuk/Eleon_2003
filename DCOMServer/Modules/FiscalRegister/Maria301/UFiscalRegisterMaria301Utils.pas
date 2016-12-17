//Copyright � 2000-2004 by Dmitry A. Sokolyuk
unit UFiscalRegisterMaria301Utils;

interface

  function FiscalRegisterResultMessage(aResult:integer):AnsiString;
  procedure FiscalRegisterResultCheck(aResult:integer);overload;
  procedure FiscalRegisterResultCheck(const aErrorPrefix:AnsiString; aResult:integer);overload;

implementation
  uses Sysutils;

function FiscalRegisterResultMessage(aResult:integer):AnsiString;
begin
  if aResult = 0 then result := '��� ������' else
  if aResult = 1 then result := '���������� ������� ��� ����' else
  if aResult = 2 then result := '������ ��������� ������� ��� �����' else
  if aResult = 3 then result := '������ ��������� ����� ��� �����' else
  if aResult = 4 then result := '���������� �������� ��������� ��� �����' else
  if aResult = 5 then result := '���������� ���������� ��������� ��� �����' else
  if aResult = 6 then result := '���������� ���������� �������� ��� �����' else
  if aResult = 7 then result := '���������� ����������� � �������������' else
  if aResult = 8 then result := '����������� �������� �� �����������' else

  if aResult = 10 then result := 'HARDPAPER - ����������� ������� ���/� ����������� �����' else
  if aResult = 11 then result := 'HARDSENSOR - ������������ ������������� ����� ���������� �������.' else
  if aResult = 12 then result := 'HARDPOINT - ����������� ���������� ������� �������������� ��������� ���������� �������.' else
  if aResult = 13 then result := 'HARDTXD - ������ ������ �����: �������� �� ��������' else
  if aResult = 14 then result := 'HARDTIMER - ������ ��������� ������ ��������� ����� ��������� ������� (������������ ��������� ''SHUTDOWN'')' else
  if aResult = 15 then result := 'HARDMEMORY - ������ �������� ������ � ���������� ������ (������������ ��������� ''SHUTDOWN'')' else
  if aResult = 16 then result := 'HARDLCD - ������������� ������� ����������' else
  if aResult = 17 then result := 'HARDUCCLOW - ������ ���������� �������' else
  if aResult = 18 then result := 'HARDCUTTER - ������������� ��������� ������� �����' else
  if aResult = 19 then result := 'SHUTDOWN - ���� ���������� �� ����������� ��������: ���� ����� ��������� ������� ��� ������ ��� ������ � ���������� �������.' else
  if aResult = 20 then result := 'SOFTBLOCK - ����� ������� ������ ����� ������� ����� 253 ������� ���� ������� ����������� ������ <�����> �����' else
  if aResult = 21 then result := 'SOFTNREP - ���������� ���������� ����� ������� ���������� ��� ���������� Z-������ ��� ����� ������� ����� ����������� ������ ����� Z-������ �� �������� �������� �������' else
  if aResult = 22 then result := 'SOFTSYSLOC - ��� ���� ������� ��������� ���������� ����� "��������" ������������.' else
  if aResult = 23 then result := 'SOFTCOMMAN - ������������������ �� ������ ������� �������� ����� ������ �� ������� � ��������� ���������� ������' else
  if aResult = 24 then begin
    result := 'SOFTPROTOC - a)	���������� ���������� ����� ������� ���������� ��� ���������� Z-������ ��� ����� ������� ����� ����������� ������ ����� Z-������ �� �������� �������� �������;'#13#10'�) �������� ��������������� ������������������ ������ �������� �����;';
    result :=  result + #13#10'�) ������ ��������� ���������� - �������� ����� �� ��� �� ������ � �� ������� ��� ��-�� ������';
  end else
  if aResult = 25 then result := 'SOFTZREPOR - Z- ����� �� ����������� ��-�� ������ ��� ������' else
  if aResult = 26 then result := 'SOFTFMFULL - ���������� ������� ���������� - ������������ ���������� ������ � ��������������� ��������.' else
  if aResult = 27 then result := 'SOFTPARAM - ���, ���������� ��� �������� ���������� ������� �������' else
  if aResult = 28 then result := 'SOFTUPAS - ��������� ��������� ���� � ����������� �������' else
  if aResult = 29 then result := 'SOFTCHECK - �� ��������� ����������� ����� ����������� ������� ��� �� �������� �� ����� ��������� (��� ������������������� � ���������� ������ ������������)' else
  if aResult = 30 then result := 'SOFTSLWORK - ��� ���������� ���� ������� ��������� ��������� ���������� ����� "������"' else
  if aResult = 31 then result := 'SOFTSLPROG - ��� ���������� ���� ������� ��������� ��������� ���������� ����� "����������������"' else
  if aResult = 32 then result := 'SOFTSLZREP - ��� ���������� ���� ������� ��������� ��������� ���������� ����� "X- �����"' else
  if aResult = 33 then result := 'SOFTSLNREP - ��� ���������� ���� ������� ��������� ��������� ���������� ����� "Z-�����"' else
  if aResult = 34 then result := 'SOFTREPL - ��������������� �������� ��� ���� � ��' else
  if aResult = 35 then result := 'SOFTREGIST - ��� ���������� � �� ��������������� ����������. ������ ��� ������� �� ��������, � ���� ������������� � ��� ��� ���������� ����������� �� ��������������. ���������� ������ �������� ��� �����������.' else
  if aResult = 36 then result := 'SOFTOVER - ��������� ������������ ���������� ����������� ����� ��� ������������ ������� ���������' else
  if aResult = 37 then result := 'SOFTNEED - ������������ ������������� ��������� �������� ��������� ��� ������������� ���������� ������� ������� � ����� � ��������� ���������� ��������/��������� �����.' else
  if aResult = 38 then result := 'SOFTFMTEST - ���������� ��������� �������� ���������� ����������, ���������� � ��' else
  if aResult = 39 then result := 'SOFTOPTEST - ���������� ��������� ������ � ����� �� � �������� ����������� �������.' else
  if aResult = 40 then result := 'SOFT24HOUR - ������ ������������ ����� 24-� ����� (������������ ��������� ''SOFTNREP'')' else
  if aResult = 41 then begin
    result := 'SOFTDIFART - ���������� ��������� ������������ ��� ���� ��������������� ��� �������� ��������� ������ �� ����������������� ����� ������ �������� ��� ������� ������������������� ������� � ������������������ �������� � ������ <������������� ����������������';
    result := result + '��� �������>.';
  end else
  if aResult = 42 then result := 'SOFTBADART - ����� �������� ����� �������� (�� �� ��������� 1-9999) ��� ��������� � �� ����������������� (�� ��������������������)��������.' else
  if aResult = 43 then result := 'SOFTCOPY - ������������ ������ ����������� - ����� 300 ����� � ����. ����������� ������� ''COPY'' �� ���������.' else
  if aResult = 44 then result := 'SOFTOVART - ��������� ������������ ���������� ���� ������ � ���� - ����� 720.' else
  if aResult = 45 then result := 'SOFTNOTAV - ����������� ������ ��� (��� ����� 301 ���)' else
  if aResult = 46 then result := 'SOFTBADDISC - ���� ������ ������ ����� ������� �� ��������������� �������� �������' else
  if aResult = 47 then result := 'SOFTBADCS - � ������ �������� ����������� ����� ����� ������ ���������� ������������ ����������� � �������� ����������� ����' else
  if aResult = 48 then result := 'SOFTARTMODE - � ������ ����������� ������� <������������� �������������������> ��� � ������ ����������� ������� <����������� �����>' else

  if aResult = 50 then result := 'MEM_ERROR_CODE_01 - ����-��� �������� ������ � ��' else
  if aResult = 51 then result := 'MEM_ERROR_CODE_02 - ������ ������ � ��' else
  if aResult = 52 then result := 'MEM_ERROR_CODE_03 - �������� ����� �������� ��' else
  if aResult = 53 then result := 'MEM_ERROR_CODE_04 - �������� ����� ��' else
  if aResult = 54 then result := 'MEM_ERROR_CODE_05 - ����������� ��� ������� ��������� �����, ���������� � ���������� ������' else
  if aResult = 55 then result := 'MEM_ERROR_CODE_06 - ����������� ������ � ������ �����' else
  if aResult = 56 then result := 'MEM_ERROR_CODE_07 - ����� ���������� Z-������, ����������� � ��, ������ ������ �������� Z-������' else
  if aResult = 57 then result := 'MEM_ERROR_CODE_08 - ����� �������� Z-������ ����� ��� �� ������� ���������� �� ������ ���������� Z-������, ����������� � ��' else
  if aResult = 58 then result := 'MEM_ERROR_CODE_09 - ����� �������� Z-������ �� ������ �� ������� ������ ���������� Z-������, ����������� � ��' else
  if aResult = 59 then result := 'MEM_ERROR_CODE_10 - �������� ���������� ���������� ������ � Z-������' else
  if aResult = 60 then result := 'MEM_ERROR_CODE_11 - �������� ���������� ���������� ������ � ������' else
  if aResult = 61 then result := 'MEM_ERROR_CODE_12 - �������� ���������� ���������� ������ � �����������' else
  if aResult = 62 then result := 'MEM_ERROR_CODE_13 - �������� ���������� ���������� ������ � ������ �����' else
  if aResult = 63 then result := 'MEM_ERROR_CODE_14 - �������� ������������������ ������� Z-������� ��� ������������ ������ �� ������' else
  if aResult = 64 then result := 'MEM_ERROR_CODE_15 - ����-��� �������� ������ � �� ���������� ��' else
  if aResult = 65 then result := 'MEM_ERROR_CODE_16 - ������ ������ � �� ���������� ��' else
  if aResult = 66 then result := 'MEM_ERROR_CODE_17 - �������� ������������������ ������� ������� ������� � �������� �� ��� ������������ ������ �� ������' else
  if aResult = 67 then result := 'MEM_ERROR_CODE_18 - �������� ���������� ���������� ������ � ������������ ��' else
  if aResult = 68 then result := 'MEM_ERROR_CODE_19 - ��������� ���������� ���������� ��������� ��������� (����� �������� ���� � ��������� ������) ����������� ������' else
  if aResult = 69 then result := 'MEM_ERROR_CODE_20 - �������� ���������� ���������� ������ ��  ��������� ��������� (����� ������� ���� � ��������� ������) ����������� ������' else
  if aResult = 70 then result := 'MEM_ERROR_CODE_21 - ��������� ������ ���������� ������ � ������� ������� � �����������' else
  if aResult = 71 then result := 'MEM_ERROR_CODE_22 - ��������� ������ ���������� ������ � ������� ������� � �������' else
  if aResult = 72 then result := 'MEM_ERROR_CODE_23 - ��������� ������ ���������� ������ � ������� ������� � ������ �����' else
  if aResult = 73 then result := 'MEM_ERROR_CODE_24 - ��������� ������ ���������� ������ � ������� ������� � ������������� �������������� (��� ����� 301 ���)' else
  if aResult = 74 then result := 'MEM_ERROR_CODE_25 - ��������� ������ ���������� ������ � ������� ������� � ������� ���������� ������� (Z-�������)' else
  if aResult = 75 then result := 'RTC_ERROR_CODE_01 - ��������� ���� ��������� ������� �����������' else
  if aResult = 76 then result := 'RTC_ERROR_CODE_02 - ���� ���������� Z-������, ����������� � ��, ������ ������� ���� � ��������� ����� ��������� �������' else
  if aResult = 77 then result := 'RTC_ERROR_CODE_03 - �������� ����� � ��������� ����� ��������� �������' else
  if aResult = 78 then result := 'RTC_ERROR_CODE_04 - �������� ���� � ��������� ����� ��������� �������' else
  if aResult = 79 then result := 'RTC_ERROR_CODE_05 - ������������� ���������� ����� ��������� ������� ��� ������ ����� ��������� - ����' else
  if aResult = 80 then result := '������� ������ ������ �� ����������� ������������' else
      result := '����������� ��� ������('+IntToStr(aResult)+')';
end;

procedure FiscalRegisterResultCheck(aResult:integer);
begin
  FiscalRegisterResultCheck('', aResult);
end;

procedure FiscalRegisterResultCheck(const aErrorPrefix:AnsiString; aResult:integer);
begin
  if aResult > 0 then raise exception.create(aErrorPrefix + ': ' + FiscalRegisterResultMessage(aResult));
end;

end.
