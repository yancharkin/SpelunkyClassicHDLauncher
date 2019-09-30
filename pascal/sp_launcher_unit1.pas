unit sp_launcher_unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Process, DefaultTranslator, LazUtf8;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  picture: TPicture;
  SettingsCfg: TStringList;
  sr: TSearchRec;
  LangList: TStringList;
  i: Integer;
  AssetsPath : String;
  VideoMode : String;
  Language : String;
  SettingsFile : TextFile;
resourcestring

  TextWindowed = 'windowed';
  TextFullscreen = 'fullscreen';

implementation

{$R *.lfm}

{ TForm1 }

function OS : String;
begin

  {$IFDEF Linux}
  OS := 'Linux'
  {$ENDIF}

  {$IFDEF WINDOWS}
  OS := 'Windows'
  {$ENDIF}

end;

function SaveConf(Mode, Lang : String) : Integer;
begin

  SettingsCfg := TStringList.Create;
  SettingsCfg.LoadFromFile(AssetsPath + 'settings.cfg');

  AssignFile(SettingsFile, AssetsPath + 'settings.cfg');
  rewrite(SettingsFile);

  for i := 0 to SettingsCfg.Count-1 do

    begin

      if i = 0 then

        begin
          writeln(SettingsFile, Mode);
        end

      else

        if i <> SettingsCfg.Count-1 then

          begin
            writeln(SettingsFile, SettingsCfg[i]);
          end

        else
          writeln(SettingsFile, Lang);

    end;

  CloseFile(SettingsFile);
  SettingsCfg.Free;

  SaveConf := 0;

end;

procedure TForm1.FormCreate(Sender: TObject);

begin

  ComboBox1.Items.Add(TextWindowed);
  ComboBox1.Items.Add(TextFullscreen);

  if OS = 'Linux' then
    begin
     Label1.Height := 36;
     Label2.Height := 36;
     AssetsPath := 'game/assets/'
    end
  else
    begin
      Label1.Height := 23;
      Label2.Height := 23;
      AssetsPath := 'game/'
    end;

  picture:=TPicture.Create;
  picture.LoadFromFile('launcher.jpg');
  Image1.Picture.Assign(picture);

  SettingsCfg := TStringList.Create;
  SettingsCfg.LoadFromFile(AssetsPath + 'settings.cfg');
  VideoMode := SettingsCfg[0];
  Language := SettingsCfg[SettingsCfg.Count - 1];

  SettingsCfg.Free;

  ComboBox1.ItemIndex := StrToInt(VideoMode);

  LangList := TStringList.Create;
  LangList.Add('english');
  if FindFirst(AssetsPath + 'translations/*',faAnyFile,sr)=0 then
    repeat
      if sr.Name <> '.' then
        if sr.Name <> '..' then
           LangList.Add(sr.Name);
    until FindNext(sr) <> 0;
  FindClose(sr);

  ComboBox2.ItemIndex := 0;
  for i := 0 to LangList.Count-1 do
    begin
      ComboBox2.Items.Add(LangList[i]);
      if LangList[i] = Language then
        ComboBox2.ItemIndex := i;
    end;

end;

procedure TForm1.Button2Click(Sender: TObject);

var
  AProcess: TProcess;

begin

  SaveConf(ComboBox1.ItemIndex.ToString, ComboBox2.Items[ComboBox2.ItemIndex]);

  Form1.Hide;

  AProcess := TProcess.Create(nil);

  if OS = 'Linux' then
    begin
     AProcess.Executable:= 'game/spelunky';
    end
  else
    begin
     AProcess.Executable:= 'game/spelunky.exe';
  end;

  AProcess.Execute;
  AProcess.Free;
  Application.Terminate;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  SaveConf(ComboBox1.ItemIndex.ToString, ComboBox2.Items[ComboBox2.ItemIndex]);
  Application.Terminate;
end;

end.

