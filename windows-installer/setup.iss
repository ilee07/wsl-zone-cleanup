; Inno Setup script for wsl-zone-cleanup.
; Compile with Inno Setup (ISCC.exe) on Windows to produce wsl-zone-cleanup-setup.exe.
; The installer copies the Linux files into {app} on the Windows side, then
; shells out to wsl.exe to run install.sh inside the default WSL distro.

[Setup]
AppId={{B6E1E9B0-6C2E-4E9A-9E9C-1B7B8B6D9F3D}
AppName=WSL Zone Cleanup
AppVersion=1.0
DefaultDirName={autopf}\WSL Zone Cleanup
DefaultGroupName=WSL Zone Cleanup
DisableProgramGroupPage=yes
OutputBaseFilename=wsl-zone-cleanup-setup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64compatible
PrivilegesRequired=lowest

[Files]
Source: "..\clean-zone-identifier.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\zone-identifier-cleanup.service"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\install.sh"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{sys}\wsl.exe"; Parameters: "-e bash ""{code:GetWslInstallPath}"""; Flags: waituntilterminated; StatusMsg: "Installing into WSL (you may be prompted for your Linux sudo password)..."

[Code]
function GetWslInstallPath(Param: String): String;
var
  WinPath, Drive, Rest: String;
begin
  WinPath := ExpandConstant('{app}\install.sh');
  Drive := Lowercase(Copy(WinPath, 1, 1));
  Rest := Copy(WinPath, 3, Length(WinPath));
  StringChangeEx(Rest, '\', '/', True);
  Result := '/mnt/' + Drive + Rest;
end;
