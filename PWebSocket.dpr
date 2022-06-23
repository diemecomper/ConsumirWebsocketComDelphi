program PWebSocket;

uses
  Vcl.Forms,
  UWebSocket in 'UWebSocket.pas' {FWebsocket},
  IdWebSocketSimpleClient in 'IdWebSocketSimpleClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFWebsocket, FWebsocket);
  Application.Run;
end.
