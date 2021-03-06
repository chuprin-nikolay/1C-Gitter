﻿Процедура ПриОткрытии()
	
	ЭтаФорма.АутентификацияСервера = ЗначениеЗаполнено(ИмяПользователя); 
	Если Не ЗначениеЗаполнено(ИмяБД) Тогда
		ЭтаФорма.ИмяБД = НСтр(СтрокаСоединенияИнформационнойБазы(), "Ref");
	КонецЕсли; 
	ОбновитьДоступность();
	
КонецПроцедуры

Процедура ОсновныеДействияФормыКнопкаОК(Кнопка = Неопределено)
	
	Если Ложь
		Или Не ЗначениеЗаполнено(ИмяСервера) 
		Или Не ЗначениеЗаполнено(ИмяБД) 
	Тогда
		Предупреждение("Не заполнены обязательные параметры");
		Возврат;
	КонецЕсли; 
	Соединение = УстановитьСоединение();
	Если Соединение <> Неопределено Тогда 
		СохранитьЗначение("ирПараметрыСоединенияСУБД.ИмяСервера", ИмяСервера);
		СохранитьЗначение("ирПараметрыСоединенияСУБД.ИмяБД", ИмяБД);
		СохранитьЗначение("ирПараметрыСоединенияСУБД.ИмяПользователя", ИмяПользователя);
		СохранитьЗначение("ирПараметрыСоединенияСУБД.Пароль", Новый ХранилищеЗначения(Пароль));
		Закрыть();
	КонецЕсли; 
	
КонецПроцедуры

Функция УстановитьСоединение()
	
	Соединение = ирОбщий.ПолучитьСоединениеСУБД(ИмяСервера, ИмяБД, ИмяПользователя, Пароль);
	Возврат Соединение;

КонецФункции

Процедура АутентификацияСервераПриИзменении(Элемент)
	
	ОбновитьДоступность();
	
КонецПроцедуры

Процедура ОбновитьДоступность()
	
	ЭлементыФормы.ИмяПользователя.Доступность = АутентификацияСервера;
	ЭлементыФормы.Пароль.Доступность = АутентификацияСервера;

КонецПроцедуры

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьПараметры();
	Если Истина
		И ЗначениеЗаполнено(ИмяСервера) 
		И ЗначениеЗаполнено(ИмяБД) 
		И Автоподключение 
	Тогда
		Соединение = УстановитьСоединение();
		Если Соединение <> Неопределено Тогда
			Отказ = Истина;
		КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры

Процедура ЗаполнитьПараметры() Экспорт 
	
	ЭтаФорма.ИмяСервера = ВосстановитьЗначение("ирПараметрыСоединенияСУБД.ИмяСервера");
	ЭтаФорма.ИмяБД = ВосстановитьЗначение("ирПараметрыСоединенияСУБД.ИмяБД");
	ЭтаФорма.ИмяПользователя = ВосстановитьЗначение("ирПараметрыСоединенияСУБД.ИмяПользователя");
	НовыйПароль = ВосстановитьЗначение("ирПараметрыСоединенияСУБД.Пароль");
	Если НовыйПароль <> Неопределено Тогда
		ЭтаФорма.Пароль = НовыйПароль.Получить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ОсновныеДействияФормыСтруктураФормы(Кнопка)
	
	ирОбщий.ОткрытьСтруктуруФормыЛкс(ЭтаФорма);
	
КонецПроцедуры

ирОбщий.ИнициализироватьФормуЛкс(ЭтаФорма, "Обработка.ирПлатформа.Форма.ПараметрыСоединенияСУБД");
ЭтаФорма.Автоподключение = Истина;