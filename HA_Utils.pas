unit HA_Utils;

interface
 uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
      Dialogs,ActiveX,opcerror,strutils;
 type
  TFileTimeARRAY = array[0..65535] of TFileTime;
  PTFileTimeARRAY = ^TFileTimeARRAY;

 { THAConvertValue=packed record
   case byte of
    vt_i2  : (asvt_i2   : smallint);
    vt_i4  : (asvt_i4   : integer);
    vt_r4  : (asvt_r4   : single);
    vt_r8  : (asvt_r8   : double);
    vt_cy  : (asvt_cy   : currency);
    vt_date: (asvt_date : TDateTime);
    vt_bool: (asvt_bool : bool);
    vt_i1  : (asvt_i1   : Shortint);
    vt_ui1 : (asvt_ui1  : byte);
    vt_ui2 : (asvt_ui2  : Word);
    vt_ui4 : (asvt_ui4  : longword);
    255    :(asData:array [0..9] of byte);
   end;
  }
 THAConvertRec=record
   case byte of
    0:  (asArrayByte:array [0..7] of byte);
    1 : (asvt_i2   : smallint );
    2 : (asvt_i4   : integer  );
    3 : (asvt_r4   : single   );
    4 : (asvt_r8   : double   );
    5 : (asvt_cy   : currency );
    6 : (asvt_date : TDateTime);
    7 : (asvt_bool : bool     );
    8 : (asvt_i1   : Shortint );
    9 : (asvt_ui1  : byte     );
    10: (asvt_ui2  : Word     );
    11: (asvt_ui4  : longword );
  end;

// function GetStrFromBranchSep(Str:string; BranchSep:char; CountBranchSep:integer):string;
 function CountBranchSep(Str,BranchSep: string): integer;
 function ExtractPath(Str,BranchSep: string; CountBranchSep: integer): string;
 function GetNextLevel(Path,Str, BranchSep: string; var IsFolder:boolean): string;
 function ConvertToFileTime(DateTime: TDateTime): TFileTime;
 function ConvertToDateTime(FileTime:TFileTime):TDateTime;
 function OffSetFileTime(FT:TFileTime; MSec:integer):TFileTime;

 function GetTimeBias:longint;

 function OPCTaskMemAlloc(var Res:HResult; Size,Count:DWord):Pointer;
 function OPCTaskMemReAlloc(var Res:HResult; P:pointer; Size,Count:DWord):Pointer;

 function BitStat (B1,B2:DWord):Dword;
 function BitSet(B1:DWord;B2:DWord;B3:Byte):Dword;
 function MakeHashId(const s: string): cardinal;
 function QualityToStr(Quality:DWord; ForDebug:boolean=false):string;
 function ArrayVariantToString(V:OleVariant):string;
 function ValidVariantType(RequestedType,CanonicalType:TVarType):boolean;
 function HAConvertVariantType(var vDest:OleVariant; vSource:OleVariant; LocaleId:LCID; vType:TVarType):HResult;

 function VarTypeToStr(AVarType:word):string;
 //function StrToVarType(SType:string):word;
// procedure GetVarTypes(L:TStrings; OnlyIsNotArray:boolean);

 procedure ParsePath(APath:string; Res:TStrings);
 function NormalizePath(APath:string):string;

 function HAVariantToHexStringValue(Value:OleVariant):string;
 function HAHexStringValueToVariant(Str:string):OleVariant;
 function DeleteCommentFromScript(Scr: String): string;

implementation
  uses ha_types;
{function GetStrFromBranchSep(Str:string; BranchSep:char; CountBranchSep:integer):string;
var s:string;
    i,j:integer;
begin
 j:=0;
 s:='';
 for i:=1 to Length(Str) do
  begin
   if Str[i]=BranchSep then
    begin
     inc(j);
     if j>CountBranchSep then break;
    end
   else
    if j=CountBranchSep then
     s:=s+Str[i];

  end;
 result:=s;
end;
}

function NormalizePath(APath:string):string;
begin
 result:=APath;
 delete(result,1,2);
 delete(result,length(result)-1,2);
end;

