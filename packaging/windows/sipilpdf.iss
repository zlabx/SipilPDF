; Inno Setup script for SipilPDF (Windows desktop build of Open PDF Studio).
;
; This is the installer the SipilStock Apps launcher installs and updates (silently, per user:
; /VERYSILENT /CURRENTUSER, no administrator rights). It replaces upstream's NSIS installer and writes the same
; registry entries as upstream's nsis/hooks.nsh (rebranded): the PDF file type ("Open with", optional default),
; the File Explorer right-click verbs (Combine / Convert to PDF) and the capabilities for Settings > Default apps.
; Left out on purpose: the virtual printer (needs administrator rights) and the File Explorer thumbnail handler
; registration (the app registers it per user when the person turns it on in Preferences).
;
; Build (done by the "SipilPDF desktop (Windows)" workflow in zlabx/Apps, step "Installer Inno"):
;     ISCC /DMyAppVersion=2027.0 /DMyAppVersionInfo=2027.0.0.0 /DDistDir=<dir> /DOutDir=<dir> sipilpdf.iss
; <dir> holds app\* (SipilPDF.exe, pdfium-worker.exe, pdfium.dll, ... and the resource folders), AppIcon.ico and docs\*.
;
; The AppId is a FIXED GUID. The launcher finds the installed app through the uninstall key {AppId}_is1
; (launcher/crates/core/src/catalog.rs in zlabx/Apps: inno_app_id). Changing it breaks detection and upgrades;
; keep both in sync (scripts/windows/sipilpdf-test-inno.ps1 checks the value).

#define MyAppName "SipilPDF"
#define MyAppPublisher "SipilStock"
#define MyAppURL "https://sipilstock.com/sipilpdf/"
#define MyAppExeName "SipilPDF.exe"

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#ifndef MyAppVersionInfo
  #define MyAppVersionInfo "0.0.0.0"
#endif
#ifndef DistDir
  #define DistDir "..\..\dist"
#endif
#ifndef OutDir
  #define OutDir DistDir
#endif

