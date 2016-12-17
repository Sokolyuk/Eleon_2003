unit UTaskStorageConsts;

interface

Const
  rstSTNoASM          :integer = -1; // - указывает ITMateTaskAdd что результат в DataCase не нужен.
  rstSTServerASM      :integer = -2; // - указывает ITMateTaskAdd что результат в DataCase нужен, и он будет серверным, т.е. кагбы не от ASM  а от сервера(это влияет на разборщик заданий).
  tkiNoTaskID         :integer = -1; // - используется как значение параметра aTaskNumbered для ITMateTaskAdd и указывает что добавляемое задание должно иметь новое Id. Если aTaskNumbered<>tsiNoTaskID то заданию присваивается указанный номер.
  tsiNoPackID         :integer = -1; // - указывает что ID пакета для результата не указан

implementation

end.
