unit HA_EnumStr;

interface

uses Classes,WinProcs,ComObj,ActiveX;

const
 IID_IEnumString : TIID = '{00000101-0000-0000-C000-000000000046}';
 IID_IEnumUnknown: TIID = '{00000100-0000-0000-C000-000000000046}';

type
  TOPCStringsEnumerator = class(TComObject, IEnumString)
  private
    nextIndex:Integer;
    strList:TStringList;
    function Clone(out enm: IEnumString): HResult; stdcall;
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
  public
    constructor Create(const inStrings: TStringList);
    destructor destroy;override;
  end;

 TOPCUnknownEnumerator = class(TComObject, IEnumUnknown)
  private
    nextIndex:Integer;
    fList:TInterfaceList;
    function Clone(out enm: IEnumUnknown): HResult; stdcall;
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
  public
    constructor Create(const L:TInterfaceList);
    destructor destroy;override;
  end;

 { IEnumUnknown = interface(IUnknown)
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumUnknown): HResult; stdcall;
  end;}

implementation

uses ComServ,OPCDA;

//const
// ['{00000101-0000-0000-C000-000000000046}']
 //IID_IUnknown: TIID = '{00000000-0000-0000-C000-000000000046}';  //is in ole2.pas


constructor TOPCStringsEnumerator.Create(const inStrings: TStringList);
var
 i:integer;
begin
 inherited Create;
 strList := TStringList.create;
 for i:=0 to inStrings.count-1 do
  strList.add(inStrings[i]);
 nextIndex := 0;
end;

destructor TOPCStringsEnumerator.destroy;
begin
 strList.free;
 inherited destroy;
end;

function TOPCStringsEnumerator.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
 i: integer;
begin
 i:=0;
 if celt < 1 then
  begin
   Result:=RPC_X_ENUM_VALUE_OUT_OF_RANGE;
   Exit;
  end;
 if pceltFetched = nil then
  begin
   Result:=E_INVALIDARG;
   Exit;
  end;

 Result := S_FALSE;
 while (i < celt) do
  begin
   if (nextIndex < strList.Count) then
    begin
     TPointerList(elt)[i]:=StringToLPOLESTR(strList[nextIndex]);
     i:=succ(i);
     nextIndex:=succ(nextIndex);
    end
   else
    begin
     Result:=RPC_X_ENUM_VALUE_OUT_OF_RANGE;
     Break;
    end;
  end;

 pceltFetched^:=i;
 if i = celt then
  Result := S_OK;
end;

function TOPCStringsEnumerator.Skip(celt: Longint): HResult;
begin
 if (nextIndex + celt) <= strList.Count then
  begin
   nextIndex:=nextIndex + celt;
   result:=S_OK;
  end
 else
  begin
   nextIndex:=strList.Count;
   result:=S_FALSE;
  end;
end;

function TOPCStringsEnumerator.Reset: HResult;
begin
 nextIndex:=0;
 result:=S_OK;
end;

function TOPCStringsEnumerator.Clone(out enm: IEnumString): HResult;
begin
 try
  enm:=TOPCStringsEnumerator.Create(strList);
  result:=S_OK;
 except
  result:=E_UNEXPECTED;
 end;
end;


{ TOPCUnknownEnumerator }

function TOPCUnknownEnumerator.Clone(out enm: IEnumUnknown): HResult;
begin
 try
  enm:=TOPCUnknownEnumerator.Create(fList);
  result:=S_OK;
 except
  result:=E_UNEXPECTED;
 end;

end;

constructor TOPCUnknownEnumerator.Create(const L:TInterfaceList);
var
 i:integer;
begin
 inherited Create;
 fList := TInterfaceList.create;
 for i:=0 to L.count-1 do
  begin
   fList.add(L[i]);
  // TComObject(fList[i]).ObjAddRef;
  end;
 nextIndex := 0;

end;

destructor TOPCUnknownEnumerator.destroy;
var i:integer;
begin
 for i:=0 to fList.Count-1 do
  TComObject(fList[i]).ObjRelease;
  fList.free;
  inherited;
end;

function TOPCUnknownEnumerator.Next(celt: Integer; out elt;
  pceltFetched: PLongint): HResult;
var
 i: integer;
begin
 i:=0;
 if celt < 1 then
  begin
   Result:=RPC_X_ENUM_VALUE_OUT_OF_RANGE;
   Exit;
  end;
 if pceltFetched = nil then
  begin
   Result:=E_INVALIDARG;
   Exit;
  end;

 Result := S_FALSE;
 while (i < celt) do
  begin
   if (nextIndex < fList.Count) then
    begin
     TPointerList(elt)[i]:=TComObject(fList[nextIndex]);// as IUnknown;
     //elt:=(fList[nextIndex]) as IUnknown;
     i:=succ(i);
     nextIndex:=succ(nextIndex);
    end
   else
    begin
     Result:=RPC_X_ENUM_VALUE_OUT_OF_RANGE;
     Break;
    end;
 end;
  pceltFetched^:=i;
  if i = celt then
  Result := S_OK;
end;

function TOPCUnknownEnumerator.Reset: HResult;
begin
 nextIndex:=0;
 result:=S_OK;
end;

function TOPCUnknownEnumerator.Skip(celt: Integer): HResult;
begin
 if (nextIndex + celt) <= fList.Count then
  begin
   nextIndex:=nextIndex + celt;
   result:=S_OK;
  end
 else
  begin
   nextIndex:=fList.Count;
   result:=S_FALSE;
  end;

end;

initialization
 TComObjectFactory.Create(ComServer,
                            TOPCStringsEnumerator,
                            IEnumString,
                            'TOPCStringsEnumerator',
                            'HA',
                            ciInternal,
                            tmApartment);
 TComObjectFactory.Create(ComServer,
                            TOPCUnknownEnumerator,
                            IEnumUnknown,
                            'TOPCUnknownEnumerator',
                            'HA',
                            ciInternal,
                            tmApartment);

end.