[Setup]
AppId={{A74CE176-2ED8-53C4-AD09-5744EB2D1E4D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#MyAppVersionInfo}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=SipilPDF setup
VersionInfoProductName={#MyAppName}

; Per user by default ({autopf} is %LOCALAPPDATA%\Programs then). The dialog lets someone who
; double-clicks the installer choose "all users" (UAC); the launcher always passes /CURRENTUSER.
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; Free software: the license page shows the licence overview (LGPL-3.0-or-later; the work also contains AGPL-3.0 code).
LicenseFile={#DistDir}\docs\LICENSE.txt

OutputDir={#OutDir}
OutputBaseFilename=sipilpdf-setup-v{#MyAppVersion}
SetupIconFile={#DistDir}\AppIcon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
WizardStyle=modern
; The installer registers file types (HKA\Software\Classes): tell Explorer to refresh icons.
ChangesAssociations=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
Compression=lzma2
SolidCompression=yes
; An update runs while the previous version may be open: close it, do not restart it.
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
; Not ticked by default: SipilPDF does not take over .pdf from the program the user already has.
; It always appears in "Open with" and in Settings > Default apps.
Name: "assocpdf"; Description: "Open .pdf files with SipilPDF (double-click)"; GroupDescription: "File associations:"; Flags: unchecked

[Files]
; The application folder: SipilPDF.exe (upstream's open-pdf-studio.exe), the PDFium worker, pdfium.dll,
; WebView2Loader.dll, the thumbnail handler DLL, file-icon.ico and the resource folders (fonts, tessdata, ...).
Source: "{#DistDir}\app\*"; DestDir: "{app}"; Excludes: "open-pdf-thumbnails.dll"; Flags: ignoreversion recursesubdirs createallsubdirs
; The thumbnail handler can be loaded by File Explorer (only when the person turned thumbnails on): it cannot be
; overwritten then, so [Code] moves the old file aside first (a loaded DLL can still be renamed).
Source: "{#DistDir}\app\open-pdf-thumbnails.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#DistDir}\AppIcon.ico"; DestDir: "{app}"; Flags: ignoreversion
; Licence and notice files (the About dialog links to the same files in the public source repository).
Source: "{#DistDir}\docs\*"; DestDir: "{app}\docs"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Registry]
; Same names as upstream's NSIS installer after the rebrand: ProgId SipilPDF.pdf, Applications\SipilPDF.exe,
; Software\SipilPDF\Capabilities, RegisteredApplications\SipilPDF.
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\DefaultIcon"; ValueType: string; ValueData: "{app}\file-icon.ico,0"
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\shell\open\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".pdf"; ValueData: ""

Root: HKA; Subkey: "Software\Classes\SipilPDF.pdf"; ValueType: string; ValueData: "PDF Document"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SipilPDF.pdf\DefaultIcon"; ValueType: string; ValueData: "{app}\file-icon.ico,0"
Root: HKA; Subkey: "Software\Classes\SipilPDF.pdf\shell\open\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
; Offered under "Open with" without becoming the default.
Root: HKA; Subkey: "Software\Classes\.pdf\OpenWithProgids"; ValueType: string; ValueName: "SipilPDF.pdf"; ValueData: ""; Flags: uninsdeletevalue
; Optional task: become the default opener. Uninstall removes the value; Windows falls back.
Root: HKA; Subkey: "Software\Classes\.pdf"; ValueType: string; ValueData: "SipilPDF.pdf"; Tasks: assocpdf; Flags: uninsdeletevalue

; File Explorer right-click (upstream #945): classic shell verbs under SystemFileAssociations, so they work next to any
; default PDF app (Windows 11: under "Show more options"). Removed on uninstall.
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.pdf\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.pdf\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.pdf\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.pdf\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dwg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dwg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dwg\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dwg\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dxf\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueData: "Convert to PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dxf\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert to PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dxf\shell\SipilPDF.ConvertToPdf"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.dxf\shell\SipilPDF.ConvertToPdf\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-to-pdf ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpg\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.jpeg\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.png\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.bmp\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.gif\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.Combine"; ValueType: string; ValueData: "Convert and combine into one PDF (SipilPDF)"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.Combine"; ValueType: string; ValueName: "MUIVerb"; ValueData: "Convert and combine into one PDF (SipilPDF)"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.Combine"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\SystemFileAssociations\.webp\shell\SipilPDF.Combine\command"; ValueType: string; ValueData: """{app}\{#MyAppExeName}"" --convert-combine ""%1"""

; The parent key holds Capabilities (below); remove it on uninstall only when nothing is left in it.
Root: HKA; Subkey: "Software\SipilPDF"; Flags: uninsdeletekeyifempty
; Settings > Default apps.
Root: HKA; Subkey: "Software\SipilPDF\Capabilities"; ValueType: string; ValueName: "ApplicationName"; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\SipilPDF\Capabilities"; ValueType: string; ValueName: "ApplicationDescription"; ValueData: "View, annotate and edit PDF files."
Root: HKA; Subkey: "Software\SipilPDF\Capabilities"; ValueType: string; ValueName: "ApplicationIcon"; ValueData: """{app}\{#MyAppExeName}"",0"
Root: HKA; Subkey: "Software\SipilPDF\Capabilities\FileAssociations"; ValueType: string; ValueName: ".pdf"; ValueData: "SipilPDF.pdf"
Root: HKA; Subkey: "Software\RegisteredApplications"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: "Software\SipilPDF\Capabilities"; Flags: uninsdeletevalue

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Code]
{ SipilPDF shows its window with the WebView2 runtime of Windows (included in Windows 11 and in current Windows 10). }
function WebView2Installed: Boolean;
var
  Version: String;
begin
  Result := False;
  if RegQueryStringValue(HKLM32, 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) then
    Result := (Version <> '') and (Version <> '0.0.0.0');
  if (not Result) and RegQueryStringValue(HKCU, 'Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', 'pv', Version) then
    Result := (Version <> '') and (Version <> '0.0.0.0');
end;

function InitializeSetup: Boolean;
begin
  Result := True;
  if (not WebView2Installed) and (not WizardSilent) then
    MsgBox('SipilPDF needs the Microsoft Edge WebView2 Runtime, which was not found on this computer.' + #13#10 +
      'Install it from https://developer.microsoft.com/microsoft-edge/webview2/ (Evergreen Standalone Installer), ' +
      'then start SipilPDF.', mbInformation, MB_OK);
end;

{ A loaded DLL cannot be overwritten, but it can be renamed: move the old thumbnail handler aside, delete it when possible. }
procedure CurStepChanged(CurStep: TSetupStep);
var
  Dll, Aside: String;
begin
  if CurStep = ssInstall then
  begin
    Dll := ExpandConstant('{app}\open-pdf-thumbnails.dll');
    if FileExists(Dll) then
    begin
      Aside := Dll + '.old';
      DeleteFile(Aside);
      if not DeleteFile(Dll) then
        RenameFile(Dll, Aside);
    end;
  end
  else if CurStep = ssDone then
    DeleteFile(ExpandConstant('{app}\open-pdf-thumbnails.dll.old'));
end;
