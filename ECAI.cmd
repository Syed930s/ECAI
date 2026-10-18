@echo off
mountvol S: /s
mkdir S:\EFI\EFICOMMAND
curl -L "https://github.com/Syed930s/EFICOMMAND/releases/download/0.4/BOOTX64.EFI" -o S:\EFI\EFICOMMAND\BOOTX64.EFI

for /f "tokens=2 delims={}" %%G in ('bcdedit /copy {bootmgr} /d "EFICOMMAND"') do set GUID={%%G}
bcdedit /set %GUID% device partition=S:
bcdedit /set %GUID% path \EFI\EFICOMMAND\BOOTX64.EFI
bcdedit /set {fwbootmgr} displayorder %GUID% /addlast

mountvol S: /d
