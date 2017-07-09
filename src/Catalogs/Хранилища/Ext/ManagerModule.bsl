﻿
#Область ВерсииХранилища

Процедура ЗагрузитьНовыеВерсии( Знач Хранилище ) Экспорт
	
	ЛогОтладка( "--Загрузка новых версий " + Хранилище + "--" );
	
	НомерПоследнейВерсииВХранилище = Справочники.Хранилища.ПолучитьНомерПоследнейВерсии( Хранилище );
	
	Если Хранилище.ПослеВосстановления Тогда
		
		НомерПоследнейВерсииВХранилище = НомерПоследнейВерсииВХранилище - Хранилище.ПотеряноВерсий;
		
	КонецЕсли;
	
	ТаблицаВерсий = ПакетныйРежим.ПолучитьТаблицуВерсийХранилища( Хранилище,
																  Хранилище.Приложение1С,
																  Хранилище.ТранзитнаяБазаАдрес,
																  Хранилище.ТранзитнаяБазаПользователь,
																  Хранилище.ТранзитнаяБазаПароль,
																  Хранилище.ХранилищеАдрес,
																  Хранилище.ХранилищеПользователь,
																  Хранилище.ХранилищеПароль,
																  НомерПоследнейВерсииВХранилище + 1 );
	
	Для Каждого ТекущаяСтрока Из ТаблицаВерсий Цикл
		
		НоваяВерсия = Справочники.ВерсииКонфигурацийХранилища.СоздатьЭлемент();
		НомерВерсии = ТекущаяСтрока.НомерВерсии;
		
		Если Хранилище.ПослеВосстановления Тогда
			
			НомерВерсии = НомерВерсии + Хранилище.ПотеряноВерсий;
			
		КонецЕсли;
		
		НоваяВерсия.Код          = НомерВерсии;
		НоваяВерсия.Владелец     = Хранилище;
		НоваяВерсия.Пользователь = Справочники.ПользователиХранилища.ПолучитьПоНаименованию( ТекущаяСтрока.ИмяПользователя,
																							 Хранилище );
		НоваяВерсия.ДатаСоздания = ТекущаяСтрока.ДатаСоздания;
		НоваяВерсия.Комментарий  = ТекущаяСтрока.Комментарий;
		НоваяВерсия.Записать();
		
		Сообщить( " +" + НомерВерсии + ". " + НоваяВерсия.Пользователь + ": " + НоваяВерсия.Комментарий );
		
		Если Хранилище.ВыгруженАктуальныйCF Тогда
			
			об = Хранилище.ПолучитьОбъект();
			об.ВыгруженАктуальныйCF = Ложь;
			об.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЛогОтладка( "++Загрузка новых версий " + Хранилище + "++" );
	
КонецПроцедуры

Функция ПолучитьНомерПоследнейВерсии( Знач Хранилище ) Экспорт

	НомерПоследнейВерсии = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	               |	ВерсииКонфигурацийХранилища.Код КАК НомерВерсии
	               |ИЗ
	               |	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
	               |ГДЕ
	               |	ВерсииКонфигурацийХранилища.Владелец = &Хранилище
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ВерсииКонфигурацийХранилища.Код УБЫВ";
	Запрос.УстановитьПараметр("Хранилище", Хранилище);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		НомерПоследнейВерсии = Выборка.НомерВерсии;		
	КонецЕсли;
	
	Возврат НомерПоследнейВерсии;
	
КонецФункции

Функция ЭтоПоследняяНевыгруженнаяВерсия( Знач пТекущаяВыгружаемаяВерсия )
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВерсииКонфигурацийХранилища.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
	|ГДЕ
	|	ВерсииКонфигурацийХранилища.Владелец = &Владелец
	|	И НЕ ВерсииКонфигурацийХранилища.ВыгруженаВЛокальныйРепозиторий
	|	И ВерсииКонфигурацийХранилища.Код > ВерсииКонфигурацийХранилища.Владелец.МинимальнаяВерсияДляВыгрузки
	|	И ВерсииКонфигурацийХранилища.Ссылка <> &ТекущаяВыгружаемаяВерсия";
	Запрос.УстановитьПараметр("Владелец", пТекущаяВыгружаемаяВерсия.Владелец );
	Запрос.УстановитьПараметр("ТекущаяВыгружаемаяВерсия", пТекущаяВыгружаемаяВерсия );
	
	Возврат Запрос.Выполнить().Пустой();

