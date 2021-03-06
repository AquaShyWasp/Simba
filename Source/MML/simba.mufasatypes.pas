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

    Type declarations for the Mufasa Macro Library
}

unit simba.mufasatypes;

{$mode objfpc}{$H+}
{$i simba.inc}

interface

uses
  Classes, SysUtils, Graphics;

type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B, G, R : byte;
  end;

  PPRGB32 = ^PRGB32;
  PRGB32 = ^TRGB32;
  TRGB32 = packed record
    B, G, R, A: Byte;
  end;

  TARGB32 = packed record A, R, G, B: Byte; end;
  PARGB32 = ^TARGB32;

  PRGB32Array = ^TRGB32Array;
  TRGB32Array = array of TRGB32;

  PPRGB32Array = ^TPRGB32Array;
  TPRGB32Array = array of PRGB32; //array of Pointers

  THSL = packed record
    H, S, L: extended;
  end;
  PHSL = ^THSL;

  PHSLArray = ^THSLArray;
  THSLArray = array of THSL;
  P2DHSLArray = ^T2DHSLArray;
  T2DHSLArray = array of array of THSL;

  TRetData = record
    Ptr: PRGB32;
    IncPtrWith: Integer;
    RowLen: Integer;
  end;

const
  NullReturnData: TRetData = (Ptr: nil; IncPtrWith: -1; RowLen: -1);

operator =(Left, Right: TRetData): Boolean; inline;
operator =(Left, Right: TRGB32): Boolean; inline;

type
  PStrings = ^TStrings;
  PFont = ^TFont;
  PColor = ^TColor;
  PCanvas = ^TCanvas;

  TClickType = (
    MOUSE_RIGHT,
    MOUSE_LEFT,
    MOUSE_MIDDLE,
    MOUSE_EXTRA_1,
    MOUSE_EXTRA_2,
    MOUSE_SCROLL_UP,
    MOUSE_SCROLL_DOWN
  );

  TMousePress = (MOUSE_DOWN, MOUSE_UP);

  PStringArray = ^TStringArray;
  TStringArray = array of String;
  P2DStringArray = ^T2DStringArray;
  T2DStringArray = array of TStringArray;

  PPoint = ^TPoint;

  PPointArray = ^TPointArray;
  TPointArray = array of TPoint;
  P2DPointArray = ^T2DPointArray;
  T2DPointArray = array of TPointArray;

  TVariantArray = array of Variant;
  PVariantArray = ^TVariantArray;

  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array of Integer;
  T2DIntegerArray = array of TIntegerArray;
  P2DIntegerArray = ^T2DIntegerArray;

  PByteArray = ^TByteArray;
  TByteArray = array of Byte;
  P2DByteArray = ^T2DByteArray;
  T2DByteArray = array of TByteArray;

  TByteMatrix = T2DByteArray;

  TBoolArray = array of boolean;
  TBooleanArray = TBoolArray;
  T2DBoolArray = array of TBoolArray;

  PExtendedArray = ^TExtendedArray;
  TExtendedArray = array of Extended;
  P2DExtendedArray = ^T2DExtendedArray;
  T2DExtendedArray = array of array of Extended;

  PSingleArray  = ^TSingleArray;
  TSingleArray  = array of Single;
  PSingleMatrix = ^TSingleMatrix;
  TSingleMatrix = array of TSingleArray;

  TSingleMatrix_Helper = type Helper for TSingleMatrix
    function Width: Int32; inline;
    function Height: Int32; inline;
  end;

  TDoubleArray = array of Double;
  T2DDoubleArray = array of TDoubleArray;

  TDoubleMatrix = T2DDoubleArray;

  TDoubleMatrix_Helper = type Helper for TDoubleMatrix
    function Width: Int32; inline;
    function Height: Int32; inline;
  end;

  PIntegerMatrix = ^TIntegerMatrix;
  TIntegerMatrix = array of TIntegerArray;

  TIntegerMatrix_Helper = type Helper for TIntegerMatrix
    function Width: Int32; inline;
    function Height: Int32; inline;
  end;

  TByteMatrix_Helper = type Helper for TByteMatrix
    function Width: Int32; inline;
    function Height: Int32; inline;
  end;

  TComplex = packed record
    Re, Im: Single;
  end;

  TComplexArray   = array of TComplex;
  T2DComplexArray = array of TComplexArray;

  TComplexMatrix = T2DComplexArray;

  TComplexMatrix_Helper = type Helper for TComplexMatrix
    function Width: Int32; inline;
    function Height: Int32; inline;
  end;

  EComparator = (__LT__, __GT__, __EQ__, __LE__, __GE__, __NE__);

  { Mask Types }
  PMask = ^TMask;
  TMask = record
    White, Black : TPointArray;
    WhiteHi,BlackHi : integer;
    W,H : integer;
  end;

  { File types }
  TMufasaFile = record
    Path: String;
    FS: TFileStream;
    BytesRead, Mode: Integer;
  end;
  TMufasaFilesArray = array of TMufasaFile;

  PBox = ^TBox;
  TBox = record
    X1, Y1, X2, Y2: Integer;
  end;

  { TBoxHelper }

  TBoxHelper = record Helper for TBox
  protected
    function GetWidth: Int32;
    function GetHeight: Int32;
  public
    function Expand(Amount: Int32): TBox;
    function Contains(X, Y, Width, Height: Int32): Boolean; overload;
    function Contains(X, Y: Int32): Boolean; overload;
    property Width: Int32 read GetWidth;
    property Height: Int32 read GetHeight;
  end;

  function Box(constref X1, Y1, X2, Y2: Int32): TBox;

