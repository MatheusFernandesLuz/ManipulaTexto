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

procedure VerificaLinha(linha: String);
var
  i: integer;
  campo: String;
begin
  campo:= '';
  for i:=0 to linha.Length do
  begin
    if linha.Chars[i+1] <> '' then campo:= campo+linha.Chars[i+1]
    else break;
  end;
  ShowMessage(campo);
end;

procedure importaArquivo();
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
      VerificaLinha(arquivoOrigem[i]);
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

  if FileExists(nomeArquivo) then importaArquivo()
  else ShowMessage('Arquivo Inválido');

end;

end.

