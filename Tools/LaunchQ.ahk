/* 
##########################################################
LAUNCHQ - MINIMALIST APPLICATION LAUNCHER
v1.5 
##########################################################

Copyright 2013 Avi Aryan  
  
Licensed under the Apache License, Version 2.0 (the "License");  
you may not use this file except in compliance with the License.  
You may obtain a copy of the License at  
  
http://www.apache.org/licenses/LICENSE-2.0  
  
Unless required by applicable law or agreed to in writing, software  
distributed under the License is distributed on an "AS IS" BASIS,  
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
See the License for the specific language governing permissions and  
limitations under the License.  

*/

#NoEnv
#SingleInstance, force
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
Page = http://www.avi-win-tips.blogspot.com/2013/05/launchq.html
version = 1.5

;-------------+
;INITIALIZE   |
;-------------+
;1 - Clips, 2- version, 3 - hotkey

IfNotExist,Q-settings/settings.ini
{
FileCreateDir,Q-settings
FileAppend,13`n%version%`n+Z,q-settings/settings.ini

FileDelete,q-settings/paths.lq
FileDelete,q-settings/names.lq
FileAppend,Notepad`nPaint`nWordpad`nWindows Explorer`nInternet Explorer`nWindows Media Player`nCalculator`nProgram Files`nSystem32 Dir`nMy Documents`nFacebook`nGoogle`nLaunchQ online,Q-settings/names.lq

FileAppend,notepad.exe`nmspaint.exe`nwordpad.exe`nexplorer.exe`niexplore.exe`nwmplayer.exe`ncalc.exe`n%A_programfiles%`n%A_WinDir%\system32`n%A_MyDocuments%`nhttp://www.facebook.com`nhttp://www.google.com`n%Page%,q-settings/paths.lq

Arrange()
}

FileReadLine,curhot,q-settings/settings.ini,3
Hotkey,%curhot%,ShowGui,On

;---------+
;GUI      |
;---------+
Gui, -Caption +ToolWindow +AlwaysOnTop
Gui, Color, CB2322
Gui, Font, S14 CBlue bold, Consolas
Gui, Add, Text, x0 y0 w350 h30 +Center gabout, LaunchQ
Gui, Font, S12 CBlack
AddtoGUI()
Gui, Font, CYellow
Gui, Add, Text, x0 y480 w350 h20 +Center gwebsite,Add Web-Site

;GUI 2 - Add item
Gui, 2: +ToolWindow 
Gui, 2:Font, S14 CDefault, Consolas
Gui, 2:Add, Text, x2 y10 w210 h20 , Shortcut Name
Gui, 2:Font, S12 CDefault, Consolas
Gui, 2:Add, Edit, x282 y10 w180 h22 vsname gsnamechange, 
Gui, 2:Font, S14 CDefault, Consolas
Gui, 2:Add, Text, x2 y60 w130 h20 , Shortcut(s)
Gui, 2:Font, S8 CDefault, Consolas
Gui, 2:Add, Edit, x2 y80 w470 h70 vshorts +ReadOnly, 
Gui, 2:Font, S12 CDefault, Consolas
Gui, 2:Add, Button, x2 y160 w160 h20 vproceed, Proceed
Gui, 2:Add, Button, x352 y160 w110 h20 , Cancel
Gui, 2:Font, S10 CBlue Italic, Consolas
Gui, 2:Add, Text, x2 y30 w210 h20 vavlblty, 

;GUI 3 - About
Gui, 3: +ToolWindow
Gui, 3:Font, S16 CRed, Consolas
Gui, 3:Add, Text, x2 y0 w590 h30 +Center gpage, LaunchQ v%version% : by Avi Aryan
Gui, 3:Font, S14 CBlue, Consolas
Gui, 3:Add, Text, x2 y30 w590 h20 +Center gblog, More Tools
Gui, 3:Font, S14 CGreen, Consolas
Gui, 3:Add, Text, x2 y70 w220 h20 , Main Shortcut
Gui, 3:Add, Text, x2 y110 w590 h20 +Center gupdate, Check for Updates
Gui, 3:Font, S12 CBlack, Consolas
Gui, 3:Add, Hotkey, x342 y70 w170 h25 ghotkeychange vhotkey,
Gui, 3:Add, edit, x1000 y1000 w1 h1 vtofool,