КонецФункции

Процедура УстановитьПризнакВыгруженностиВерсииВЛокальныйРепозиторий( Знач Версия )
	
	ВерсияОбъект = Версия.ПолучитьОбъект();
	ВерсияОбъект.ВыгруженаВЛокальныйРепозиторий = Истина;
	ВерсияОбъект.Записать();
	
КонецПроцедуры

Процедура УстановитьВерсиюВВерсию( Знач Версия )
	
	ВерсияОбъект = Версия.ПолучитьОбъект();
	ВерсияОбъект.ВерсияКонфигурации = ОпределитьВерсиюКонфигурации( Версия.Владелец );
	ВерсияОбъект.Записать();
	
КонецПроцедуры

Функция ОпределитьВерсиюКонфигурации( Знач пХранилище )
	
	каталог = ПолучитьКаталогКонфигурации( пХранилище );
	
	файлКонфигурации = каталог + "\Configuration.xml";
	
	Если Не ФайлСуществует(файлКонфигурации) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	чтениеXML = Новый ЧтениеXML;
	
	чтениеXML.ОткрытьФайл(файлКонфигурации);
	
	ВерсияКонфигурации = Неопределено;
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И ВРег( ЧтениеXML.Имя ) = ВРег( "Version" ) Тогда
			
			Если Не ЧтениеXML.Прочитать() Тогда
				Продолжить;
			КонецЕсли;
			
			Если Не ЧтениеXML.ТипУзла = ТипУзлаXML.Текст Тогда
				Продолжить;
			КонецЕсли;
			
			ВерсияКонфигурации = ЧтениеXML.Значение;
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат ВерсияКонфигурации;
	
КонецФункции

Процедура УстановитьНовуюВерсиюКонфигурации( Знач Хранилище, ВерсияКонфигурации )
	
	Если Хранилище.ТекущаяВерсияКонфигурации = ВерсияКонфигурации Тогда
		
		Возврат;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено( Хранилище.СкриптПриСменеВерсии ) Тогда
		
		началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		ЛогОтладка( "--Начало выполнения скрипта при смене версии на " + ВерсияКонфигурации + "--" );
		
		командаСкрипта = Вычислить( Хранилище.СкриптПриСменеВерсии );
		
		командныйФайл = ПолучитьИмяВременногоФайла( "bat" );
		
		записьТекста = Новый ЗаписьТекста( командныйФайл, "cp866" );
		записьТекста.ЗаписатьСтроку( командаСкрипта );
		записьТекста.Закрыть();
		
		КодВозврата = ВыполнитьКомандныйФайл( Хранилище.ЛокальныйРепозиторийАдрес, командныйФайл );
		
		УдалитьФайлы( командныйФайл );
		
		Если КодВозврата <> 0 Тогда
			
			ОписаниеОшибки = "При выполнении скрипта на смену версии произошла ошибка";
			ВызватьИсключение ОписаниеОшибки + "(" + командаСкрипта + ")";
			
		КонецЕсли;
		
		затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
		
		логИнформация( "Выполнен скрипт при смене версии на " + ВерсияКонфигурации + ". " + затрачено + "мс" );
		
	КонецЕсли;
	
	об = Хранилище.ПолучитьОбъект();
	об.ТекущаяВерсияКонфигурации = ВерсияКонфигурации;
	об.Записать();
	
КонецПроцедуры


#КонецОбласти

#Область Выгрузка

