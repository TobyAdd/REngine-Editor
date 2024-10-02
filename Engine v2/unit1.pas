unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Grids, StdCtrls,
  ComCtrls, lclintf;

type

  { TFormMain }

  TFormMain = class(TForm)
    MainMenu: TMainMenu;
    MenuItemMoveItemUp: TMenuItem;
    MenuItemMoveItemDown: TMenuItem;
    MenuItemItemAdd: TMenuItem;
    MenuItemRemoveItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    MenuItemFIle: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemAbout: TMenuItem;
    Separator1: TMenuItem;
    StringGridInputs: TStringGrid;
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemMoveItemUpClick(Sender: TObject);
    procedure MenuItemMoveItemDownClick(Sender: TObject);
    procedure MenuItemItemAddClick(Sender: TObject);
    procedure MenuItemOpenClick(Sender: TObject);
    procedure MenuItemRemoveItemClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
  private

  public
    procedure SaveReplay(const ReplayName: String);
  	procedure LoadReplay(const ReplayName: String);
  end;

  TReplayData2 = record
    Frame: Cardinal;
    Hold: Boolean;
    Button: Integer;
    Player: Boolean;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.SaveReplay(const ReplayName: String);
var
  I: Integer;
  FileStream: TFileStream;
  Replay2Size: Cardinal;
  Replay2: array of TReplayData2;
  Header: AnsiString;
begin
  FileStream := nil;
  try
    FileStream := TFileStream.Create(ReplayName, fmCreate);

    Header := 'RE2';
    FileStream.WriteBuffer(PAnsiChar(Header)^, Length(Header));

    Replay2Size := StringGridInputs.RowCount - 1;
    FileStream.WriteBuffer(Replay2Size, SizeOf(Replay2Size));

    SetLength(Replay2, Replay2Size);
    for I := 0 to Replay2Size - 1 do
    begin
      Replay2[I].Frame := StrToInt(StringGridInputs.Cells[0, I+1]);
      Replay2[I].Hold := StrToBool(StringGridInputs.Cells[1, I+1]);
      Replay2[I].Button := StrToInt(StringGridInputs.Cells[2, I+1]);
      Replay2[I].Player := StrToBool(StringGridInputs.Cells[3, I+1]);
    end;

    FileStream.WriteBuffer(Replay2[0], SizeOf(TReplayData2) * Replay2Size);

  finally
    FileStream.Free;
  end;
end;

procedure TFormMain.LoadReplay(const ReplayName: String);
var
  I: Integer;
  FileStream: TFileStream;
  Replay2Size: Cardinal;
  Replay2: array of TReplayData2;
  Header: AnsiString;
  FileHeader: array[0..2] of AnsiChar;
begin
  FileStream := nil;
  try
    FileStream := TFileStream.Create(ReplayName, fmOpenRead);

    FileStream.ReadBuffer(FileHeader, SizeOf(FileHeader));
    Header := 'RE2';
    if String(FileHeader) <> Header then begin
      MessageDlg('Error', 'Invalid Replay Format', mtError, [mbOK], 0);
    end else begin
      FileStream.ReadBuffer(Replay2Size, SizeOf(Replay2Size));
    	StringGridInputs.RowCount := Replay2Size + 1;

    	SetLength(Replay2, Replay2Size);

    	FileStream.ReadBuffer(Replay2[0], SizeOf(TReplayData2) * Replay2Size);
    	for I := 0 to High(Replay2) do
    	begin
    	  with Replay2[I] do
    	  begin
    	    StringGridInputs.Cells[0, I+1] := IntToStr(Frame);
    	    StringGridInputs.Cells[1, I+1] := BoolToStr(Hold, True);
    	    StringGridInputs.Cells[2, I+1] := IntToStr(Button);
    	    StringGridInputs.Cells[3, I+1] := BoolToStr(Player, True);
    	  end;
    	end;
    end;
  finally
    FileStream.Free;
  end;
end;

procedure TFormMain.MenuItemOpenClick(Sender: TObject);
var
  LocalAppData: string;
  MacroDirectoryPath: string;
