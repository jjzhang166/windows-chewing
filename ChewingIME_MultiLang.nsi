; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "New Chewing IM"
!define PRODUCT_VERSION "0.3.4.5"
!define PRODUCT_PUBLISHER "PCMan, seamxr, andyhorng, sky008888, kcwu"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define TMPDIR "$TEMP\ChewingInst"

SetCompressor lzma

!include "LogicLib.nsh"
; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

Function uninstOld
  ClearErrors
  ${If} ${FileExists} "$SYSDIR\Chewing.ime"
    Delete "$SYSDIR\Chewing.ime"
    ${If} ${Errors}
      StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
        TradChineseIs:
          MessageBox MB_ICONSTOP|MB_OK "無法移除已存在的新酷音client端。$\n通常是因為舊版的新酷音client端已經被某些程式載入而無法移除。$\n請關閉所有程式或重新開機後，再安裝一次即可。"
          Abort
        TradChineseNot:
          MessageBox MB_ICONSTOP|MB_OK "Unable to remove the new chewing client which already exists. $\nUsually is because the old version new chewing client is already loading by some programs is unable the detachment. $\nAfter please close all programs or reboot computer, then installs one time then."
          Abort
    ${EndIf}
  ${EndIf}
  ; shutdown chewing server.
  ExecWait '"$SYSDIR\IME\Chewing\Installer.exe" /uninstall'
  
; run uninstaller
  ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"