type
  TSysProc = record
    Title: WideString;
    Handle: UInt32;
    PID: UInt32;
    Width, Height: integer;
  end;
  TSysProcArr = array of TSysProc;
  PSysProcArr = ^TSysProcArr;
  PSysProc = ^TSysProc;

const
  TMDTMPointSize = 5*SizeOf(integer)+Sizeof(boolean);
type
  TMDTMPoint = record //TMufasaDTMPoint
    x,y,c,t,asz : integer;
    bp : boolean;
  end;

  PMDTMPoint = ^TMDTMPoint; //PointerMufasaDTMPoint
  TMDTMPointArray = array of TMDTMPoint; //TMufasaDTMPointArray


  { Other DTM Types }

  TSDTMPointDef = record
    x, y, Color, Tolerance, AreaSize, AreaShape: integer;
  end;

  TSDTMPointDefArray = array of TSDTMPointDef;

  PSDTM = ^TSDTM;
  TSDTM = record
    MainPoint: TSDTMPointDef;
    SubPoints: TSDTMPointDefArray;
  end;

type
  VirtualKeyInfo = record
    Str : string;
    Key : byte;
  end;

  TOCRFilterData = packed record
      _type: integer;
      is_text_color: boolean;

      r_low,r_high,g_low,g_high,b_low,b_high,set_col: integer;

      ref_color,tol,cts: integer;
  end;

  POCRFilterData = ^TOCRFilterData;

  TOcrFilterDataArray = array of TOCRFilterData;
  POcrFilterDataArray = ^TOCRFilterDataArray;

