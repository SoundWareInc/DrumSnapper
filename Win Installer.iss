#define AppVer "1.0.0"
#define MyAppName "DrumSnapper"
#define MyCompanyName "SoundWare, Inc."
#define RootDirectory "Builds\VisualStudio2019"

[Setup]
DisableDirPage=yes
ArchitecturesInstallIn64BitMode=x64
AppName={#MyAppName}
AppPublisher={#MyCompanyName}
AppPublisherURL=https://soundware.io/
AppSupportURL=https://help.soundware.io/
AppVerName={#MyAppName} {#AppVer}
AppId={{C1F77E1E-A15B-4EF9-89E0-9F61BEC1DD2D}
AppVersion={#AppVer}
Compression=lzma2/ultra64
DefaultDirName={pf}\{#MyAppName}\
DefaultGroupName={#MyAppName}
DisableReadyPage=true
DisableWelcomePage=yes
LanguageDetectionMethod=uilanguage
OutputBaseFilename={#MyAppName} Win Installer
OutputDir=Builds
ShowLanguageDialog=no
VersionInfoCompany={#MyCompanyName}
VersionInfoCopyright={#MyCompanyName}
VersionInfoDescription={#MyAppName} {#AppVer}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#AppVer}
VersionInfoVersion={#AppVer}

[Files]  
//32-Bit
Source: "{#RootDirectory}\Win32\Release32Bit\VST3\{#MyAppName}.vst3\Contents\x86-win\{#MyAppName}.vst3"; DestDir: "{cf32}\VST3\"; Flags: ignoreversion; Components: VST3 
Source: "{#RootDirectory}\Win32\Release32Bit\VST\{#MyAppName}.dll"; DestDir: "{code:GetVST2Dir|1}"; Flags: ignoreversion; Components: VST 
Source: "{#RootDirectory}\Win32\Release32Bit\Standalone Plugin\{#MyAppName}.exe"; DestDir: "{pf32}\{#MyAppName}"; Flags: ignoreversion; Components: StandAlone 

//64-Bit
Source: "{#RootDirectory}\x64\Release64Bit\VST3\{#MyAppName}.vst3\Contents\x86_64-win\{#MyAppName}.vst3"; DestDir: "{cf64}\VST3\"; Flags: ignoreversion; Components: VST364 
Source: "{#RootDirectory}\x64\Release64Bit\VST\{#MyAppName}.dll"; DestDir: "{code:GetVST2Dir|0}"; Flags: ignoreversion; Components: VST64 
Source: "{#RootDirectory}\x64\Release64Bit\Standalone Plugin\{#MyAppName}.exe"; DestDir: "{pf64}\{#MyAppName}"; Flags: ignoreversion; Components: StandAlone64 

[Types]
Name: "custom"; Description: "custom"; Flags: iscustom

[Components]
Name: "VST364"; Description: "64-bit VST3"; Types: custom; Check: Is64BitInstallMode;
Name: "VST64"; Description: "64-bit VST2"; Types: custom; Check: Is64BitInstallMode; 
Name: "StandAlone64"; Description: "64-bit Stand Alone"; Types: custom; Check: Is64BitInstallMode; 
Name: "VST3"; Description: "32-bit VST3"; Types: custom; 
Name: "VST"; Description: "32-bit VST2"; Types: custom; 
Name: "StandAlone"; Description: "32-bit Stand Alone"; Types: custom; 

[Code]
//Find VST Folder
var
  VST2DirPage: TInputDirWizardPage;
  TypesComboOnChangePrev: TNotifyEvent;

procedure ComponentsListCheckChanges;
begin
  WizardForm.NextButton.Enabled := (WizardSelectedComponents(False) <> '');
end;

procedure ComponentsListClickCheck(Sender: TObject);
begin
  ComponentsListCheckChanges;
end;

procedure TypesComboOnChange(Sender: TObject);
begin
  TypesComboOnChangePrev(Sender);
  ComponentsListCheckChanges;
end;

procedure InitializeWizard;
begin

  WizardForm.ComponentsList.OnClickCheck := @ComponentsListClickCheck;
  TypesComboOnChangePrev := WizardForm.TypesCombo.OnChange;
  WizardForm.TypesCombo.OnChange := @TypesComboOnChange;

  VST2DirPage := CreateInputDirPage(wpSelectComponents,
  'Confirm VST2 Plugin Directory', '',
  'Select the folder in which setup should install the VST2 Plugin, then click Next.',
  False, '');

  VST2DirPage.Add('64-bit folder');
  VST2DirPage.Values[0] := GetPreviousData('VST64', ExpandConstant('{reg:HKLM\SOFTWARE\VST,VSTPluginsPath|{pf}\VSTPlugins}'));
  VST2DirPage.Add('32-bit folder');
  VST2DirPage.Values[1] := GetPreviousData('VST32', ExpandConstant('{reg:HKLM\SOFTWARE\WOW6432NODE\VST,VSTPluginsPath|{pf32}\VSTPlugins}'));

  If not Is64BitInstallMode then
  begin
    VST2DirPage.Values[1] := GetPreviousData('VST32', ExpandConstant('{reg:HKLM\SOFTWARE\VSTPluginsPath\VST,VSTPluginsPath|{pf}\VSTPlugins}'));
    VST2DirPage.Buttons[0].Enabled := False;
    VST2DirPage.PromptLabels[0].Enabled := VST2DirPage.Buttons[0].Enabled;
    VST2DirPage.Edits[0].Enabled := VST2DirPage.Buttons[0].Enabled;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = VST2DirPage.ID then
  begin
    VST2DirPage.Buttons[0].Enabled := IsComponentSelected('VST64');
    VST2DirPage.PromptLabels[0].Enabled := VST2DirPage.Buttons[0].Enabled;
    VST2DirPage.Edits[0].Enabled := VST2DirPage.Buttons[0].Enabled;

    VST2DirPage.Buttons[1].Enabled := IsComponentSelected('VST');
    VST2DirPage.PromptLabels[1].Enabled := VST2DirPage.Buttons[1].Enabled;
    VST2DirPage.Edits[1].Enabled := VST2DirPage.Buttons[1].Enabled;
  end;

  if CurPageID = wpSelectComponents then
  begin
    ComponentsListCheckChanges;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = VST2DirPage.ID then
  begin
    If (not IsComponentSelected('VST')) and (not IsComponentSelected('VST64'))then
      begin
        Result := True
      end;
  end;
end;

function GetVST2Dir(Param: string): string;
begin
    Result := VST2DirPage.Values[StrToInt(Param)];
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'VST64', VST2DirPage.Values[0]);
  SetPreviousData(PreviousDataKey, 'VST32', VST2DirPage.Values[1]);
end;