Процедура ВыгрузитьВерсииВЛокальныйРепозиторий( Знач Хранилище, КоличествоВерсийВыгружаемыхЗаРаз = 0 ) Экспорт
	
	ЛогОтладка( "--Получение изменений из удаленного репозитория " + Хранилище + "--" );
	
	Git.Pull( Хранилище.ЛокальныйРепозиторийАдрес );
	
	ЛогОтладка( "++Получение изменений из удаленного репозитория " + Хранилище + "++" );
	
	ЛогОтладка( "--Выгрузка версий в локальный репозиторий " + Хранилище + "--" );
	
	ТекстЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВерсииКонфигурацийХранилища.Ссылка КАК Версия,
		|	ВерсииКонфигурацийХранилища.Код КАК НомерВерсии,
		|	ВерсииКонфигурацийХранилища.ДатаСоздания КАК ДатаСоздания,
		|	ВЫБОР
		|		КОГДА ВерсииКонфигурацийХранилища.Пользователь.ИмяПользователя = """"
		|			ТОГДА ВерсииКонфигурацийХранилища.Пользователь.Наименование
		|		ИНАЧЕ ВерсииКонфигурацийХранилища.Пользователь.ИмяПользователя
		|	КОНЕЦ КАК ИмяПользователя,
		|	ВерсииКонфигурацийХранилища.Пользователь.Email КАК EmailПользователя,
		|	ВерсииКонфигурацийХранилища.Комментарий КАК Комментарий
		|ИЗ
		|	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
		|ГДЕ
		|	ВерсииКонфигурацийХранилища.Владелец = &Хранилище
		|	И НЕ ВерсииКонфигурацийХранилища.ВыгруженаВЛокальныйРепозиторий
		|	И ВерсииКонфигурацийХранилища.Владелец.МинимальнаяВерсияДляВыгрузки <= ВерсииКонфигурацийХранилища.Код
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВерсииКонфигурацийХранилища.Код";
	
	Если ЗначениеЗаполнено( КоличествоВерсийВыгружаемыхЗаРаз ) Тогда
		
		ТекстЗапроса = СтрЗаменить( ТекстЗапроса,
									"ПЕРВЫЕ 1",
									"ПЕРВЫЕ " + Формат( КоличествоВерсийВыгружаемыхЗаРаз, "ЧГ=0" ) );
		
	Иначе
		
		ТекстЗапроса = СтрЗаменить( ТекстЗапроса, "ПЕРВЫЕ 1", "" );
		
	КонецЕсли;
	
	Запрос = Новый Запрос( ТекстЗапроса );
	Запрос.УстановитьПараметр( "Хранилище", Хранилище );
	
	результатЗапроса = Запрос.Выполнить();
	
	Если результатЗапроса.Пустой() Тогда
		
		Возврат;
	
	КонецЕсли;
	
	Выборка = результатЗапроса.Выбрать();
	
	Попытка
		
		РегистрыСведений.СтатусыВыгрузки.Выгружается( Хранилище );
		
		Пока Выборка.Следующий() Цикл
			
			#Если Клиент Тогда
			
			ОбработкаПрерыванияПользователя();
			
			#КонецЕсли
	
			НомерВерсииВХранилище = Выборка.НомерВерсии;
			
			Если Хранилище.ПослеВосстановления Тогда
				
				НомерВерсииВХранилище = НомерВерсииВХранилище - Хранилище.ПотеряноВерсий;
				
			КонецЕсли;
			
			каталогКонфигурации = ПолучитьКаталогКонфигурации( Хранилище );
			
			началоВыгрузкиОбщая = ТекущаяУниверсальнаяДатаВМиллисекундах();
			
			ЛогИнформация( "Версия: " + НомерВерсииВХранилище + ", " + выборка.ИмяПользователя + ": " + выборка.Комментарий );
			
			началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
			
			ЛогОтладка( "Загрузка из хранилища версии " + НомерВерсииВХранилище );
			
			ПакетныйРежим.ЗагрузитьКонфигурациюИзХранилища( Хранилище,
															Хранилище.Приложение1С,
															Хранилище.ТранзитнаяБазаАдрес,
															Хранилище.ТранзитнаяБазаПользователь,
															Хранилище.ТранзитнаяБазаПароль,
															Хранилище.ХранилищеАдрес,
															Хранилище.ХранилищеПользователь,
															Хранилище.ХранилищеПароль,
															НомерВерсииВХранилище );
			
			затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
			ЛогОтладка( "Выгружена " + НомерВерсииВХранилище + ". " + затрачено + "мс" );
			
			ЛогОтладка( "Подготовка каталога и конфигурирование пользователя" );
			
			Git.СконфигурироватьИмяПользователя( Хранилище.ЛокальныйРепозиторийАдрес, Выборка.ИмяПользователя );
			Git.СконфигурироватьEmailПользователя( Хранилище.ЛокальныйРепозиторийАдрес, Выборка.EmailПользователя );
			
			началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
			
			ЛогОтладка( "Выгрузка файлов" );
			
			ПакетныйРежим.ВыгрузитьКонфигурациюВФайлы( Хранилище,
													   Хранилище.Приложение1С,
													   Хранилище.ТранзитнаяБазаАдрес,
													   Хранилище.ТранзитнаяБазаПользователь,
													   Хранилище.ТранзитнаяБазаПароль,
													   каталогКонфигурации );
			
			затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузки;
			ЛогОтладка( "Выгружены файлы. " + затрачено + "мс" );
			
			РаспаковатьОбычныеФормы( каталогКонфигурации, Хранилище );
			
			УстановитьВерсиюВВерсию( выборка.Версия );
			
			ВыгрузитьАктуальныйCF( Хранилище, Выборка.Версия ); // Выгружаем cf до коммита, т.к. cf может выгружаться как раз в репо
			УстановитьНовуюВерсиюКонфигурации( Хранилище, выборка.Версия.ВерсияКонфигурации ); // Аналогично скрипт при смене запускает до коммита
			
			ЛогОтладка( "Включение отслеживания и коммит" );
			
			Git.ВыполнитьИндексированиеИКоммит( Хранилище.ЛокальныйРепозиторийАдрес,
												Выборка.Комментарий,
												Выборка.ДатаСоздания,
												Хранилище );
			Git.СохранитьСписокИзменений( Хранилище.ЛокальныйРепозиторийАдрес, Хранилище, Выборка.Версия );
			
			УстановитьПризнакВыгруженностиВерсииВЛокальныйРепозиторий( Выборка.Версия );
			
			затраченоВсего = ТекущаяУниверсальнаяДатаВМиллисекундах() -началоВыгрузкиОбщая;
			логИнформация( "Обработана версия " + НомерВерсииВХранилище + ". " + затраченоВсего + "мс" );
			
		КонецЦикла;

		
		ЛогОтладка( "++Выгрузка версий в локальный репозиторий++" );
		
		РегистрыСведений.СтатусыВыгрузки.Выгружено( Хранилище );
		
	Исключение
		
		подробноеОписаниеОшибки = ПодробноеПредставлениеОшибки( ИнформацияОбОшибке() );
		
		РегистрыСведений.СтатусыВыгрузки.ЗавершеноСОшибками( Хранилище, подробноеОписаниеОшибки );
		
		логОшибка( подробноеОписаниеОшибки );
		
	КонецПопытки;
	
КонецПроцедуры


Процедура ВыгрузитьАктуальныйCF( Знач Хранилище, Знач пТекущаяВыгружаемаяВерсия ) Экспорт
	
	началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЛогОтладка( "---Выгрузка актуального cf " + Хранилище + "---" );
	
	Если Хранилище.ВыгруженАктуальныйCF Тогда
		ЛогОтладка( "+++Актуальный cf " + Хранилище + " уже выгружен+++" );
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено( Хранилище.ПутьКАктуальномуCF ) Тогда
		ЛогОтладка( "+++Путь к актуальному cf " + Хранилище + " не указан. Выгрузка отменена+++" );
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоПоследняяНевыгруженнаяВерсия(пТекущаяВыгружаемаяВерсия) Тогда
		ЛогОтладка( "+++Есть невыгруженные версии " + Хранилище + ". Выгрузка отменена+++" );
		Возврат;
	КонецЕсли;
	
	ПакетныйРежим.ВыгрузитьКонфигурациюВCF(Хранилище,
	Хранилище.Приложение1С,
	Хранилище.ТранзитнаяБазаАдрес,
	Хранилище.ТранзитнаяБазаПользователь,
	Хранилище.ТранзитнаяБазаПароль,
	Хранилище.ПутьКАктуальномуCF);
	
	об = Хранилище.ПолучитьОбъект();
	об.ВыгруженАктуальныйCF = Истина;
	об.Записать();
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() - началоВыгрузки;
	ЛогИнформация( "+++Выгружен актуальный cf. " + затрачено + "мс  +++");
	
КонецПроцедуры

Процедура РаспаковатьОбычныеФормы(Знач каталогКонфигурации, Знач Хранилище)
	
	файлРаспаковщика = Константы.ПрограммаРаспаковки.Получить();
	
	Если Не (Хранилище.РаспаковыватьОбычныеФормы
		И ЗначениеЗаполнено( файлРаспаковщика )) Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ФайлСуществует( файлРаспаковщика ) Тогда
		ВызватьИсключение "Файл распаковщика не найден по пути " + файлРаспаковщика;
	КонецЕсли;
	
	началоВыгрузки = ТекущаяУниверсальнаяДатаВМиллисекундах();
	ЛогОтладка( "		Начало распаковки обычных форм." );
	
	формыКРаспаковке = НайтиФайлы( каталогКонфигурации, "form.bin", Истина );
	
	ЛогОтладка( "		Форм к распаковке: " + формыКРаспаковке.Количество() );
	
	ц = 0;
	
	Для каждого цФайл Из формыКРаспаковке Цикл
		
		ц = ц + 1;
		
		каталогРаспаковки = СтрЗаменить( цФайл.ПолноеИмя, "\Ext\Form.bin", "" );
		СтрокаЗапуска = """" + файлРаспаковщика + """ -parse """ + цФайл.ПолноеИмя + """ """ + каталогРаспаковки + """";
		
		ВыполнитьКоманду( каталогКонфигурации, СтрокаЗапуска,, Истина );
		
		Попытка
			УдалитьФайлы( каталогРаспаковки + "\Form" );
		Исключение
		КонецПопытки;
		
		Попытка
			ПереместитьФайл( каталогРаспаковки + "\module", каталогРаспаковки + "\module.bsl" );
		Исключение
		КонецПопытки;
		
		Попытка
			УдалитьФайлы( цФайл.ПолноеИмя );
		Исключение
		КонецПопытки;
		
		Если ц%100 = 0 Тогда
			ЛогОтладка( "		Распаковано форм: " +ц );
		КонецЕсли;
		
	КонецЦикла;
	
	затрачено = ТекущаяУниверсальнаяДатаВМиллисекундах() - началоВыгрузки;
	ЛогОтладка( "		Завершена распаковка обычных форм. " + затрачено + "мс" );
	