var
  VirtualKeys : array[0..173] of VirtualKeyInfo = (
                (str :'UNKNOWN'; key :  0),
                (str :'LBUTTON'; key :  1),
                (str :'RBUTTON'; key :  2),
                (str :'CANCEL'; key :  3),
                (str :'MBUTTON'; key :  4),
                (str :'XBUTTON1'; key :  5),
                (str :'XBUTTON2'; key :  6),
                (str :'BACK'; key :  8),
                (str :'TAB'; key :  9),
                (str :'CLEAR'; key :  12),
                (str :'RETURN'; key :  13),
                (str :'SHIFT'; key :  16),
                (str :'CONTROL'; key :  17),
                (str :'MENU'; key :  18),
                (str :'PAUSE'; key :  19),
                (str :'CAPITAL'; key :  20),
                (str :'KANA'; key :  21),
                (str :'HANGUL'; key :  21),
                (str :'JUNJA'; key :  23),
                (str :'FINAL'; key :  24),
                (str :'HANJA'; key :  25),
                (str :'KANJI'; key :  25),
                (str :'ESCAPE'; key :  27),
                (str :'CONVERT'; key :  28),
                (str :'NONCONVERT'; key :  29),
                (str :'ACCEPT'; key :  30),
                (str :'MODECHANGE'; key :  31),
                (str :'SPACE'; key :  32),
                (str :'PRIOR'; key :  33),
                (str :'NEXT'; key :  34),
                (str :'END'; key :  35),
                (str :'HOME'; key :  36),
                (str :'LEFT'; key :  37),
                (str :'UP'; key :  38),
                (str :'RIGHT'; key :  39),
                (str :'DOWN'; key :  40),
                (str :'SELECT'; key :  41),
                (str :'PRINT'; key :  42),
                (str :'EXECUTE'; key :  43),
                (str :'SNAPSHOT'; key :  44),
                (str :'INSERT'; key :  45),
                (str :'DELETE'; key :  46),
                (str :'HELP'; key :  47),
                (str :'0'; key :  $30),
                (str :'1'; key :  $31),
                (str :'2'; key :  $32),
                (str :'3'; key :  $33),
                (str :'4'; key :  $34),
                (str :'5'; key :  $35),
                (str :'6'; key :  $36),
                (str :'7'; key :  $37),
                (str :'8'; key :  $38),
                (str :'9'; key :  $39),
                (str :'A'; key :  $41),
                (str :'B'; key :  $42),
                (str :'C'; key :  $43),
                (str :'D'; key :  $44),
                (str :'E'; key :  $45),
                (str :'F'; key :  $46),
                (str :'G'; key :  $47),
                (str :'H'; key :  $48),
                (str :'I'; key :  $49),
                (str :'J'; key :  $4A),
                (str :'K'; key :  $4B),
                (str :'L'; key :  $4C),
                (str :'M'; key :  $4D),
                (str :'N'; key :  $4E),
                (str :'O'; key :  $4F),
                (str :'P'; key :  $50),
                (str :'Q'; key :  $51),
                (str :'R'; key :  $52),
                (str :'S'; key :  $53),
                (str :'T'; key :  $54),
                (str :'U'; key :  $55),
                (str :'V'; key :  $56),
                (str :'W'; key :  $57),
                (str :'X'; key :  $58),
                (str :'Y'; key :  $59),
                (str :'Z'; key :  $5A),
                (str :'LWIN'; key :  $5B),
                (str :'RWIN'; key :  $5C),
                (str :'APPS'; key :  $5D),
                (str :'SLEEP'; key :  $5F),
                (str :'NUMPAD0'; key :  96),
                (str :'NUMPAD1'; key :  97),
                (str :'NUMPAD2'; key :  98),
                (str :'NUMPAD3'; key :  99),
                (str :'NUMPAD4'; key :  100),
                (str :'NUMPAD5'; key :  101),
                (str :'NUMPAD6'; key :  102),
                (str :'NUMPAD7'; key :  103),
                (str :'NUMPAD8'; key :  104),
                (str :'NUMPAD9'; key :  105),
                (str :'MULTIPLY'; key :  106),
                (str :'ADD'; key :  107),
                (str :'SEPARATOR'; key :  108),
                (str :'SUBTRACT'; key :  109),
                (str :'DECIMAL'; key :  110),
                (str :'DIVIDE'; key :  111),
                (str :'F1'; key :  112),
                (str :'F2'; key :  113),
                (str :'F3'; key :  114),
                (str :'F4'; key :  115),
                (str :'F5'; key :  116),
                (str :'F6'; key :  117),
                (str :'F7'; key :  118),
                (str :'F8'; key :  119),
                (str :'F9'; key :  120),
                (str :'F10'; key :  121),
                (str :'F11'; key :  122),
                (str :'F12'; key :  123),
                (str :'F13'; key :  124),
                (str :'F14'; key :  125),
                (str :'F15'; key :  126),
                (str :'F16'; key :  127),
                (str :'F17'; key :  128),
                (str :'F18'; key :  129),
                (str :'F19'; key :  130),
                (str :'F20'; key :  131),
                (str :'F21'; key :  132),
                (str :'F22'; key :  133),
                (str :'F23'; key :  134),
                (str :'F24'; key :  135),
                (str :'NUMLOCK'; key :  $90),
                (str :'SCROLL'; key :  $91),
                (str :'LSHIFT'; key :  $A0),
                (str :'RSHIFT'; key :  $A1),
                (str :'LCONTROL'; key :  $A2),
                (str :'RCONTROL'; key :  $A3),
                (str :'LMENU'; key :  $A4),
                (str :'RMENU'; key :  $A5),
                (str :'BROWSER_BACK'; key :  $A6),
                (str :'BROWSER_FORWARD'; key :  $A7),
                (str :'BROWSER_REFRESH'; key :  $A8),
                (str :'BROWSER_STOP'; key :  $A9),
                (str :'BROWSER_SEARCH'; key :  $AA),
                (str :'BROWSER_FAVORITES'; key :  $AB),
                (str :'BROWSER_HOME'; key :  $AC),
                (str :'VOLUME_MUTE'; key :  $AD),
                (str :'VOLUME_DOWN'; key :  $AE),
                (str :'VOLUME_UP'; key :  $AF),
                (str :'MEDIA_NEXT_TRACK'; key :  $B0),
                (str :'MEDIA_PREV_TRACK'; key :  $B1),
                (str :'MEDIA_STOP'; key :  $B2),
                (str :'MEDIA_PLAY_PAUSE'; key :  $B3),
                (str :'LAUNCH_MAIL'; key :  $B4),
                (str :'LAUNCH_MEDIA_SELECT'; key :  $B5),
                (str :'LAUNCH_APP1'; key :  $B6),
                (str :'LAUNCH_APP2'; key :  $B7),
                (str :'OEM_1'; key :  $BA),
                (str :'OEM_PLUS'; key :  $BB),
                (str :'OEM_COMMA'; key :  $BC),
                (str :'OEM_MINUS'; key :  $BD),
                (str :'OEM_PERIOD'; key :  $BE),
                (str :'OEM_2'; key :  $BF),
                (str :'OEM_3'; key :  $C0),
                (str :'OEM_4'; key :  $DB),
                (str :'OEM_5'; key :  $DC),
                (str :'OEM_6'; key :  $DD),
                (str :'OEM_7'; key :  $DE),
                (str :'OEM_8'; key :  $DF),
                (str :'OEM_102'; key :  $E2),
                (str :'PROCESSKEY'; key :  $E7),
                (str :'ATTN'; key :  $F6),
                (str :'CRSEL'; key :  $F7),
                (str :'EXSEL'; key :  $F8),
                (str :'EREOF'; key :  $F9),
                (str :'PLAY'; key :  $FA),
                (str :'ZOOM'; key :  $FB),
                (str :'NONAME'; key :  $FC),
                (str :'PA1'; key :  $FD),
                (str :'OEM_CLEAR'; key :  $FE),

                (str :'HIGHESTVALUE'; key :  $FE),
                (str :'UNDEFINED'; key :  $FF)
                );