procedure ParsePath(APath:string; Res:TStrings);
var i:integer;
    ss:string;
begin
 if APath='' then exit;
 ss:='';
 for i:=1 to Length(APath) do
  if APath[i]<>BranchSep then
   begin
    ss:=ss+APath[i];
    if i=Length(APath) then
     Res.Add(ss);
   end
  else
   begin
    res.Add(ss);
    ss:='';
   end;
end;

function VarTypeToStr(AVarType:word):string;
var s:string;
begin
 result:='';
 if (AVarType and VarArray)=VarArray then
  begin
   s:=VarTypeToStr(AVarType and VarTypeMask);
   if s<>'' then
    result:='Array of ' +s;
  // result:=UpperCase(result);
   exit;
  end;





 case AVarType and VarTypeMask of
  vt_i1:result:='ShortInt';
  vt_ui1:result:='Byte';

  vt_i2:result:='Smallint';
  vt_ui2:result:='Word';

  vt_i4:result:='Integer';
  vt_ui4:result:='LongWord';

  vt_r4:result:='Single';
  vt_r8:result:='Double';

  vt_cy:result:='Currency';

  vt_date:result:='Date';

  vt_bstr:result:='String';

  vt_bool:result:='Boolean';

 end;
// result:=UpperCase(result);
end;

{function StrToVarType(SType:string):word;
begin
 result:=0;
 if CompareText('vt_i1',SType)=0 then
  result:=vt_i1
 else
 if CompareText('vt_ui1',SType)=0 then
  result:=vt_ui1
 else
 if CompareText('vt_i2',SType)=0 then
  result:=vt_i2
 else
 if CompareText('vt_ui2',SType)=0 then
  result:=vt_ui2
 else
 if CompareText('vt_i4',SType)=0 then
  result:=vt_i4
 else
 if CompareText('vt_ui4',SType)=0 then
  result:=vt_ui4
 else
 if CompareText('vt_r4',SType)=0 then
  result:=vt_r4
 else
 if CompareText('vt_r8',SType)=0 then
  result:=vt_r8
 else
 if CompareText('vt_cy',SType)=0 then
  result:=vt_cy
 else
 if CompareText('vt_date',SType)=0 then
  result:=vt_date
 else
 if CompareText('vt_bstr',SType)=0 then
  result:=vt_bstr
 else
 if CompareText('vt_bool',SType)=0 then
  result:=vt_bool;

end; }

{procedure GetVarTypes(L:TStrings; OnlyIsNotArray:boolean);
const
 VarT:array [0..11] of word=(vt_i1,vt_ui1, vt_i2, vt_ui2, vt_i4, vt_ui4, vt_r4, vt_r8, vt_cy, vt_date, vt_bstr,vt_bool);
var i:integer;
    s:string;
begin

 for i:=0 to High(VarT) do
  begin
   s:=VarTypeToStr(VarT[i]);
   l.AddObject(s,TObject(VarT[i]));
  end;

 if not OnlyIsNotArray then
  for i:=0 to High(VarT) do
  begin
   s:=VarTypeToStr(VarT[i] or VarArray);
   l.AddObject(s,TObject(VarT[i] or VarArray));
  end;

end;
 }

function OffSetFileTime(FT:TFileTime; MSec:integer):TFileTime;
var LI,LRes:LARGE_INTEGER;
begin
 LI.LowPart:=FT.dwLowDateTime;
 LI.HighPart:=FT.dwHighDateTime;
 LRes.QuadPart:=LI.QuadPart+(mSec*1000000);
 result.dwLowDateTime:=LRes.LowPart;
 result.dwHighDateTime:=LRes.HighPart;
end;


function GetTimeBias:longint;
var zi:TTimeZoneInformation;
begin
 GetTimeZoneInformation(zi);
 result:=zi.Bias;
end;

