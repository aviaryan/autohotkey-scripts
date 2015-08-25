#SingleInstance, force
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir

if !A_IsAdmin
{
	msgbox, 48, Warning, % "Please run this script as administrator."
}

global PROGNAME := "Pendrive Shortcut Fix"
global VERSION := "v1.0"
makeGUI()
return


makeGUI(){
	global
	Gui, Font, s20
	Gui, Add, Text, x10 y10, % PROGNAME
	Gui, Font, s10
	Gui, Add, Text, xp y+10, % VERSION " by Avi Aryan"
	Gui, Font, s14
	Gui, Add, Text, xp y+50, % "Select Drive"
	DriveGet, OV, List, REMOVABLE
	x := ""
	loop, parse, OV
		x .= A_LoopField "|"
	Gui, Add, DropDownList, vlist x+30 yp, % x "|"
	Gui, Add, Button, xp y+50 gbuttonok, % "Clean it"
	Gui, Show,, % PROGNAME
	return

buttonok:
	Gui, submit, nohide
	if (list == "")
		return
	DriveGet, ol, Label, % list ":"
	Msgbox, % 4+64, Confirmation, The drive %ol% (%list%:) will be diagnoised. Continue ?
	IfMsgBox, Yes
		if ((z:=fuckThemOff(list, ct2, ct3)) >= 0)
			Msgbox, 64, % "Success", % "Deleted " z " items`nFixed " ct2 " items`nFound " ct3 " viruses and successfully disposed them off`n`n" "Your system may also have the virus and shortcut fix can't disinfect that. Use an antivirus for that."
		else
			Msgbox, 48, % "Fail", % "There was some problem"
	return

GuiClose:
	Exitapp

}


fuckThemOff(drive, Byref ct2, Byref ct3){
	ct := 0
	ct2 := 0
	ct3 := 0
	k := 1
	loop, % drive ":\*.*", 1
	{
		if A_LoopFileExt = LNK
		{
			ct++
			FileDelete, % A_LoopFileFullPath
			if (Errorlevel != 0)
				k := -1
		} else if A_LoopFileExt in wsf, vbs
		{
			FileSetAttrib, -S-H, % A_LoopFileFullPath
			FileDelete, % A_LoopFileFullPath
			ct3++
		} else {
			ov := A_LoopFileAttrib
			if (Instr(ov, "S") && Instr(ov, "H")){
				ct2++
				FileSetAttrib, -S-H, % A_LoopFileFullPath, 1
			}
		}
	}
	return k==-1 ? -1 : ct
}