implementation

operator =(Left, Right: TRetData): Boolean;
begin
  Result := (Left.Ptr = Right.Ptr) and (Left.RowLen = Right.RowLen) and (Left.IncPtrWith = Right.IncPtrWith);
end;

operator =(Left, Right: TRGB32): Boolean;
begin
  Result := Int32(Left) = Int32(Right);
end;

function TDoubleMatrix_Helper.Width: Int32;
begin
  if Length(Self) > 0 then
    Result := Length(Self[0])
  else
    Result := 0;
end;

function TDoubleMatrix_Helper.Height: Int32;
begin
  Result := Length(Self);
end;

function TComplexMatrix_Helper.Width: Int32;
begin
  if Length(Self) > 0 then
    Result := Length(Self[0])
  else
    Result := 0;
end;

function TComplexMatrix_Helper.Height: Int32;
begin
  Result := Length(Self);
end;

function TSingleMatrix_Helper.Width: Int32;
begin
  if Length(Self) > 0 then
    Result := Length(Self[0])
  else
    Result := 0;
end;

function TSingleMatrix_Helper.Height: Int32;
begin
  Result := Length(Self);
end;

function TByteMatrix_Helper.Width: Int32;
begin
  if Length(Self) > 0 then
    Result := Length(Self[0])
  else
    Result := 0;
end;

function TByteMatrix_Helper.Height: Int32;
begin
  Result := Length(Self);
end;

function TIntegerMatrix_Helper.Width: Int32;
begin
  if Length(Self) > 0 then
    Result := Length(Self[0])
  else
    Result := 0;
end;

function TIntegerMatrix_Helper.Height: Int32;
begin
  Result := Length(Self);
end;

function TBoxHelper.GetWidth: Int32;
begin
  Result := (Self.X2 - Self.X1) + 1;
end;

function TBoxHelper.GetHeight: Int32;
begin
  Result := (Self.Y2 - Self.Y1) + 1;
end;

function TBoxHelper.Expand(Amount: Int32): TBox;
begin
  Result.X1 := Self.X1 - Amount;
  Result.Y1 := Self.Y1 - Amount;
  Result.X2 := Self.X2 + Amount;
  Result.Y2 := Self.Y2 + Amount;
end;

function TBoxHelper.Contains(X, Y, Width, Height: Int32): Boolean;
begin
  Result := (X >= Self.X1) and (Y >= Self.Y1) and (X + Width <= Self.X2) and (Y + Height <= Self.Y2);
end;

function TBoxHelper.Contains(X, Y: Int32): Boolean;
begin
  Result := (X >= Self.X1) and (Y >= Self.Y1) and (X <= Self.X2) and (Y <= Self.Y2);
end;

function Box(constref X1, Y1, X2, Y2: Int32): TBox;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;

end.

