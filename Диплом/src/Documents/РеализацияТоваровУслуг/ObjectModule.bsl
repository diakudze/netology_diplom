
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	#Область ОбработчикиСобытий
	
	Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
		
		Ответственный = Пользователи.ТекущийПользователь();
		
		Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
			ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
		КонецЕсли; 
		
		//Дьяков Г.А. 16.01.2023 
		Если ТипЗнч(ДанныеЗаполнения) = Тип("Массив") Тогда
			ЗаполнитьРеквизитыШапки(ДанныеЗаполнения);
			ВыполнитьАвтозаполнение(); 
		КонецЕсли;      
		

	КонецПроцедуры 
	
	Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
		
		Если ОбменДанными.Загрузка Тогда
			Возврат;
		КонецЕсли;
		
		СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
		
	КонецПроцедуры
	
	Процедура ОбработкаПроведения(Отказ, Режим)
		
		АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
		
		Движения.ОбработкаЗаказов.Записывать = Истина;
		Движения.ОстаткиТоваров.Записывать = Истина;
		Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина; //Дьяков 26.12.2023, пишем в регистр РН ВКМ_ВыполненныеКлиентуРаботы	
		
		Движение = Движения.ОбработкаЗаказов.Добавить();
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Договор = Договор;
		Движение.Заказ = Основание;
		Движение.СуммаОтгрузки = СуммаДокумента;
		
		Для Каждого ТекСтрокаТовары Из Товары Цикл
			Движение = Движения.ОстаткиТоваров.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Контрагент = Контрагент;
			Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
			Движение.Сумма = ТекСтрокаТовары.Сумма;
			Движение.Количество = ТекСтрокаТовары.Количество;
		КонецЦикла;
		
		//Дьяков 26.12.2023, пишем в регистр РН ВКМ_ВыполненныеКлиентуРаботы	
		Для Каждого ТекСтрокаУслуги Из Услуги Цикл
			Если ТекСтрокаУслуги.Номенклатура <> АбонентскаяПлата Тогда 
				Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
				Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
				Движение.Период = Дата;
				Движение.Клиент = Контрагент;
				Движение.Договор = Договор;
				Движение.СуммаКОплате = ТекСтрокаУслуги.Сумма;
				Движение.КоличествоЧасов = ТекСтрокаУслуги.Количество;
			КонецЕсли;
		КонецЦикла;  
		
	КонецПроцедуры
	
	#КонецОбласти
	
	#Область СлужебныеПроцедурыИФункции 
	
	Процедура ЗаполнитьРеквизитыШапки(ДанныеЗаполнения);
		
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДанныеЗаполнения[0]);
		
	КонецПроцедуры  
	
	Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ЗаказПокупателя.Организация КАК Организация,
		|	ЗаказПокупателя.Контрагент КАК Контрагент,
		|	ЗаказПокупателя.Договор КАК Договор,
		|	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
		|	ЗаказПокупателя.Товары.(
		|		Ссылка КАК Ссылка,
		|		НомерСтроки КАК НомерСтроки,
		|		Номенклатура КАК Номенклатура,
		|		Количество КАК Количество,
		|		Цена КАК Цена,
		|		Сумма КАК Сумма
		|	) КАК Товары,
		|	ЗаказПокупателя.Услуги.(
		|		Ссылка КАК Ссылка,
		|		НомерСтроки КАК НомерСтроки,
		|		Номенклатура КАК Номенклатура,
		|		Количество КАК Количество,
		|		Цена КАК Цена,
		|		Сумма КАК Сумма
		|	) КАК Услуги
		|ИЗ
		|	Документ.ЗаказПокупателя КАК ЗаказПокупателя
		|ГДЕ
		|	ЗаказПокупателя.Ссылка = &Ссылка";
		
		Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Не Выборка.Следующий() Тогда
			Возврат;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
		
		ТоварыОснования = Выборка.Товары.Выбрать();
		Пока ТоварыОснования.Следующий() Цикл
			ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
		КонецЦикла;
		
		УслугиОснования = Выборка.Услуги.Выбрать();
		Пока ТоварыОснования.Следующий() Цикл
			ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
		КонецЦикла;
		
		Основание = ДанныеЗаполнения;
		
	КонецПроцедуры
	
	Процедура ВыполнитьАвтозаполнение() Экспорт
		
		НоменклатураАбонентскийДоговор = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
		НоменклатураРаботыСотрудника = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
		
		Если НЕ ЗначениеЗаполнено(НоменклатураАбонентскийДоговор) 
			Или НЕ ЗначениеЗаполнено(НоменклатураРаботыСотрудника) Тогда
			ОбщегоНазначения.СообщитьПользователю("Заполните константы ""Номенклатура абонентский договор"" и ""Номенклатура работы сотрудника""");
			ЗаписьЖурналаРегистрации("Не заполнены константы ВКМ_АбоненсткаяПлата и ВКМ_РаботыСпециалиста", УровеньЖурналаРегистрации.Ошибка, Метаданные.Документы.РеализацияТоваровУслуг,,,);  
			Возврат;
		КонецЕсли;
		
		Услуги.Очистить();
		
		АктуальныйДоговор = ВернутьРезультатПроверкиПериодаДействияДоговора();
		
		Если ЗначениеЗаполнено(АктуальныйДоговор) и НЕ АктуальныйДоговор Тогда
			ОбщегоНазначения.СообщитьПользователю(СтрШаблон("Для договора %1 с контрагентом %2 не может быть сформирован документ ""Реализатия товаров и услуг"", т.к. срок действия договора не актуален.",Договор,Контрагент));
			ЗаписьЖурналаРегистрации("Договор с истекшим сроком действия.", УровеньЖурналаРегистрации.Ошибка, Метаданные.Документы.РеализацияТоваровУслуг,,,);  
			Возврат;
		КонецЕсли;
		
		ВыборкаАбонПлата = ВернутьСуммуАбонПлатыДоговора();
		ВыборкаАбонПлата.Следующий();
		
		Если ЗначениеЗаполнено(ВыборкаАбонПлата.АбоненсткаяПлата) Тогда
			
			СтрокаТЧ = Услуги.Добавить();
			СтрокаТЧ.Количество = 1;
			СтрокаТЧ.Цена = ВыборкаАбонПлата.АбоненсткаяПлата;
			СтрокаТЧ.Номенклатура = НоменклатураАбонентскийДоговор;
			СтрокаТЧ.Сумма = ВыборкаАбонПлата.АбоненсткаяПлата*СтрокаТЧ.Количество;
			
		КонецЕсли; 
		
		
		ВыборкаВыполненыеРаботы = ВернутьВыполненыеРаботы();
		ВыборкаВыполненыеРаботы.Следующий();
		
		Если ЗначениеЗаполнено(ВыборкаВыполненыеРаботы.СуммаКОплате) Тогда
			
			СтрокаТЧ = Услуги.Добавить();	
			СтрокаТЧ.Номенклатура = НоменклатураРаботыСотрудника; 
			СтрокаТЧ.Цена = ВыборкаВыполненыеРаботы.СуммаКОплате/ВыборкаВыполненыеРаботы.Количество;
			СтрокаТЧ.Количество = ВыборкаВыполненыеРаботы.Количество;
			СтрокаТЧ.Сумма = ВыборкаВыполненыеРаботы.СуммаКОплате;
			
		КонецЕсли;      
		
		СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
		
		
	КонецПроцедуры
	
	Функция ВернутьРезультатПроверкиПериодаДействияДоговора() 
		
		РезультатПроверкиПериодаДоговора = Ложь;
		
		Запрос = Новый Запрос;
		
		Запрос.Текст = "ВЫБРАТЬ
		               |	ВЫБОР
		               |		КОГДА ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание)
		               |				И (&Дата МЕЖДУ НАЧАЛОПЕРИОДА(ДоговорыКонтрагентов.ВКМ_НачалоДействия, ДЕНЬ) И КОНЕЦПЕРИОДА(ДоговорыКонтрагентов.ВКМ_ОкончаниеДействия, ДЕНЬ))
		               |			ТОГДА ИСТИНА
		               |		ИНАЧЕ ЛОЖЬ
		               |	КОНЕЦ КАК АктуальныйПериодДествияДоговора
		               |ИЗ
		               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		               |ГДЕ
		               |	НЕ ДоговорыКонтрагентов.ПометкаУдаления
		               |	И ДоговорыКонтрагентов.Ссылка = &Ссылка";
		
		Запрос.УстановитьПараметр("Ссылка", Договор);
		Запрос.УстановитьПараметр("Дата", Дата);

		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Выборка.Количество() > 0 Тогда
			
			Выборка.Следующий();
			
			РезультатПроверкиПериодаДоговора = Выборка.АктуальныйПериодДествияДоговора;	
			
		КонецЕсли;
		
		Возврат РезультатПроверкиПериодаДоговора;
		
	КонецФункции
	
	Функция ВернутьСуммуАбонПлатыДоговора();
		
		Запрос = Новый Запрос();
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ДоговорыКонтрагентов.ВКМ_АбоненсткаяПлата КАК АбоненсткаяПлата
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Ссылка = &Договор";
		Запрос.УстановитьПараметр("Договор", Договор);
		
		Возврат Запрос.Выполнить().Выбрать(); 
		
	КонецФункции
	
	Функция ВернутьВыполненыеРаботы(); 
		
		Запрос = Новый Запрос();
		
		Запрос.Текст = "ВЫБРАТЬ
		               |	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор КАК Договор,
		               |	ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовПриход КАК Количество,
		               |	ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеПриход КАК СуммаКОплате
		               |ИЗ
		               |	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(НАЧАЛОПЕРИОДА(&Дата, МЕСЯЦ), КОНЕЦПЕРИОДА(&Дата, МЕСЯЦ), , Договор = &Договор) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты
		               |ГДЕ
		               |	ВКМ_ВыполненныеКлиентуРаботыОбороты.Договор = &Договор";
				
		Запрос.УстановитьПараметр("Дата", Дата);  
		Запрос.УстановитьПараметр("Договор", Договор); 
		
		Возврат Запрос.Выполнить().Выбрать(); 
		
	КонецФункции

		
	#КонецОбласти
	
#КонецЕсли   


