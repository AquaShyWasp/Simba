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

    Files Class for the Mufasa Macro Library
}

unit simba.files;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simba.mufasatypes;
const
  File_AccesError = -1;
  File_EventError = -2;

type

  { TMFiles }

  TMFiles = class(TObject)
  public
    function CreateFile(Path: string): Integer;
    function OpenFile(Path: string; Shared: Boolean): Integer;
    function RewriteFile(Path: string; Shared: Boolean): Integer;
    function AppendFile(Path: string): Integer;
    function DeleteFile(Filename: string): Boolean;
    function RenameFile(OldName, NewName: string): Boolean;
    procedure CloseFile(FileNum: Integer);
    procedure WriteINI(const Section, KeyName, NewString : string; FileName : string);
    function ReadINI(const Section, KeyName : string; FileName : string) : string;
    procedure DeleteINI(const Section, KeyName : string; FileName : string);
    function EndOfFile(FileNum: Integer): Boolean;
    function FileSizeMuf(FileNum: Integer): LongInt;
    function ReadFileString(FileNum: Integer; out s: string; x: Integer): Boolean;
    function WriteFileString(FileNum: Integer;const s: string): Boolean;
    function SetFileCharPointer(FileNum, cChars, Origin: Integer): Integer;
    function FilePointerPos(FileNum: Integer): Integer;
    constructor Create(Owner : TObject);
    destructor Destroy; override;
  private
    MFiles: TMufasaFilesArray;
    FreeSpots: Array Of Integer;
    Client : TObject;
    procedure CheckFileNum(FileNum : integer);
    procedure FreeFileList;
    function AddFileToManagedList(Path: string; FS: TFileStream; Mode: Integer): Integer;
  end;

  function GetFiles(Path, Ext: string): TStringArray;
  function GetDirectories(Path: string): TstringArray;
  function FindFile(var FileName: string; Extension: String; const Directories: array of String): Boolean;
  function FindPlugin(var FileName: String; const Directories: array of String): Boolean;
  procedure ZipFiles(constref ArchiveFileName: String; constref Files: TStringArray);
  procedure UnZipFile(constref ArchiveFileName, OutputDirectory: String);
  function UnZipOneFile(constref ArchiveFileName, FileName, OutputDirectory: String): Boolean;

  function ReadFile(constref FileName: String): String;
  function WriteFile(constref FileName, Contents: String): Boolean;
  function CreateTempFile(constref Contents, Prefix: String): String;

  function GetSimbaPath: String;
  function GetDataPath: String;
  function GetIncludePath: String;
  function GetPluginPath: String;
  function GetFontPath: String;
  function GetScriptPath: String;
  function GetPackagePath: String;
  function GetOpenSSLBinaryPath: String;

implementation

uses
  Forms,
  IniFiles, FileUtil, LazFileUtils, LazUTF8, Zipper, dynlibs;

function FindFile(var FileName: string; Extension: String; const Directories: array of String): Boolean;
var
  I: Int32;
begin
  Result := False;

  if FileExists(FileName) then
  begin
    FileName := ExpandFileName(FileName);

    Exit(True);
  end;

  for I := 0 to High(Directories) do
    if FileExists(IncludeTrailingPathDelimiter(Directories[I]) + FileName + Extension) then
    begin
      FileName := ExpandFileName(IncludeTrailingPathDelimiter(Directories[I]) + FileName + Extension);

      Exit(True);
    end;
end;

function FindPlugin(var FileName: String; const Directories: array of String): Boolean;
begin
  Result := FindFile(FileName, '', Directories) or
            {$IFDEF CPUAARCH64} 
            FindFile(FileName, '.' + SharedSuffix + '.aarch64', Directories) or
            FindFile(FileName, {$IFDEF CPU32}'32'{$ELSE}'64'{$ENDIF} + '.' + SharedSuffix + '.aarch64', Directories) or
            {$ENDIF}
            FindFile(FileName, '.' + SharedSuffix, Directories) or
            FindFile(FileName, {$IFDEF CPU32}'32'{$ELSE}'64'{$ENDIF} + '.' + SharedSuffix, Directories);
end;

function GetFiles(Path, Ext: string): TStringArray;
var
  SearchRec : TSearchRec;
  c : integer;
begin
  c := 0;
  if FindFirst(Path + '*.' + ext, faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory) = faDirectory then
        Continue;
      inc(c);
      SetLength(Result,c);
      Result[c-1] := SearchRec.Name;
    until FindNext(SearchRec) <> 0;
    SysUtils.FindClose(SearchRec);
  end;
end;

function GetDirectories(Path: string): TStringArray;
var
    SearchRec : TSearchRec;
    c : integer;
