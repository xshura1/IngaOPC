// Биты StateCpu

#define StreamCold       0x0001 //Есть проток Н301
#define StreamConden     0x0002 //Есть проток Н201
#define AvFan            0x0004 //Авария вентиляторов
#define FanOn            0x0008 //Вентиляторы включены
#define APrOnCpu         0x0010 //Автоматы включены
#define SPumpOn          0x0020 //Насосы включены
#define AvStopCpu        0x0040 //Нажата аварийный стоп
#define DConden          0x0080 //Давление на насосе Н201 в норме
#define DCold            0x0100 //Давление на насосе Н301 в норме
#define PhErrCpu         0x0200 //Ошибка фазы
#define CpuAdcError      0x0400 //Неисправны датчики АЦП
#define SystemColdOn     0x0800// Включена система охлаждени
#define CompAllEn        0x1000 //Включение компрессоров разрешено
#define CompAllHan       0x2000 //Все компрессоры в ручном
#define CompAllOff       0x4000 //Все компрессоры выключены
#define NoPower          0x8000 //Мала мощность компрессоров

//Биты AdStateCpu
#define HandlEeprom       0x0001// Управление Eeprom





// Биты ResAvCpu

#define rNoStreamCold     0x0001 //Нет проток Н301
#define rNoStreamConden   0x0002 //Нет протока Н201
#define rAvFan            0x0004 //Авария вентиляторов
#define BigIcold          0x0008 //Перегрузка тока испарительного насоса
#define rAPrOffCpu        0x0010 //Автоматы выключены
#define BigIconden        0x0020 //Перегрузка тока конденсаторного насоса
#define rAvStopCpu        0x0040 //Нажата аварийный стоп
#define rNoDConden        0x0080 //Пропало давление Н201
#define rNoDCold          0x0100 //Пропало давление Н301
#define rPhErrCpu         0x0200 //Ошибка фазы
#define rBadReg           0x0400 //Работа компрессора при выключенных насосах



// Биты ErrorCpuI

#define NoHandlComp1      0x0001//Потеряно управление компрессором 1;
#define NoHandlComp2      0x0002//Потеряно управление компрессором 2;
#define NoHandlComp3      0x0004//Потеряно управление компрессором 3;
#define NoHandlPump       0x0008//Потеряно управление насосами Н201, Н301;
#define NoPowerComp1      0x0010//Контроллер компрессора 1 не подключен к сети
#define NoPowerComp2      0x0020//Контроллер компрессора 2 не подключен к сети
#define NoPowerComp3      0x0040//Контроллер компрессора 3 не подключен к сети
#define NoConnectComp1    0x0080//Нет связи с компрессором 1
#define NoConnectComp2    0x0100//Нет связи с компрессором 2
#define NoConnectComp3    0x0200//Нет связи с компрессором 3
#define NoConnectBoard    0x0400//Нет связи с центральным  пультом jоператора (ЦПО)




// Биты StateComp

#define SCompWork         0x0001//Компрессор включен
#define SOilWork          0x0002//Маслонасос включен
#define Zclose            0x0004//Идет закрытие золотника(читать через ТУ)
#define Zopen             0x0008//Идет открытие золотника(читать через ТУ)
#define APrOnComp         0x0010//Автоматы включены
#define SZopen            0x0020//Золотник полностью открыт
#define AvStopComp        0x0040//Нажата (экстренный) стоп (или через меню)
#define StreamOil         0x0080//Есть проток этиленгликоля через маслоохладитель
#define Doil              0x0100//Перепад давления масла в коллекторе масла - в маслоотделителе в норме
#define PhErrComp         0x0200//Ошибка фазы
#define SZclose           0x0400//Золотник полностью закрыт
#define LimitI            0x0800//Достигнут режим ограничения тока
#define CompAggrEn        0x1000//Компрессорный агрегат разрешен
//#define MastCompAggrEn    0x2000//Агрегат разрешен Центральным контроллером
//#define LimitIEn          0x4000//Разрешен режим ограничения тока

// Биты AdStateComp

