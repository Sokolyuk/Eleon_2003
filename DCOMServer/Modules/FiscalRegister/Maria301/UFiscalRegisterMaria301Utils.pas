//Copyright © 2000-2004 by Dmitry A. Sokolyuk
unit UFiscalRegisterMaria301Utils;

interface

  function FiscalRegisterResultMessage(aResult:integer):AnsiString;
  procedure FiscalRegisterResultCheck(aResult:integer);overload;
  procedure FiscalRegisterResultCheck(const aErrorPrefix:AnsiString; aResult:integer);overload;

implementation
  uses Sysutils;

function FiscalRegisterResultMessage(aResult:integer):AnsiString;
begin
  if aResult = 0 then result := 'Нет ошибки' else
  if aResult = 1 then result := 'Невозможно открыть СОМ порт' else
  if aResult = 2 then result := 'Ошибка настройки буферов СОМ порта' else
  if aResult = 3 then result := 'Ошибка настройки маски СОМ порта' else
  if aResult = 4 then result := 'Невозможно получить состояние СОМ порта' else
  if aResult = 5 then result := 'Невозможно установить параметры СОМ порта' else
  if aResult = 6 then result := 'Невозможно установить таймауты СОМ порта' else
  if aResult = 7 then result := 'Невозможно соединиться с регистратором' else
  if aResult = 8 then result := 'Отсутствует лицензия на регистратор' else

  if aResult = 10 then result := 'HARDPAPER - Отсутствует чековая или/и контрольная лента' else
  if aResult = 11 then result := 'HARDSENSOR - Недопустимый температурный режим печатающей головки.' else
  if aResult = 12 then result := 'HARDPOINT - Отсутствует напряжение питания нагревательных элементов печатающей головки.' else
  if aResult = 13 then result := 'HARDTXD - Ошибки канала связи: контроль по четности' else
  if aResult = 14 then result := 'HARDTIMER - Ошибки обработки данных системных часов реального времени (сопровождает сообщение ''SHUTDOWN'')' else
  if aResult = 15 then result := 'HARDMEMORY - Ошибки контроля данных в фискальной памяти (сопровождает сообщение ''SHUTDOWN'')' else
  if aResult = 16 then result := 'HARDLCD - Неисправность дисплея покупателя' else
  if aResult = 17 then result := 'HARDUCCLOW - Низкое напряжение питания' else
  if aResult = 18 then result := 'HARDCUTTER - Неисправность обрезчика чековой ленты' else
  if aResult = 19 then result := 'SHUTDOWN - ЭККР блокирован по техническим причинам: сбой часов реального времени или ошибки при работе с фискальной памятью.' else
  if aResult = 20 then result := 'SOFTBLOCK - После символа начала блока принято более 253 символа либо неверен контрольный символ <длина> блока' else
  if aResult = 21 then result := 'SOFTNREP - дальнейшее применение такой команды невозможно без выполнения Z-отчета или такая команда может применяться только после Z-отчета до фиксации движения товаров' else
  if aResult = 22 then result := 'SOFTSYSLOC - для этой команды положение системного ключа "ОТКЛЮЧЕН" Недопустимое.' else
  if aResult = 23 then result := 'SOFTCOMMAN - последовательность из первых четырех символов блока данных не найдена в множестве допустимых команд' else
  if aResult = 24 then begin
    result := 'SOFTPROTOC - a)	дальнейшее применение такой команды невозможно без выполнения Z-отчета или такая команда может применяться только после Z-отчета до фиксации движения товаров;'#13#10'б) нарушена рекомендованная последовательность команд создания чеков;';
    result :=  result + #13#10'в) печать документа невозможна - открытый ранее по чек не закрыт и не отменен или из-за ошибки';
  end else
  if aResult = 25 then result := 'SOFTZREPOR - Z- отчет не сформирован из-за ошибок или аварии' else
  if aResult = 26 then result := 'SOFTFMFULL - Выполнение команды невозможно - переполнение фискальной памяти в соответствующих областях.' else
  if aResult = 27 then result := 'SOFTPARAM - Тип, количество или значение параметров команды неверно' else
  if aResult = 28 then result := 'SOFTUPAS - Требуется парольный вход и регистрация кассира' else
  if aResult = 29 then result := 'SOFTCHECK - Не выполнены соотношения между параметрами команды или их значения не равны расчетным (или запрограммированным в фискальную память регистратора)' else
  if aResult = 30 then result := 'SOFTSLWORK - Для выполнения этой команды требуется положение системного ключа "РАБОТА"' else
  if aResult = 31 then result := 'SOFTSLPROG - Для выполнения этой команды требуется положение системного ключа "ПРОГРАММИРОВАНИЕ"' else
  if aResult = 32 then result := 'SOFTSLZREP - Для выполнения этой команды требуется положение системного ключа "X- ОТЧЕТ"' else
  if aResult = 33 then result := 'SOFTSLNREP - Для выполнения этой команды требуется положение системного ключа "Z-ОТЧЕТ"' else
  if aResult = 34 then result := 'SOFTREPL - Программируемое значение уже есть в ФП' else
  if aResult = 35 then result := 'SOFTREGIST - При отсутствии в ФП регистрационной информации. Данный код ошибкой НЕ ЯВЛЯЕТСЯ, а лишь сигнализирует о том что фискальный регистратор не фискализирован. Дальнейшая работа возможна без ограничений.' else
  if aResult = 36 then result := 'SOFTOVER - Превышено максимальное количество загружаемых строк или переполнение учетных регистров' else
  if aResult = 37 then result := 'SOFTNEED - Недопустимый отрицательный результат операции вычитания при корректировке исходящего остатка средств в кассе в операциях служебного внесения/вынесения денег.' else
  if aResult = 38 then result := 'SOFTFMTEST - Обнаружено искажение основных фискальных реквизитов, записанных в ФП' else
  if aResult = 39 then result := 'SOFTOPTEST - Обнаружено искажение данных в блоке ОП с дневными фискальными данными.' else
  if aResult = 40 then result := 'SOFT24HOUR - Работа продолжается более 24-х часов (сопровождает сообщение ''SOFTNREP'')' else
  if aResult = 41 then begin
    result := 'SOFTDIFART - Обнаружено изменение наименования или схем налогообложения или признака делимости товара по активизированному ранее номеру артикула или попытка перепрограммировать артикул с зарегистрированной продажей в режиме <Использование запрограммирован';
    result := result + 'ных товаров>.';
  end else
  if aResult = 42 then result := 'SOFTBADART - Задан неверный номер артикула (не из диапазона 1-9999) или обращение к не активизированному (не запрограммированному)артикулу.' else
  if aResult = 43 then result := 'SOFTCOPY - Переполнение буфера копирования - более 300 строк в чеке. Последующая команда ''COPY'' не применима.' else
  if aResult = 44 then result := 'SOFTOVART - Превышено максимальное количество этих команд в чеке - более 720.' else
  if aResult = 45 then result := 'SOFTNOTAV - Недоступный объект АЗС (для Мария 301 МТМ)' else
  if aResult = 46 then result := 'SOFTBADDISC - Сума скидки больше суммы оборота по соответствующей товарной позиции' else
  if aResult = 47 then result := 'SOFTBADCS - В режиме проверки контрольной суммы блока данных обнаружено несовпадение вычисленной и принятой контрольных сумм' else
  if aResult = 48 then result := 'SOFTARTMODE - в режиме артикульной таблицы <Использование запрограммированных> или в режиме артикульной таблицы <Регистрация новых>' else

  if aResult = 50 then result := 'MEM_ERROR_CODE_01 - Тайм-аут процесса записи в ФП' else
  if aResult = 51 then result := 'MEM_ERROR_CODE_02 - Ошибки записи в ФП' else
  if aResult = 52 then result := 'MEM_ERROR_CODE_03 - Неверный номер страницы ФП' else
  if aResult = 53 then result := 'MEM_ERROR_CODE_04 - Неверный адрес ФП' else
  if aResult = 54 then result := 'MEM_ERROR_CODE_05 - Отсутствует или искажен заводской номер, записанный в фискальную память' else
  if aResult = 55 then result := 'MEM_ERROR_CODE_06 - Отсутствует запись о валюте учета' else
  if aResult = 56 then result := 'MEM_ERROR_CODE_07 - Номер последнего Z-отчета, записанного в ФП, больше номера текущего Z-отчета' else
  if aResult = 57 then result := 'MEM_ERROR_CODE_08 - Номер текущего Z-отчета более чем на единицу отличается от номера последнего Z-отчета, записанного в ФП' else
  if aResult = 58 then result := 'MEM_ERROR_CODE_09 - Номер текущего Z-отчета не больше на единицу номера последнего Z-отчета, записанного в ФП' else
  if aResult = 59 then result := 'MEM_ERROR_CODE_10 - Неверное физическое размещение записи о Z-отчете' else
  if aResult = 60 then result := 'MEM_ERROR_CODE_11 - Неверное физическое размещение записи о налоге' else
  if aResult = 61 then result := 'MEM_ERROR_CODE_12 - Неверное физическое размещение записи о регистрации' else
  if aResult = 62 then result := 'MEM_ERROR_CODE_13 - Неверное физическое размещение записи о валюте учета' else
  if aResult = 63 then result := 'MEM_ERROR_CODE_14 - Нарушена последовательность номеров Z-отчетов при формировании отчета за период' else
  if aResult = 64 then result := 'MEM_ERROR_CODE_15 - Тайм-аут процесса записи в ФП реализации НП' else
  if aResult = 65 then result := 'MEM_ERROR_CODE_16 - Ошибки записи в ФП реализации НП' else
  if aResult = 66 then result := 'MEM_ERROR_CODE_17 - Нарушена последовательность номеров записей отчетов о движении НП при формировании отчета за период' else
  if aResult = 67 then result := 'MEM_ERROR_CODE_18 - Неверное физическое размещение записи о наименовании НП' else
  if aResult = 68 then result := 'MEM_ERROR_CODE_19 - Превышено допустимое количество аварийных обнулений (после ремонтов ЭККР в сервисном центре) оперативной памяти' else
  if aResult = 69 then result := 'MEM_ERROR_CODE_20 - Неверное физическое размещение записи об  аварийном обнулении (после ремонта ЭККР в сервисном центре) оперативной памяти' else
  if aResult = 70 then result := 'MEM_ERROR_CODE_21 - Искажение данных фискальной памяти в области записей о регистрации' else
  if aResult = 71 then result := 'MEM_ERROR_CODE_22 - Искажение данных фискальной памяти в области записей о налогах' else
  if aResult = 72 then result := 'MEM_ERROR_CODE_23 - Искажение данных фискальной памяти в области записей о валюте учета' else
  if aResult = 73 then result := 'MEM_ERROR_CODE_24 - Искажение данных фискальной памяти в области записей о наименованиях нефтепродуктах (для Мария 301 МТМ)' else
  if aResult = 74 then result := 'MEM_ERROR_CODE_25 - Искажение данных фискальной памяти в области записей о дневных фискальных отчетах (Z-отчетах)' else
  if aResult = 75 then result := 'RTC_ERROR_CODE_01 - Системные часы реального времени остановлены' else
  if aResult = 76 then result := 'RTC_ERROR_CODE_02 - Дата последнего Z-отчета, записанного в ФП, больше текущей даты в системных часах реального времени' else
  if aResult = 77 then result := 'RTC_ERROR_CODE_03 - Неверное время в системных часах реального времени' else
  if aResult = 78 then result := 'RTC_ERROR_CODE_04 - Неверная дата в системных часах реального времени' else
  if aResult = 79 then result := 'RTC_ERROR_CODE_05 - Неисправность микросхемы часов реального времени или канала связи процессор - часы' else
  if aResult = 80 then result := 'Таймаут чтения ответа от фискального регистратора' else
      result := 'Неизвестный код ошибки('+IntToStr(aResult)+')';
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