function ValidVariantType(RequestedType,CanonicalType:TVarType):boolean;
begin
 if RequestedType<>vt_empty then
 if (((RequestedType and VarArray)=varArray) and ((CanonicalType and VarArray)<>varArray)) or
    (((RequestedType and VarArray)<>varArray) and ((CanonicalType and VarArray)=varArray)) then
     begin
      result:=false;
      exit;
     end;
{ if RequestedType=(vt_cy or varArray) then
  begin
   result:=false;
   exit;
  end;
 }
 //if ((RequestedType and VarTypeMask)<>vt_bstr) and ((CanonicalType and VarTypeMask)=vt_bstr) then
 // result:=false
 //else
  result:=boolean((RequestedType and VarTypeMask) in [vt_Empty, vt_i2..vt_r8,vt_cy,vt_date,vt_bstr,vt_bool,vt_i1..vt_ui4]);
end;


function HAConvertVariantType(var vDest:OleVariant; vSource:OleVariant; LocaleId:LCID; vType:TVarType):HResult;
var res:HResult;
    v:OleVariant;
    i:integer;

procedure CheckVar(var V1:OleVariant);
begin
 if VarType(v1)=vt_bstr then
  begin
   if v1='' then
    if vType<>vt_bstr then
     v1:=varastype(0,vt_i4);
  end;
end;

begin
 VarClear(vDest);
 if not ValidVariantType(vType,VarType(vSource)) then
  begin
   result:=DISP_E_TYPEMISMATCH;
   exit;
  end;

//  DISP_E_OVERFLOW


 if (vType and VarArray)=VarArray then
  begin
   result:=s_ok;
   vDest:=varArrayCreate([VarArrayLowBound(vSource,1),VarArrayHighBound(vSource,1)],vType and VarTypeMask);
   varClear(v);
   TVarData(v).VType:=VarType(vSource) and VarTypeMask;
   //vDest:=vSource;
   //TVarData(vDest).VType:=vType;
   for i:=VarArrayLowBound(vDest,1) to VarArrayHighBound(vDest,1) do
    begin
     v:=vSource[i];
//     checkvar(v);
    if ((VarType(v) and VarTypeMask) in [vt_i1,vt_i2,vt_i4]) and ((vType and VarTypeMask) in [vt_ui1,vt_ui2,vt_ui4]) then
     begin
      if v<0 then
       res:=OPC_E_RANGE
      else
       res:=VariantChangeTypeEx(v,v,LocaleID,0,vType and VarTypeMask);
     end
    else
      res:=VariantChangeTypeEx(v,v,LocaleID,0,vType and VarTypeMask);

     if res<>s_ok then
      result:=res
     else
      vDest[i]:=v;
    end;
   Varclear(v);
  end
 else
  begin
 //  checkvar(vSource);
   if (VarType(vSource) in [vt_i1,vt_i2,vt_i4]) and (vType in [vt_ui1,vt_ui2,vt_ui4]) then
    begin
      if vSource<0 then
       result:=OPC_E_RANGE
      else
       result:=VariantChangeTypeEx(vDest,vSource,LocaleID,0,vType);
    end
   else
    result:=VariantChangeTypeEx(vDest,vSource,LocaleID,0,vType);
  end;
end;


function MakeHashId(const s: string): cardinal;
{small hash maker}
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(s) do
    Result := ((Result shl 7) or (Result shr 25)) + Ord(s[I]);
  //result:=abs(result);
end;

function BitStat (B1,B2:DWord):Dword;
    { Пpовеpяет состояние бита    }
    { B1 - число, B2 - номеp бита }
    begin
      if (B1 and (1 shl B2) <>0) then result:=1
      else result:=0;
    end;

function BitSet(B1:DWord;B2:DWord;B3:Byte):Dword;
    { Устанавливает опpеделённый бит в 0 или 1 }
    { B1 - число, B2 - номеp бита, B3 - флаг   }
    begin
    if B3=1 then result:= B1 or ( 1 shl B2 )
     else result:= B1 and  not(1 shl B2) ;
    end;


function OPCTaskMemAlloc(var Res:HResult; Size,Count:DWord):Pointer;
begin
 result:=nil;
 res:=s_ok;
 result:=CoTaskMemAlloc(Count*Size);
 if result=nil then
  begin
   res:=E_OUTOFMEMORY;
   exit;
  end;
 FillChar(result^,Count*Size,0);
