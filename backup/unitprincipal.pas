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
  extratoCSV: TextFile;

implementation

{$R *.lfm}

{ TPrincipal }

procedure TPrincipal.btCarregarClick(Sender: TObject);
var
  open: TOpenDialog;
begin

  try
    open:= TOpenDialog.Create(nil);
    open.Filter:='Arquivo CSV | *.csv';
    open.Execute;
    extratoCSV:= open.FileName;
  finally
    open.Free;
  end;

end;

end.