#define ModeHand            0x0001//Режим ручной
#define HalfAutomat         0x0002//Режим полу автомат
#define ModeAutomat         0x0004//Режим автомат
#define LimitTimeMin        0x0008//Предельное время работы с минимальной производительностью
#define LimitTimeMax        0x0010//Предельное время работы с максимальной производительностью
#define SelfWork            0x0020//Автономный режим
#define AdcError            0x0040//Неисправны датчики АЦП


#define AvStopCompAnswer    0x0080//Ответ, что аварийный стоп принят
#define PlanStopComAnswer   0x0100//Ответ, что плановый стоп принят
#define CompOnAnswer        0x0200//Ответ, что включение компрессора принято
// Биты ResAvComp

#define NoDOil                0x0001// Нет перепада давления масла в коллекторе масла - в маслоотделителе
#define NoStreamOil           0x0002// Нет протока этиленгликоля через маслоохладитель
#define rPhErrComp            0x0004//Ошибка фазы
#define rAvStopComp           0x0008//Нажата аварийный стоп
#define BadRegComp            0x0010//Работа компрессора при выключенном маслонасосе
#define NoPin                 0x0020//Давление всасывания ниже нормы
#define BigPout               0x0040//Давление нагнетания выше нормы
#define BigToil               0x0080//Перегрев масла
#define NoToil                0x0100//Холодное масло
#define BigTout               0x0200//Температура нагнетания выше нормы
#define BigIcomp              0x0400//Перегрузка тока компрессора
#define AvAdc                 0x0800//Авария АЦП
#define CountValveMinError    0x1000//Не открывается золотник
#define CountValveMaxError    0x2000//Не закрывается золотник
#define OilError              0x4000//Не включается маслонасос  
#define CompError             0x8000//Не включается компрессор

// Биты ComComprIn

#define SetModeHand         0x0001//Перейти на ручной режим
#define SetHalfAutomat      0x0002//Перейти на режим полу автомат
#define SetModeAutomat      0x0004//Перейти на режим автомат
#define OilOff              0x0008//Маслонасос выключить
#define CompOn              0x0010//Компрессор включить
#define OilOn               0x0020//Маслонасос включить
#define OpenValve           0x0040//Открывать золотник
#define CloseValve          0x0080//Закрывать золотник
#define PlanStopCom         0x0100//Компрессор выключить планово (приоритет 2)
#define AvStopCom           0x0200//Компрессор выключить аварийно (приоритет 1)
//#define SetLimitI           0x0400//Включить режим ограничения тока
#define SystemStart         0x0800//Включить систему охлаждения
#define StopValve           0x1000//Стоп золотник
#define IdComp1             0x2000//Компрессор 1
#define IdComp2             0x4000//Компрессор 2
#define IdComp3             0x8000//Компрессор 3

// Биты AdComComprIn (дополнительного регистра команд)

//#define DoMastCompAggrDis     0x0001//Запретить агрегат
//#define DoMastCompAggrEn      0x0002//Разрещить агрегат
#define DoSelfWork            0x0004//Работать автономно
#define ExitSelfWork          0x0008//Выйти из автономного режима
#define SystemStop            0x0010//Выключить систему охлаждения
#define FlowOn                0x0020//Включить прокачку
#define FlowOff               0x0040//Выключить прокачку
#define DoFanOn               0x0080//Включить вентиляторы
#define DoFanOff              0x0100//Выключить вентиляторы
//#define ResLimitI             0x0200//Выключить режим ограничения тока
#define PowerIncrease         0x0400//Увеличить мощность компрессора
#define ResetAvFlags          0x0800//Сбросить аварийные флаги
#define NewUstav              0x1000//Новая уставка
#define IdComp1               0x2000//Компрессор 1
#define IdComp2               0x4000//Компрессор 2
#define IdComp3               0x8000//Компрессор 3

// Биты регистра MessageComp

