unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, dateutils;

type

  { TPrincipal }

  TPrincipal = class(TForm)
    btCarregarCsv: TButton;
    btSelecionarPasta: TButton;
    btSalvar: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btCarregarCsvClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure btSelecionarPastaClick(Sender: TObject);
  private

  public

  end;

var
  Principal: TPrincipal;
  arquivoOrigem: TStringList;
  arquivoDestino: TStringList;
  numLinhasTabela: Integer;

implementation

{$R *.lfm}

procedure CriaCabecalho();
begin
  arquivoDestino:= TStringList.Create;
  numLinhasTabela:=0;

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
  Inc(numLinhasTabela);
end;

function ModificaFormato(numero: String): String;
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
    ModificaFormato:= FormatFloat('R$ #,##0.00', aux);
  finally
    FormatSettings.DecimalSeparator:= separadorDec;
  end;

end;

procedure ValidarCampos(campos: array of String);
var
  Date: TDateTime;
  valida: Boolean;
  data, documento, historico, valor, saldo, color: String;
begin
  valida:= false;

  if TryStrToDate(campos[0], Date, 'yy-mm-dd', '/') then
  begin

    data:= DateToStr(Date);
    documento:= Trim(campos[1]);
    historico:= Trim(campos[2]);
    try
      valor:= ModificaFormato(Trim(campos[3]));
      saldo:= ModificaFormato(Trim(campos[4]));
    except
      Exit;
    end;

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

  ValidarCampos(campos);
end;

procedure MensagemErro(msg: String);
begin
  ShowMessage(msg);
  arquivoDestino.Free;
  arquivoOrigem.Free;
  Principal.btSalvar.Enabled:=false;
  Principal.Edit2.Clear;
end;

procedure CriaTabela();
var
  i: integer;
begin
  arquivoOrigem:= TStringList.Create;
  arquivoOrigem.LoadFromFile(Principal.Edit2.text);

  CriaCabecalho();

  i:=0;
  while i <= arquivoOrigem.Count-1 do
  begin
    if Trim(arquivoOrigem[i]) = '' then
    begin
      MensagemErro('Arquivo inválido.');
      Exit;
    end
    else
    begin
      SeparaCampos(arquivoOrigem[i]);
      Inc(i);
    end;
  end;
end;

{ TPrincipal }

procedure TPrincipal.btSalvarClick(Sender: TObject);
var
  data, hora: String;
begin

  try
    if numLinhasTabela = 0 then
    begin
     MensagemErro('Aquivo inválido.');
     Exit;
    end
    else
    begin
      data:= StringReplace(DateToStr(Date()), '/', '.', [rfReplaceAll]);
      hora:= StringReplace(TimeToStr(Time()), ':', '.', [rfReplaceAll]);
      if Edit1.Text = '' then Edit1.Text:=Edit1.TextHint;
      arquivoDestino.SaveToFile(Edit1.Text+'\EXTRATO - ' + data  + ' - ' + hora + '.html');
      ShowMessage('Arquivo Salvo');
      btSalvar.Enabled:=false;
      Edit2.Clear;
    end;
  except
    MensagemErro('Arquivo Inválido.');
  end;

end;

procedure TPrincipal.btCarregarCsvClick(Sender: TObject);
var
  open: TOpenDialog;
begin

  try
    open:= TOpenDialog.Create(nil);
    open.Filter:='Arquivo CSV | *.csv';
    open.Execute;
    Edit2.Text:= open.FileName;

    btSalvar.Enabled:=true;
    btSalvar.SetFocus;
    if FileExists(open.FileName) then CriaTabela();
  finally
    open.Free;
  end;

end;

procedure TPrincipal.btSelecionarPastaClick(Sender: TObject);
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