;-------+
;TRAY   |
;-------+
Menu, Tray, NoStandard
Menu, Tray, Tip, LaunchQ by Avi Aryan
Menu, Tray, Add, LaunchQ, about
Menu, Tray, Add,
Menu, Tray, Add, Online Help, help
Menu, Tray, Add, Run at Startup, startup
Menu, Tray, Add
Menu, Tray, Add, Quit, quit
Menu, Tray, Default, LaunchQ

;OTHERS
IfExist,%a_startup%/LaunchQ.lnk
{
FileDelete,%a_startup%/LaunchQ.lnk
FileCreateShortcut,%A_ScriptFullPath%,%A_Startup%/LaunchQ.lnk
Menu,Tray,Check,Run At Startup
}

global ontop
ontop := 1
EmptyMem()
return

;###############################################################################
;END OF AUTO-EXCEUTE : FUNCS AND SUBS
;###############################################################################

Scroll(y, x){
IfInString,y,-
{
ToolTip
IfNotEqual,ontop,1
{
StringTrimLeft,y,y,1
y := 300 - y
IfLess,y,20
	y := 20
ontop-=1
loop,10
{
FileReadLine,pname,Q-settings/names.lq,% (ontop + A_index - 1)
GuiControl,,item%a_index%,%pname%
}
sleep, %y%
}
}
;End of Up scroll
else IfGreater,y,500
{
ToolTip
FileReadLine,index,q-settings/settings.ini,1
IfLess,ontop,% (index - 9)
{
y := 800 - y	;500 is default
if instr(y, "-")
	y := 20
ontop+=1
loop,10
{
FileReadLine,pname,Q-settings/names.lq,% (ontop + A_index - 1)
GuiControl,,item%a_index%,%pname%
}
sleep, %y%
}
}
;End of down scroll
else
{
IfLess,x,350
	if !(Instr(x, "-"))
	{
	MouseGetPos,,,,classnn
	StringTrimLeft,classnn,classnn,6	;Staticx where x from 2 to 11
	If (classnn > 1 and 12 > classnn)	;so that te required 10 show up
	{
	FileReadLine,path,q-settings/paths.lq,% (ontop - 1 + classnn - 1)
	StringReplace,path,path,|,`n,All
	Tooltip, %path%
	}
	else
		ToolTip
	}
;Mouseget
}
;Show Mouse Data
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
AddtoGUI(){
global
FileReadLine,index,q-settings/settings.ini,1
IfGreaterOrEqual,index,1
{
FileReadLine,pname,Q-settings/names.lq,1
Gui, Add, Text, x10 y50 w330 h25 vitem1 glaunch,%pname%

loop,9
{
FileReadLine,pname,Q-settings/names.lq,% (A_index + 1)
if Errorlevel = 1
	break
item := "item" . (A_Index + 1)
Gui, Add, Text, xp+0 yp+43 w350 h25 glaunch v%item%,%pname%
}
}
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UpdateGUI(){
ontop := 1
loop, 10
	GuiControl,1:,item%a_index%
;;Blanking
loop, 10
{
FileReadLine,pname,Q-settings/names.lq,% (A_index)
if Errorlevel = 1
	break
GuiControl,1:,item%a_index%,%pname%
}
EmptyMem()
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Deleter(){
BlockInput, MouseMove
MouseGetPos,,,Hwnd
WinGetTitle, title, ahk_id %Hwnd%

if (Winactive("LaunchQ ahk_class AutoHotkeyGUI") AND title == "LaunchQ")
{
MouseGetPos,,,,classnn
BlockInput,MouseMoveOff
KeyWait,Lbutton
MouseGetPos,fx,fy
if (fx < 0 or fx > 350 or fy < 0 or fy > 500)
	{
	StringTrimLeft,classnn,classnn,6	;Staticx where x from 2 to 11
	FileReadLine,name,q-settings/names.lq,% (ontop - 1 + classnn - 1)
	Tooltip, %name% Deleted !
	RemoveApp(ontop - 1 + classnn - 1)
	UpdateGUI()
	Sleep, 1000
	ToolTip
	}
	else{
	Send, {Lbutton Down}
	KeyWait, Lbutton
	Send, {Lbutton Up}
	}
}
else{
	;Out of window click event
	BlockInput, MouseMoveOff
	Send, {Lbutton Down}
	KeyWait, Lbutton
	Send, {Lbutton Up}
	DisableGUI()
}
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
GuiDropFiles:
ToolTip

loop,parse,A_guievent,`n
{
IfInString,a_loopfield,.lnk
{
	FileGetShortcut,%A_LoopField%,file
	allfile .= file . "|"
}
else
	allfile .= A_LoopField . "|"
}
StringTrimRight,allfile,allfile,1
Gui, 1:Hide
;;
StringReplace,allfilex,allfile,|,`n,All
GuiControl,2:,shorts,%allfilex%
allfilex = 
;;
Gui, 2:Show, w480 h191, Choose a Name
SetTimer,mousecheck,Off
GuiControl,2:Disable,proceed
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
launch:
DisableGUI()
Stringtrimleft,linetolaunch,A_guicontrol,4
FileReadLine,path,q-settings/paths.lq,% (linetolaunch + ontop - 1)
loop,parse,path,|
{
try{
	IfInString,A_LoopField,http://
		BrowserRun(A_LoopField)
	else
		run, %A_loopfield%
}catch{
	MsgBox, 16, WARNING, The path`n%A_loopfield%`nis invalid . Please re-check the path or re-add the shortcut.
}
}
EmptyMem()
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
2buttonproceed:
Gui, 2:submit, hide
FileAppend,`n%sname%,q-settings/names.lq
FileAppend,`n%allfile%,q-settings/paths.lq
FileReadLine,index,q-settings/settings.ini,1
strength := index + 1
FileAtline("q-settings/settings.ini", strength, 1)

Arrange()
UpdateGUI()
file =
strength =
index =
Gui, 1:Show
SetTimer,mousecheck,100
allfile = 
GuiControl,2:,sname
EmptyMem()
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
snamechange:
Gui, 2:submit, nohide
GuiControl,2:,avlblty,Available
GuiControl,2:Enable,proceed
loop,read,q-settings/names.lq
{
IfEqual,A_loopreadline,%sname%
{
	GuiControl,2:,avlblty,Unavailable
	GuiControl,2:Disable,proceed
	break
}
}
return

;#############################################################
;OTHER IMPORTNANT FUNCS AND SUBS
;#############################################################
ShowGUI:
IfWinNotExist, LaunchQ ahk_class AutoHotkeyGUI
{
Gui, Show, w350 h500, LaunchQ
WinSet, Region, 0-0 W350 H500 R40-40, LaunchQ ahk_class AutoHotkeyGUI
Winset, Transparent, 180, LaunchQ ahk_class AutoHotkeyGUI
WinActivate,LaunchQ
SetTimer,Mousecheck,100
Hotkey,$Lbutton,LeftMouse,On
}
else
	DisableGUI()
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DisableGUI(){
Gui, 1:Hide
Tooltip
SetTimer,Mousecheck,Off
Hotkey,$Lbutton,LeftMouse,Off
EmptyMem()
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

2GuiDropFiles:
Gui,2:submit,nohide
GuiControl,2:,shorts,% shorts . "`n" . A_GuiEvent
StringReplace,shorts,A_GuiEvent,`n,|,All
allfile .= "|" . shorts
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

website:
Gui, 1:Hide
Hotkey,$Lbutton,LeftMouse,Off
SetTimer,mousecheck,Off
InputBox,allfile,URL,Write here the URL of the web-link,,300,200,,,,,http://www.avi-win-tips.blogspot.com
IfNotEqual,allfile
{
If !(Instr(allfile, "http://") or InStr(allfile, "https://") or InStr(allfile, "ftp://"))
	allfile := "http://" . allfile
GuiControl,2:,shorts,%allfile%
Gui, 2:Show, w480 h191, Choose a Name
GuiControl,2:Disable,proceed
}
return
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Arrange(){
FileRead,paths,q-settings/paths.lq
FileRead,names,q-settings/names.lq
StringReplace,names,names,`r`n,`n,All
Sort, names
loop, parse, names, `n
{
name := A_LoopField
loop, read, q-settings/names.lq
{
IfEqual,name,%A_loopreadline%
{
FileReadLine,path,q-settings/paths.lq,%a_index%
break
}
}
newpath .= path . "`n"
}
StringTrimRight,newpath,newpath,1
FileDelete,q-settings/paths.lq
FileDelete,q-settings/names.lq
FileAppend,%names%,q-settings/names.lq
FileAppend,%newpath%,q-settings/paths.lq
EmptyMem()
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RemoveApp(Linenumber){

loop,% (linenumber - 1)
{
FileReadLine,name,q-settings/names.lq,%A_index%
FileReadLine,path,q-settings/paths.lq,%A_Index%
firstname .= name . "`n"
firstpath .= path . "`n"
}
loop,
{
FileReadLine,name,q-settings/names.lq,% (A_index + Linenumber)
FileReadLine,path,q-settings/paths.lq,% (A_index + Linenumber)
if Errorlevel = 1
	break
secondname .= name . "`n"
secondpath .= path . "`n"
}
name := Rtrim(firstname . secondname , "`n")
path := Rtrim(firstpath . secondpath , "`n")
FileDelete,q-settings/paths.lq
FileDelete,q-settings/names.lq
FileAppend,%name%,q-settings/names.lq
FileAppend,%path%,q-settings/paths.lq
;;Ini
FileReadLine,index,q-settings/settings.ini,1
strength := index - 1
FileAtline("q-settings/settings.ini", strength, 1)
}
;#############################################################
;NONE OF BUSINESS (CONSTANT) FUNCTIONS AND SUBS
;#############################################################

MouseCheck:
;Critical
MouseGetPos,x,y
Scroll(y, x)
return

LeftMouse:
Deleter()
return

2guiclose:
2buttoncancel:
Gui, 2:hide
Gui, 1:Show
SetTimer,mousecheck,100
allfile = 
GuiControl,2:,sname
return

EmptyMem(){
dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Fileatline(file, what, linenum){
loop, read, %file%
{
if !(A_index == linenum)
	filedata .= A_LoopReadLine . "`r`n"
else
	filedata .= what . "`r`n"
}
StringTrimRight,filedata,filedata,2
FileDelete, %file%
FileAppend, %filedata%, %file%
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BrowserRun(site){
RegRead, OutputVar, HKEY_CLASSES_ROOT, http\shell\open\command 
IfNotEqual, Outputvar
{
StringReplace, OutputVar, OutputVar,"
SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive
run,% OutDir . "\" . OutNameNoExt . ".exe" . " """ . site . """"
}
else
  run,% "iexplore.exe" . " """ . site . """"	;internet explorer
}

;###############################################################
;TRAY AND GUI OFF SUBS
;###############################################################

startup:
Menu,Tray,Togglecheck,Run At Startup
IfExist, %a_startup%/LaunchQ.lnk
	FileDelete,%a_startup%/LaunchQ.lnk
else
	FileCreateShortcut,%A_ScriptFullPath%,%A_Startup%/LaunchQ.lnk
return

about:
DisableGUI()
GuiControl,3:,hotkey,%curhot%
Gui, 3:Show, w595 h143, LaunchQ by Avi
return
help:
BrowserRun("http://www.avi-win-tips.blogspot.com/2013/05/lqguide.html")
return
blog:
BrowserRun("http://avi-win-tips.blogspot.in/p/my-autohotkey.html")
return
page:
BrowserRun(page)
return

hotkeychange:
Gui, 3:Submit, Nohide
IfNotEqual, hotkey
{
Fileatline("q-settings/settings.ini", hotkey, 3)
Hotkey,%curhot%,ShowGUI, Off
Hotkey,%hotkey%,ShowGUI, On
curhot := hotkey
}
return

update:
URLDownloadToFile,https://dl.dropboxusercontent.com/u/116215806/Products/LaunchQ/version.txt,q-settings/latest.txt
FileRead,latest,q-settings/latest.txt
if (latest > version)
	MsgBox, 48, Updates Available, Your version		%version%`nCurrent version		%latest%
else
	MsgBox, 64, Hello, No updates available
return

quit:
ExitApp

;###################################################################
#IfWinActive, LaunchQ by Avi
{
!space::
GuiControl,3:,hotkey,!space
gosub, hotkeychange
GuiControl,3:focus,tofool
return
}
#IfWinNotActive, LaunchQ by Avi
{
Hotkey,%curhot%,ShowGUI,On
}