unit BinPropStorage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StreamBase;

type

  ISessionData = interface
    property SessionProps: TStrings;
  end;

  { TAppPropStorage }

  TAppPropStorage = class(TComponent)
  private
    FActive, FRestoring, FRestored, FSaving, FSaved: Boolean;
    FReader: TRegisteredComponentReader;
    FWriter: TWriter;
    FStream: TFileStream;
    FFileName: string;
    FSavedOnDestroy: TNotifyEvent;
    procedure BeginRestore;
    procedure BeginSave;
    procedure EndRestore;
    procedure EndSave;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    function GetFileName: string;
    function GetForm: TForm;
    procedure Restore;
    procedure Save;
    procedure SetActive(AValue: Boolean);
  protected

  public
    property Form: TForm read GetForm;
  published
    property Active: Boolean read FActive write SetActive;
    property FileName: string read GetFileName write FFileName;
  end;

procedure Register;

implementation

uses Patch;

procedure Register;
begin
  RegisterComponents('Misc',[TAppPropStorage]);
end;

const
  FBSize = 1024;

{ TAppPropStorage }

procedure TAppPropStorage.BeginRestore;
begin
  FRestoring := True;
  FStream := TFileStream.Create(FileName, fmOpenRead);
  FReader := TRegisteredComponentReader.Create(FStream, FBSize);
end;

procedure TAppPropStorage.BeginSave;
begin
  FSaving := True;
  FStream := TFileStream.Create(FileName, fmCreate);
  FWriter := TWriter.Create(FStream, FBSize);
end;

procedure TAppPropStorage.EndRestore;
begin
  FreeAndNil(FReader);
  FreeAndNil(FStream);
  FRestored := True;
  FRestoring := False;
end;

procedure TAppPropStorage.EndSave;
begin
  FreeAndNil(FWriter);
  FreeAndNil(FStream);
  FSaved := True;
  FSaving := False
end;

procedure TAppPropStorage.FormCreate(Sender: TObject);
begin
  if FileExists(FileName) then Restore
end;

procedure TAppPropStorage.FormDestroy(Sender: TObject);
begin
  Save;
  if Assigned(FSavedOnDestroy) then FSavedOnDestroy(Self)
end;

procedure TAppPropStorage.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if CloseAction = caFree then Save
end;

function TAppPropStorage.GetFileName: string;
begin
  if FFileName = '' then FFileName := BuildFileName(GetAppConfigDir(False), 'session.dat');
  Result := FFilename
end;

function TAppPropStorage.GetForm: TForm;
begin
  Result := Owner as TForm
end;

procedure TAppPropStorage.Restore;
begin
  if not (FRestoring or FRestored or FSaving or FSaved) then begin
    BeginRestore;
    while not FReader.EndOfList do begin
      try
        FReader.ReadRootComponent(nil);
      except
        on Exception do raise;
      end;
    end;
    EndRestore;
  end;
end;

procedure TAppPropStorage.Save;
var
  i: Integer;
begin
  if not (FSaving or FSaved) then begin
    BeginSave;
    FWriter.IgnoreChildren := False;
    FWriter.WriteListBegin;
    for i := 0 to Screen.FormCount - 1 do
      FWriter.WriteRootComponent(Screen.Forms[i]);
    FWriter.WriteListEnd;
    EndSave
  end
end;

procedure TAppPropStorage.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  if not (csDesigning in ComponentState) then
    if AValue then begin
      Form.AddHandlerOnBeforeDestruction(@FormDestroy);
      Form.AddHandlerClose(@FormClose);
      Form.AddHandlerCreate(@FormCreate);
    end
    else begin
      Form.RemoveHandlerCreate(@FormCreate);
      Form.RemoveHandlerClose(@FormClose);
      Form.RemoveHandlerOnBeforeDestruction(@FormDestroy);
    end;
  FActive:=AValue;
end;

end.
