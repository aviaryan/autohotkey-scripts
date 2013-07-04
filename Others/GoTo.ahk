/*
#####################
GoTo v0.5
Avi Aryan
#####################

Go To functions, labels, hotkeys and hotstrings in any editor.
The only requirement is that the Editor shows file full path in Title Bar and has a Goto (Ctrl+G) option.
Examples of such editors - Notepad++, Sublime Text, PSPad, ConTEXT, Emacs

Any script which shows the full path and has a goto option is vaild

*/

;------- CONFIGURE -------------------
GoTo_AutoExecute(1, A_temp)		;1 = Gui is resizble, A_temp = Working Directory

F7::Goto_Main_Gui()
;-------------------------------------

return

GoTo_AutoExecute(resizable=true, WorkingDir=""){

	SetWorkingDir,% ( WorkingDir == "" ) ? A_scriptdir : WorkingDir
	FileCreateDir, gotoCache
	FileDelete, gotoCache\*.gotolist
	SetTimer, filecheck, 500
	if resizable
		OnMessage(0x201, "DragGotoGui") ; WM_LBUTTONDOWN
}

GoTo_Readfile(File) {
	static filecount , commentneedle := A_space ";|" A_tab	";"
	
	if ( filecount_N := fileiscached(File) )
		Filename := filecount_N
	else
	{
		Filename := filecount := filecount ? filecount+1 : 1
		FileAppend,% file "`n",gotoCache\filelist.gotolist
	}
	FileDelete, gotoCache\%Filename%-*

	loop, read, %file%
	{
		readline := Trim( A_LoopReadLine )
		if block_comments
			if Instr(readline, "*/") = 1
				block_comments := 0 , continue
			else continue

		if Instr(readline, ";") = 1
			continue

		if Instr(readline, "/*") = 1
			block_comments := 1 , continue
		
		readline := Trim( Substr(readline, 1, SuperInstr(readline, commentneedle, 1) ? SuperInstr(readline, commentneedle, 1)-1 : Strlen(readline)) )

		if ( readline_temp := Check4Hotkey(readline) )
			CreateCache(filename, "hotkey", readline_temp, A_index)
		else if ( Instr(readline, ":") = 1 ) and ( Instr(readline, "::", 0, 0) > 1 )
			CreateCache(filename, "hotstr", Substr(readline, 1, Instr(readline, "::", 0, 0)-1), A_index )
		else if !SuperInstr(readline, "``|`t| |,", 0) and Substr(readline,0) == ":"
			CreateCache(filename, "label", readline, A_index)
		else if Check4func(readline, A_index, file)
			CreateCache(filename, "func", Substr(readline, 1, Instr(readline, "(")) ")", A_index)
	}
}

CreateCache(hostfile, type, data, linenum){
	if type = func
		if ( Substr( data, 1, SuperInstr(data, " |`t|,|(", 1)-1 ) == "while" )
			return
	;Exceptions are listed above

	FileAppend,% data ">" linenum "`n",% "Gotocache\" hostfile "-" type ".gotolist"
}

Check4Hotkey(line) {
;The function assumes line is trimmed using Trim() and then checked for ; comment

	if ( Instr(line, "::") = 1 ) and ( Instr(line, ":", false, 0) = 3 )		;hotstring
		return ":"
	hK := Substr( line, 1, ( Instr(line, ":::") ? Instr(line, ":::")+2 : ( Instr(line, "::") ? Instr(line, "::")+1 : Strlen(line)+2 ) ) - Strlen(line) - 2)
	if hK = 
		return

	if !SuperInstr(hK, " |	", 0)
		if !SuperInstr(hK, "^|!|+|#", 0) And RegExMatch(hK, "[a-z]+[,(]")
			return
		else
			return hK
	else
		if Instr(hK, " & ") or ( Substr(hK, -1) == "UP" )
			return hK
}


Check4func(readline, linenum, file){

	if RegExmatch(readline, "i)[A-Z0-9#_@\$\?\[\]]+\(.*\)") != 1
		return
	if ( Substr(readline, 0) == "{" )
		return 1

	loop,
	{
		FileReadLine, cl, %file%,% linenum+A_index
		if Errorlevel = 1
			return
		cl := Trim( Substr(cl, 1, Instr(cl, ";") ? Instr(cl, ";")-1 : Strlen(cl)) )
		if cl = 
			continue

		if block_comments
			if Instr(readline, "*/") = 1
				block_comments := 0 , continue
			else continue
		if Instr(readline, "/*") = 1
			block_comments := 1 , continue

		return Instr(cl, "{") = 1 ? 1 : 0
	}
}

