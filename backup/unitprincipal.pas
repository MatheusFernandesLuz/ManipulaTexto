unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, dateutils;

type

  { TPrincipal }

  TPrincipal = class(TForm)
    btCarregar: TButton;
    btSelecionar: TButton;
    btSalvar: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btCarregarClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btSelecionarClick(Sender: TObject);
  private

  public

  end;

var
  Principal: TPrincipal;
  nomeArquivo: String;
  arquivoDestino: TStringList;
  cont: Integer;

implementation

{$R *.lfm}

procedure SalvarArquivoDestino(local: String);
var
  data, hora: String;
begin

  data:= StringReplace(DateToStr(Date()), '/', '.', [rfReplaceAll]);
  hora:= StringReplace(TimeToStr(Time()), ':', '.', [rfReplaceAll]);

  try
   arquivoDestino.SaveToFile(local+'\EXTRATO - ' + data  + ' - ' + hora + '.html');
   ShowMessage('Arquivo Salvo');
  finally
   arquivoDestino.Free;
   cont:=0;
  end;
end;

procedure CriaTabela();
begin
  arquivoDestino:= TStringList.Create;

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

procedure IncrementaLinhaExtrato(data, documento, historico, valor, saldo, color: String);
begin
  arquivoDestino.Add('<tr>');
  arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + data + '</td>');
  arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + documento + '</td>');
  arquivoDestino.Add('<td style="border: solid 1px black; text-align: left;">' + historico + '</td>');
  arquivoDestino.Add('<td style="border: solid 1px black; text-align: center;">' + valor + '</td>');
  arquivoDestino.Add('<td style="border: solid 1px black; text-align: center; background-color:' + color + '"><b>' + saldo + '</b></td>');
  arquivoDestino.Add('</tr>');
  Inc(cont);
end;

function ModificaValor(numero: String): String;
var
  separadorDec: Char;
  aux: Double;
begin

  if (numero = '') then Exit;
  try
    separadorDec:= FormatSettings.DecimalSeparator;
    FormatSettings.DecimalSeparator:='.';
    aux:= StrToFloat(numero);
    FormatSettings.DecimalSeparator:=',';
    ModificaValor:= FormatFloat('#,##0.00', aux);
  finally
    FormatSettings.DecimalSeparator:= separadorDec;
  end;

end;

procedure ValidarDados(campos: array of String);
var
 Date: TDateTime;
 valida: Boolean;
 data, documento, historico, valor, saldo, color: String;
begin
  valida:= false;

  if TryStrToDate(campos[0], Date, 'yy-mm-dd', '/') then
  begin

    data:= campos[0];
    documento:= campos[1];
    historico:= campos[2];
    valor:= ModificaValor(campos[3]);
    saldo:= ModificaValor(campos[4]);

    if saldo.Contains('-') then color:='red'
    else color:='lightgray';

    if (documento = '') then
    begin
     if (historico = 'SALDO') or (historico = 'SALDO ANTERIOR') then valida:=true;
    end
    else valida:=true;
  end;

  if valida = true then IncrementaLinhaExtrato(data, documento, historico, valor, saldo, color);

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
    if arquivoDestino = nil then CriaTabela();
    i:=0;
    while i <= arquivoOrigem.Count-1 do
    begin
      SeparaCampos(arquivoOrigem[i]);
      Inc(i);
    end;
    if (i = 0) and (cont < 1) then
    begin
     ShowMessage('Arquivo de entrada inválido.');
     arquivoOrigem.Free;
     Exit;
    end;
    Principal.btSalvar.Enabled:=true;
    Principal.btSalvar.SetFocus;
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
    Edit2.Text:= open.FileName;
    nomeArquivo:= open.FileName;
  finally
    open.Free;
  end;

  if FileExists(nomeArquivo) then leArquivo()
  else ShowMessage('Selecione um arquivo válido.');

end;

procedure TPrincipal.btSalvarClick(Sender: TObject);
begin
  if (Edit1.Text = '') then SalvarArquivoDestino(Edit1.TextHint)
  else SalvarArquivoDestino(Edit1.Text);
end;

procedure TPrincipal.btSelecionarClick(Sender: TObject);
var
  open: TSelectDirectoryDialog;
begin
  try
    open:= TSelectDirectoryDialog.Create(nil);
    open.Execute;
    Edit1.Text:= open.FileName;
  finally
    open.Free;
  end;
end;


end.

