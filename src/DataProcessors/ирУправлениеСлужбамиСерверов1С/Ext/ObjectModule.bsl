﻿//ирПортативный Перем ирПортативный Экспорт;
//ирПортативный Перем ирОбщий Экспорт;
//ирПортативный Перем ирСервер Экспорт;
//ирПортативный Перем ирКэш Экспорт;
//ирПортативный Перем ирПривилегированный Экспорт;

Перем мПлатформа;

Функция ПрименитьИзменения() Экспорт
	
	Если Не ЗначениеЗаполнено(Компьютер) Тогда
		Компьютер = ИмяКомпьютера();
	КонецЕсли; 
	СлужбаWMI = ирКэш.ПолучитьCOMОбъектWMIЛкс(Компьютер);
	Если СлужбаWMI = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли; 
	Для Каждого СтрокаСлужбы Из СлужбыАгентовСерверов1С Цикл
		АктуальныеСлужбы = СлужбаWMI.ExecQuery("SELECT * 
		|FROM Win32_Service
		|WHERE NAME = '" + СтрокаСлужбы.Имя + "'");
		АктуальнаяСлужба = Неопределено;
		Для Каждого АктуальнаяСлужба Из АктуальныеСлужбы Цикл
			Прервать;
		КонецЦикла;
		Команда = "sc \\" + Компьютер;
		Порт = СтрокаСлужбы.Порт;
		Если Не ЗначениеЗаполнено(Порт) Тогда
			Порт = 1540;
		КонецЕсли; 
		НачальныйПортРабочихПроцессов = СтрокаСлужбы.НачальныйПортРабочихПроцессов;
		Если Ложь
			Или Не ЗначениеЗаполнено(НачальныйПортРабочихПроцессов)
			Или ирОбщий.СтрокиРавныЛкс("<Авто>", НачальныйПортРабочихПроцессов)
		Тогда
			НачальныйПортРабочихПроцессов = Порт + 20;
		КонецЕсли; 
		КонечныйПортРабочихПроцессов = СтрокаСлужбы.КонечныйПортРабочихПроцессов;
		Если Ложь
			Или Не ЗначениеЗаполнено(КонечныйПортРабочихПроцессов)
			Или ирОбщий.СтрокиРавныЛкс("<Авто>", КонечныйПортРабочихПроцессов)
		Тогда
			КонечныйПортРабочихПроцессов = Порт + 51;
		КонецЕсли; 
		ДиапазонПортов = XMLСтрока(НачальныйПортРабочихПроцессов) + ":" + XMLСтрока(КонечныйПортРабочихПроцессов);
		ПортКластера = XMLСтрока(Порт + 1);
		ПортАгента = XMLСтрока(Порт);
		ИмяСлужбы = СтрокаСлужбы.Имя;
		Если Ложь
			Или Не ЗначениеЗаполнено(ИмяСлужбы)
			Или ирОбщий.СтрокиРавныЛкс("<Авто>", ИмяСлужбы)
		Тогда
			ИмяСлужбы = "1C:Enterprise Server Agent " + ПортАгента;
		КонецЕсли;
		ТекстИмяСлужбы = """" + ИмяСлужбы + """";
		Если СтрокаСлужбы.Удалить Тогда
			Команда = Команда + " delete " + ТекстИмяСлужбы;
		Иначе
			ОтборВерсий = Новый Структура("Сервер, СборкаПлатформы", Истина, СтрокаСлужбы.СборкаПлатформыНовая);
			ПодходящиеВерсии = СборкиПлатформы.Выгрузить(ОтборВерсий);
			ПодходящиеВерсии.Сортировать("x64 Убыв");
			Если ПодходящиеВерсии.Количество() > 0 Тогда
				КаталогИсполняемыхФайлов = ПодходящиеВерсии[0].Каталог;
			Иначе
				КаталогИсполняемыхФайлов = СтрокаСлужбы.СборкаПлатформыНовая;
			КонецЕсли; 
			КаталогКонфигурации = СтрокаСлужбы.КаталогКонфигурации;
			Если Ложь
				Или Не ЗначениеЗаполнено(КаталогКонфигурации)
				Или ирОбщий.СтрокиРавныЛкс("<Авто>", КаталогКонфигурации)
			Тогда
				ФайлКаталогаВерсии = Новый Файл(КаталогИсполняемыхФайлов);
				КаталогКонфигурации = ФайлКаталогаВерсии.Путь + "srvinfo" + XMLСтрока(ПортАгента);
			КонецЕсли;
			ПредставлениеСлужбы = СтрокаСлужбы.Представление;
			Если Ложь
				Или Не ЗначениеЗаполнено(ПредставлениеСлужбы)
				Или ирОбщий.СтрокиРавныЛкс("<Авто>", ПредставлениеСлужбы)
			Тогда
				ПредставлениеСлужбы = "1C:Enterprise Server Agent " + ПортАгента;
			КонецЕсли;
			ПредставлениеСлужбы = """" + ПредставлениеСлужбы + """";
			//СтрокаЗапускаСлужбы = БазовыйКаталог + "\" + СборкаПлатформы + "\bin\ragent.exe -srvc -agent -regport " + ПортКластера + " -port " + ПортАгента + " -range "
			СтрокаЗапускаСлужбы = "\""" + КаталогИсполняемыхФайлов + "bin\ragent.exe\"" -srvc -agent -regport " + ПортКластера + " -port " 
				+ ПортАгента + " -range " + ДиапазонПортов + " -d \""" + КаталогКонфигурации + "\""";
			Если СтрокаСлужбы.РежимОтладки = "tcp" Тогда
				СтрокаЗапускаСлужбы = СтрокаЗапускаСлужбы + " -debug";
			ИначеЕсли СтрокаСлужбы.РежимОтладки = "http" Тогда
				СтрокаЗапускаСлужбы = СтрокаЗапускаСлужбы + " -debug -http";
				Если ЗначениеЗаполнено(СтрокаСлужбы.СерверОтладкиАдрес) Тогда
					СтрокаЗапускаСлужбы = СтрокаЗапускаСлужбы + " -debugServerAddr " + СтрокаСлужбы.СерверОтладкиАдрес;
				КонецЕсли; 
				Если ЗначениеЗаполнено(СтрокаСлужбы.СерверОтладкиПорт) Тогда
					СтрокаЗапускаСлужбы = СтрокаЗапускаСлужбы + " -debugServerPort " + XMLСтрока(СтрокаСлужбы.СерверОтладкиПорт);
				КонецЕсли; 
				Если ЗначениеЗаполнено(СтрокаСлужбы.СерверОтладкиПароль) Тогда
					СтрокаЗапускаСлужбы = СтрокаЗапускаСлужбы + " -debugServerPwd " + СтрокаСлужбы.СерверОтладкиПароль;
				КонецЕсли; 
			КонецЕсли;
			СоздатьКаталог(КаталогКонфигурации);
			//Если УдалитьСуществующуюПоИмени Тогда
			//	Команда = "sc delete " + ТекстИмяСлужбы;
			//	Результат = ирОбщий.ПолучитьТекстРезультатаКомандыОСЛкс(Команда);
			//	Сообщить(Результат);
			//КонецЕсли;
			Если АктуальнаяСлужба = Неопределено Тогда
				ТипОперации = "create";
			Иначе
				ТипОперации = "config";
			КонецЕсли; 
			Если СтрокаСлужбы.Автозапуск Тогда
				РежимЗапускаСлужбы = "auto";
			Иначе
				РежимЗапускаСлужбы = "demand";
			КонецЕсли; 
			Команда = Команда + " " + ТипОперации + " " + ТекстИмяСлужбы + " binPath= """ + СтрокаЗапускаСлужбы + """ start= " + РежимЗапускаСлужбы + " displayname= " + ТекстИмяСлужбы 
				+ " depend= Dnscache/Tcpip/lanmanworkstation/lanmanserver displayname= " + ПредставлениеСлужбы;
			Если ЗначениеЗаполнено(СтрокаСлужбы.ПарольПользователя) Тогда
				Команда = Команда + " obj= " + СтрокаСлужбы.ИмяПользователя + " password= " + СтрокаСлужбы.ПарольПользователя;
			КонецЕсли; 
		КонецЕсли; 
		Результат = ирОбщий.ПолучитьТекстРезультатаКомандыОСЛкс(Команда,,, Истина);
		Если Не ЗначениеЗаполнено(Результат) Тогда
			Результат = "Не удалось получить результат обработки службы агента";
		КонецЕсли;
		Сообщить(Результат);
		//Если ЗапуститьСразу Тогда
		//	Команда = "net start " + ТекстИмяСлужбы;
		//	Результат = ирОбщий.ПолучитьТекстРезультатаКомандыОСЛкс(Команда);
		//	Сообщить(Результат);
		//КонецЕсли; 
	КонецЦикла;
	Результат = Истина;
	Возврат Результат;
		
КонецФункции

Процедура Заполнить() Экспорт 

	ирОбщий.ЗаполнитьДоступныеСборкиПлатформыЛкс(СборкиПлатформы, Компьютер);
	ПортПоУмолчанию = 1540;
	СлужбыАгентовСерверов1С.Очистить();
	СлужбаWMI = ирКэш.ПолучитьCOMОбъектWMIЛкс(Компьютер);
	Если СлужбаWMI = Неопределено Тогда
		Возврат;
	КонецЕсли; 
	АктуальныеСлужбы = СлужбаWMI.ExecQuery("SELECT 
		|* 
		|FROM Win32_Service
		|WHERE PathName LIKE '%ragent.exe%'
		|AND PathName LIKE '%-srvc -agent%'");
	Для Каждого АктуальнаяСлужба Из АктуальныеСлужбы Цикл
		СтрокаЗапускаСлужбы = АктуальнаяСлужба.PathName;
		СтрокаСлужбыАгента = СлужбыАгентовСерверов1С.Добавить();
		СтрокаСлужбыАгента.Имя = АктуальнаяСлужба.Name;
		СтрокаСлужбыАгента.СтрокаЗапускаНовая = СтрокаЗапускаСлужбы;
		СтрокаЗапускаСлужбы = СтрЗаменить(СтрокаЗапускаСлужбы + " ", " /", " -");
		Если ЗначениеЗаполнено(АктуальнаяСлужба.ProcessId) Тогда
			АктивныйПроцесс = ирОбщий.ПолучитьПроцессОСЛкс(АктуальнаяСлужба.ProcessId);
			Если ТипЗнч(АктивныйПроцесс) <> Тип("Строка") Тогда
				СтрокаСлужбыАгента.СтрокаЗапускаАктивная = АктивныйПроцесс.CommandLine;
				СтрокаСлужбыАгента.ПараметрыИзменены = Не ирОбщий.СтрокиРавныЛкс(СтрокаСлужбыАгента.СтрокаЗапускаАктивная, СтрокаСлужбыАгента.СтрокаЗапускаНовая);
			КонецЕсли; 
		КонецЕсли; 
		СтрокаСлужбыАгента.Представление = АктуальнаяСлужба.Caption;
		СтрокаСлужбыАгента.ИмяПользователя = АктуальнаяСлужба.StartName;
		СтрокаСлужбыАгента.ИдентификаторПроцесса = АктуальнаяСлужба.ProcessId;
		СтрокаСлужбыАгента.Порт = Число(ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(НРег(СтрокаЗапускаСлужбы), "-port ", " ", Ложь));
		СтрокаДиапазона = ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(НРег(СтрокаЗапускаСлужбы), "-range ", " ", Ложь);
		Если ЗначениеЗаполнено(СтрокаДиапазона) Тогда
			ФрагментыДиапазона = ирОбщий.ПолучитьМассивИзСтрокиСРазделителемЛкс(СтрокаДиапазона, ":");
			СтрокаСлужбыАгента.НачальныйПортРабочихПроцессов = Число(ФрагментыДиапазона[0]);
			СтрокаСлужбыАгента.КонечныйПортРабочихПроцессов = Число(ФрагментыДиапазона[1]);
		КонецЕсли; 
		СтрокаСлужбыАгента.Выполняется = ирОбщий.СтрокиРавныЛкс(АктуальнаяСлужба.State, "Running");
		СтрокаСлужбыАгента.Автозапуск = ирОбщий.СтрокиРавныЛкс(АктуальнаяСлужба.StartMode, "Auto");
		СтрокаСлужбыАгента.КаталогКонфигурации = ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(СтрокаЗапускаСлужбы, "-d """, """"); // Регистрозависимость маркера не убрана!
		Если ЗначениеЗаполнено(СтрокаСлужбыАгента.ИдентификаторПроцесса) Тогда
			АктивныйПроцесс = ирОбщий.ПолучитьПроцессОСЛкс(АктуальнаяСлужба.ProcessId, , Компьютер);
			СтрокаЗапускаПроцесса = АктивныйПроцесс.CommandLine;
		Иначе
			АктивныйПроцесс = Неопределено;
		КонецЕсли; 
		СтрокаСлужбыАгента.СборкаПлатформыНовая = ПолучитьСборкуПлатформуИзКоманднойСтроки(СтрокаЗапускаСлужбы);
		Если АктивныйПроцесс <> Неопределено И ТипЗнч(СтрокаЗапускаПроцесса) = Тип("Строка") Тогда 
			СтрокаСлужбыАгента.СборкаПлатформыАктивная = ПолучитьСборкуПлатформуИзКоманднойСтроки(СтрокаЗапускаПроцесса);
		КонецЕсли; 
		МаркерОтладки = "-debug";
		ПозицияСтрокиТипаОтладчика = Найти(НРег(СтрокаЗапускаСлужбы), Нрег(МаркерОтладки));
		Если ЗначениеЗаполнено(ПозицияСтрокиТипаОтладчика) Тогда
			СтрокаОтладчика = СокрЛ(Сред(СтрокаЗапускаСлужбы, ПозицияСтрокиТипаОтладчика + СтрДлина(МаркерОтладки)));
			Если Найти(НРег(СтрокаОтладчика), "-http") = 1 Тогда 
				РежимОтладки = "http"; 
			Иначе
				РежимОтладки = "tcp"; 
			КонецЕсли; 
		Иначе
			РежимОтладки = "нет";
		КонецЕсли;
		СтрокаСлужбыАгента.РежимОтладки = РежимОтладки;
		СтрокаСлужбыАгента.СерверОтладкиАдрес = ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(Нрег(СтрокаЗапускаСлужбы), НРег("-debugServerAddr "), " ", Ложь);
		СтрокаСлужбыАгента.СерверОтладкиПорт = ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(Нрег(СтрокаЗапускаСлужбы), НРег("-debugServerPort "), " ", Ложь);
		СтрокаСлужбыАгента.СерверОтладкиПароль = ирОбщий.ПолучитьСтрокуМеждуМаркерамиЛкс(Нрег(СтрокаЗапускаСлужбы), НРег("-debugServerPwd "), " ", Ложь);
	КонецЦикла; 
	СлужбыАгентовСерверов1С.Сортировать("Имя");

КонецПроцедуры // Заполнить()

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Отказ = Ложь;
	МассивИсключений = Новый Массив;
	МассивИсключений.Добавить("");
	МассивИсключений.Добавить("<Авто>");
	Отказ = Отказ Или Не ирОбщий.ПроверитьУникальностьСтрокТЧПоКолонкеЛкс(ЭтотОбъект, "СлужбыАгентовСерверов1С", "Имя",,, МассивИсключений);
	Отказ = Отказ Или Не ирОбщий.ПроверитьУникальностьСтрокТЧПоКолонкеЛкс(ЭтотОбъект, "СлужбыАгентовСерверов1С", "Представление",,, МассивИсключений);
	Отказ = Отказ Или Не ирОбщий.ПроверитьУникальностьСтрокТЧПоКолонкеЛкс(ЭтотОбъект, "СлужбыАгентовСерверов1С", "Порт", , Новый Структура("Автозапуск", Истина));
	//Отказ = Отказ Или Не ирОбщий.ПроверитьУникальностьСтрокТЧПоКолонкеИис(ЭтотОбъект, "СлужбыАгентовСерверов1С", "КаталогКонфигурации", , Новый Структура("Автозапуск", Истина));
	Для Индекс = 0 По СлужбыАгентовСерверов1С.Количество() - 1 Цикл
		СтрокаСлужбы = СлужбыАгентовСерверов1С[Индекс];
		Если Не СтрокаСлужбы.Удалить Тогда
			МассивПутейКДанным = Новый Соответствие;
			//МассивПутейКДанным.Вставить("СлужбыАгентовСерверов1С[" + Индекс + "].КаталогКонфигурации");
			МассивПутейКДанным.Вставить("СлужбыАгентовСерверов1С[" + Индекс + "].СборкаПлатформыНовая");
			МассивПутейКДанным.Вставить("СлужбыАгентовСерверов1С[" + Индекс + "].Порт");
			ирОбщий.ПроверитьЗаполнениеРеквизитовОбъектаЛкс(ЭтотОбъект, МассивПутейКДанным, Отказ);
		КонецЕсли; 
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьWMIОбъектСлужбы(ИмяСлужбы, Компьютер = Неопределено, ВызыватьИсключениеЕслиНеНайдена = Истина) Экспорт 
	
	СлужбаWMI = ирКэш.ПолучитьCOMОбъектWMIЛкс(Компьютер);
	Если СлужбаWMI = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли; 
	ТекстЗапросаWQL = "Select * from Win32_Service Where Name = '" + ИмяСлужбы + "'";
	ВыборкаСистемныхСлужб = СлужбаWMI.ExecQuery(ТекстЗапросаWQL);
	Для Каждого лСистемнаяСлужба Из ВыборкаСистемныхСлужб Цикл
		СистемнаяСлужба = лСистемнаяСлужба;
	КонецЦикла;
	Если СистемнаяСлужба = Неопределено Тогда 
		СистемнаяСлужба = "Системная служба с именем """ + ИмяСлужбы + """ не найдена на компьютере """ + Компьютер + """" ; // Сигнатура (начало строки) используется в Обработка.ПоддержаниеСервераПриложенийИис
		Если ВызыватьИсключениеЕслиНеНайдена Тогда
			ВызватьИсключение СистемнаяСлужба;
		КонецЕсли; 
	КонецЕсли;
	Возврат СистемнаяСлужба;

КонецФункции

Функция ПолучитьСборкуПлатформуИзКоманднойСтроки(Строка)
	
	#Если Сервер И Не Сервер Тогда
	    мПлатформа = Обработки.ирПлатформа.Создать();
	#КонецЕсли
	Результат = "";
	ВычислительРегулярок = мПлатформа.RegExp;
	ВычислительРегулярок.Pattern = "\\(\d+\.\d+\.\d+\.\d+)\\";
	Вхождения = ВычислительРегулярок.Execute(Строка);
	Если Вхождения.Count > 0 Тогда
		Результат = Вхождения.Item(0).Submatches(0);
	Иначе
		ВычислительРегулярок = мПлатформа.RegExp;
		ВычислительРегулярок.Pattern = """(.+\\)bin\\ragent.exe""";
		Вхождения = ВычислительРегулярок.Execute(Строка);
		Если Вхождения.Count > 0 Тогда
			Результат = Вхождения.Item(0).Submatches(0);
		КонецЕсли; 
	КонецЕсли; 
	Возврат Результат;
	
КонецФункции

//ирПортативный лФайл = Новый Файл(ИспользуемоеИмяФайла);
//ирПортативный ПолноеИмяФайлаБазовогоМодуля = Лев(лФайл.Путь, СтрДлина(лФайл.Путь) - СтрДлина("Модули")) + "ирПортативный.epf";
//ирПортативный #Если Клиент Тогда
//ирПортативный 	Контейнер = Новый Структура();
//ирПортативный 	Оповестить("ирПолучитьБазовуюФорму", Контейнер);
//ирПортативный 	Если Не Контейнер.Свойство("ирПортативный", ирПортативный) Тогда
//ирПортативный 		ПолноеИмяФайлаБазовогоМодуля = ВосстановитьЗначение("ирПолноеИмяФайлаОсновногоМодуля");
//ирПортативный 		ирПортативный = ВнешниеОбработки.ПолучитьФорму(ПолноеИмяФайлаБазовогоМодуля);
//ирПортативный 	КонецЕсли; 
//ирПортативный #Иначе
//ирПортативный 	ирПортативный = ВнешниеОбработки.Создать(ПолноеИмяФайлаБазовогоМодуля, Ложь); // Это будет второй экземпляр объекта
//ирПортативный #КонецЕсли
//ирПортативный ирОбщий = ирПортативный.ПолучитьОбщийМодульЛкс("ирОбщий");
//ирПортативный ирКэш = ирПортативный.ПолучитьОбщийМодульЛкс("ирКэш");
//ирПортативный ирСервер = ирПортативный.ПолучитьОбщийМодульЛкс("ирСервер");
//ирПортативный ирПривилегированный = ирПортативный.ПолучитьОбщийМодульЛкс("ирПривилегированный");

мПлатформа = ирКэш.Получить();