end;

function OPCTaskMemReAlloc(var Res:HResult; P:pointer; Size,Count:DWord):Pointer;
begin
 result:=nil;
 res:=s_ok;
 result:=CoTaskMemReAlloc(P,Count*Size);
 if result=nil then
  begin
   res:=E_OUTOFMEMORY;
   exit;
  end;
end;


function ConvertToFileTime(DateTime: TDateTime): TFileTime;
var
  sTime: TSystemTime;
begin
  DateTimeToSystemTime(DateTime, sTime);
  SystemTimeToFileTime(sTime, Result);
  LocalFileTimeToFileTime(Result, Result);
end;

function ConvertToDateTime(FileTime:TFileTime):TDateTime;
var
  sTime: TSystemTime;
begin
 FileTimeToSystemTime(FileTime,sTime);
 result:=SystemTimeToDateTime(sTime);
end;


function CountBranchSep(Str,BranchSep: string): integer;
var i:integer;
begin
 result:=0;
 for i:=1 to length(Str) do
  begin
   if Str[i]=BranchSep then
    result:=result+1;
  end;
end;

function ExtractPath(Str,BranchSep: string; CountBranchSep: integer): string;
var i,j:integer;

begin
 result:='';
 j:=0;
 for i:=1 to length(str) do
 begin
  if str[i]=BranchSep then
   inc(j);
  if j>CountBranchSep then
   break;
//  if j=CountBranchSep then
   result:=result+str[i];

 end;

end;

function GetNextLevel(Path,Str, BranchSep: string; var IsFolder:boolean): string;
var s:string;
    i:integer;
begin
 result:='';
 if pos(Path,Str)=0 then exit;

 i:=CountBranchSep(Path,BranchSep);
 s:=ExtractPath(Str,BranchSep,i);
 if CompareText(s,path)<>0 then exit;
 s:=str;
 delete(s,1,length(Path)+1);
 if pos(BranchSep,s)=0 then
  begin
   IsFolder:=false;
   result:=s;
   exit;
  end;
 i:=1;

 while (s[i]<>BranchSep) and (i<=length(s)) do
  begin
   result:=result+s[i];
   inc(i);
  end;
 IsFolder:=true;
end;

function QualityToStr(Quality:DWord; ForDebug:boolean=false):string;
begin
 if not ForDebug then
   case Quality of
    $00:result:='Плохое (без уточнений)';
    $04:result:='Плохое (ошибка конфигурации)';
    $08:result:='Плохое (нет связи)';
    $0C:result:='Плохое (сбой устройства)';
    $10:result:='Плохое (сбой датчика)';
    $14:result:='Плохое (нет связи, последнее значение доступно)';
    $18:result:='Плохое (нет связи, последнее значение не доступно)';
    $1C:result:='Плохое (не обслуживается)';
    $C0:result:='Хорошее';
   else
    result:='Не определено';
   end
 else
   case Quality of
    $00:result:='OPC_QUALITY_BAD';
    $04:result:='OPC_QUALITY_CONFIG_ERROR';
    $08:result:='OPC_QUALITY_NOT_CONNECTED';
    $0C:result:='OPC_QUALITY_DEVICE_FAILURE';
    $10:result:='OPC_QUALITY_SENSOR_FAILURE';
    $14:result:='OPC_QUALITY_LAST_KNOWN';
    $18:result:='OPC_QUALITY_COMM_FAILURE';
    $1C:result:='OPC_QUALITY_OUT_OF_SERVICE';
    $C0:result:='OPC_QUALITY_GOOD';
   else
    result:='Не определено';
   end;

end;



function ArrayVariantToString(V:OleVariant):string;
var i:integer;
begin
 result:='';
 if (VarType(v) and VarArray)<>VarArray then
  result:=VarToStr(v)
 else
  begin
  for i:=VarArrayLowBound(v,1) to VarArrayHighBound(v,1) do
   if result='' then
    result:=VarToStr(v[i])
   else
    result:=result+';'+VarToStr(v[i]);
   result:='['+result+']';
  end;

end;