КонецПроцедуры

#КонецОбласти

#Область Команды1С

Процедура ЗагрузитьПользователейХранилища(Хранилище) Экспорт
	
	ТаблицаВерсий = ПакетныйРежим.ПолучитьТаблицуВерсийХранилища(Хранилище,
																Хранилище.Приложение1С,
																Хранилище.ТранзитнаяБазаАдрес,
																Хранилище.ТранзитнаяБазаПользователь,
																Хранилище.ТранзитнаяБазаПароль,
																Хранилище.ХранилищеАдрес,
																Хранилище.ХранилищеПользователь,
																Хранилище.ХранилищеПароль);
												
	ТаблицаВерсий.Свернуть("ИмяПользователя");
	
	Для Каждого ТекущаяСтрока Из ТаблицаВерсий Цикл
		НайденныйПользователь = Справочники.ПользователиХранилища.НайтиПоНаименованию(ТекущаяСтрока.ИмяПользователя, Истина,, Хранилище);
		Если Не ЗначениеЗаполнено(НайденныйПользователь) Тогда
			НовыйПользователь = Справочники.ПользователиХранилища.СоздатьЭлемент();
			НовыйПользователь.Владелец = Хранилище;
			НовыйПользователь.Наименование = ТекущаяСтрока.ИмяПользователя;
			НовыйПользователь.Записать();
		КонецЕсли;
	КонецЦикла;												
	
