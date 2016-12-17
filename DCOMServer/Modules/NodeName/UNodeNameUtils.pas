//Copyright © 2000-2003 by Dmitry A. Sokolyuk
unit UNodeNameUtils;

interface
  uses UPackPDPlacesTypes, UNodeNameTypes, UPackTypes;

  procedure TwoNodeNameToPDPlaces(const aFromNodeName, aToNodeName:AnsiString; aPlaces:IPackPDPlaces);
  procedure TwoNodeNameToPlace(const aFromNodeName, aToNodeName:AnsiString; out aPlace:TPlace; out aPlaceData:Variant);

implementation
  uses Sysutils, UErrorConsts, UNodeNameStrUtils{$IFNDEF VER130}, Variants{$ENDIF}, UNodeTypes;

procedure TwoNodeNameToPDPlaces(const aFromNodeName, aToNodeName:AnsiString; aPlaces:IPackPDPlaces);
  Var tmpNodeNameTo, tmpNodeNameFrom, tmpNodeValueTo, tmpNodeValueFrom:AnsiString;
      tmpCurPosFrom, tmpCurPosTo:Integer;
      tmpLengthFrom, tmpLengthTo:Integer;
      tmpNodeWhereFrom, tmpNodeWhereTo:TNodeType;
  //procedure CheckRaise; begin
  //  if tmpCurPos=-1 then raise exception.createFmtHelp(cserInvalidValueOf, ['aFromNodeName/aToFromNodeName'], cnerInvalidValueOf);
  //end;
  procedure localExtendedCheckForFromForPegas; begin
    PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
    if (tmpCurPosFrom=-1)or(NodeNameToNodeWhere(tmpNodeNameFrom)<>nodPGS)or(tmpNodeValueFrom<>'') then raise exception.createFmtHelp(cserInternalError, ['''aFromNodeName'' is invalid'], cnerInternalError);
    PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
    if tmpCurPosFrom<>-1 then raise exception.createFmtHelp(cserInternalError, ['''aFromNodeName'' is invalid'], cnerInternalError);
  end;
begin
  try
    if not assigned(aPlaces) then raise exception.createFmtHelp(cserInvalidValueOf, ['aPlaces'], cnerInvalidValueOf);
    if (aFromNodeName='')or(aToNodeName='') then raise exception.createFmtHelp(cserInvalidValueOf, ['aFrom(To)NodeName'], cnerInvalidValueOf);
    aPlaces.Clear;
    aPlaces.CurrNum:=0;
    tmpCurPosFrom:=-1;
    tmpCurPosTo:=-1;
    tmpLengthFrom:=-1;
    tmpLengthTo:=-1;
    //Определяю место "от куда"
    PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
    tmpNodeWhereFrom:=NodeNameToNodeWhere(tmpNodeNameFrom);
    //Определяю место "куда"
    PrevNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);
    tmpNodeWhereTo:=NodeNameToNodeWhere(tmpNodeNameTo);
    if (tmpNodeWhereFrom=nodPGS)and(tmpNodeWhereTo=nodPGS) then Exit;//Маршрут не нужен
    //Определяю способ приведения маршрута
    if tmpNodeWhereFrom=nodPGS then begin//Схема простая, с пегаса.
      tmpCurPosTo:=-1;
      NextNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//это должен быть пегас
      //Проверочка
      if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodPGS)or(tmpNodeValueTo<>'') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+''''], cnerInvalidValueOf);
      NextNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//это должен быть Ems
      //tmpCurPosTo быть -1 не может, с пегаса на пегас проверено.
      //Проверочка
      if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodEMS)or(tmpNodeValueTo='') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+':'+tmpNodeValueTo+''''], cnerInvalidValueOf);
      aPlaces.AddPlace(pdsEventOnBridge, StrToInt(tmpNodeValueTo));//*?
      //..
      NextNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//это должен быть Esc
      if tmpCurPosTo<>-1 then begin//есть клиент
        //Проверочка
        if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodESC)or(tmpNodeValueTo='') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+':'+tmpNodeValueTo+''''], cnerInvalidValueOf);
        aPlaces.AddPlace(pdsEventOnID, StrToInt(tmpNodeValueTo));//*?
      end;
    end else if tmpNodeWhereTo=nodPGS then begin//Схема простая, на пегас.
      if tmpNodeWhereFrom=nodEMS then begin
        aPlaces.AddPlace(pdsCommandOnBridge, StrToInt(tmpNodeValueFrom));
        //Дополнительная порерочка для Пегаса
        localExtendedCheckForFromForPegas;
      end else if tmpNodeWhereFrom=nodESC then begin
        aPlaces.AddPlace(pdsCommandOnID, StrToInt(tmpNodeValueFrom));
        PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
        if (tmpCurPosFrom=-1)or(NodeNameToNodeWhere(tmpNodeNameFrom)<>nodEMS)or(tmpNodeValueFrom='') then raise exception.createFmtHelp(cserInternalError, ['''aFromNodeName'' is invalid'], cnerInternalError);
        aPlaces.AddPlace(pdsCommandOnBridge, StrToInt(tmpNodeValueFrom));
        //Дополнительная порерочка для Пегаса
        localExtendedCheckForFromForPegas;
      end else raise exception.createFmtHelp(cserInternalError, ['Unknown NodeWhereFrom'], cnerInternalError);
    end else if (tmpNodeWhereFrom=nodEMS)and(tmpNodeWhereTo=nodESC) then begin//Схема простая, с локального сервера на клиента.
      aPlaces.AddPlace(pdsEventOnID, StrToInt(tmpNodeValueTo));
      //Больше проверять ничего не буду
    end else if (tmpNodeWhereFrom=nodESC)and(tmpNodeWhereTo=nodEMS) then begin//Схема простая, с клиента на локальный сервер.
      aPlaces.AddPlace(pdsCommandOnID, StrToInt(tmpNodeValueFrom));
      //Тут возможен сложный случай пример: from:'pegas.node:19.id:33' to:'pegas.node:100'
      PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
      if (tmpCurPosFrom=-1)or(NodeNameToNodeWhere(tmpNodeNameFrom)<>nodEMS)or(tmpNodeValueFrom='') then raise exception.createFmtHelp(cserInternalError, ['''aFromNodeName'' is invalid'], cnerInternalError);
      if tmpNodeValueFrom=tmpNodeValueTo then begin
        //..
      end else begin
        raise exception.createFmtHelp(cserInternalError, ['Такую схему пока не сделал'], cnerInternalError);
      end;
    end else raise exception.createFmtHelp(cserInternalError, ['Другие схемы пока не сделал'], cnerInternalError);
    //from - pegas.node:19
    //to - pegas
  except on e:exception do begin
    aPlaces.Clear;
    e.Message:='TwoNodeNameToPDPlaces: '+e.Message;
    raise;
  end;end;
end;

procedure TwoNodeNameToPlace(const aFromNodeName, aToNodeName:AnsiString; out aPlace:TPlace; out aPlaceData:Variant);
  var tmpNodeNameTo, tmpNodeNameFrom, tmpNodeValueTo, tmpNodeValueFrom:AnsiString;
      tmpCurPosFrom, tmpCurPosTo:Integer;
      tmpLengthFrom, tmpLengthTo:Integer;
      tmpNodeWhereFrom, tmpNodeWhereTo:TNodeType;
begin
  try
    if (aFromNodeName='')or(aToNodeName='') then raise exception.createFmtHelp(cserInvalidValueOf, ['aFrom(To)NodeName'], cnerInvalidValueOf);
    tmpCurPosFrom:=-1;
    tmpCurPosTo:=-1;
    tmpLengthFrom:=-1;
    tmpLengthTo:=-1;
    //Определяю место "от куда"
    PrevNode(tmpCurPosFrom, aFromNodeName, @tmpLengthFrom, tmpNodeNameFrom, tmpNodeValueFrom);
    tmpNodeWhereFrom:=NodeNameToNodeWhere(tmpNodeNameFrom);
    //Определяю место "куда"
    PrevNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);
    tmpNodeWhereTo:=NodeNameToNodeWhere(tmpNodeNameTo);
    if AnsiUpperCase(aFromNodeName)=AnsiUpperCase(aToNodeName){(tmpNodeWhereFrom=nodPGS)and(tmpNodeWhereTo=nodPGS)} then begin
      aPlace:=pdsNone;
      aPlaceData:=unassigned;
      exit;//Маршрут не нужен
    end;
    if tmpNodeWhereFrom=nodPGS then begin//Схема простая, с пегаса.
      tmpCurPosTo:=-1;
      NextNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//это должен быть пегас
      //Проверочка
      if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodPGS)or(tmpNodeValueTo<>'') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+''''], cnerInvalidValueOf);
      NextNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//это должен быть Ems
      //tmpCurPosTo быть -1 не может, с пегаса на пегас проверено.
      //Проверочка
      if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodEMS)or(tmpNodeValueTo='') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+':'+tmpNodeValueTo+''''], cnerInvalidValueOf);
      aPlace:=pdsEventOnBridge;
      aPlaceData:=StrToInt(tmpNodeValueTo);
    end else if tmpNodeWhereTo=nodPGS then begin//Схема простая, на пегас.
      if tmpNodeWhereFrom=nodEMS then begin
        aPlace:=pdsCommandOnBridge;
        aPlaceData:=StrToInt(tmpNodeValueFrom);
      end else if tmpNodeWhereFrom=nodESC then begin
        aPlace:=pdsCommandOnID;
        aPlaceData:=StrToInt(tmpNodeValueFrom);
      end else raise exception.createFmtHelp(cserInternalError, ['Unknown NodeWhereFrom'], cnerInternalError);
    end else if (tmpNodeWhereFrom=nodEMS)and(tmpNodeWhereTo=nodEMS) then begin//С локального сервера на локальный сервер
      if StrToInt(tmpNodeValueFrom)<>StrToInt(tmpNodeValueTo) then begin
        aPlace:=pdsCommandOnBridge;
        aPlaceData:=StrToInt(tmpNodeValueFrom);
      end else begin
        aPlace:=pdsNone;
        aPlaceData:=unassigned;
      end;
    end else if (tmpNodeWhereFrom=nodEMS)and(tmpNodeWhereTo=nodESC) then begin//Схема простая, с локального сервера на клиента.
      aPlace:=pdsEventOnID;
      aPlaceData:=StrToInt(tmpNodeValueTo);
      PrevNode(tmpCurPosTo, aToNodeName, @tmpLengthTo, tmpNodeNameTo, tmpNodeValueTo);//д.б. EMS
      if (NodeNameToNodeWhere(tmpNodeNameTo)<>nodEMS)or(tmpNodeValueTo='') then raise exception.createFmtHelp(cserInvalidValueOf, [''''+tmpNodeNameTo+''''], cnerInvalidValueOf);
      if StrToInt(tmpNodeValueFrom)<>StrToInt(tmpNodeValueTo) then begin//для клиента другого узла
        aPlace:=pdsCommandOnBridge;
        aPlaceData:=StrToInt(tmpNodeValueFrom);
      end;
    end else if (tmpNodeWhereFrom=nodESC)and(tmpNodeWhereTo=nodEMS) then begin//Схема простая, с клиента на локальный сервер.
      aPlace:=pdsCommandOnID;
      aPlaceData:=StrToInt(tmpNodeValueFrom);
    end else if (tmpNodeWhereFrom=nodESC)and(tmpNodeWhereTo=nodESC) then begin//С клиента на клиент.
      aPlace:=pdsCommandOnID;    
      aPlaceData:=StrToInt(tmpNodeValueFrom);
    end else raise exception.createFmtHelp(cserInternalError, ['Неизвестная схема'], cnerInternalError);
  except on e:exception do begin
    aPlaceData:=unassigned;
    e.Message:='TwoNodeNameToPlace: '+e.Message;
    raise;
  end;end;
end;

end.
