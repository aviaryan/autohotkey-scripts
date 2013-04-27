/*
AutoHotkey Updater by Avi Aryan
Updated 24/4/13
===============================
For AHK_L
As ahk_basic is not updated anymore . Version stuck to 1.0.48.05
===============================

---------
Know-Hows
---------

* The Auto-Detect Feature works on the default registered autohotkey for opening script files.The one which opens .ahk files when you Double-Click on them.
* If any application other than Autohotkey is registered as the default, use Manual Option.
* The application can be run by ahk_basic also. It doesn't depend which version runs this script, the registered version of Autohotkey will only be taken into account
  in the Auto-Detect Feature. ( Useful in external environments such as Scite4Autohotkey )
* Don't worry about the files created when the script runs, they will be Deleted!
* Tested in Win 7 32-bit

*/

SetWorkingDir, %A_scriptdir%
ID := A_Now

MsgBox, 35, Select, Do you want to manually select an Autohotkey.exe OR let the script do it for the registered one .`n`nYes  --  Manually

ifMsgBox, Yes
	CustomPath(ID)
IfMsgBox, No
	AutoDetect(ID)
IfMsgBox, Cancel
	Exitapp

AutoDetect(ID)
{
currentahk := GetPath()
ifnotequal, currentahk
{
	temp := "#NoTrayIcon`nfileappend,%a_ahkversion%," . ID . ".txt"
	FileAppend,%temp%,%ID%.ahk
	RunWait, %currentahk% "%ID%.ahk"
	CheckV(ID)
}
else
{
	MsgBox, 48, Hello, Autohotkey can't be auto-detected. Please browse it manually.
	CustomPath(ID)
}
}

CustomPath(ID)
{
FileSelectFile,currentahk,,,Select AutoHotkey Executable
IfNotEqual, currentahk
{
temp := "#NoTrayIcon`nfileappend,%a_ahkversion%," . ID . ".txt"
FileAppend,%temp%,%ID%.ahk
RunWait, %currentahk% "%ID%.ahk"
CheckV(ID)
}
}

CheckV(ID)
{
UrlDownloadToFile, http://l.autohotkey.net/version.txt,%ID%_current.txt
loop,
	IfExist, %ID%_current.txt
		break
	
Fileread,curversion,%ID%_current.txt
Fileread,version,%ID%.txt
Msgbox, 48,Update,% (curversion > version) ? ("Update Needed`n`nYour Version   ----    " . version . "`nCurrent Version  -----   " . curversion) : ("You are fine!")

FileDelete, %ID%_current.txt
FileDelete, %ID%.ahk
FileDelete, %ID%.txt
}

;Function to GET registered ahk path.
GetPath()
{
Regread, Application, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ahk\UserChoice, Progid
IfNotEqual, Application
{
	Regread, Totalpath, HKCR, %Application%\Shell\Open\Command
	loop,parse,Totalpath,%a_space%,""
	{
	Path := A_LoopField
	break
	}
	return, path
}
}