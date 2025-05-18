; PDF2PNG Converter Installer Script (Fixed version)
; For NSIS (Nullsoft Scriptable Install System)

; Request administrator privileges
RequestExecutionLevel admin

!define APP_NAME "PDF2PNG Converter"
!define COMP_NAME "OkayAbedin"
!define VERSION "1.0.0"
!define COPYRIGHT "Minhazul Abedin"
!define DESCRIPTION "PDF to PNG Converter"
!define INSTALLER_NAME "PDF2PNG_Converter_Setup_Fixed.exe"
!define MAIN_APP_EXE "PDF2PNG_Converter.exe"
!define STARTER_APP_EXE "PDF2PNG_Starter.exe"
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_EXE}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"

; Modern UI setup
!define MUI_ABORTWARNING
!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "EULA.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Base settings
Name "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
InstallDir "$LOCALAPPDATA\${APP_NAME}"
ShowInstDetails show
ShowUnInstDetails show

Section -MainProgram
    ${INSTALL_TYPE}
    SetOverwrite on
    
    ; Create install directory
    CreateDirectory "$INSTDIR"
    
    ; Copy main files
    SetOutPath "$INSTDIR"
    File "dist\${MAIN_APP_EXE}"
    File "dist\${STARTER_APP_EXE}"
    File "icon.ico"
    File "Run_PDF2PNG_Converter.bat"
    File "Launch_PDF2PNG.vbs"
    File "troubleshoot.ps1"
    File "EULA.txt"
    File "release_notes.md"
    File "banner.txt"
    
    ; Create Poppler bin directory and copy binaries
    CreateDirectory "$INSTDIR\poppler-bin"
    SetOutPath "$INSTDIR\poppler-bin"
    File /r "poppler-bin\*.*"
    
    ; Create shortcuts
    SetOutPath "$INSTDIR"
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${STARTER_APP_EXE}" "" "$INSTDIR\icon.ico"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Release Notes.lnk" "$INSTDIR\release_notes.md" "" "$INSTDIR\icon.ico"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe"
    
    ; Add to desktop
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${STARTER_APP_EXE}" "" "$INSTDIR\icon.ico"
    
    ; Add file associations for PDF files
    WriteRegStr HKCR ".pdf\shell\ConvertToPNG" "" "Convert to PNG"
    WriteRegStr HKCR ".pdf\shell\ConvertToPNG\command" "" '"$INSTDIR\${MAIN_APP_EXE}" "%1"'
    
    ; Register application in registry
    WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
    WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "Path" "$INSTDIR"
    
    ; Register uninstaller
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayName" "${APP_NAME}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayIcon" "$INSTDIR\icon.ico"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "Publisher" "${COMP_NAME}" 
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayVersion" "${VERSION}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "URLInfoAbout" "https://okayabedin.com"
    
    ; Create verification file to test installation
    FileOpen $0 "$INSTDIR\install_verified.txt" w
    FileWrite $0 "Installation completed successfully on $\r$\n"
    FileWrite $0 "Installed version: ${VERSION}$\r$\n"
    FileClose $0
    
    ; Create registry entry for path to make DLLs findable
    WriteRegExpandStr HKCU "Environment" "Path" "$INSTDIR;$INSTDIR\poppler-bin;$%PATH%"
    
    ; Create a batch file that starts the app with the correct PATH environment
    FileOpen $0 "$INSTDIR\Start_PDF2PNG.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "set PATH=%PATH%;%~dp0;%~dp0poppler-bin$\r$\n"
    FileWrite $0 "start \"\" \"%~dp0${STARTER_APP_EXE}\"$\r$\n"
    FileClose $0
    
    ; Create shortcut to the batch file
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Start ${APP_NAME}.lnk" "$INSTDIR\Start_PDF2PNG.bat" "" "$INSTDIR\icon.ico"
    
    ; Uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section Uninstall
    ${INSTALL_TYPE}
    
    ; Remove program files
    RMDir /r "$INSTDIR"
    
    ; Remove shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Start ${APP_NAME}.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Release Notes.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    
    ; Remove registry keys
    DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
    DeleteRegKey HKCR ".pdf\shell\ConvertToPNG"
SectionEnd
