REBOL [
	Title: "Win Extension Test"
	author: "Jocko"
	date: 2-Nov-2009
	comment: {
	test and demo of the use of winExt.dll
	}
]
{
#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_FORCEMINIMIZE    11
#define SW_MAX              11
}
{
#define WM_SETFOCUS                     0x0007
#define WM_KILLFOCUS                    0x0008
#define WM_ENABLE                       0x000A
#define WM_SETREDRAW                    0x000B
#define WM_SETTEXT                      0x000C
#define WM_GETTEXT                      0x000D
#define WM_GETTEXTLENGTH                0x000E
#define WM_PAINT                        0x000F
#define WM_CLOSE                        0x0010
#ifndef _WIN32_WCE
#define WM_QUERYENDSESSION              0x0011
#define WM_QUERYOPEN                    0x0013
#define WM_ENDSESSION                   0x0016
#endif
#define WM_QUIT                         0x0012
#define WM_ERASEBKGND                   0x0014
#define WM_SYSCOLORCHANGE               0x0015
#define WM_SHOWWINDOW                   0x0018
#define WM_WININICHANGE                 0x001A
#if(WINVER >= 0x0400)
#define WM_SETTINGCHANGE                WM_WININICHANGE
#endif /* WINVER >= 0x0400 */
}

secure [extension allow]
t: import %winExt.dll
print " "
print rejoin ["dll version " w-version]

; general commands

w-sound ; system sound ...
;w-beep  ; really too noisy !

print " "
print "don't worry, I will reduce all windows !"
wait 1
w-minimize-all
wait 1
w-restore-all

print " "
print "--- application commands ---"

wait 2
w-playsound "essai.wav"
wait 2
w-launch "calc.exe"

;test !
wait 2
; test find-window 
; with one parameter
hCalc: w-find-window "Calc"
; or, with two parameters
;hCalc: w-find-window-cl "Calc" "SciCalc"

; just to try
print w-showwindow hCalc 2
wait 1
print w-showwindow hCalc 9
wait 1

print "--- a short sendkeys demo ---"
; case-sensitive ... 
; this may be useful, for proper window focus ...
;w-sendkeys  "Calc" ""
w-sendkeys hCalc "123"
w-sendkeys hCalc "*5"
wait 1
w-sendkeys hCalc "<ENTER>"
wait 2
w-close hCalc

print " "
print "--- I close the console from outside ..."
wait 2
hConsole: w-find-window "REBOL 3"
w-close hConsole
; this will not be executed ...
ask "close ?"
