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
    MenuItemChangeTPS: TMenuItem;
    Separator3: TMenuItem;
    MenuItemMoveItemUp: TMenuItem;
    MenuItemMoveItemDown: TMenuItem;
    MenuItemItemAdd: TMenuItem;
    MenuItemRemoveItem: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Separator2: TMenuItem;
    MenuItemFIle: TMenuItem;
    MenuItemEdit: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemPhysics: TMenuItem;
    MenuItemInputs: TMenuItem;
    Separator1: TMenuItem;
    StringGridPhysics: TStringGrid;
    StringGridInputs: TStringGrid;
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemChangeTPSClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemMoveItemUpClick(Sender: TObject);
    procedure MenuItemMoveItemDownClick(Sender: TObject);
    procedure MenuItemInputsClick(Sender: TObject);
    procedure MenuItemItemAddClick(Sender: TObject);
    procedure MenuItemOpenClick(Sender: TObject);
    procedure MenuItemPhysicsClick(Sender: TObject);
    procedure MenuItemRemoveItemClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
  private

  public
    procedure SaveReplay(const ReplayName: String);
  	procedure LoadReplay(const ReplayName: String);
  end;

  TReplayData = record
    Frame: Cardinal;
    X: Single;
    Y: Single;
    Rotation: Single;
    YAccel: Double;
    Player: Boolean;
  end;

  TReplayData2 = record
    Frame: Cardinal;
    Hold: Boolean;
    Button: Integer;
    Player: Boolean;
  end;

var
  FormMain: TFormMain;
  TPS: Single;

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.SaveReplay(const ReplayName: String);
var
  I: Integer;
  FileStream: TFileStream;
  ReplaySize, Replay2Size: Cardinal;
  Replay: array of TReplayData;
  Replay2: array of TReplayData2;
begin
  FileStream := nil;
  try
    FileStream := TFileStream.Create(ReplayName, fmCreate);

    FileStream.WriteBuffer(TPS, SizeOf(TPS));

    ReplaySize := StringGridPhysics.RowCount - 1;
    FileStream.WriteBuffer(ReplaySize, SizeOf(ReplaySize));

    Replay2Size := StringGridInputs.RowCount - 1;
    FileStream.WriteBuffer(Replay2Size, SizeOf(Replay2Size));

    SetLength(Replay, ReplaySize);
    for I := 0 to ReplaySize - 1 do
    begin
      Replay[I].Frame := StrToInt(StringGridPhysics.Cells[0, I+1]);
      Replay[I].X := StrToFloat(StringGridPhysics.Cells[1, I+1]);
      Replay[I].Y := StrToFloat(StringGridPhysics.Cells[2, I+1]);
      Replay[I].Rotation := StrToFloat(StringGridPhysics.Cells[3, I+1]);
      Replay[I].YAccel := StrToFloat(StringGridPhysics.Cells[4, I+1]);
      Replay[I].Player := StrToBool(StringGridPhysics.Cells[5, I+1]);
    end;

    FileStream.WriteBuffer(Replay[0], SizeOf(TReplayData) * ReplaySize);

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
  ReplaySize, Replay2Size: Cardinal;
  Replay: array of TReplayData;
  Replay2: array of TReplayData2;
begin
  FileStream := nil;
  try
    FileStream := TFileStream.Create(ReplayName, fmOpenRead);

    FileStream.ReadBuffer(TPS, SizeOf(TPS));

    FileStream.ReadBuffer(ReplaySize, SizeOf(ReplaySize));
    StringGridPhysics.RowCount := ReplaySize + 1;

    FileStream.ReadBuffer(Replay2Size, SizeOf(Replay2Size));
    StringGridInputs.RowCount := Replay2Size + 1;

    SetLength(Replay, ReplaySize);
    SetLength(Replay2, Replay2Size);

    FileStream.ReadBuffer(Replay[0], SizeOf(TReplayData) * ReplaySize);

    for I := 0 to High(Replay) do
    begin
      with Replay[I] do
      begin
        StringGridPhysics.Cells[0, I+1] := IntToStr(Frame);
        StringGridPhysics.Cells[1, I+1] := FloatToStr(X);
        StringGridPhysics.Cells[2, I+1] := FloatToStr(Y);
        StringGridPhysics.Cells[3, I+1] := FloatToStr(Rotation);
        StringGridPhysics.Cells[4, I+1] := FloatToStr(YAccel);
        StringGridPhysics.Cells[5, I+1] := BoolToStr(Player, True);
      end;
    end;

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
  finally
    FileStream.Free;
  end;
end;

procedure TFormMain.MenuItemPhysicsClick(Sender: TObject);
begin
	MenuItemPhysics.Checked := true;
  MenuItemInputs.Checked := false;

  StringGridPhysics.Visible := true;
  StringGridInputs.Visible := false;
end;

procedure TFormMain.MenuItemInputsClick(Sender: TObject);
begin
	MenuItemPhysics.Checked := false;
  MenuItemInputs.Checked := true;

  StringGridPhysics.Visible := false;
  StringGridInputs.Visible := true;
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
    Caption := ExtractFileName(OpenDialog.FileName) + ' - RE Macro Editor';
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
    Caption := ExtractFileName(SaveDialog.FileName) + ' - RE Macro Editor';
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
  if StringGridPhysics.Visible then begin AddRow(StringGridPhysics, StringGridPhysics.Row); end
  else begin AddRow(StringGridInputs, StringGridInputs.Row); end;
end;

procedure TFormMain.MenuItemRemoveItemClick(Sender: TObject);
begin
  if StringGridPhysics.Visible then begin RemoveRow(StringGridPhysics, StringGridPhysics.Row); end
  else begin RemoveRow(StringGridInputs, StringGridInputs.Row); end;
end;

procedure TFormMain.MenuItemMoveItemUpClick(Sender: TObject);
begin
  if StringGridPhysics.Visible then begin MoveRowUp(StringGridPhysics, StringGridPhysics.Row); end
  else begin MoveRowUp(StringGridInputs, StringGridInputs.Row); end;
end;

procedure TFormMain.MenuItemMoveItemDownClick(Sender: TObject);
begin
  if StringGridPhysics.Visible then begin MoveRowDown(StringGridPhysics, StringGridPhysics.Row); end
  else begin MoveRowDown(StringGridInputs, StringGridInputs.Row); end;
end;

procedure TFormMain.MenuItemExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MenuItemAboutClick(Sender: TObject);
begin
  OpenURL('https://discord.gg/ahYEz4MAwP');
end;

procedure TFormMain.MenuItemChangeTPSClick(Sender: TObject);
var
  inputStr: string;
begin
	try
	  inputStr := InputBox('Chnage TPS', 'Value:', FloatToStr(TPS));
	  TPS := StrToFloat(inputStr);
	except
	  on E: EConvertError do
	    ShowMessage('Invalid input. Please enter a valid floating-point number.');
	end;
end;


end.