begin
  c := 0;
  if FindFirst(Path + '*', faDirectory, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name[1] = '.') or ((SearchRec.Attr and faDirectory) <> faDirectory) then
        continue;
      inc(c);
      SetLength(Result,c);
       Result[c-1] := SearchRec.Name;
    until FindNext(SearchRec) <> 0;
    SysUtils.FindClose(SearchRec);
  end;
end;

procedure UnZipFile(constref ArchiveFileName, OutputDirectory: String);
var
  UnZipper: TUnZipper;
begin
  if (not FileExistsUTF8(ArchiveFileName)) then
    raise Exception.CreateFmt('UnZipFile: Archive "%s" does not exist', [ArchiveFileName]);

  UnZipper := TUnZipper.Create();
  try
    UnZipper.FileName := ArchiveFileName;
    UnZipper.OutputPath := OutputDirectory;
    UnZipper.Examine();
    UnZipper.UnZipAllFiles();
  finally
    UnZipper.Free();
  end;
end;

function UnZipOneFile(constref ArchiveFileName, FileName, OutputDirectory: String): Boolean;
var
  UnZipper: TUnZipper;
  I: Int32;
begin
  Result := False;

  UnZipper := TUnZipper.Create();
  UnZipper.Files.Add(FileName);

  try
    UnZipper.FileName := ArchiveFileName;
    UnZipper.OutputPath := OutputDirectory;
    UnZipper.Examine();

    for I := 0 to UnZipper.Entries.Count - 1 do
      if (UnZipper.Entries[I].ArchiveFileName = FileName) then
      begin
        UnZipper.UnZipAllFiles();

        Result := True;
        Break;
      end;
  finally
    UnZipper.Free();
  end;
end;

procedure ZipFiles(constref ArchiveFileName: String; constref Files: TStringArray);
var
  Zipper: TZipper;
  I: Integer;
begin
  if (Length(Files) = 0) then
    raise Exception.Create('ZipFiles: No files to zip');

  Zipper := TZipper.Create;
  try
    Zipper.FileName := ArchiveFileName;
    for I := 0 to High(Files) do
      Zipper.Entries.AddFileEntry(Files[I], Files[I]);

    Zipper.ZipAllFiles();
  finally
    Zipper.Free;
  end;
end;

function ReadFile(constref FileName: String): String;
var
  Stream: TFileStream;
begin
  Result := '';
  if not FileExists(FileName) then
    Exit;

  Stream := nil;
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);

    SetLength(Result, Stream.Size);
    if Length(Result) > 0 then
      Stream.Read(Result[1], Length(Result));
  except
  end;

  if (Stream <> nil) then
    Stream.Free();
end;

function WriteFile(constref FileName, Contents: String): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;

  Stream := nil;
  try
    Stream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    if Stream.Write(Contents[1], Length(Contents)) = Length(Contents) then
      Result := True;
  except
  end;

  if (Stream <> nil) then
    Stream.Free();
end;

function CreateTempFile(constref Contents, Prefix: String): String;
begin
  Result := GetTempFileName(GetDataPath(), Prefix);

  with TStringList.Create() do
  try
    Text := Contents;

    SaveToFile(Result);
  finally
    Free();
  end;
end;

function GetSimbaPath: String;
begin
  Result := IncludeTrailingPathDelimiter(Application.Location);
end;

function GetDataPath: String;
begin
  Result := GetSimbaPath() + 'Data' + DirectorySeparator;
end;

function GetIncludePath: String;
begin
  Result := GetSimbaPath() + 'Includes' + DirectorySeparator;
end;

function GetPluginPath: String;
begin
  Result := GetSimbaPath() + 'Plugins' + DirectorySeparator;
end;

function GetFontPath: String;
begin
  Result := GetSimbaPath() + 'Fonts' + DirectorySeparator;
end;

function GetScriptPath: String;
begin
  Result := GetSimbaPath() + 'Scripts' + DirectorySeparator;
end;

function GetPackagePath: String;
begin
  Result := GetDataPath() + 'packages' + DirectorySeparator;
end;

function GetOpenSSLBinaryPath: String;
begin
  {$IFDEF WINDOWS}
  Result := GetDataPath() + {$IFDEF CPU32}'32'{$ELSE}'64'{$ENDIF} + DirectorySeparator;
  {$ELSE}
  Result := GetSimbaPath();
  {$ENDIF}
end;

constructor TMFiles.Create(Owner : TObject);
begin
  inherited Create;
  self.Client := Owner;
  SetLength(Self.MFiles, 0);
  SetLength(Self.FreeSpots, 0);
end;

procedure TMFiles.FreeFileList;
var
  I : integer;
begin;
  For I := 0 To High(MFiles) Do
    if MFiles[i].FS <> nil then
    begin
      Writeln(Format('File[%s] has not been freed in the script, freeing it now.',[MFiles[i].Path]));
      try
        MFiles[I].FS.Free;
      except
        Writeln('FreeFileList - Exception when freeing FileStream');
      end;
    end;
  SetLength(MFiles, 0);
  SetLength(FreeSpots, 0);