#define mPoutErr               0x0001//Неисправен датчик давления нагнетания
#define mPinErr                0x0002//Неисправен датчик давления всасывания
#define mPoilErr               0x0004//Неисправен датчик давления масла 
#define mToutErr               0x0008//Неисправен датчик температуры нагнетания 
#define mTinErr                0x0010//Неисправен датчик температуры всасывания 
#define mToilErr               0x0020//Неисправен датчик температуры масла 
#define mDoilErr               0x0040//Обрыв датчика перепада давления
#define mPhErrCmp              0x0080//Ошибка фазы
#define mAPrOnErrCmp           0x0100//Автоматы выключены
#define mAvStopErrCmp          0x0200//Нажата аварийный стоп
#define mValveErr              0x0400//Для управления золотниками включи маслонасос
#define mOilErr                0x0800//Сначала выключи маслонасос и проверни компрессор вручную
#define mStreamOilErr          0x1000//Нет протока этиленгликоля через маслоохладитель
#define mOilOffErr             0x2000// Рано выключать маслонасос 
#define mOK                    0x8000//Команда выполнена 

// Биты регистра SensorComp


#define sPoutErr               0x0001//Неисправен датчик давления нагнетания
#define sPinErr                0x0002//Неисправен датчик давления всасывания
#define sPoilErr               0x0004//Неисправен датчик давления масла 
#define sToutErr               0x0008//Неисправен датчик температуры нагнетания 
#define sTinErr                0x0010//Неисправен датчик температуры всасывания 
#define sToilErr               0x0020//Неисправен датчик температуры масла 
#define sDoilErr               0x0040//Обрыв датчика перепада давления






// Определения для регистра отладки Debug  (nDebug = 512 = 0x0200)

#define ModeLimitMin  1// По умолчанию 1

//0 - Автомат выключается в момент достижения LimitTimeMin,
// сразу после передачи управления правому компрессору.

//1 - Автомат выключается в момент достижения LimitTimeMin, 
// после передачи управления правому компрессору, уже 
// также достигшему LimitTimeMin.

#define ModePumpOff   2// По умолчанию 0

//0 - Выключение насосов в последнюю очередь, т.е. после выключения
// всех маслонасосов.
//1 - Выключение насосов в первую очередь, т.е. сразу
//после получения команды SystemStop.

#define AllAutomatEn  4 // По умолчанию 1
//0 - В системе только один автомат.
//1 - Разрешен режим, когда все доступные компрессоры автоматы.

#define ValveWithComp 8// По умолчанию 1
//0 - При плановом выключении разгрузка золотников
//производится при выключенных компрессорах 
//1 - При плановом выключении разгрузка золотников
//производится при включенных компрессорах 






/* 1. Группа регистов состояния и команд ЦК. Хранятся в ОЗУ*/


/*-----------------------------------------------------
int CpuStateRegs[8];

---------------------------------------------------------*/

// Начальный номер группы 400

#define nStateCpu         400// Состояние ЦК
#define nResAvCpu         401// Причина отключения
#define nErrorCpuI        402// Ошибки связи
#define nComSystemIn      403// Команды, получаемые для выполнения
#define nComSystemOut     404// Команды, отправляемые для выполнения
#define nAdComSystemIn    405// Дополнительные команды, получаемые для выполнения
#define nAdComSystemOut   406// Команды, отправляемые для выполнения
#define nAdStateCpu       407// Дополнительное состояние ЦК

#if defined (_ProcessComp) || defined (_ProcessCpu)

#define StateCpu        *(CpuStateRegs + (nStateCpu -400))
#define ResAvCpu        *(CpuStateRegs + (nResAvCpu - 400))
#define ErrorCpuI       *(CpuStateRegs + (nErrorCpuI - 400))
#define ComSystemIn     *(CpuStateRegs + (nComSystemIn - 400))
#define ComSystemOut    *(CpuStateRegs + (nComSystemOut - 400))
#define AdComSystemIn   *(CpuStateRegs + (nAdComSystemIn - 400))
#define AdComSystemOut  *(CpuStateRegs + (nAdComSystemOut - 400))
#define AdStateCpu      *(CpuStateRegs + (nAdStateCpu - 400))

#endif

/* 2. Группа регистов информации ЦК. Хранятся в ОЗУ */


/*-----------------------------------------------------
int CpuInfRegs[4];

---------------------------------------------------------*/

// Начальный номер группы 430

#define niTrCpu      430// Температура регулировани
#define niTetgl      431// Температура этиленгликоля на охлаждение компрессоров;
#define niIconden    432// Ток конденсаторного насоса Н201
#define niIcold      433// Ток испарительного насоса   Н301

#if defined (_ProcessComp) || defined (_ProcessCpu)