{формат записи значений вариантов в строку:
 2байта - тип данных;

 если тип данных не массив и не строка, то:
 8байт - значение (побайтовое);

 если тип данных строка, то:
 4байта - длина строки;
 Nбайт - строка;

 если тип данных массив простых типов (не строк), то:
 4байта - кол-во ячеек массива;
 8байт * кол-во ячеек массива;

 если тип данных массив строк, то:
 4байта - кол-во ячеек массива;
 (4байта - длина строки;
  Nбайт - строка)         * кол-во ячеек массива;
}

function HAVariantToHexStringValue(Value:OleVariant):string;
var st:TStringStream;

procedure SetSimpleValue(TypeData:word; V:OleVariant);
var cr:THAConvertRec;
begin
 case TypeData of
    vt_i2   : cr.asvt_i2:=V;
    vt_i4   : cr.asvt_i4:=V;
    vt_r4   : cr.asvt_r4:=V;
    vt_r8   : cr.asvt_r8:=V;
    vt_cy   : cr.asvt_cy:=V;
    vt_date : cr.asvt_date:=V;
    vt_bool : cr.asvt_bool:=V;
    vt_i1   : cr.asvt_i1:=V;
    vt_ui1  : cr.asvt_ui1:=V;
    vt_ui2  : cr.asvt_ui2:=V;
    vt_ui4  : cr.asvt_ui4:=V;
  end;
  ST.Write(cr.asArrayByte,8);
end;

procedure SetStrValue(V:OleVariant);
var Len:dword;
    s:string;
    i:integer;
begin
 s:=VarToStr(v);
 Len:=Length(s);
 ST.Write(Len,sizeof(Len));
 for i:=1 to Len do
  ST.Write(s[i],1);

end;

var TypeData:word;
    LenArray:dword;
    i,Len:integer;
    s:string;



begin
 st:=TStringStream.Create('');
 try
  TypeData:=VarType(Value);
  st.Position:=0;
  st.Write(TypeData,2);

  if (TypeData and vt_Array)=vt_Array then
   begin
    LenArray:=VarArrayHighBound(Value,1)+1;
    st.Write(LenArray,sizeof(LenArray));
    for i:=0 to LenArray-1 do
     if (TypeData and VarTypeMask)=vt_bstr then
      SetStrValue(Value[i])
     else
      SetSimpleValue(TypeData and VarTypeMask,Value[i]);
   end
  else
   if TypeData=vt_bstr then
    begin
     SetStrValue(Value);
    end
   else
    SetSimpleValue(TypeData, Value);

  s:=st.DataString;
  len:=Length(s);
  for i:=1 to len do
    result:=result+inttohex(ord(s[i]),2);
 finally
  st.Free;
 end;

end;

function HAHexStringValueToVariant(Str:string):OleVariant;
var st:TStringStream;

function GetSimpleValue(TypeData:word):OleVariant;
var cr:THAConvertRec;
    Len:dword;
    i:integer;
begin
 fillchar(cr.asArrayByte,sizeof(cr.asArrayByte),0);
 Len:=ST.Position+8;
 i:=0;
 while ST.Position<Len do
  begin
   ST.Read(cr.asArrayByte[i],1);
   inc(i);
  end;

 case TypeData of
    vt_i2   : result:=VarAsType(cr.asvt_i2,TypeData);
    vt_i4   : result:=VarAsType(cr.asvt_i4,TypeData);
    vt_r4   : result:=VarAsType(cr.asvt_r4,TypeData);
    vt_r8   : result:=VarAsType(cr.asvt_r8,TypeData);
    vt_cy   : result:=VarAsType(cr.asvt_cy,TypeData);
    vt_date : result:=VarAsType(cr.asvt_date,TypeData);
    vt_bool : result:=VarAsType(cr.asvt_bool,TypeData);
    vt_i1   : result:=VarAsType(cr.asvt_i1,TypeData);
    vt_ui1  : result:=VarAsType(cr.asvt_ui1,TypeData);
    vt_ui2  : result:=VarAsType(cr.asvt_ui2,TypeData);
    vt_ui4  : result:=VarAsType(cr.asvt_ui4,TypeData);
  end;
