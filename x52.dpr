program x52;

uses
  Forms,
  main in 'main.pas' {Form1},
  DirectOutput_explicit in 'DirectOutput_explicit.pas' {$R *.res},
  ServiceUnit in 'ServiceUnit.pas';


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'X3TC_Plugin';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