#define iTrCpu      *(CpuInfRegs + (niTrCpu - 430))
#define iTetgl      *(CpuInfRegs + (niTetgl - 430))
#define iIconden    *(CpuInfRegs + (niIconden - 430))
#define iIcold      *(CpuInfRegs + (niIcold - 430))

#endif




/* 3. Группа регистов уставок. Хранятся в EEPROM */

/*-----------------------------------------------------
__eeprom __no_init int UstRegs[26];

int tUstRegs[13];
---------------------------------------------------------*/

// Начальный номер группы 500

// Уставки для ЦК

#define nuTr         500//Температура регулирования
#define nuTetgl      501//Температура этиленгликоля на охлаждение компрессоров;
#define nuMaxIconden 502//Предельный ток конденсаторного насоса Н201
#define nuMaxIcold   503//Предельный ток испарительного насоса   Н301

// Уставки для компрессоров

#define nuPout       504//Давление нагнетания.
#define nuPin 	     505//Давление всасывани
#define nuToil       506//Температура масла
#define nuTout       507//Температура нагнетани
#define nuMaxIcomp   508//Предельный ток компрессора
#define nuLimitIcomp 509//Уровень ограничения тока компрессора
#define nuK          510//Коэффициент усиления ПИ закона
#define nuTime       511//Время интегрирования ПИ закона
#define nDebug       512// Регистр отладки//ZZZZZZZZZZZZZZZZZZZZZZ

#if defined (_ProcessComp) || defined (_ProcessCpu)

#define uTr         *(UstRegs + (nuTr - 500))
#define uTetgl      *(UstRegs + (nuTetgl - 500))
#define uMaxIconden *(UstRegs + (nuMaxIconden - 500))
#define uMaxIcold   *(UstRegs + (nuMaxIcold - 500))
#define uPout       *(UstRegs + (nuPout - 500))
#define uPin 	    *(UstRegs + (nuPin - 500))
#define uToil       *(UstRegs + (nuToil - 500))
#define uTout       *(UstRegs + (nuTout - 500))
#define uMaxIcomp   *(UstRegs + (nuMaxIcomp - 500))
#define uLimitIcomp *(UstRegs + (nuLimitIcomp - 500))
#define uK          *(UstRegs + (nuK - 500))
#define uTime       *(UstRegs + (nuTime - 500))
#define Debug       *(UstRegs + (nDebug - 500))//ZZZZZZZZZZZZZZZZZZZZZZ

// Далее в EEPROM вторая копия.

// ОЗУ для операций с уставками.


#define tuTr         *(tUstRegs + (nuTr - 500))
#define tuTetgl      *(tUstRegs + (nuTetgl - 500))
#define tuMaxIconden *(tUstRegs + (nuMaxIconden - 500))
#define tuMaxIcold   *(tUstRegs + (nuMaxIcold - 500))
#define tuPout       *(tUstRegs + (nuPout - 500))
#define tuPin 	     *(tUstRegs + (nuPin - 500))
#define tuToil       *(tUstRegs + (nuToil - 500))
#define tuTout       *(tUstRegs + (nuTout - 500))
#define tuMaxIcomp   *(tUstRegs + (nuMaxIcomp - 500))
#define tuLimitIcomp *(tUstRegs + (nuLimitIcomp - 500))
#define tuK          *(tUstRegs + (nuK - 500))
#define tuTime       *(tUstRegs + (nuTime - 500))
#define tDebug       *(tUstRegs + (nDebug - 500))//ZZZZZZZZZZZZZZZZZZZZZZ




#endif





/* 4. Группа константных регистов только для чтения. Хранятся во FLASH*/
/*-----------------------------------------------------
__flash int FlashRegs[] = {300,1000,500,900,1800,300,6000};

---------------------------------------------------------*/

// Начальный номер группы   600



// Задержка на проверку Doil и включение компрессора после включения маслонасоса = 3сек
#define   nuTimeOilStart   600

// Задержка на выключение маслонасоса после выключения компрессора 1000 = 10сек
#define   nuTimeOilStop    601

// Задержка на проверку перегрузки при включении компрессора 500 = 5сек
#define   nuBlocTimer      602

//Махимальное время с полностью открытым золотником 900 = 900 сек или 15 мин.
#define   nuTimeMaxOpen    603

