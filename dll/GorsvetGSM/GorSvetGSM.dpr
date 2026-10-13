library GorSvetGSM;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  windows,
  ActiveX,
  UComPort in 'UComPort.pas',
  Intf in '..\Intf.pas',
  UDialog in 'UDialog.pas' {fmDialog},
  HAAES in '..\..\..\..\Delphi7\aes\HAAES.pas';

{$R *.res}





function Write(ppDriverData:pDriverData):HResult; stdcall;
begin
 result:=co.Write(ppDriverData);
end;

function Read(out ppDriverData:pDriverData):HResult; stdcall;
begin
 result:=co.Read(ppDriverData);
end;

function OpenDriver:HResult; stdcall;
begin
 result:=co.OpenPort;
end;

function CloseDriver:HResult; stdcall;
begin
 result:=co.ClosePort;
end;

function ShowDialog:HResult; stdcall;
begin
 TfmDialog.Create(nil).ShowModal;
 result:=s_ok;
end;

 exports
  Write,
  Read,
  OpenDriver,
  CloseDriver,
  ShowDialog;


begin
end.
