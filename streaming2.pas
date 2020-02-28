{
 /***************************************************************************
                                   streaming2.pas
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
  |$Date: 2018-06-12 23:40:14 +0200 (Di, 12 Jun 2018) $ (letzter Aenderungszeitpunkt)
  |$Revision: 2823 $ (letzter geaenderte Revision)
  |$Author: andreas $ (letzter Autor)
  |$HeadURL: svn://martina:3691/Lazarus/packages/streams/streaming2.pas $ (Archivadresse)
  |$Id: streaming2.pas 2823 2018-06-12 21:40:14Z andreas $ (eindeutige Dateikennzeichnung)
}
unit Streaming2;

{$mode objfpc}{$H+}

interface

uses
  Classes;

procedure ReadBinaryFromStream(AStream: TStream; var RootComponent: TComponent);

procedure ReadBinaryFromFile(FileName: string; var RootComponent: TComponent);

procedure WriteBinaryToStream(AStream: TStream; AComponent: TComponent);

procedure WriteBinaryToFile(FileName: string; RootComponent: TComponent);

procedure RegisterForStreaming(AComponentClass: TComponentClass);

implementation

uses StreamBase;

procedure ReadBinaryFromStream(AStream: TStream; var RootComponent: TComponent);
var
  Reader: TRegisteredComponentReader;
begin
  Reader := TRegisteredComponentReader.Create(AStream, FilerBufferSize);
  try
    Reader.IgnoreChildren := True;
    Reader.OnFindComponentClass := @Reader.FindComponentClass;
    if RootComponent = nil then
      RootComponent := Reader.ReadRootComponent(RootComponent)
    else begin
      Reader.ReadRootComponent(RootComponent)
    end;
  finally
    Reader.Free
  end;
end;

procedure ReadBinaryFromFile(FileName: string; var RootComponent: TComponent);
var
  S: TFileStream;
begin
  S := TFileStream.Create(FileName, fmOpenRead);
  try
    ReadBinaryFromStream(S, RootComponent);
  finally
    S.Free
  end;
end;

procedure WriteBinaryToStream(AStream: TStream; AComponent: TComponent);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(AStream, FilerBufferSize);
  try
    Writer.WriteDescendent(AComponent, nil);
  finally
    Writer.Free
  end;
end;

procedure WriteBinaryToFile(FileName: string; RootComponent: TComponent);
var
  S: TFileStream;
begin
  S := TFileStream.Create(FileName, fmCreate);
  try
    WriteBinaryToStream(S, RootComponent);
  finally
    S.Free
  end
end;

procedure RegisterForStreaming(AComponentClass: TComponentClass);
begin
  StreamableClasses[AComponentClass.ClassName] := AComponentClass
end;

end.