filecheck:
	FileGetTime, Timeforfile,% GetActiveFile(), M
	if ( Timeforfile != Lasttimefile ) and ( Timeforfile != "" )
		GoTo_Readfile(GetActiveFile())
	Lasttimefile := Timeforfile
	return

fileiscached(file){
	loop, read, gotoCache\filelist.gotolist
		if ( file == A_LoopReadLine )
			return A_index
}

;-------------------------------------- GUI --------------------------------------------------------------

Goto_Main_GUI()
{
	global
	static IsGuicreated , Activefile_old
	
	Activefileindex := fileiscached( GetActiveFile() )
	
	if ( Activefile_old != Activefileindex )
	{
		Guicontrol, Main:, Mainlist,% "|"
		Guicontrol, Main:Choose, maintab, 1
		Update_GUI("-label", activefileindex)
	}
	
	if !IsGuicreated
	{
		Gui, Main:New
		Gui, +AlwaysOnTop -Caption +ToolWindow
		Gui, Margin, 3, 3
		Gui, Font, s11, Consolas
		Gui, Add, Tab2,% "w" 310 " h30 vmaintab gtabclick AltSubmit", Labels|Functions|Hotkeys|Hotstrings
		Gui, Tab
		Gui, Font, s10, Courier New
		Gui, Add, Dropdownlist,% "xs y+10 h30 r20 vMainList gDDLclick Altsubmit w" 300
		Update_GUI("-label", activefileindex)
		IsGuicreated := 1
	}
	if !WinExist("GoTo ahk_class AutoHotkeyGUI")
		Gui, Main:Show,, GoTo
	else
		Gui, Main:Hide

	Activefile_old := Activefileindex
	return

DDLclick:
	Gui, Main:submit, nohide
	GoToMacro(ActivefileIndex, Typefromtab(Maintab), Mainlist)
	return

tabClick:
	Gui, Main:submit, nohide
	Update_GUI(Typefromtab(maintab), Activefileindex)
	return

}

Update_GUI(mode, fileindex){
	if !fileindex
		return
	loop, read, gotoCache\%fileIndex%%Mode%.gotolist
		MainList .= "|" Substr(A_loopreadline, 1, Instr(A_loopreadline, ">", 0, 0)-1)
	Guicontrol, Main:,Mainlist,% !MainList ? "|" : Mainlist
}

GoToMacro(Fileindex, type, linenum){
	BlockInput, On
	Gui, Main:Hide
	Filereadline, cl, gotocache\%Fileindex%%type%.gotolist, %linenum%
	runline := Substr(cl, Instr(cl, ">", 0, 0)+1)
	SendInput, ^g
	sleep, 100
	SendInput,% runline "{Enter}"
	BlockInput, Off
}
;---------------------------------------------------------------------------------------------------------

GetActiveFile(){
	WinGetActiveTitle, Title
	if !Instr(title, ".ahk")
		return ""
	return Trim( Substr( Title, temp := Instr(Title, ":\")-1, Instr(Title, ".ahk", 0, 0)-temp+4 ) ) 
	;~ return Trim( Substr(Title, 1, SuperInstr(Title, "-|*|•", 0, 0, 0)-1) , " `t*•-")	;Scite, Sublime Text, N++
}

TypefromTab(TabCount){

	if Tabcount = 1
		return "-label"
	else if Tabcount = 2
		return "-func"
	else if Tabcount = 3
		return "-hotkey"
	else
		return "-hotstr"
}

DragGotoGui(){		;Thanks Pulover
	PostMessage, 0xA1, 2,,, A
}

;Helper Function(s) --------------------------------------------------------------------------------------
/*
SuperInstr()
	Returns min/max position for a | separated values of Needle(s)
	
	return_min = true  ; return minimum position
	return_min = false ; return maximum position

*/

SuperInstr(Hay, Needles, return_min=true, Case=false, Startpoint=1, Occurrence=1){
	
	pos := return_min*Strlen(Hay)
	if return_min
	{
		loop, parse, Needles,|
			if ( pos > (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) )
				pos := var ? var : pos
		if ( pos == Strlen(Hay) )
			return 0
	}
	else
	{
		loop, parse, Needles,|
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}