; MessageBox MB_OK|MB_ICONINFORMATION "R0 = '$R0'" IDOK
  ${If} $R0 != ""
    ClearErrors
    ExecWait '$R0 /S _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
 
    ${Unless} ${Errors}
      Delete $R0
    ${EndIf}
  ${EndIf}

  ; uninst.exe will copy itself to $TEMP\~nsu.tmp\Au_.exe and execute that copy.
  ; Therefore, ExecWait "$INSTDIR\uninst.exe" is useless since it terminates after
  ; executing the copy Au_.exe.  We should ExecWait Au_.exe instead.
  ; This is a dirty hack to mimic the behavior of default NSIS uninst.exe.
  ; Reference: http://nsis.cvs.sourceforge.net/nsis/NSIS/Source/exehead/Main.c?view=markup
  SetOverwrite on
  SetOutPath "$TEMP\~nsu.tmp"
  CopyFiles /SILENT "$SYSDIR\IME\Chewing\uninst.exe" "$TEMP\~nsu.tmp\Au_.exe"

  ; This is really dirty! :-(
  ; uninst.exe of NSIS will try Au_.exe, Bu_.exe, Cu_.exe, ...Zu_.exe until success.
  ; There is little chance that Au_.exe cannot be use, so I omit this.
  ExecWait '"$TEMP\~nsu.tmp\Au_.exe" /S _?=$SYSDIR\IME\Chewing\'
  Delete "$TEMP\~nsu.tmp\Au_.exe"
  RMDir "$TEMP\~nsu.tmp"
  ClearErrors

; Ensure the old IME is deleted.
  Delete "$SYSDIR\Chewing.ime"
  ${If} ${Errors}
    Call OnInstError
  ${EndIf}
FunctionEnd

Function OnInstError
  StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
  TradChineseIs:
    MessageBox MB_ICONSTOP|MB_OK "安裝發生錯誤，請確定你有系統管理員權限，以及舊版不在執行中$\n$\n建議到控制台輸入法設定當中，移除舊版並重開機後再安裝一次。"
    Abort
  TradChineseNot:
    MessageBox MB_ICONSTOP|MB_OK "The installment has error. Please determine you have the system manager jurisdiction, as well as old version not in execution.$\n$\nSuggests the control bench input method hypothesis, after remove old version pays equal attention to starting installs one time again."
    Abort
FunctionEnd

BGGradient 0000FF 000000 FFFFFF

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!define MUI_LICENSEPAGE_RADIOBUTTONS
!insertmacro MUI_PAGE_LICENSE "License.txt"
; Directory page
; !insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_LINK_LOCATION "http://chewing.im/"
!define MUI_FINISHPAGE_LINK "Visit Our Web Site： ${MUI_FINISHPAGE_LINK_LOCATION}"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "TradChinese"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "win32-chewing-${PRODUCT_VERSION}.exe"
InstallDir "$SYSDIR\IME\Chewing"
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
  
  ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"
  ${If} $0 != ""
    StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
    TradChineseIs:
     MessageBox MB_OKCANCEL|MB_ICONQUESTION "偵測到已安裝舊版 $0 ，是否要移除舊版後繼續安裝新版？" IDOK +2
      Abort
      Call uninstOld
      Goto +5
    TradChineseNot:
      MessageBox MB_OKCANCEL|MB_ICONQUESTION "Detects has installed the old version $0, After whether wants the detachment old version to continue to install the new edition?" IDOK +2
      Abort
      Call uninstOld
  ${EndIf}
FunctionEnd

Section "MainSection" SEC01

  SetOverwrite on
  ; Generate data files on installation to reduce the size of installer.
    SetOutPath "${TMPDIR}"
    File "big52utf8\Release\big52utf8.exe"

    File "..\libchewingdata\source\utf-8\tsi.src"
    File "..\libchewingdata\source\utf-8\phone.cin"
    File "dat2bin\Release\dat2bin.exe"
    ExecWait '"${TMPDIR}\dat2bin.exe"'

    ; Rename will fail if destination file exists. So, delete them all.
    Delete "$SYSDIR\IME\Chewing\*"
    ; If the files to delete don't exist, error flag if *NOT* set.

    SetOutPath "$SYSDIR\IME\Chewing"
    Rename "${TMPDIR}\dat2bin.exe" 'dat2bin.exe'
    Rename "${TMPDIR}\ch_index.dat_bin" 'ch_index.dat'
    Rename "${TMPDIR}\dict.dat" 'dict.dat'
    Rename "${TMPDIR}\us_freq.dat" 'us_freq.dat'
    Rename "${TMPDIR}\ph_index.dat_bin" 'ph_index.dat'
    Rename "${TMPDIR}\fonetree.dat_bin" 'fonetree.dat'

    File "Data\statuswnd.bmp"
    File "License.txt"
    File "UserGuide\chewing.chm"
    File "Installer\Release\Installer.exe"
    File "ChewingServer\Release\ChewingServer.exe"
    File "HashEd-UTF8\Release\HashEd.exe"
    File "OnlineUpdate\Release\Update.exe"
  
  SetOverwrite off
    File "..\libchewing\branches\win32-utf8\data\symbols.dat"
    File "..\libchewing\branches\win32-utf8\data\swkb.dat"
  
  SetOverwrite on
    ExecWait '"$SYSDIR\IME\Chewing\Installer.exe" /privilege'
    SetOutPath "$SYSDIR"
    File "ChewingIME\Release\Chewing.ime"

  ${If} ${Errors}
    File /oname=Chewing-tmp.ime "ChewingIME\Release\Chewing.ime"
    Rename /REBOOTOK Chewing-tmp.ime Chewing.ime
  ${EndIf}
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
  TradChineseIs:
    CreateDirectory "$SMPROGRAMS\新酷音輸入法"
    CreateShortCut "$SMPROGRAMS\新酷音輸入法\新酷音輸入法使用說明.lnk" "$INSTDIR\Chewing.chm"
    CreateShortCut "$SMPROGRAMS\新酷音輸入法\使用者詞庫編輯工具.lnk" "$INSTDIR\HashEd.exe"
    CreateShortCut "$SMPROGRAMS\新酷音輸入法\線上檢查是否有新版本.lnk" "$INSTDIR\Update.exe"
    CreateShortCut "$SMPROGRAMS\新酷音輸入法\解除安裝.lnk" "$INSTDIR\uninst.exe"
    Goto +6
  TradChineseNot:
    CreateDirectory "$SMPROGRAMS\New Chewing IM"
    CreateShortCut "$SMPROGRAMS\New Chewing IM\User's manual.lnk" "$INSTDIR\Chewing.chm"
    CreateShortCut "$SMPROGRAMS\New Chewing IM\User word stock edition tool.lnk" "$INSTDIR\HashEd.exe"
    CreateShortCut "$SMPROGRAMS\New Chewing IM\Online Update.lnk" "$INSTDIR\Update.exe"
    CreateShortCut "$SMPROGRAMS\New Chewing IM\UnInstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
  WriteUninstaller "$SYSDIR\IME\Chewing\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "LANGUAGE" "$LANGUAGE"
  
  ExecWait '"$SYSDIR\IME\Chewing\Installer.exe"'

  SetShellVarContext current
  IfFileExists $APPDATA\Chewing\uhash.dat +2 0
    ExecWait '"${TMPDIR}\big52utf8.exe" $APPDATA\Chewing\hash.dat'

    Delete "${TMPDIR}\*"
    RMDir "${TMPDIR}"

  IfErrors 0 +2
    Call OnInstError
SectionEnd

Function un.onUninstSuccess
  ;HideWindow
  StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
  TradChineseIs:
    MessageBox MB_ICONINFORMATION|MB_OK "已成功地從你的電腦移除 $(^Name) 。" /SD IDOK
    Goto +2
  TradChineseNot:
    MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer." /SD IDOK
FunctionEnd

Function un.onInit
  ReadRegStr $LANGUAGE ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "LANGUAGE"
  StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
  TradChineseIs:
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "你確定要完全移除 $(^Name) ，其及所有的元件？" /SD IDYES IDYES +4
    Abort
  TradChineseNot:
    MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" /SD IDYES IDYES +2
    Abort
FunctionEnd

Section Uninstall
  ; shutdown chewing server.
  ExecWait '"$SYSDIR\IME\Chewing\Installer.exe" /uninstall'

  Delete "$INSTDIR\License.txt"
  Delete "$INSTDIR\statuswnd.bmp"
  Delete "$INSTDIR\ch_index.dat"
  Delete "$INSTDIR\dict.dat"
  Delete "$INSTDIR\fonetree.dat"
  Delete "$INSTDIR\ph_index.dat"
  Delete "$INSTDIR\us_freq.dat"
  Delete "$INSTDIR\Chewing.chm"
  Delete "$INSTDIR\Installer.exe"
  Delete "$INSTDIR\ChewingServer.exe"
  Delete "$INSTDIR\HashEd.exe"
  Delete "$INSTDIR\Update.exe"

  Delete "$INSTDIR\symbols.dat"
  Delete "$INSTDIR\dat2bin.exe"
  
  StrCmp $LANGUAGE 1028 TradChineseIs TradChineseNot
  TradChineseIs:
    Delete "$SMPROGRAMS\新酷音輸入法\新酷音輸入法使用說明.lnk"
    Delete "$SMPROGRAMS\新酷音輸入法\使用者詞庫編輯工具.lnk"
    Delete "$SMPROGRAMS\新酷音輸入法\解除安裝.lnk"
    Delete "$SMPROGRAMS\新酷音輸入法\線上檢查是否有新版本.lnk"
    RMDir "$SMPROGRAMS\新酷音輸入法"
    Goto +6
  TradChineseNot:
    Delete "$SMPROGRAMS\New Chewing IM\User's manual.lnk"
    Delete "$SMPROGRAMS\New Chewing IM\User word stock edition tool.lnk"
    Delete "$SMPROGRAMS\New Chewing IM\UnInstall.lnk"
    Delete "$SMPROGRAMS\New Chewing IM\Online Update.lnk"
    RMDir "$SMPROGRAMS\New Chewing IM"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"

  Delete "$INSTDIR\uninst.exe"
  RMDir "$SYSDIR\IME\Chewing"

  ; Put Delete Chewing.ime in last line, or other files will not be deleted
  ; because the uninstaller aborts when there is any error.
  Delete /REBOOTOK "$SYSDIR\Chewing.ime"

  SetAutoClose true
SectionEnd

