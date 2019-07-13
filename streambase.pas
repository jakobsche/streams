{
 /***************************************************************************
                                 streambase.pas
                                 --------------


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus packages by Andreas Jakobsche

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
{ |Subversion-Dokumentation
  |------------------------
  |$Date: 2018-01-08 15:28:51 +0100 (Mo, 08. Jan 2018) $ (letzter Aenderungszeitpunkt)
  |$Revision: 2607 $ (letzter geaenderte Revision)
  |$Author: andreas $ (letzter Autor)
  |$HeadURL: svn://192.168.2.3:3691/Lazarus/packages/streams/streambase.pas $ (Archivadresse)
  |$Id: streambase.pas 2607 2018-01-08 14:28:51Z andreas $ (eindeutige Dateikennzeichnung)
}
unit StreamBase;

{$mode objfpc}{$H+}

interface

uses
  Classes;

const
  FilerBufferSize = 1024;

type

  { TRegisteredComponentReader }

  TRegisteredComponentReader = class(TReader)
  public
    procedure FindComponentClass(Reader: TReader; const AClassName: string;
      var ComponentClass: TComponentClass); {Klasse aus dem Klassennamen
      ermitteln, z.B. aus der mit RegisterForStreaming erstellten Liste,
      eventuell nicht nötig bei binärem Speichern}
  end;

  { TStreamableClasses }

  TStreamableClasses = class(TList)
  private
    function GetClasses(AClassName: string): TComponentClass;
    procedure SetClasses(AClassName: string; AValue: TComponentClass);
  public
    destructor Destroy; override;
  public
    property Classes[AClassName: string]: TComponentClass read GetClasses
      write SetClasses; default;
  end;

var
  StreamableClasses: TStreamableClasses;

implementation

type

  TStreamableClass = record
    Name: string;
    ClassRef: TComponentClass;
  end;

  PStreamableClass = ^TStreamableClass;

{ TStreamableClasses }

function TStreamableClasses.GetClasses(AClassName: string): TComponentClass;
var i: Integer;
begin
  for i := 0 to Count - 1 do
    if AClassName = PStreamableClass(Items[i])^.Name then begin
      Result := PStreamableClass(Items[i])^.ClassRef;
      Exit
    end;
  Result := nil
end;

procedure TStreamableClasses.SetClasses(AClassName: string;
  AValue: TComponentClass);
var
  x: PStreamableClass;
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if PStreamableClass(Items[i])^.Name = AClassName then begin
      PStreamableClass(Items[i])^.ClassRef := AValue;
      Exit
    end;
  x := New(PStreamableClass);
  x^.Name := AClassname;
  x^.ClassRef := AValue;
  Add(x)
end;

destructor TStreamableClasses.Destroy;
var i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i] <> nil then Dispose(PStreamableClass(Items[i]));
  inherited Destroy;
end;

procedure TRegisteredComponentReader.FindComponentClass(Reader: TReader;
  const AClassName: string; var ComponentClass: TComponentClass);
begin
  ComponentClass := StreamableClasses[AClassName]
end;

initialization

StreamableClasses := TStreamableClasses.Create;

finalization

StreamableClasses.Free;

end.

