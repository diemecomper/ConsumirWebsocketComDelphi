unit UWebSocket;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdEcho, IdHTTP,
  Bird.Socket.Client,
  IdWebSocketSimpleClient,
  System.JSON, System.Win.ScktComp, Vcl.ExtCtrls;

type
  TFWebsocket = class(TForm)
    Label4: TLabel;
    linhas: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Shape1: TShape;
    ws_host: TEdit;
    ws_porta: TEdit;
    Button1: TButton;
    Panel2: TPanel;
    Label3: TLabel;
    Edit4: TEdit;
    Button2: TButton;
    Timer1: TTimer;
    ClientSocket: TClientSocket;
    procedure desconectaClick(Sender: TObject);
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketLookup(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button1Click(Sender: TObject);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    connp: boolean;
    sid: string;
    c1: tstrings;
    c2: tstrings;
  end;

var
  FWebsocket: TFWebsocket;

implementation

{$R *.dfm}


procedure TFWebsocket.Button1Click(Sender: TObject);
begin
  linhas.lines.Add('conectado');
  Timer1.Enabled := true;


  ClientSocket.Host := ws_host.Text;
  ClientSocket.Port := strtoint(ws_porta.Text);
  ClientSocket.Active := not ClientSocket.Active;
  connp := not ClientSocket.Active;
end;

procedure TFWebsocket.Button2Click(Sender: TObject);
var
  texto: string;
begin
  texto := '42["message","' + Edit4.Text + '","' + sid + '"]';
  ClientSocket.Socket.SendText(chr($81) + chr(length(texto)) + texto);
end;

procedure TFWebsocket.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  linhas.lines.Add('on connect');
end;

procedure TFWebsocket.ClientSocketError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  linhas.lines.Add('Erro ' + IntToStr(ErrorCode));
end;

procedure TFWebsocket.ClientSocketLookup(Sender: TObject;
  Socket: TCustomWinSocket);
  var data : string;
begin
  //data := ClientSocket.Socket.SendText;
  //linhas.lines.Add('retorno ' + data);
end;

procedure TFWebsocket.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
  var data : string;
  recO, rec: String;
begin
  recO := Socket.ReceiveText;

  if pos(String('"sid":"'), recO) > 0 then
  begin
    rec := recO;
    delete(rec, 1, pos(String('"sid":"'), rec) + length('"sid":"') - 1);
    sid := copy(rec, 1, pos(String('","'), rec) - 1);
    Label4.Caption := 'Id da sessão: ' + sid;
  end;

  if pos(String('Cookie: io='), recO) > 0 then
  begin
    rec := recO;
    c2.Clear;
    c2.Add('GET /socket.io/?EIO=2&transport=websocket' + ' HTTP/1.1');
    c2.Add('Host: ' + ClientSocket.Host + ':' + inttostr(ClientSocket.Port));
    //c2.Add('Host: ' + ClientSocket1.Host);
    c2.Add('Upgrade: websocket');
    c2.Add('Connection: Upgrade');
    c2.Add('Sec-WebSocket-Key: xV9SQKwQShaeeiCcxtJviA==');
    c2.Add('Origin: ' + ClientSocket.Host);
    c2.Add('Sec-WebSocket-Version: 13');
    c2.Add('');
    ClientSocket.Socket.SendText(c2.Text);
  end;
  if pos('HTTP/1.1', recO) = 0 then
    if pos('V0{', recO) = 0 then
      if pos('[', recO) <> 0 then
        if pos(']', recO) <> 0 then
          linhas.Lines.Add(copy(recO, pos('[', recO), pos(']', recO) + 1));
end;

procedure TFWebsocket.desconectaClick(Sender: TObject);
begin
  ClientSocket.Active := false;
  linhas.lines.Add('desconectado');
  Timer1.Enabled := false;
end;

procedure TFWebsocket.FormCreate(Sender: TObject);
begin
  connp := false;
  c1 := tstringlist.Create;
  c2 := tstringlist.Create;
end;

procedure TFWebsocket.Timer1Timer(Sender: TObject);
begin
  if ClientSocket.Active then
  begin
    Shape1.Brush.Color := cllime;
    Button1.Caption := 'Desconectar';

    if connp then
    begin
      c1.Clear;
      c1.Add('GET /socket.io/?EIO=2&transport=polling&b64=true&t=1496620800-0 HTTP/1.1');
      //c1.Add('Host: ' + ClientSocket1.Host);
      c1.Add('Host: ' + ClientSocket.Host + ':' + inttostr(ClientSocket.Port));
      c1.Add('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
      c1.Add('Accept-Encoding: identity');
      c1.Add('User-Agent: Mozilla/3.0 (compatible; Indy Library)');
      c1.Add('');
      ClientSocket.Socket.SendText(c1.Text);
      connp := false;
    end;

  end
  else
  begin
    Shape1.Brush.Color := clred;
    Button1.Caption := 'Conectar';
  end;
end;

end.
