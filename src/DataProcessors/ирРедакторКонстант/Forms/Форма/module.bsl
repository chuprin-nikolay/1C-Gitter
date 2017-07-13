﻿//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;

//Запомним ограничение типа

Процедура КнопкаВыполнитьНажатие(Кнопка)
	// Вставить содержимое обработчика.
КонецПроцедуры

Процедура КоманднаяПанель1ЗаписатьКонстанты(Кнопка)
	
	Для каждого СтрокаКонстанты Из ТаблицаКонстант Цикл
		Если НЕ СтрокаКонстанты.ПризнакМодификации Тогда
			Продолжить;
		КонецЕсли;
		Если ПравоДоступа("Изменение", Метаданные.Константы[СтрокаКонстанты.ИдентификаторКонстанты], ПользователиИнформационнойБазы.ТекущийПользователь()) Тогда
			МенеджерЗначения = Константы[СтрокаКонстанты.ИдентификаторКонстанты].СоздатьМенеджерЗначения();
			МенеджерЗначения.Значение = СтрокаКонстанты.РасширенноеЗначение;
			Попытка
				ирОбщий.ЗаписатьОбъектЛкс(МенеджерЗначения, ЗаписьНаСервере,,, ОтключатьКонтрольЗаписи);
			Исключение
				Сообщить("Ошибка записи константы """ + СтрокаКонстанты.ИдентификаторКонстанты + """:" + ОписаниеОшибки());
				Продолжить;
			КонецПопытки;
			СтрокаКонстанты.ПризнакМодификации = Ложь;
			МенеджерЗначения.Прочитать();
			УстановитьСчитанноеЗначениеКонстанты(СтрокаКонстанты, МенеджерЗначения.Значение);
			//ЗаписьЖурналаРегистрации("Редактирование константы", УровеньЖурналаРегистрации.Информация, Метаданные.Константы[СтрокаКонстанты.ИдентификаторКонстанты], СтрокаКонстанты.Значение);
		КонецЕсли; 
	КонецЦикла;
	Модифицированность = Ложь;
	
КонецПроцедуры

Процедура ПрочитатьКонстантыИзБазы()
	
	ИмяТекущейКонстаты = Неопределено;
	Если ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока <> Неопределено Тогда
		ИмяТекущейКонстаты = ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока.ИдентификаторКонстанты;
	КонецЕсли; 
	ТаблицаКонстант.Очистить();
	ЭлементыФормы.НадписьЕстьНедоступныеКонстанты.Видимость = Ложь;
	Для каждого Константа Из Метаданные.Константы Цикл
		//Если НЕ ПравоДоступа("Чтение", Константа, ПользователиИнформационнойБазы.ТекущийПользователь()) Тогда
		//    Продолжить;
		//КонецЕсли;
		КонстантаМенеджер = Константы[Константа.имя];
		Попытка
			ЗначениеКонстанты = КонстантаМенеджер.Получить();
		Исключение
			ОписаниеОшибки = ОписаниеОшибки();
			Сообщить("Пропущена недоступная константа """ + Константа.Имя + """");
			ЭлементыФормы.НадписьЕстьНедоступныеКонстанты.Видимость = Истина;
			Продолжить;
		КонецПопытки;
		НоваяСтрока = ТаблицаКонстант.Добавить();
		НоваяСтрока.ИдентификаторКонстанты = Константа.Имя;
		НоваяСтрока.СинонимКонстанты = Константа.Синоним;
		НоваяСтрока.Подсказка = Константа.Подсказка;
		НоваяСтрока.ОписаниеТипов = Константа.Тип;
		НоваяСтрока.РазрешеноИзменение = ПравоДоступа("Изменение", Константа, ПользователиИнформационнойБазы.ТекущийПользователь());
		Для Каждого МетаФункциональнаяОпция Из Метаданные.ФункциональныеОпции Цикл
			Если МетаФункциональнаяОпция.Хранение = Константа Тогда
				НоваяСтрока.ФункциональнаяОпция = МетаФункциональнаяОпция.Имя;
			КонецЕсли; 
		КонецЦикла;
		Если ИмяТекущейКонстаты = НоваяСтрока.ИдентификаторКонстанты Тогда
			ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока = НоваяСтрока;
		КонецЕсли; 
		УстановитьСчитанноеЗначениеКонстанты(НоваяСтрока, ЗначениеКонстанты);
	КонецЦикла;
	
КонецПроцедуры

Процедура УстановитьСчитанноеЗначениеКонстанты(Знач НоваяСтрока, Знач ЗначениеКонстанты)
	
	НоваяСтрока.РасширенноеЗначение = ЗначениеКонстанты;
	НоваяСтрока.Значение = ЗначениеКонстанты;
	ирОбщий.ОбновитьТипЗначенияВСтрокеТаблицыЛкс(НоваяСтрока, "РасширенноеЗначение");

КонецПроцедуры

Процедура ПередОткрытием(Отказ, СтандартнаяОбработка)
	ПрочитатьКонстантыИзБазы();
КонецПроцедуры

Процедура ТаблицаКонстантПередНачаломДобавления(Элемент, Отказ, Копирование)
	Отказ = ИСТИНА;
КонецПроцедуры

Процедура ТаблицаКонстантПередУдалением(Элемент, Отказ)
	Отказ = ИСТИНА;
КонецПроцедуры

Процедура ТаблицаКонстантПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	Если ОтменаРедактирования Тогда
		Возврат;
	КонецЕсли;
	Элемент.Колонки.Значение.ЭлементУправления.ОграничениеТипа = Метаданные.Константы[ЭлементыФормы.ТаблицаКонстант.ТекущиеДанные.ИдентификаторКонстанты].Тип;
	ЭлементыФормы.ТаблицаКонстант.ТекущиеДанные.ПризнакМодификации = ИСТИНА;
	ЭтаФорма.Модифицированность = Истина;
КонецПроцедуры

Процедура ТаблицаКонстантПриВыводеСтроки(Элемент, ОформлениеСтроки, ДанныеСтроки)
	
	Если ДанныеСтроки.ПризнакМодификации = Истина Тогда
		ОформлениеСтроки.ЦветТекста = WebЦвета.КожаноКоричневый;
	КонецЕсли; 
	
	Если НЕ ДанныеСтроки.РазрешеноИзменение Тогда
		ОформлениеСтроки.Ячейки.Значение.ТолькоПросмотр = ИСТИНА;
	КонецЕсли;

	Если Истина
		И ДанныеСтроки.РазрешеноИзменение
		И ТипЗнч(ДанныеСтроки.Значение) = Тип("Булево") 
	Тогда
		ОформлениеСтроки.Ячейки.Значение.УстановитьФлажок(ДанныеСтроки.Значение);
	КонецЕсли; 
	ирОбщий.ТабличноеПолеПриВыводеСтрокиЛкс(Элемент, ОформлениеСтроки, ДанныеСтроки, , "Значение",
		Новый Структура("Значение", "РасширенноеЗначение"), Истина);
	
КонецПроцедуры

// <Описание функции>
//
// Параметры:
//  <Параметр1>  – <Тип.Вид> – <описание параметра>
//                 <продолжение описания параметра>;
//  <Параметр2>  – <Тип.Вид> – <описание параметра>
//                 <продолжение описания параметра>.
//
// Возвращаемое значение:
//               – <Тип.Вид> – <описание значения>
//                 <продолжение описания значения>;
//  <Значение2>  – <Тип.Вид> – <описание значения>
//                 <продолжение описания значения>.
//
Функция ПроверкаМодифицированностиФормы()

	Если ЭтаФорма.Модифицированность Тогда
		Ответ = Вопрос("Данные в форме были изменены. Сохранить изменения?", РежимДиалогаВопрос.ДаНетОтмена);
		Если Ответ = КодВозвратаДиалога.Отмена Тогда
			Возврат Ложь;
		ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
			КоманднаяПанель1ЗаписатьКонстанты(0);
		КонецЕсли;
	КонецЕсли;
	Возврат Истина;

КонецФункции // ПроверкаМодифицированностиФормы()

Процедура КоманднаяПанель1Перечиать(Кнопка)
	
	Если Не ПроверкаМодифицированностиФормы() Тогда
		Возврат;
	КонецЕсли;
	ПрочитатьКонстантыИзБазы();
	
КонецПроцедуры

Процедура ТаблицаКонстантПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	ЭлементыФормы.ТаблицаКонстант.Колонки.Значение.ЭлементУправления.ОграничениеТипа = Метаданные.Константы[Элемент.ТекущиеДанные.ИдентификаторКонстанты].Тип;
КонецПроцедуры

Процедура ПриОткрытии()
	
	Если ЗначениеЗаполнено(НачальноеЗначениеВыбора) Тогда
		ТекущаяСтрока = ТаблицаКонстант.Найти(НачальноеЗначениеВыбора, "ИдентификаторКонстанты");
		Если ТекущаяСтрока <> Неопределено Тогда
			ЭтаФорма.ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока = ТекущаяСтрока;
			ЭтаФорма.ЭлементыФормы.ТаблицаКонстант.ТекущаяКолонка = ЭтаФорма.ЭлементыФормы.ТаблицаКонстант.Колонки.Значение;
		КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры

Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	
	Отказ = Не ПроверкаМодифицированностиФормы();
	
КонецПроцедуры

Процедура КоманднаяПанель1ОПодсистеме(Кнопка)
	ирОбщий.ОткрытьСправкуПоПодсистемеЛкс(ЭтотОбъект);
КонецПроцедуры

Процедура ТаблицаКонстантЗначениеКонстантыПриИзменении(Элемент)
	
	ТекущиеДанные = ЭлементыФормы.ТаблицаКонстант.ТекущиеДанные;
	ТекущиеДанные.РасширенноеЗначение = ТекущиеДанные.Значение;
	ОбновитьТипЗначенияВСтрокеТаблицы();
	
КонецПроцедуры

Процедура ТаблицаКонстантПриИзмененииФлажка(Элемент, Колонка)
	
	ирОбщий.ИнтерактивноЗаписатьВКолонкуТабличногоПоляЛкс(Элемент, Колонка, Не Элемент.ТекущаяСтрока[Колонка.Данные]);

КонецПроцедуры

Процедура ТаблицаКонстантЗначениеКонстантыОкончаниеВводаТекста(Элемент, Текст, Значение, СтандартнаяОбработка)
	
	ирОбщий.ПолеВвода_ОкончаниеВводаТекстаЛкс(Элемент, Текст, Значение, СтандартнаяОбработка);

КонецПроцедуры

Процедура КоманднаяПанель1ЖурналРегистрации(Кнопка)
	
	ТекущаяСтрока = ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока;
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	АнализЖурналаРегистрации = ирОбщий.ПолучитьОбъектПоПолномуИмениМетаданныхЛкс("Обработка.ирАнализЖурналаРегистрации");
	#Если Сервер И Не Сервер Тогда
		АнализЖурналаРегистрации = Обработки.ирАнализЖурналаРегистрации.Создать();
	#КонецЕсли
	АнализЖурналаРегистрации.ОткрытьСПараметром("Метаданные", "Константа." + ТекущаяСтрока.ИдентификаторКонстанты);
	
КонецПроцедуры

Процедура КоманднаяПанель1РедакторОбъектаБДСтроки(Кнопка)
	
	ТекущаяСтрока = ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока;
	Если ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	КлючОбъекта = Новый ("КонстантаМенеджерЗначения." + ТекущаяСтрока.ИдентификаторКонстанты);
	ирОбщий.ОткрытьСсылкуВРедактореОбъектаБДЛкс(КлючОбъекта);
	
КонецПроцедуры

Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	ирОбщий.ФормаОбработкаОповещенияЛкс(ЭтаФорма, ИмяСобытия, Параметр, Источник); 

КонецПроцедуры

Процедура КлсУниверсальнаяКомандаНажатие(Кнопка) Экспорт 
	
	ирОбщий.УниверсальнаяКомандаФормыЛкс(ЭтаФорма, Кнопка);
	
КонецПроцедуры

Процедура ОбработчикОжиданияСПараметрамиЛкс() Экспорт 
	
	ирОбщий.ОбработчикОжиданияСПараметрамиЛкс();

КонецПроцедуры

Процедура ТаблицаКонстантВыбор(Элемент, ВыбраннаяСтрока, Колонка, СтандартнаяОбработка)
	
	Если Колонка = ЭлементыФормы.ТаблицаКонстант.Колонки.ФункциональнаяОпция Тогда
		Если ЗначениеЗаполнено(ВыбраннаяСтрока.ФункциональнаяОпция) Тогда
			ирОбщий.ИсследоватьЛкс(Метаданные.ФункциональныеОпции[ВыбраннаяСтрока.ФункциональнаяОпция]);
		КонецЕсли; 
	ИначеЕсли Колонка = ЭлементыФормы.ТаблицаКонстант.Колонки.Подсказка Тогда
		Если ЗначениеЗаполнено(ВыбраннаяСтрока[Колонка.Имя]) Тогда
			ирОбщий.ОткрытьТекстЛкс(ВыбраннаяСтрока[Колонка.Имя]);
		КонецЕсли; 
	Иначе
		Если ирОбщий.ЯчейкаТабличногоПоляРасширенногоЗначения_ВыборЛкс(Элемент, СтандартнаяОбработка, ВыбраннаяСтрока.РасширенноеЗначение) Тогда 
			ОбновитьТипЗначенияВСтрокеТаблицы();
		КонецЕсли; 
	КонецЕсли; 
	
КонецПроцедуры

Процедура ОбновитьТипЗначенияВСтрокеТаблицы()
	
	ирОбщий.ОбновитьТипЗначенияВСтрокеТаблицыЛкс(ЭлементыФормы.ТаблицаКонстант.ТекущиеДанные, "РасширенноеЗначение");

КонецПроцедуры

Процедура ТаблицаКонстантЗначениеНачалоВыбора(Элемент, СтандартнаяОбработка)
	
	ирОбщий.ПолеВводаКолонкиРасширенногоЗначения_НачалоВыбораЛкс(ЭлементыФормы.ТаблицаКонстант, СтандартнаяОбработка);
		
КонецПроцедуры

Процедура КоманднаяПанель1СправкаМетаданного(Кнопка)
	
	Если ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	ОткрытьСправку(Метаданные.НайтиПоПолномуИмени("Константа." + ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока.ИдентификаторКонстанты));
	
КонецПроцедуры

Процедура КоманднаяПанель1ВключитьВсеФункциональныеОпции(Кнопка)
	
	Индикатор = ирОбщий.ПолучитьИндикаторПроцессаЛкс(ТаблицаКонстант.Количество());
	Для каждого СтрокаКонстанты из ТаблицаКонстант Цикл
		ирОбщий.ОбработатьИндикаторЛкс(Индикатор);
		Если Истина
			И ЗначениеЗаполнено(СтрокаКонстанты.ФункциональнаяОпция) 
			И СтрокаКонстанты.РазрешеноИзменение
			И СтрокаКонстанты.ТипЗначения.СодержитТип(Тип("Булево")) 
		Тогда
			СтрокаКонстанты.РасширенноеЗначение = Истина;
			СтрокаКонстанты.Значение = СтрокаКонстанты.РасширенноеЗначение;
			СтрокаКонстанты.ПризнакМодификации = Истина;
			ЭтаФорма.Модифицированность = Истина;
		КонецЕсли; 
	КонецЦикла;
	ирОбщий.ОсвободитьИндикаторПроцессаЛкс();
	
КонецПроцедуры

Процедура ТаблицаКонстантЗначениеОткрытие(Элемент, СтандартнаяОбработка)
	
	РасширенноеЗначение = ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока.РасширенноеЗначение;
	Если Ложь
		Или ТипЗнч(РасширенноеЗначение) = Тип("ХранилищеЗначения")
	Тогда
		СтандартнаяОбработка = Ложь;
		ирОбщий.ИсследоватьЛкс(ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока.РасширенноеЗначение);
	КонецЕсли; 

КонецПроцедуры

Процедура СтруктураКоманднойПанелиНажатие(Кнопка)
	
	ирОбщий.ОткрытьСтруктуруКоманднойПанелиЛкс(ЭтаФорма, Кнопка);
	
КонецПроцедуры

Процедура ОсновныеДействияФормыСтруктураФормы(Кнопка)
	
	ирОбщий.ОткрытьСтруктуруФормыЛкс(ЭтаФорма);
	
КонецПроцедуры

Процедура КоманднаяПанель1ОткрытьОбъектМетаданных(Кнопка)
	
	Если ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	ирОбщий.ОткрытьОбъектМетаданныхЛкс("Константа." + ЭлементыФормы.ТаблицаКонстант.ТекущаяСтрока.ИдентификаторКонстанты);
	
КонецПроцедуры

//ирПортативный #Если Клиент Тогда
//ирПортативный Контейнер = Новый Структура();
//ирПортативный Оповестить("ирПолучитьБазовуюФорму", Контейнер);
//ирПортативный Если Не Контейнер.Свойство("ирПортативный", ирПортативный) Тогда
//ирПортативный 	ПолноеИмяФайлаБазовогоМодуля = ВосстановитьЗначение("ирПолноеИмяФайлаОсновногоМодуля");
//ирПортативный 	ирПортативный = ВнешниеОбработки.ПолучитьФорму(ПолноеИмяФайлаБазовогоМодуля);
//ирПортативный КонецЕсли; 
//ирПортативный ирОбщий = ирПортативный.ПолучитьОбщийМодульЛкс("ирОбщий");
//ирПортативный ирКэш = ирПортативный.ПолучитьОбщийМодульЛкс("ирКэш");
//ирПортативный ирСервер = ирПортативный.ПолучитьОбщийМодульЛкс("ирСервер");
//ирПортативный ирПривилегированный = ирПортативный.ПолучитьОбщийМодульЛкс("ирПривилегированный");
//ирПортативный #КонецЕсли

ирОбщий.ИнициализироватьФормуЛкс(ЭтаФорма, "Обработка.ирРедакторКонстант.Форма.Форма");

ТаблицаКонстант.Колонки.Добавить("РасширенноеЗначение");