КонецПроцедуры

#КонецОбласти

#Область КомандыГит

Процедура ВыгрузитьВерсииВУдаленныйРепозиторий(Хранилище) Экспорт
	
	Если Хранилище.ВыгружатьВУдаленныйРепозиторий Тогда	
		Сообщить( "" + ТекущаяДата() + "  --Начало выгрузки в удаленный репозиторий " + Хранилище + "--" );
		Git.Push(Хранилище.ЛокальныйРепозиторийАдрес);			
		Сообщить( "" + ТекущаяДата() + "  ++Конец выгрузки в удаленный репозиторий " + Хранилище + "++" );
	КонецЕсли; 		
	
КонецПроцедуры

Процедура ИнициироватьЛокальныйРепозиторий(Хранилище) Экспорт
	
	ОбеспечитьКаталог( Хранилище.ЛокальныйРепозиторийАдрес );
	
	Git.ИнициироватьЛокальныйРепозиторий(Хранилище.ЛокальныйРепозиторийАдрес);
	СоздатьКаталог(ПолучитьКаталогКонфигурации(Хранилище));
	
	Если Хранилище.ВыгружатьВУдаленныйРепозиторий Тогда
		Git.ДобавитьУдаленныйРепозиторий(Хранилище.ЛокальныйРепозиторийАдрес, Хранилище.УдаленныйРепозиторийАдрес);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область Каталог

