#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	#Область СлужебныеПроцедурыИФункции
	
	Процедура ЗаполнитьГрафик(ДатаНачала, ДатаОкончания, ВыходныеДни) Экспорт
		
		
		Набор = РегистрыСведений.ВКМ_ГрафикиРаботы.СоздатьНаборЗаписей();
		Набор.Отбор.ГрафикРаботы.Установить(ГрафикРаботы);
		
		Набор.Прочитать();
		
		ЧислоСекундВСутках = 86400;
		
		Дат = ДатаНачала;
		Для к = 0 По Набор.Количество()-1 Цикл
			
			Запись = Набор[к];
			Если Запись.Дата < ДатаНачала Тогда
				Продолжить;
			ИначеЕсли Запись.Дата =Дат Тогда
				Если СтрНайти(ВыходныеДни, Строка(ДеньНедели(Дат))) Тогда
					Запись.РабочихДней = 0;
					Запись.РабочихЧасов = 0;
				Иначе	          
					Запись.РабочихДней = 1;
					Запись.РабочихЧасов = 8;
				КонецЕсли;
				Дат = Дат + ЧислоСекундВСутках;
			Иначе
				Пока Дат < Мин(Запись.Дата, ДатаОкончания) Цикл
					НоваяЗапись = Набор.Добавить();
					НоваяЗапись.ГрафикРаботы = ГрафикРаботы;
					НоваяЗапись.Дата = Дат;
					Если СтрНайти(ВыходныеДни, Строка(ДеньНедели(Дат))) Тогда
						НоваяЗапись.РабочихДней = 0;
						НоваяЗапись.РабочихЧасов = 0;
					Иначе	          
						НоваяЗапись.РабочихДней = 1;
						НоваяЗапись.РабочихЧасов = 8;
					КонецЕсли; 
					Дат = Дат + ЧислоСекундВСутках;
				КонецЦикла; 
				Если Запись.Дата > ДатаОкончания Тогда
					Прервать;
				Иначе
					Если СтрНайти(ВыходныеДни, Строка(ДеньНедели(Дат))) Тогда
						Запись.РабочихДней = 0;
						Запись.РабочихЧасов = 0;
					Иначе	          
						Запись.РабочихДней = 1;
						Запись.РабочихЧасов = 8;
					КонецЕсли;
				КонецЕсли;
				Дат = Дат + ЧислоСекундВСутках;
			КонецЕсли; 
		КонецЦикла;
		Набор.Записать();
		
		Пока Дат <= ДатаОкончания Цикл
			Запись = Набор.Добавить();
			Запись.ГрафикРаботы = ГрафикРаботы;
			Запись.Дата = Дат;
			Если СтрНайти(ВыходныеДни, Строка(ДеньНедели(Дат))) Тогда
				Запись.РабочихДней = 0;
				Запись.РабочихЧасов = 0;
			Иначе	          
				Запись.РабочихДней = 1;
				Запись.РабочихЧасов = 8;
			КонецЕсли; 
			Дат = Дат + ЧислоСекундВСутках;
		КонецЦикла; 
		Набор.Записать();
	КонецПроцедуры
	
	#КонецОбласти
#КонецЕсли
