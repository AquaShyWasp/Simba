{
	This file is part of the Mufasa Macro Library (MML)
	Copyright (c) 2009-2012 by Raymond van Venetië and Merlijn Wajer

    MML is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MML is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MML.  If not, see <http://www.gnu.org/licenses/>.

	See the file COPYING, included in this distribution,
	for details about the copyright.

    Client class for the Mufasa Macro Library
}
unit simba.client;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simba.mufasatypes,
  simba.iomanager, simba.files, simba.finder, simba.bitmap, simba.dtm, simba.ocr, simba.internet;

(*

Client Class
============

The ``TClient`` class is the class that glues all other MML classes together
into one usable class. Internally, quite some MML classes require other MML
classes, and they access these other classes through their "parent"
``TClient``
class.

An image tells more than a thousands words:

    .. image:: ../../Pics/Client_Classes.png


    And the class dependency graph: (An arrow indicates a dependency)

    .. image:: ../../Pics/client_classes_dependencies.png

    The client class does not do much else except creating the classes when it
    is
    created and destroying the classes when it is being destroyed. 

*)

type

  TClient = class(TObject)
  private
    FOwnIOManager: Boolean;
  public
    IOManager: TIOManager;
    MFiles: TMFiles;
    MFinder: TMFinder;
    MBitmaps: TMBitmaps;
    MDTMs: TMDTMS;
    MOCR: TMOCR;
    MInternets: TMInternet;
    MSockets: TMSocks;

    constructor Create(const plugin_dir: string = ''; const UseIOManager: TIOManager = nil);
    destructor Destroy; override;
  end;

(*
  Properties:

      - IOManager
      - MFiles
      - MFinder
      - MBitmaps
      - MDTMs
      - MOCR
      - WriteLnProc
*)

implementation

(*

TClient.Create
~~~~~~~~~~~~~~

.. code-block:: pascal

  constructor TClient.Create(const plugin_dir: string = ''; const UseIOManager : TIOManager = nil);

*)

// Possibly pass arguments to a default window.
constructor TClient.Create(const plugin_dir: string = ''; const UseIOManager : TIOManager = nil);
begin
  inherited Create;

  if UseIOManager = nil then
    IOManager := TIOManager.Create(plugin_dir)
  else
    IOManager := UseIOManager;

  FOwnIOManager := (UseIOManager = nil);

  MFiles := TMFiles.Create(self);
  MFinder := TMFinder.Create(Self);
  MBitmaps := TMBitmaps.Create(Self);
  MDTMs := TMDTMS.Create(Self);
  MOCR := TMOCR.Create(Self);
  MInternets := TMInternet.Create(Self);
  MSockets := TMSocks.Create(Self);
end;

(*

TClient.Destroy
~~~~~~~~~~~~~~~

.. code-block:: pascal

    destructor TClient.Destroy;

*)

destructor TClient.Destroy;
begin

  MOCR.Free;
  MDTMs.Free;
  MBitmaps.Free;
  MFinder.Free;
  MFiles.Free;
  MInternets.Free;
  MSockets.Free;
  if FOwnIOManager then
    IOManager.Free;

  inherited;
end;

end.

