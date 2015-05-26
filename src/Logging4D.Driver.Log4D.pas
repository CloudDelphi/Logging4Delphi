unit Logging4D.Driver.Log4D;

interface

uses
  Logging4D;

type

  TLog4DLoggingFactory = class sealed
  strict private
  const
    CanNotBeInstantiatedException = 'This class can not be instantiated!';
  strict private

    {$HINTS OFF}

    constructor Create;

    {$HINTS ON}

  public
    class function Build(const pIdentifier, pConfigFileName: string; pAppender: TLoggerAppender = nil): ILogging; static;
  end;

implementation

uses
  System.SysUtils,
  Log4D,
  Logging4D.Driver.Base;

var
  _vLog4DLevels: array [TLoggerLevel] of TLogLevel;

type

  TLog4DAnonymousAppender = class(TLogCustomAppender)
  strict private
    FAppender: TLoggerAppender;
  protected
    procedure DoAppend(const Message: string); override;
  public
    constructor Create(pAppender: TLoggerAppender); reintroduce;
    destructor Destroy; override;
  end;

  TLog4DLoggingAdapter = class(TDriverLogging, ILogging)
  strict private
    FLogLogger: TLogLogger;
  protected
    procedure DoLog(const pLevel: TLoggerLevel; pLogger: ILogger); override;
  public
    constructor Create(const pIdentifier, pConfigFileName: string; pAppender: TLoggerAppender = nil);
  end;

procedure RegisterLog4DLevels();
begin
  _vLog4DLevels[TLoggerLevel.Off] := Log4D.Off;
  _vLog4DLevels[TLoggerLevel.Fatal] := Log4D.Fatal;
  _vLog4DLevels[TLoggerLevel.Error] := Log4D.Error;
  _vLog4DLevels[TLoggerLevel.Warn] := Log4D.Warn;
  _vLog4DLevels[TLoggerLevel.Info] := Log4D.Info;
  _vLog4DLevels[TLoggerLevel.Debug] := Log4D.Debug;
  _vLog4DLevels[TLoggerLevel.Trace] := Log4D.Trace;
  _vLog4DLevels[TLoggerLevel.All] := Log4D.All;
end;

function LoggerLevelToLog4DLevel(const pLoggerLevel: TLoggerLevel): TLogLevel;
begin
  Result := _vLog4DLevels[pLoggerLevel];
end;

{ TLog4DAnonymousAppender }

constructor TLog4DAnonymousAppender.Create(pAppender: TLoggerAppender);
begin
  inherited Create(EmptyStr);
  FAppender := pAppender;
end;

destructor TLog4DAnonymousAppender.Destroy;
begin
  FAppender := nil;
  inherited;
end;

procedure TLog4DAnonymousAppender.DoAppend(const Message: string);
begin
  if Assigned(FAppender) then
    FAppender(Message);
end;

{ TLog4DLoggingAdapter }

constructor TLog4DLoggingAdapter.Create(const pIdentifier, pConfigFileName: string;
  pAppender: TLoggerAppender);
begin
  if pIdentifier.IsEmpty then
    raise ELoggerException.Create('Log Identifier Undefined!');

  if pConfigFileName.IsEmpty then
    raise ELoggerException.Create('Log Configuration File Name Undefined!');

  DefaultHierarchy.ResetConfiguration;

  TLogPropertyConfigurator.Configure(pConfigFileName);

  FLogLogger := TLogLogger.GetLogger(pIdentifier);

  if Assigned(pAppender) then
    FLogLogger.AddAppender(TLog4DAnonymousAppender.Create(pAppender));
end;

procedure TLog4DLoggingAdapter.DoLog(const pLevel: TLoggerLevel; pLogger: ILogger);
var
  vMsg: string;
  vKeywords: string;
begin
  inherited;
  vMsg := 'Log';

  vKeywords := TLoggerUtil.KeywordsToString(pLogger.GetKeywords);
  if (vKeywords <> EmptyStr) then
    vMsg := vMsg + ' | Keywords:' + vKeywords;

  if (pLogger.GetOwner <> EmptyStr) then
    vMsg := vMsg + ' | Owner:' + pLogger.GetOwner;

  if (pLogger.GetMessage <> EmptyStr) then
    vMsg := vMsg + ' | Message:' + pLogger.GetMessage;

  if (pLogger.GetMarker <> nil) and (pLogger.GetMarker.GetName <> EmptyStr) then
    vMsg := vMsg + ' | Marker:' + pLogger.GetMarker.GetName;

  if (pLogger.GetException <> nil) then
    vMsg := vMsg + ' | Exception:' + pLogger.GetException.ToString;

  FLogLogger.Log(LoggerLevelToLog4DLevel(pLevel), vMsg, pLogger.GetException);
end;

{ TLog4DLoggingFactory }

class function TLog4DLoggingFactory.Build(const pIdentifier, pConfigFileName: string;
  pAppender: TLoggerAppender): ILogging;
begin
  Result := TLog4DLoggingAdapter.Create(pIdentifier, pConfigFileName, pAppender);
end;

constructor TLog4DLoggingFactory.Create;
begin
  raise ELoggerException.Create(CanNotBeInstantiatedException);
end;

initialization

RegisterLog4DLevels();

RegisterAppender(TLog4DAnonymousAppender);

end.
