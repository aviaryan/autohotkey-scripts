/*
------------
HTML & CSS  |
------------
##########################################
HTML+CSS Helper by Avi Aryan             #
Works with all Editors                   #
v0.1                                     #
##########################################
*/

#SingleInstance, force
SetWorkingDir, %A_scriptdir%

helpfile := "htmlref.chm"	;In script's dir
;The file can be downloaded from    https://dl.dropboxusercontent.com/u/116215806/Products/BlogTemp/htmlref.chm

;--- CONFIGURE ---------------------------------------------------------------

F1::RunHelp(Helpfile, true)

;--- XXXXXXXXX ---------------------------------------------------------------

;HelpFile = the path of HTML help file
;Single File = true		 means all the help will be managed in a single help file

RunHelp(Helpfile, SingleFile=true){

	BlockInput, Sendandmouse
	oldclip := ClipboardAll
	Send, +{End}^c
	copiedcode1 := Clipboard	;rightside
	Send, {Home}+{End}^c{Right}
	copiedcode2 := Clipboard
	leftofcaret := Substr(copiedcode2, 1, Instr(copiedcode2, copiedcode1, false, 0)-1) 	;leftside

	needles := "<|>|;|{"
	
	copiedcode := Ltrim( (temp_pos := SuperInstr(leftofcaret, needles, 0, false, 0)) ? Substr(leftofcaret, temp_pos+1) : leftofcaret )
	copiedcode .= copiedcode1
	comand := RegExReplace(copiedcode, "([A-Z]*)( |`t|\<|\>|\{|\;)(.*)", $1)
	
	BlockInput, off
	Clipboard := oldclip
	
	needles .= "\|/|:"
	loop, parse, needles,|
		comand := Trim(comand, A_LoopField)	
	;;Running
	IfNotEqual, comand
	{
		 if !SingleFile
			Run, %Helpfile%,,Max, PID
		else if !Winexist("ahk_pid " PID)
			Run, %Helpfile%,,Max, PID
		WinWait, ahk_pid %PID%
		WinActivate
		WinWaitActive
		SendMessage, 0x1330, 1,, SysTabControl321
		SendMessage, 0x130C, 1,, SysTabControl321
		SendPlay, +{Home}%comand%{enter}
	}
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
				pos := ( var = 0 ? pos : var )
	}
	else
	{
		loop, parse, Needles,|
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}
