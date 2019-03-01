unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TPrincipal }

  TPrincipal = class(TForm)
    btCarregar: TButton;
    btSalvar: TButton;
    procedure btCarregarClick(Sender: TObject);
  private

  public

  end;

var
  Principal: TPrincipal;
  nomeArquivo: String;
  arquivoDestino: TStringList;

implementation

{$R *.lfm}

procedure separaCampos(delimitador: array of Integer; linha: String);
var
  i, inicio, fim: Integer;
  campo: String;
begin
  inicio:=0;
  fim:=0;
  for i:=inicio to linha.Length do
  begin
    campo:= Copy(linha, inicio+2, delimitador[fim]-2);
    inicio:=delimitador[fim];
    Inc(fim);
  end;
  ShowMessage(campo);
end;

procedure VerificaLimites(linha: String);
var
  i, cont: integer;
  delimitador: array[0..3] of Integer;
begin
  cont:=0;
  for i:=0 to linha.Length do
  begin
    if (linha.Chars[i] = ';') then
    begin
      delimitador[cont]:= i;
      Inc(cont);
    end
  end;
  separaCampos(delimitador, linha);
end;

procedure leArquivo();
var
  arquivoOrigem: TStringList;
  i: integer;
begin
  arquivoOrigem:= TStringList.Create;

  try
    arquivoOrigem.LoadFromFile(nomeArquivo);
    i:=0;
    while i <= arquivoOrigem.Count-1 do
    begin
      VerificaLimites(arquivoOrigem[i]);
      Inc(i);
    end;
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

end.