end;

function GetStrValue:string;
var Len:dword;
    c:char;
    i:integer;
begin
 ST.Read(Len,sizeof(len));
 SetLength(result,Len);
 Len:=ST.Position+Len;
 i:=1;
 while ST.Position<Len do
  begin
   ST.Read(c,1);
   result[i]:=c;
   inc(i);
  end;
end;


var TypeData:word;
    LenArray:dword;
    i,lenstr:integer;
    s:string;
    b:byte;
begin
 result:=null;
 lenstr:=length(str);
 i:=1;
 s:='';
 if Lenstr<6 then exit;
 while i<=Lenstr do
  begin
   b:=strtoint('$'+str[i]+str[i+1]);
   s:=s+chr(b);
   inc(i,2);
  end;

 st:=TStringStream.Create(S);
 try
   st.Position:=0;
   st.Read(TypeData,sizeof(TypeData));
   if (TypeData and vt_Array)=vt_Array then
    begin
     st.Read(LenArray,sizeof(LenArray));
     result:=VarArrayCreate([0,LenArray-1], TypeData and VarTypeMask);

     for i:=0 to LenArray-1 do
      if (TypeData and VarTypeMask)=vt_bstr then
       result[i]:=GetStrValue
      else
       result[i]:=GetSimpleValue(TypeData and VarTypeMask);

    end
   else
    if TypeData=vt_bstr then
     begin
      result:=GetStrValue;
     end
    else
     result:=GetSimpleValue(TypeData);



 finally
  st.Free;
 end;
end;


function DeleteCommentFromScript(Scr: String): string;

function GoodDelim(s:string; i:integer):boolean;
var j:integer;
    f:boolean;
 begin

  f:=true;
  for j:=i downto 1 do
   if s[j]='''' then
    begin
     f:=false;
     break;
    end;
  result:=f;
 end;

{function ClearComment(sComm:string; APos:integer):string;
var s:string;
begin
  s:=DupeString(' ',(Length(sComm)-APos)+1);
  if APos=1 then
    result:=s
  else
    result:=copy(sComm,1,APos-1)+s;

end;}

var i,j,j1:integer;
    fl:boolean;
    s,s1:string;
    Ascr:TStringList;
begin
 result:='';
 Ascr:=TStringList.Create;
 try
 Ascr.Text:=Scr;

 fl:=false;
 for i:=0 to aScr.Count-1 do
  begin
    s:=aScr[i];
    j:=pos('//',s);
    if j>0 then
     if GoodDelim(s,j) then
      begin
       //delete(s,j,length(s));

       s1:=DupeString(' ',(Length(s)-j)+1);
       s:=StuffString(s,j,length(s1),s1);
      { if j=1 then
         s:=s1
       else
         s:=copy(s,1,j-1)+s1;}

       aScr[i]:=s;
      end;
  end;

 fl:=false;
 for i:=0 to aScr.Count-1 do
  begin
    s:=aScr[i];
    if not fl then
     begin
      j:=pos('{',s);
      if j>0 then
       if GoodDelim(s,j) then
        begin
         fl:=true;
         for j1:=j+1 to length(s) do
          if (s[j1]='}') then
           begin
            s1:=DupeString(' ',(j1-j)+1);
            s:=StuffString(s,j,length(s1),s1);
           // delete(s,j,(j1-j)+1);
            fl:=false;
            aScr[i]:=s;
           end;
          if fl then
             begin
              s1:=DupeString(' ',(Length(s)-j)+1);
              s:=StuffString(s,j,length(s1),s1);

            //  delete(s,j,length(s));
              aScr[i]:=s;
             end;
        end;
      end
     else
      begin
       j:=pos('}',s);
       if j>0 then
        begin
         s1:=DupeString(' ',j);
         s:=StuffString(s,1,length(s1),s1);
        // delete(s,1,j);
         fl:=false;
         aScr[i]:=s;
        end
       else
        aScr[i]:='';
      end;

  end;

 result:=AScr.Text;
 finally
  AScr.Free;
 end;

end;



end.
