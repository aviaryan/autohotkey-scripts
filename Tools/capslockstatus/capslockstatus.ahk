#SingleInstance force
SetWorkingDir, % A_ScriptDir

global PROGNAME := "CapsLockStatus"

gosub traymenu

FileCreateShortcut, % A_ScriptFullPath, % A_Startup "\" PROGNAME ".lnk"

gosub changeState
return

~CapsLock::
	Critical
	SetTimer, changeState, -20
	return

changeState:
	z := GetKeyState("CapsLock", "T")
	if (z==1)
		Menu, Tray, Icon, capslockon.ico
	Else
		Menu, Tray, Icon, capslockoff.ico
	Dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
	return


; CREDITS

about:
	MsgBox, 64, About, A simple capslock status notifier by Avi Aryan.`nhttp://aviaryan.in
	return

quit:
	Exitapp
	return

traymenu:
	Menu, Tray, NoStandard
	Menu, Tray, Add, About, about
	Menu, Tray, Add, Exit, quit
	Menu, Tray, Default, About
	Menu, Tray, Tip, % PROGNAME
	return