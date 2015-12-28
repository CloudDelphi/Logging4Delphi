unit Logging4D;

interface

uses
  System.SysUtils;

type

  ELoggerException = class(Exception);

  TLoggerKeywords = TArray<string>;
  TLoggerAppender = TProc<string>;

  TLoggerLevel = (Off, Fatal, Error, Warn, Info, Debug, Trace, All);

  ILoggerMarker = interface
    ['{1A3E7857-90FF-415D-B69B-3A5202C400C0}']
    procedure SetName(const pName: string);
    function GetName(): string;

    procedure SetParent(pMarker: ILoggerMarker);
    function GetParent(): ILoggerMarker;

    property Name: string read GetName write SetName;
    property Parent: ILoggerMarker read GetParent write SetParent;
  end;

  ILogger = interface
    ['{449A6325-37D4-45F4-A3AF-E581FF2A4A70}']
    function Keywords(const pKeywords: TLoggerKeywords): ILogger;
    function Owner(const pOwner: string): ILogger;
    function Message(const pMessage: string): ILogger;
    function Exception(pException: Exception): ILogger;
    function Marker(const pName: string; pParent: ILoggerMarker = nil): ILogger;

    function GetKeywords(): TLoggerKeywords;
    function GetOwner(): string;
    function GetMessage(): string;
    function GetException(): Exception;
    function GetMarker(): ILoggerMarker;
  end;

  ILogging = interface
    ['{04148C83-66F4-4269-91C2-166CD192DE95}']
    procedure Fatal(pLogger: ILogger); overload;
    procedure Fatal(const pLogMsg: string); overload;

    procedure Error(pLogger: ILogger); overload;
    procedure Error(const pLogMsg: string); overload;

    procedure Warn(pLogger: ILogger); overload;
    procedure Warn(const pLogMsg: string); overload;

    procedure Info(pLogger: ILogger); overload;
    procedure Info(const pLogMsg: string); overload;

    procedure Debug(pLogger: ILogger); overload;
    procedure Debug(const pLogMsg: string); overload;

    procedure Trace(pLogger: ILogger); overload;
    procedure Trace(const pLogMsg: string); overload;

    procedure Log(const pLevel: TLoggerLevel; pLogger: ILogger); overload;
    procedure Log(const pLevel: TLoggerLevel; const pLogMsg: string); overload;
  end;

  LoggerHelpful = class
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function KeywordsToString(const pKeywords: TLoggerKeywords): string; static;
  end;

function NewLogger(): ILogger;

implementation

type

  TLoggerMarker = class(TInterfacedObject, ILoggerMarker)
  private
    FName: string;
    FParent: ILoggerMarker;
  public
    constructor Create(const pName: string; pParent: ILoggerMarker);
    destructor Destroy(); override;

    procedure SetName(const pName: string);
    function GetName(): string;

    procedure SetParent(pMarker: ILoggerMarker);
    function GetParent(): ILoggerMarker;

    property Name: string read GetName write SetName;
    property Parent: ILoggerMarker read GetParent write SetParent;
  end;

  TLogger = class(TInterfacedObject, ILogger)
  private
    FKeywords: TLoggerKeywords;
    FOwner: string;
    FMessage: string;
    FException: Exception;
    FMarker: ILoggerMarker;
  public
    constructor Create();
    destructor Destroy(); override;

    function Keywords(const pKeywords: TLoggerKeywords): ILogger;
    function Owner(const pOwner: string): ILogger;
    function Message(const pMessage: string): ILogger;
    function Exception(pException: Exception): ILogger;
    function Marker(const pName: string; pParent: ILoggerMarker = nil): ILogger;

    function GetKeywords(): TLoggerKeywords;
    function GetOwner(): string;
    function GetMessage(): string;
    function GetException(): Exception;
    function GetMarker(): ILoggerMarker;
  end;

function NewLogger(): ILogger;
begin
  Result := TLogger.Create();
end;

{ TLoggerMarker }

constructor TLoggerMarker.Create(const pName: string;
  pParent: ILoggerMarker);
begin
  FName := pName;
  FParent := pParent;
end;

destructor TLoggerMarker.Destroy;
begin
  FParent := nil;
  inherited Destroy;
end;

function TLoggerMarker.GetName: string;
begin
  Result := FName;
end;

function TLoggerMarker.GetParent: ILoggerMarker;
begin
  Result := FParent;
end;

procedure TLoggerMarker.SetName(const pName: string);
begin
  FName := pName;
end;

procedure TLoggerMarker.SetParent(pMarker: ILoggerMarker);
begin
  FParent := pMarker;
end;

{ TLogger }

constructor TLogger.Create;
begin
  FKeywords := nil;
  FOwner := EmptyStr;
  FMessage := EmptyStr;
  FException := nil;
  FMarker := nil;
end;

destructor TLogger.Destroy;
begin
  FKeywords := nil;
  FException := nil;
  FMarker := nil;
  inherited;
end;

function TLogger.Exception(pException: Exception): ILogger;
begin
  FException := pException;
  Result := Self;
end;

function TLogger.GetException: Exception;
begin
  Result := FException;
end;

function TLogger.GetKeywords: TLoggerKeywords;
begin
  Result := FKeywords;
end;

function TLogger.GetMarker: ILoggerMarker;
begin
  Result := FMarker;
end;

function TLogger.GetMessage: string;
begin
  Result := FMessage;
end;

function TLogger.GetOwner: string;
begin
  Result := FOwner;
end;

function TLogger.Keywords(const pKeywords: TLoggerKeywords): ILogger;
begin
  FKeywords := pKeywords;
  Result := Self;
end;

function TLogger.Marker(const pName: string; pParent: ILoggerMarker): ILogger;
begin
  FMarker := TLoggerMarker.Create(pName, pParent);
  Result := Self;
end;

function TLogger.Message(const pMessage: string): ILogger;
begin
  FMessage := pMessage;
  Result := Self;
end;

function TLogger.Owner(const pOwner: string): ILogger;
begin
  FOwner := pOwner;
  Result := Self;
end;

{ LoggerHelpful }

constructor LoggerHelpful.Create;
begin
  raise ELoggerException.Create(CanNotBeInstantiatedException);
end;

class function LoggerHelpful.KeywordsToString(const pKeywords: TLoggerKeywords): string;
var
  vStr: string;
begin
  Result := EmptyStr;
  for vStr in pKeywords do
    Result := Result + vStr + ';';
end;

end.
