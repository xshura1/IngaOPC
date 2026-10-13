unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

type
 TBuff=array [0..255] of byte;

function CalcCRC(Arr:TBuff; Len:cardinal):byte;
var h:byte;
    i,index:integer;
begin
 h:=Arr[0];
 for i:=1 to Len-1 do
  h:=h xor Arr[i];
 result:=h;
end;

function crcpsch(data:TBuff; n:byte):string; // CRC äëÿ ÏÑ×
var i:byte;
    temp,temp1,temp2:integer;

begin
 temp:=0;
 for i:=0 to n-1 do
  temp:=temp+data[i];
 temp:=temp mod 256;
 temp1:=temp div 16;
 temp2:=temp mod 16;
 if (temp1>=0)and(temp1<=9)then
  temp1:=temp1+48
 else
  temp1:=temp1+55;
 if (temp2>=0) and (temp2<=9) then
  temp2:=temp2+48
 else
  temp2:=temp2+55;

result:=chr(temp1)+chr(temp2);

end;

procedure TForm1.Button1Click(Sender: TObject);
var pw:TBuff;
    crc:byte;
    scrc:string;
begin
 pw[0]:=35;
 pw[1]:=52;
 pw[2]:=50;
 pw[3]:=48;
 pw[4]:=48;
 pw[5]:=48;
 pw[6]:=48;
 pw[7]:=48;
 pw[8]:=48;
 pw[9]:=69;
{ pw[10]:=48;
 pw[11]:=50;
 pw[12]:=50;
 pw[13]:=49;
 pw[14]:=50;
 pw[15]:=48;
 pw[16]:=48;
 pw[17]:=70;
 pw[18]:=13;  }
 crc:=CalcCRC(pw,10);
 scrc:= crcpsch(pw,10);
 if crc=0 then exit;
end;

end.