begin
  LocalAppData := GetEnvironmentVariable('LOCALAPPDATA');
  MacroDirectoryPath := LocalAppData + '\GeometryDash\geode\mods\tobyadd.gdh\Macros';
  if DirectoryExists(MacroDirectoryPath) then
  	OpenDialog.InitialDir := MacroDirectoryPath;

  if OpenDialog.Execute then begin
  	LoadReplay(OpenDialog.FileName);
    Caption := ExtractFileName(OpenDialog.FileName) + ' - RE Macro Editor v2';
  end;
end;

procedure TFormMain.MenuItemSaveClick(Sender: TObject);
var
  LocalAppData: string;
  MacroDirectoryPath: string;
begin
  LocalAppData := GetEnvironmentVariable('LOCALAPPDATA');
  MacroDirectoryPath := LocalAppData + '\GeometryDash\geode\mods\tobyadd.gdh\Macros';
  if DirectoryExists(MacroDirectoryPath) then
  	SaveDialog.InitialDir := MacroDirectoryPath;

  if SaveDialog.Execute then begin
  	SaveReplay(SaveDialog.FileName);
    Caption := ExtractFileName(SaveDialog.FileName) + ' - RE Macro Editor v2';
  end;
end;

procedure AddRow(Grid: TStringGrid; RowIndex: Integer);
var
  i, j: Integer;
begin
  if (RowIndex < 0) or (RowIndex > Grid.RowCount) then
    Exit;

  Grid.RowCount := Grid.RowCount + 1;

  for i := Grid.RowCount - 2 downto RowIndex do
    for j := 0 to Grid.ColCount - 1 do
      Grid.Cells[j, i + 1] := Grid.Cells[j, i];

  for j := 0 to Grid.ColCount - 1 do
    Grid.Cells[j, RowIndex] := '';

  Application.ProcessMessages;
end;


procedure RemoveRow(Grid: TStringGrid; RowIndex: Integer);
var
  i, j: Integer;
begin
  if (RowIndex < 1) or (RowIndex >= Grid.RowCount) then
    Exit;

  for i := RowIndex to Grid.RowCount - 2 do
    for j := 0 to Grid.ColCount - 1 do
      Grid.Cells[j, i] := Grid.Cells[j, i + 1];

  Grid.RowCount := Grid.RowCount - 1;

  Application.ProcessMessages;
end;

procedure MoveRowUp(Grid: TStringGrid; RowIndex: Integer);
var
  i, j: Integer;
  Temp: string;
begin
  if (RowIndex <= 1) or (RowIndex >= Grid.RowCount) then
    Exit;

  for j := 0 to Grid.ColCount - 1 do
  begin
    Temp := Grid.Cells[j, RowIndex];
    Grid.Cells[j, RowIndex] := Grid.Cells[j, RowIndex - 1];
    Grid.Cells[j, RowIndex - 1] := Temp;
  end;

  Grid.Row := Grid.Row - 1;
end;

procedure MoveRowDown(Grid: TStringGrid; RowIndex: Integer);
var
  j: Integer;
  Temp: string;
begin
  if (RowIndex < 1) or (RowIndex >= Grid.RowCount - 1) then
    Exit;

  for j := 0 to Grid.ColCount - 1 do
  begin
    Temp := Grid.Cells[j, RowIndex];
    Grid.Cells[j, RowIndex] := Grid.Cells[j, RowIndex + 1];
    Grid.Cells[j, RowIndex + 1] := Temp;
  end;

  Grid.Row := Grid.Row + 1;
end;

procedure TFormMain.MenuItemItemAddClick(Sender: TObject);
begin
  AddRow(StringGridInputs, StringGridInputs.Row);
end;

procedure TFormMain.MenuItemRemoveItemClick(Sender: TObject);
begin
  RemoveRow(StringGridInputs, StringGridInputs.Row);
end;

procedure TFormMain.MenuItemMoveItemUpClick(Sender: TObject);
begin
  MoveRowUp(StringGridInputs, StringGridInputs.Row);
end;

procedure TFormMain.MenuItemExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MenuItemAboutClick(Sender: TObject);
begin
  OpenURL('https://discord.gg/ahYEz4MAwP');
end;

procedure TFormMain.MenuItemMoveItemDownClick(Sender: TObject);
begin
  MoveRowDown(StringGridInputs, StringGridInputs.Row);
end;


end.

