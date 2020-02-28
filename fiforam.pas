{
 /***************************************************************************
                                   fiforam.pas
                                   -----------


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
  |$HeadURL: svn://martina:3691/Lazarus/packages/streams/fiforam.pas $ (Archivadresse)
  |$Id: fiforam.pas 2607 2018-01-08 14:28:51Z andreas $ (eindeutige Dateikennzeichnung)
}
unit FIFORAM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FIFOBuff;

type

{ TFIFORAM }

  TFIFORAM = class(TFIFOBuffer)
  private
    FA, FB: TMemoryStream;
  protected
    function GetA: TStream; override;
    function GetB: TStream; override;
  public
    destructor Destroy; override;
  end;

implementation

{ TFIFORAM }

function TFIFORAM.GetA: TStream;
begin
  if not Assigned(FA) then FA := TMemoryStream.Create;
  Result := FA
end;

function TFIFORAM.GetB: TStream;
begin
  if not Assigned(FB) then FB := TMemoryStream.Create;
  Result := FB;
end;

destructor TFIFORAM.Destroy;
begin
  FA.Free; FB.Free;
  inherited Destroy;
end;

end.