//Махимальное время с полностью закрытым золотником 1800 = 1800 сек или 30 мин.
#define   nuTimeMaxClose   604

//Задержка на проверку протоков насосов Н201, Н301 = 3сек.
#define   nuTimeStream     605

//Задержка на  включение компрессора, если все они оказались выключены в режиме мин. производительности 1 мин.
#define   nuTimePause      606

// Задержка на проверку перегрузки при включении маслонасоса 300 = 3сек
#define   nuOilBlocTimer   607

#define   nuPreTimeOilStart 608

#if defined(_ProcessComp) || defined(_ProcessCpu)

#define   uTimeOilStart     *(FlashRegs+(nuTimeOilStart - 600))
#define   uTimeOilStop      *(FlashRegs+(nuTimeOilStop - 600))
#define   uBlocTimer        *(FlashRegs+(nuBlocTimer - 600))
#define   uTimeMaxOpen      *(FlashRegs+(nuTimeMaxOpen - 600))
#define   uTimeMaxClose     *(FlashRegs+(nuTimeMaxClose - 600))
#define   uTimeStream       *(FlashRegs+(nuTimeStream - 600))
#define   uTimePause        *(FlashRegs+(nuTimePause - 600))
#define   uOilBlocTimer     *(FlashRegs+(nuOilBlocTimer - 600))
#define   uPreTimeOilStart  *(FlashRegs+(nuPreTimeOilStart - 600))
#endif




/* 5. Группа регистов состояния и команд компрессора. Хранятся в ОЗУ*/

/*-----------------------------------------------------
int CompStateRegs[10];
int AllCompStateRegs[3][10];
---------------------------------------------------------*/

// Начальный номер группы 100, 200, 300 (комп.1, комп.2, комп.3)


// Абсолютные номера


#define nStateComp1        100
#define nAdStateComp1      101
#define nResAvComp1        102
#define nComComprIn1       103
#define nComComprOut1      104
#define nAdComComprIn1     105
#define nAdComComprOut1    106
#define nCountValve1       107
#define nSensorComp1       108 
#define nMessageComp1      109



#define nStateComp2        200
#define nAdStateComp2      201
#define nResAvComp2        202
#define nComComprIn2       203
#define nComComprOut2      204
#define nAdComComprIn2     205
#define nAdComComprOut2    206
#define nCountValve2       207
#define nSensorComp2       208 
#define nMessageComp2      209


#define nStateComp3        300
#define nAdStateComp3      301
#define nResAvComp3        302
#define nComComprIn3       303
#define nComComprOut3      304
#define nAdComComprIn3     305
#define nAdComComprOut3    306
#define nCountValve3       307
#define nSensorComp3       308 
#define nMessageComp3      309

#if defined(_ProcessComp) || defined(_ProcessCpu)

// Относительные номера

#define nStateComp        0
#define nAdStateComp      1
#define nResAvComp        2
#define nComComprIn       3
#define nComComprOut      4
#define nAdComComprIn     5
#define nAdComComprOut    6
#define nCountValve       7
#define nSensorComp       8
#define nMessageComp      9
#endif

#ifdef _ProcessComp

#define StateComp     *(CompStateRegs + nStateComp)
#define AdStateComp   *(CompStateRegs + nAdStateComp)
#define ResAvComp     *(CompStateRegs + nResAvComp)
#define ComComprIn    *(CompStateRegs + nComComprIn)
#define ComComprOut   *(CompStateRegs + nComComprOut)
#define AdComComprIn  *(CompStateRegs + nAdComComprIn)
#define AdComComprOut *(CompStateRegs + nAdComComprOut)
#define CountValve    *(CompStateRegs + nCountValve)
#define SensorComp    *(CompStateRegs + nSensorComp)
#define MessageComp   *(CompStateRegs + nMessageComp)

#endif

#ifdef _ProcessCpu



