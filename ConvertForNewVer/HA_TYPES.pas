unit HA_TYPES;

interface
 uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs, Menus, GsvObjectInspectorTypes,VirtualTrees;

 const

  {биты в ClassID определяющие принадлежность конкретного объекта

               3 byte                           2 byte                          1 byte                    0 byte
     ___________________________     ___________________________     _________________________    ____________________
    |                           |   |                           |   |                         |  |                    |
   31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0
       |________|   |___________|   |___________________________|   |_________________________|  |________|  |_____|  |- если =0 то у объекта могут быть дочерние объекты
            |              |                      |                             |                     |           |- класс дочернего объекта 2 уровень
            |              |                      |                             |                     |- класс дочернего объекта 1 уровень
            |              |                      |                             |- класс родительского объекта
            |              |                      |
            |              |                      |- папка для объектов в категории (Tag,Property и т.д.)
            |              |
            |              |- тип категории в шаблоне (DA,HDA,AE и т.д. всего может быть 15 типов)
            |
            |- тип документа (конфигурация, шаблон и т.д.)
  }



   // Типы документов
   ClassTypeTemplate = $10000000;
   ClassTypeConfig   = $20000000;

   // Категории объектов
   ClassCatDA  = $1000000;
   ClassCatHDA = $2000000;
   ClassCatAE  = $3000000;

   // Папки для объектов
   ClassFolderTags     = $10000;
   ClassFolderProps    = $20000;
   ClassFolderCommands = $30000;
   ClassFolderEvents   = $40000;
   ClassFolderTimers   = $50000;

   // Классы объектов
   ClassFolder  = $100;
   ClassTag     = $201;
   ClassProp    = $301;
   ClassCommand = $401;
   ClassEvent   = $500;
   ClassTimer   = $601;
   ClassDevice  = $701;

   // Классы дочерних объектов
   ClassLinkProp = $211;


   // Классы для папок объектов типа DA
   ClassFoldersDA        = ClassTypeTemplate or ClassCatDA; //$11000000;

   ClassFolderTagsDA     = ClassFoldersDA or ClassFolderTags;    //$11010000;
   ClassFolderPropsDA    = ClassFoldersDA or ClassFolderProps;   //$11020000;
   ClassFolderCommandsDA = ClassFoldersDA or ClassFolderCommands;//$11030000;
   ClassFolderTimersDA   = ClassFoldersDA or ClassFolderTimers;  //$11050000;


   // Классы конкретных объектов для шаблонов

   ClassTagDA     = ClassFolderTagsDA     or ClassTag;      //$11010201;
   ClassFolderDA  = ClassFolderTagsDA     or ClassFolder;   //$11010100;
   ClassPropDA    = ClassFolderPropsDA    or ClassProp;     //$11010301;
   ClassCommandDA = ClassFolderCommandsDA or ClassCommand;  //$11010401;
   ClassTimerDA   = ClassFolderTimersDA   or ClassTimer;    //$11010601;
   ClassLinkPropDA =ClassFolderTagsDA     or ClassLinkProp; //$11010211;



   // Классы конкретных объектов для конфигураций

   ClassFolderConfig = ClassTypeConfig or ClassFolder;
   ClassDeviceConfig = ClassTypeConfig or ClassDevice;




  //--------------------- OLD VERSION!!!!---------------------------------------



  BranchSep='\';

  OldClassTemplate        = 10;

  OldClassFolderTags      = 20;
  OldClassFolderProps     = 25;
  OldClassFolderCommands  = 30;
  OldClassFolderEvents    = 35;
  OldClassFolderTimers    = 38;

  //reserved up 50
  OldClassFolder          = 50;


  OldClassTag      = 120;
  OldClassProp     = 125;
  OldClassCommand  = 130;
  OldClassEvent    = 135;
  OldClassSubEvent = 136;
  OldClassCatEvent = 137;
  OldClassTimer    = 138;

 // OldClassScript   = 135;
  OldClassController   = 140;
  OldClassLinkProp = 145;



  HighClassFolders=100;

 
  //--------------------- OLD VERSION!!!!---------------------------------------



  

  RegPScript='HAOBJ\d+_\d+'; //'(HAOBJ\d+_\d+_\d+)|(HAOBJ\d+_\d+)'
  FormatPScript='HAOBJ%d_%d';
  RegScript='\["[^"\]]*"\]';
  FormatScript='["%s"]';

  FormatPScriptProc='HAPROC%d';
  RegScriptProc='<.+/>';
  FormatScriptProc='<%s/>';

  // от какого окна пришло сообщение
  HAMsgListObj=1;
  HAMsgScript=2;

  // типы сообщений
  HATypeMsgError=1;
  HATypeMsgWarning=2; 
  HATypeMsgExecError=3;

 type
  TOID=type integer;
  TChangeNameEvent=procedure (OldName,NewName:string) of object;

  PDataItem2=^TDataItem2;
  TDataItem2=record
   LinkNode:PDataItem2;//pointer;
   OID:TOID;
   ClassID:TOID;
   Name:widestring;
   Props:widestring;
  end;

 TPSTypeProc=(pstp_Global,pstp_Local,pstp_Params);
 TPSTypeEvent=(pste_TagsR,pste_TagsW,pste_CommandsBW,pste_CommandsAR,pste_EventDef,pste_Device,pste_Timer);




 function DecodePSVar(PSVar:string; var ClassId,OID:integer):boolean;
implementation
  uses ActiveX;


 function DecodePSVar(PSVar:string; var ClassId,OID:integer):boolean;
 var s,sps:string;

 begin
  result:=false;
  ClassId:=0;
  OID:=0;
  if pos('HAOBJ',psvar)<>1 then exit;
  sps:=copy(psvar,6,length(psvar));
  if pos('_',sps)=0 then exit;
  s:=copy(sps,1,pos('_',sps)-1);
  classid:=strtoint(s);
  delete(sps,1,pos('_',sps));
  if pos('_',sps)=0 then
   OID:=strtoint(sps);
{  else
   begin
    s:=copy(sps,1,pos('_',sps)-1);
    oid:=strtoint(s);
    delete(sps,1,pos('_',sps));
    Dop:=strtoint(sps);
   end; }
 result:=true;

 end;



end.
