; PDF2PNG Converter Installer Script
; For NSIS (Nullsoft Scriptable Install System)

; Request administrator privileges
RequestExecutionLevel admin

!define APP_NAME "PDF2PNG Converter"
!define COMP_NAME "YourCompany"
!define VERSION "1.0.0"
!define COPYRIGHT "Your Name"
!define DESCRIPTION "PDF to PNG Converter"
!define INSTALLER_NAME "PDF2PNG_Converter_Setup.exe"
!define MAIN_APP_EXE "PDF2PNG_Converter.exe"
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

; Custom function to display installation location options
Function LocationOptionsPage
  !define MUI_PAGE_HEADER_TEXT "Choose Installation Location"
  !define MUI_PAGE_HEADER_SUBTEXT "Choose where to install ${APP_NAME}"
  !define MUI_DIRECTORYPAGE_TEXT_TOP "Select one of the following installation locations:"
  
  StrCpy $0 "Program Files (Requires Administrator Privileges)"
  StrCpy $1 "User AppData Folder (No Administrator Required)"
  
  nsDialogs::Create 1018
  Pop $2
  
  ${NSD_CreateRadioButton} 10u 30u 100% 12u $0
  Pop $3
  ${NSD_CreateRadioButton} 10u 50u 100% 12u $1
  Pop $4
  
  ${NSD_SetState} $3 ${BST_CHECKED}
  
  nsDialogs::Show
FunctionEnd

Function LocationOptionsLeave
  ${NSD_GetState} $3 $5
  ${If} $5 == ${BST_CHECKED}
    StrCpy $INSTDIR "$PROGRAMFILES\${APP_NAME}"
  ${Else}
    StrCpy $INSTDIR "$LOCALAPPDATA\${APP_NAME}"
  ${EndIf}
FunctionEnd

; Pages
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE LocationOptionsPage
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE LocationOptionsLeave
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
; Try to install in Program Files, but provide alternative locations
InstallDir "$PROGRAMFILES\${APP_NAME}"
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
ShowInstDetails show
ShowUnInstDetails show

; Function to handle installation errors
Function .onInstError
  MessageBox MB_YESNO|MB_ICONEXCLAMATION "Installation failed. Would you like to try installing in your AppData folder instead?" IDYES TryAppDataInstall IDNO GiveUp
  
  TryAppDataInstall:
    StrCpy $INSTDIR "$LOCALAPPDATA\${APP_NAME}"
    Return
  
  GiveUp:
    Abort "Installation canceled by user."
FunctionEnd

Section -MainProgram
    ${INSTALL_TYPE}
    SetOverwrite on
    
    ; Check if we have write permissions to the install directory
    ClearErrors
    CreateDirectory "$INSTDIR"
    FileOpen $0 "$INSTDIR\writetest.txt" w
    
    ${If} ${Errors}
        ; If we don't have write permissions and this is Program Files, suggest AppData
        ${If} $INSTDIR == "$PROGRAMFILES\${APP_NAME}"
            MessageBox MB_YESNO|MB_ICONEXCLAMATION "Cannot write to $INSTDIR. Would you like to install in your AppData folder instead?" IDYES AppDataInstall
            MessageBox MB_OK|MB_ICONEXCLAMATION "Installation cannot proceed without write permissions. Please run the installer with administrator rights."
            Abort
            
            AppDataInstall:
                StrCpy $INSTDIR "$LOCALAPPDATA\${APP_NAME}"
                ; Create directory and test again
                ClearErrors
                CreateDirectory "$INSTDIR"
                FileOpen $0 "$INSTDIR\writetest.txt" w
                ${If} ${Errors}
                    MessageBox MB_OK|MB_ICONEXCLAMATION "Still cannot write to $INSTDIR. Installation cannot proceed."
                    Abort
                ${EndIf}
        ${Else}
            MessageBox MB_OK|MB_ICONEXCLAMATION "Cannot write to $INSTDIR. Please choose a different location or run as administrator."
            Abort
        ${EndIf}
    ${EndIf}
    
    FileClose $0
    Delete "$INSTDIR\writetest.txt"
    ; Now proceed with installation
    SetOutPath "$INSTDIR"
    File "dist\PDF2PNG_Converter.exe"
    File "icon.ico"
    File "Run_PDF2PNG_Converter.bat"
    File "troubleshoot.ps1"
    File "setup_poppler.bat"
    File "fix_poppler.bat"
    File "user_guide.md"
    
    ; Create Poppler bin directory and copy binaries
    SetOutPath "$INSTDIR\poppler-bin"
    File /nonfatal "poppler-bin\*.*"
    
    SetOutPath "$INSTDIR"
      ; Create shortcuts to the batch launcher, not directly to the exe
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\Run_PDF2PNG_Converter.bat" "" "$INSTDIR\icon.ico"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\User Guide.lnk" "$INSTDIR\user_guide.md" "" "$INSTDIR\icon.ico"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe"
    
    ; Add to desktop
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\Run_PDF2PNG_Converter.bat" "" "$INSTDIR\icon.ico"
    
    ; Add file associations for PDF files
    WriteRegStr HKCR ".pdf\shell\ConvertToPNG" "" "Convert to PNG"
    WriteRegStr HKCR ".pdf\shell\ConvertToPNG\command" "" '"$INSTDIR\${MAIN_APP_EXE}" "%1"'
    
    ; Start Menu
    WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayName" "${APP_NAME}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayIcon" "$INSTDIR\icon.ico"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "Publisher" "${COMP_NAME}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "DisplayVersion" "${VERSION}"
    WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}" "URLInfoAbout" "https://yourcompany.com"
    
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
    Delete "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    
    ; Remove registry keys
    DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
    DeleteRegKey HKCR ".pdf\shell\ConvertToPNG"
SectionEnd