#define StateComp(r)        AllCompStateRegs[r] [nStateComp]
#define AdStateComp(r)      AllCompStateRegs[r] [nAdStateComp]
#define ResAvComp(r)        AllCompStateRegs[r] [nResAvComp]
#define ComComprIn(r)       AllCompStateRegs[r] [nComComprIn]
#define ComComprOut(r)      AllCompStateRegs[r] [nComComprOut]
#define AdComComprIn(r)     AllCompStateRegs[r] [nAdComComprIn]
#define AdComComprOut(r)    AllCompStateRegs[r] [nAdComComprOut]
#define CountValve(r)       AllCompStateRegs[r] [nCountValve]
#define SensorComp(r)       AllCompStateRegs[r] [nSensorComp]
#define MessageComp(r)      AllCompStateRegs[r] [nMessageComp]

#endif






/* 6. Группа регистов информации компрессора. Хранится в ОЗУ */

/*-----------------------------------------------------
int CompInfRegs[10];
int AllCompInfRegs[3][10];
---------------------------------------------------------*/

// Начальный номер группы 130, 230, 330 (комп.1, комп.2, комп.3)



// Абсолютные номера

#define niPout1      130
#define niPin1       131
#define niToil1      132
#define niTout1      133
#define niTr1        134
#define niIcomp1     135
#define niPoil1      136
#define niTin1       137
#define niMotorL1    138
#define niMotorH1    139

#define niPout2      230
#define niPin2       231
#define niToil2      232
#define niTout2      233
#define niTr2        234
#define niIcomp2     235
#define niPoil2      236
#define niTin2       237
#define niMotorL2    238
#define niMotorH2    239

#define niPout3      330
#define niPin3       331
#define niToil3      332
#define niTout3      333
#define niTr3        334
#define niIcomp3     335
#define niPoil3      336
#define niTin3       337
#define niMotorL3    338
#define niMotorH3    339




#if defined(_ProcessComp) || defined(_ProcessCpu)

// Относительные номера

#define niPout      0// Давление нагнетания
#define niPin       1// Давление всасывания
#define niToil      2// Температура масла
#define niTout      3// Температура нагнетания
#define niTr        4//	Температура регулирования
#define niIcomp     5// Ток компрессора
#define niPoil      6// Давление масла
#define niTin       7// Температура всасывания
#define niMotorL    8// Моточасы мл.
#define niMotorH    9// Моточасы ст.

#endif

#ifdef _ProcessComp

#define iPout      *(CompInfRegs + niPout)
#define iPin       *(CompInfRegs + niPin)
#define iToil      *(CompInfRegs + niToil)
#define iTout      *(CompInfRegs + niTout)
#define iTr        *(CompInfRegs + niTr)
#define iIcomp     *(CompInfRegs + niIcomp)
#define iPoil      *(CompInfRegs + niPoil)
#define iTin       *(CompInfRegs + niTin)
#define iMotorL    *(CompInfRegs + niMotorL)
#define iMotorH    *(CompInfRegs + niMotorH)
#endif


#ifdef _ProcessCpu

#define iPout(r)   AllCompInfRegs[r][niPout]
#define iPin(r)    AllCompInfRegs[r][niPin]
#define iToil(r)   AllCompInfRegs[r][niToil]
#define iTout(r)   AllCompInfRegs[r][niTout]
#define iTr(r)     AllCompInfRegs[r][niTr]
#define iIcomp(r)  AllCompInfRegs[r][niIcomp]
#define iPoil(r)   AllCompInfRegs[r][niPoil]
#define iTin(r)    AllCompInfRegs[r][niTin]
#define iMotorL(r) AllCompInfRegs[r][niMotorL]
#define iMotorH(r) AllCompInfRegs[r][niMotorH]

#endif

// Регистры реального времени.
// Эти регистры хранятся в объекте theTime класса Cds1302 (по названию микросхемы)
// и доступны только через его член функции GetRealTime, WriteRealTime.
// Для подробностей см. файл RTC_DS1302.h.
// Так как эти функции встроены в GetReg и SetReg, то для ModBus проще пользоваться
// последними. Как обычно, можно использовать функции 3 и 6.
#define SecAndMin   700// Мл. байт - сек (0-59), ст. байт - мин.(0-59)
#define HourAndMday 701// Мл. байт - часы (0-23), ст. байт - число месяца (1-31).
#define MonAndYear  702// Мл. байт - месяц (1-12), ст. байт - год (00-99).
#define Wday        703// Мл. байт - день недели (1-7), ст. байт - не используется.