end;

destructor TMFiles.Destroy;
begin
  FreeFileList;
  inherited;
end;

procedure TMFiles.CheckFileNum(FileNum: integer);
begin
  if(FileNum < 0) or (FileNum >= Length(MFiles)) then
    raise Exception.CreateFmt('Invalid FileNum passed: %d',[FileNum]);
end;

function TMFiles.AddFileToManagedList(Path: String; FS: TFileStream; Mode: Integer): Integer;
var
  tFile: TMufasaFile;
begin
  tFile.Path := Path;
  tFile.FS := FS;
  tFile.Mode := Mode;
  tFile.BytesRead := 0;
  if Length(FreeSpots) > 0 then
  begin
    MFiles[FreeSpots[High(FreeSpots)]] := tFile;
    Result := FreeSpots[High(FreeSpots)];
    SetLength(FreeSpots, High(FreeSpots));
  end else
  begin
    SetLength(MFiles, Length(MFiles) + 1);
    MFiles[High(MFiles)] := tFile;
    Result := High(MFiles);
  end;
end;

function TMFiles.SetFileCharPointer(FileNum, cChars, Origin: Integer): Integer;
begin
  CheckFileNum(FileNum);
  case Origin of
    fsFromBeginning:
                      if(cChars < 0) then
                        raise Exception.CreateFmt('fsFromBeginning takes no negative cChars. (%d)',[cChars]);
    fsFromCurrent:
                  ;
    fsFromEnd:
                  if(cChars > 0) then
                    raise Exception.CreateFmt('fsFromEnd takes no positive cChars. (%d)',[cChars]);
    else
      raise Exception.CreateFmt('Invalid Origin: %d',[Origin]);
  end;

  try
    Result := MFiles[FileNum].FS.Seek(cChars, Origin);
  except
    Writeln('SetFileCharPointer - Exception Occured.');
    Result := File_AccesError;
  end;
  //Result := FileSeek(Files[FileNum].Handle, cChars, Origin);
end;

{/\
  Creates a file for reading/writing.
  Returns the handle (index) to the File Array.
  Returns File_AccesError if unsuccesfull.
/\}

function TMFiles.CreateFile(Path: string): Integer;
var
  FS: TFileStream;
begin
  try
    FS := TFileStream.Create(UTF8ToSys(Path), fmCreate);
    Result := AddFileToManagedList(Path, FS, fmCreate);
  except
    Result := File_AccesError;
    Writeln(Format('CreateFile - Exception. Could not create file: %s',[path]));
  end;
end;

{/\
  Opens a file for reading.
  Returns the handle (index) to the File Array.
  Returns File_AccesError if unsuccesfull.
/\}

function TMFiles.OpenFile(Path: string; Shared: Boolean): Integer;
var
  FS: TFileStream;
  fMode: Integer;
begin
  if Shared then
    fMode := fmOpenRead or fmShareDenyNone
  else
    fMode := fmOpenRead or fmShareExclusive;
  try
      FS := TFileStream.Create(UTF8ToSys(Path), fMode)
  except
    Result := File_AccesError;
    Writeln(Format('OpenFile - Exception. Could not open file: %s',[path]));
    Exit;
  end;
  Result := AddFileToManagedList(Path, FS, fMode);
end;

function TMFiles.AppendFile(Path: string): Integer;
var
  FS: TFileStream;
  fMode: Integer;
begin
  fMode := fmOpenReadWrite;
  if not FileExists(Path) then
    fMode := fMode or fmCreate;
  try
    FS := TFileStream.Create(UTF8ToSys(Path), fMode);
    FS.Seek(0, fsFromEnd);
    Result := AddFileToManagedList(Path, FS, fMode);
  except
    Result := File_AccesError;
    Writeln(Format('AppendFile - Exception. Could not create file: %s',[path]));
  end;
end;

{/\
  Reads key from INI file
/\}

function TMFiles.ReadINI(const Section, KeyName: string; FileName: string): string;
begin
  FileName := ExpandFileNameUTF8(FileName);

  with TINIFile.Create(FileName, True) do
    try
      Result := ReadString(Section, KeyName, '');
    finally
      Free;
  end;
end;

{/\
  Deletes a key from INI file
/\}

procedure TMFiles.DeleteINI(const Section, KeyName : string; FileName : string);
begin; 
  FileName := ExpandFileNameUTF8(FileName);

  with TIniFile.Create(FileName, True) do
    try
      if KeyName = '' then
	    EraseSection(Section)
	  else
		DeleteKey(Section, KeyName);
    finally
      Free;
  end;
end;

{/\
  Writes a key to INI file
/\}

