unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, dateutils;

type

  { TPrincipal }

  TPrincipal = class(TForm)
    btCarregar: TButton;
    btSelecionar: TButton;
    btSalvar: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btCarregarClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btSelecionarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Principal: TPrincipal;
  nomeArquivo: String;
  arquivoDestino: TStringList;
  lista: TStringList;

implementation

{$R *.lfm}

procedure SalvarArquivoDestino(local: String);
begin
  arquivoDestino.SaveToFile(local+'\extrato.html');
end;

procedure CriaTabela();
begin

 arquivoDestino.add('<!DOCTYPE html>');
 arquivoDestino.add('<html>');
 arquivoDestino.add('<head>');
 arquivoDestino.add('<meta charset="utf-8">');
 arquivoDestino.add('<title> Extrato bancário </title>');
 arquivoDestino.add('</head>');
 arquivoDestino.add('<body>');
 arquivoDestino.add('<h2> EXTRATO BANCÁRIO </h2>');
 arquivoDestino.add('<table>');
 arquivoDestino.add('<thead style="color: white; background-color: black;">');
 arquivoDestino.add('<tr>');
 arquivoDestino.add('<th style="width: 100px; text-align: center;"> Data </th>');
 arquivoDestino.add('<th style="width: 100px; text-align: center;"> Documento </th>');
 arquivoDestino.add('<th style="width: 600px; text-align: center;"> Histórico </th>');
 arquivoDestino.add('<th style="width: 100px; text-align: center;"> Valor </th>');
 arquivoDestino.add('<th style="width: 100px; text-align: center;"> Saldo </th>');
 arquivoDestino.add('</tr>');
 arquivoDestino.add('</thead>');
 arquivoDestino.add('<tbody>');

end;

procedure ValidarDados(campos: array of String);
var
 Data:TDateTime;
 valida: Boolean;
 i: Integer;
begin
  valida:= false;
  if TryStrToDate(campos[0], Data, 'yy-mm-dd', '/') then
  begin
   if (campos[1] = '') then
   begin
    if (campos[2] = 'SALDO') or (campos[2] = 'SALDO ANTERIOR') then
     valida:=true;
   end
   else valida:=true;
  end;

  if valida = true then
  begin
    arquivoDestino.Add('<tr>');
    arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + campos[0] + '</td>');
    arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + campos[1] + '</td>');
    arquivoDestino.Add('<td style="border: solid 1px black; text-align: left;">' + campos[2] + '</td>');
    arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + campos[3] + '</td>');
    arquivoDestino.Add('<td style="border: solid 1px black; text-align: center; background-color: lightgray;"><b>' + campos[4] + '</b></td>');
    arquivoDestino.Add('</tr>');
  end;

end;

procedure SeparaCampos(linha: String);
var
  i, j: integer;
  campos: array[0..4] of String;
begin
  j:=0;
  for i:=0 to linha.Length do
  begin
    if (linha.Chars[i] <> ';') and (linha.Chars[i] <> '"')  then campos[j]:= campos[j]+linha.Chars[i]
    else if linha.Chars[i] <> '"' then Inc(j);
  end;
  ValidarDados(campos);
end;

procedure leArquivo();
var
  arquivoOrigem: TStringList;
  i: integer;
begin
  arquivoOrigem:= TStringList.Create;

  try
    arquivoOrigem.LoadFromFile(nomeArquivo);
    CriaTabela();
    i:=0;
    while i <= arquivoOrigem.Count-1 do
    begin
      SeparaCampos(arquivoOrigem[i]);
      Inc(i);
    end;
    Principal.btSalvar.Enabled:=true;
  finally
    arquivoOrigem.Free;
  end;
end;

{ TPrincipal }

procedure TPrincipal.btCarregarClick(Sender: TObject);
var
  open: TOpenDialog;
begin

  try
    open:= TOpenDialog.Create(nil);
    open.Filter:='Arquivo CSV | *.csv';
    open.Execute;
    nomeArquivo:= open.FileName;
  finally
    open.Free;
  end;

  if FileExists(nomeArquivo) then leArquivo()
  else ShowMessage('Arquivo Inválido');

end;

procedure TPrincipal.btSalvarClick(Sender: TObject);
begin
  if (Edit1.Text = '') then Edit1.Text:=Edit1.TextHint;
  SalvarArquivoDestino(Edit1.Text);
end;

procedure TPrincipal.btSelecionarClick(Sender: TObject);
var
  open: TOpenDialog;
begin
  try
    open:= TOpenDialog.Create(nil);
    open.Execute;
    Edit1.Text:= open.FileName;
  finally
    open.Free;
  end;
end;

procedure TPrincipal.FormCreate(Sender: TObject);
begin
  arquivoDestino:= TStringList.Create;
end;


end.

