{
 /***************************************************************************
                                   fifobuff.pas
                                   ------------


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus packages by Andreas Jakobsche

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
{ |Subversion-Dokumentation
  |------------------------
  |$Date: 2018-01-08 15:28:51 +0100 (Mo, 08 Jan 2018) $ (letzter Aenderungszeitpunkt)
  |$Revision: 2607 $ (letzter geaenderte Revision)
  |$Author: andreas $ (letzter Autor)
  |$HeadURL: svn://martina:3691/Lazarus/packages/streams/fifobuff.pas $ (Archivadresse)
  |$Id: fifobuff.pas 2607 2018-01-08 14:28:51Z andreas $ (eindeutige Dateikennzeichnung)
}
unit FIFOBuff;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  EFIFOBufferError = class(EStreamError)

  end;

  { TFIFOBuffer }

  TFIFOBuffer = class(TStream)
  protected
    function GetA: TStream; virtual;
    function GetB: TStream; virtual;
  private
    { Private declarations }
    Swapping: Boolean;
    FInput, FOutput: TStream;
    procedure SwapInOut;
    property A: TStream read GetA;
    property B: TStream read GetB;
    property Input: TStream read FInput write FInput;
    property Output: TStream read FOutput write FOutput;
  protected
    { Protected declarations }
    function GetSize: Int64; override;
  public
    { Public declarations }
    constructor Create; virtual;
    function CopyFrom(Source: TStream; Count: Int64): Int64; virtual;
    function MoveTo(Dest: TStream; Count: Int64): Int64; virtual; {Umkehrung von CopyFrom,
      muß anstelle von Dest.CopyFrom verwendet werden wenn Dest nicht von der Klasse
      TFIFOBuffer ist}
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override; overload;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

implementation

{Debug} uses Dialogs;

{ TFIFOBuffer }

function TFIFOBuffer.GetA: TStream;
begin
  raise EFIFOBufferError.Create('Die Methode TFIFOBuffer.GetA muß überschrieben werden');
end;

function TFIFOBuffer.GetB: TStream;
begin
  raise EFIFOBufferError.Create('Die Methode TFIFOBuffer.GetB muß überschrieben werden');
end;

procedure TFIFOBuffer.SwapInOut;
var
  x: TStream;
begin
  Swapping := True;
{ Ringtausch }
  x := Output;
  Output := Input;
  Input := x;
{ Eingabepuffer leeren }
  Input.Position := 0;
  Input.Size := 0;
{ Position im Ausgabepuffer auf Anfang setzen }
  Output.Position := 0;
  Swapping := False;
end;

function TFIFOBuffer.GetSize: Int64;
begin
  Result := Input.Size + Output.Size;
end;

constructor TFIFOBuffer.Create;
begin
  inherited Create;
  Input := A;
  Output := B;
end;

function TFIFOBuffer.CopyFrom(Source: TStream; Count: Int64): Int64;
begin
  if Source = nil then Result := 0
  else begin
    if Count = 0 then Count := Source.Size;
    if Source is TFIFOBuffer then begin
      Result := TFIFOBuffer(Source).MoveTo(Self, Count);
    end
    else
      Result := Input.CopyFrom(Source, Count)
  end
end;

function TFIFOBuffer.MoveTo(Dest: TStream; Count: Int64): Int64;
const
  BufferSize = $FFFF;
var
  Buffer: Pointer;
  ReadSize, WrittenSize: Int64;
begin
  GetMem(Buffer, BufferSize);
  try
    if Count = 0 then Count := Size;
    Result := 0;
    repeat
      try
        if Count > BufferSize then
          ReadSize := Read(Buffer^, BufferSize)
        else
          ReadSize := Read(Buffer^, Count);
        WrittenSize := Dest.Write(Buffer^, ReadSize);
        Result := Result + WrittenSize;
        Count := Count - ReadSize;
      except
        {on EReadError do Result := 0;}
        on E: Exception do ShowMessage(Format('TRAMFIFOBuffer.CopyTo: Output.Read(Buffer^, %d) hat %s ausgelöst', [Count, E.ClassName]));
      end;
    until ReadSize < BufferSize;
  finally
    FreeMem(Buffer, BufferSize)
  end;
end;

function TFIFOBuffer.Read(var Buffer; Count: Longint): Longint;
begin
  while Swapping do;
  Result:= Output.Read(Buffer, Count);
  if Result < Count then
    if Input.Size > 0 then begin
      SwapInOut;
      Result := Result + Output.Read(PByte(@Buffer)[Result], Count - Result)
    end;
end;

function TFIFOBuffer.Seek(Offset: Longint; Origin: Word): Longint;
begin
  raise EFIFOBufferError.Create('TFIFOBuffer.Seek: In einem FIFO-Puffer gibt es keine eindeutige Position.')
end;

function TFIFOBuffer.Write(const Buffer; Count: Longint): Longint;
begin
  while Swapping do;
  Result:= Input.Write(Buffer, Count);
  if Result < Count then
    if Output.Size = 0 then begin
      SwapInOut;
      Result := Result + Input.Write(PByte(@Buffer)[Result], Count - Result);
    end;
end;

end.