procedure TMFiles.WriteINI(const Section, KeyName, NewString : string; FileName : string);
begin;
  FileName := ExpandFileNameUTF8(FileName);

  with TINIFile.Create(FileName, True) do
    try
	  WriteString(Section, KeyName, NewString);
    finally
	  Free;
  end;
end;

{/\
  Opens a file for writing. And deletes the contents.
  Returns the handle (index) to the File Array.
  Returns File_AccesError if unsuccesfull.
/\}

function TMFiles.RewriteFile(Path: string; Shared: Boolean): Integer;
var
  FS: TFileStream;
  fMode: Integer;
begin
  if Shared then
    fMode := fmOpenReadWrite or fmShareDenyNone  or fmCreate
  else
    fMode := fmOpenReadWrite or fmShareDenyWrite or fmShareDenyRead or fmCreate;
  try
    FS := TFileStream.Create(UTF8ToSys(Path), fMode);
    FS.Size:=0;
    Result := AddFileToManagedList(Path, FS, fMode);
  except
    Result := File_AccesError;
    WriteLn(Format('ReWriteFile - Exception. Could not create file: %s',[path]));
  end;
end;

function TMFiles.DeleteFile(Filename: string): Boolean;
begin
  Result := DeleteFileUTF8(Filename);
end;

function TMFiles.RenameFile(OldName, NewName: string): Boolean;
begin
  Result := RenameFileUTF8(OldName, NewName);
end;

{/\
  Free's the given File at the given index.
/\}
procedure TMFiles.CloseFile(FileNum: Integer);
begin
  CheckFileNum(filenum);
  try
    MFiles[FileNum].FS.Free;
    MFiles[FileNum].FS := nil;
    SetLength(FreeSpots, Length(FreeSpots) + 1);
    FreeSpots[High(FreeSpots)] := FileNum;
  except
    WriteLn(Format('CloseFile, exception when freeing the file: %d',[filenum]));
  end;
end;

{/\
  Returns true if the BytesRead of the given FileNum (Index) has been reached.
  Also returns true if the FileNum is not valid.
/\}

function TMFiles.EndOfFile(FileNum: Integer): Boolean;
begin
  CheckFileNum(filenum);
  if MFiles[FileNum].FS = nil then
  begin
    WriteLn(format('EndOfFile: Invalid Internal Handle of File: %d',[filenum]));
    Result := True;
    Exit;
  end;
  Result := FilePointerPos(FileNum) >= FileSizeMuf(FileNum);
end;

{/\
  Returns the FileSize of the given index (FileNum)
/\}

function TMFiles.FileSizeMuf(FileNum: Integer): LongInt;
begin
  CheckFileNum(filenum);
  if MFiles[FileNum].FS = nil then
  begin
    WriteLn(format('FileSize: Invalid Internal Handle of File: %d',[filenum]));
    Result := File_AccesError;
    Exit;
  end;

  Result := MFiles[FileNum].FS.Size;
end;

function TMFiles.FilePointerPos(FileNum: Integer): Integer;
begin
  CheckFileNum(filenum);
  if MFiles[FileNum].FS = nil then
  begin
    WriteLn(format('FilePointerPos: Invalid Internal Handle of File: %d',[filenum]));
    Result := File_AccesError;
    Exit;
  end;
  try
    Result := MFiles[FileNum].FS.Seek(0, fsFromCurrent);
  except
    WriteLn('Exception in FilePointerPos');
  end;
end;

{/\
  Reads x numbers of characters from a file, and stores it into s.
/\}

function TMFiles.ReadFileString(FileNum: Integer; out s: string; x: Integer): Boolean;
begin
  CheckFileNum(filenum);
  if MFiles[FileNum].FS = nil then
  begin
    WriteLn(format('ReadFileString: Invalid Internal Handle of File: %d',[filenum]));
    Exit;
  end;

  SetLength(S, X);
  Result := MFiles[FileNum].FS.Read(S[1], x) = x;
  {Files[FileNum].BytesRead := Files[FileNum].BytesRead + X;
  FileRead(Files[FileNum].Handle, S[1], X);
  SetLength(S, X); }
end;

{/\
  Writes s in the given File.
/\}

function TMFiles.WriteFileString(FileNum: Integer;const  s: string): Boolean;
begin
  result := false;
  CheckFileNum(filenum);
  if(MFiles[FileNum].FS = nil) then
  begin
    WriteLn(format('WriteFileString: Invalid Internal Handle of File: %d',[filenum]));
    Exit;
  end;
  if (MFiles[FileNum].Mode and (fmOpenWrite or fmOpenReadWrite)) = 0 then //Checks if we have write rights..
    exit;
  try
    Result := MFiles[FileNum].FS.Write(S[1], Length(S)) <> 1;
  except
    WriteLn('Exception - WriteFileString.');
    Result := False;
  end;
end;

end.