Функция ПолучитьКаталогКонфигурации(Знач Хранилище) Экспорт
	
	каталогКонфигурации = ЗавершитьРазделителемПутьДоКаталога(Хранилище.ЛокальныйРепозиторийАдрес) + ОтносительныйПутьККаталогуИсходныхКодов( Хранилище );
	
	ОбеспечитьКаталог( каталогКонфигурации );
	
	каталог = Новый Файл(каталогКонфигурации); // Для обрезания всяких /../ и /./
	каталогРепозитория = Новый Файл( Хранилище.ЛокальныйРепозиторийАдрес );
	
	Если каталог.ПолноеИмя = каталогРепозитория.ПолноеИмя Тогда
		ВызватьИсключение НСтр( "ru='Каталог репозитория и каталог исходных кодов не могут совпадать. Это приведет к уничтожению папки .git'" );
	КонецЕсли;
	
	Возврат ЗавершитьРазделителемПутьДоКаталога(каталог.ПолноеИмя);
	
КонецФункции

Функция ОтносительныйПутьККаталогуИсходныхКодов(Знач Хранилище) Экспорт
	
	адресИсходников = Хранилище.КаталогСИсходнымКодом;
	
	Если Не ЗначениеЗаполнено( адресИсходников ) Тогда
		адресИсходников = ПолучитьИмяКаталогаКонфигурации();
	КонецЕсли;
	
	Возврат ЗавершитьРазделителемПутьДоКаталога( адресИсходников );
	
КонецФункции // ОтносительныйПутьККаталогуИсходныхКодов()


Процедура УдалитьВсеФайлыВКаталоге(Знач Каталог) Экспорт
		
	Каталог = ЗавершитьРазделителемПутьДоКаталога(Каталог);
	УдалитьФайлы(Каталог, "*");
	
КонецПроцедуры

Функция ЗавершитьРазделителемПутьДоКаталога(Знач Каталог)
	
	РазделительПути = ПолучитьРазделительПути();	
	Если Прав(Каталог, 1) <> РазделительПути Тогда
		Каталог = Каталог + РазделительПути;
	КонецЕсли;
	Возврат Каталог;	
	
КонецФункции

#КонецОбласти

#Область ВолшебныеКонстанты

Функция ПолучитьИмяКаталогаКонфигурации() Экспорт
	
	Возврат "src";
	
КонецФункции

Функция ИмяФайлаИзменений(Знач Хранилище) Экспорт

	каталог = ПолучитьКаталогКонфигурации( Хранилище );
	
	Возврат ЗавершитьРазделителемПутьДоКаталога(Каталог) + "Changes.1c";

КонецФункции

#КонецОбласти