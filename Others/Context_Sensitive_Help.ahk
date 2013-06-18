/*
#####################################
Context Sensitive Help by Avi Aryan #
v0.8                                #
#####################################
*/

#SingleInstance, force
SetWorkingDir, %A_scriptdir%

helpfile := Search4AhkHelp()

;--- CONFIGURE ---------------------------------------------------------------

F1::RunHelp(Helpfile, true, "!r!n")

;--- XXXXXXXXX ---------------------------------------------------------------

;HelpFile = the path of ahk help file

;Single File = true		 means all the help will be managed in a single help file

;Indexshortcut = the shortcut to open Index tab inside the Help file 
	;See - http://www.autohotkey.com/board/topic/94493-context-sensitive-help-in-any-editor-best-edition/page-2#entry595850

RunHelp(Helpfile, SingleFile=true, IndexShortcut="!r!n"){

	BlockInput, Sendandmouse
	oldclip := ClipboardAll
	Send, +{End}^c
	copiedcode1 := Clipboard	;rightside
	Send, {Home}+{End}^c{Right}
	copiedcode2 := Clipboard
	leftofcaret := Substr(copiedcode2, 1, Instr(copiedcode2, copiedcode1, false, 0)-1) 	;leftside
	
	if ( ( !Instr(copiedcode1, " ") ? Strlen(copiedcode1) : Instr(copiedcode1, " ") ) > ( !Instr(copiedcode1, "(") ? Strlen(copiedcode1) : Instr(copiedcode1, "(") ) )
		needles := "=|+|-|*|?|:|(|% |%	|\|/|,|!|<|>|.| "
	else
		needles := "%|=|."	;If it is a command, we dont need any parsing, but if it is a Sys variable, we need . Add more from above if you find it right
	
	copiedcode := Ltrim( (temp_pos := SuperInstr(leftofcaret, needles, 0, false, 0)) ? Substr(leftofcaret, temp_pos+1) : leftofcaret )
	copiedcode .= copiedcode1
	comand := RegExReplace(copiedcode, "([A-Z]*)(,|`t| |\()(.*)", $1)
	BlockInput, off
	Clipboard := oldclip
	;;Running
	IfNotEqual, comand
	{
		 if !SingleFile
			Run, %Helpfile%,,Max
		else if !Winexist("AutoHotkey Help")
			Run, %Helpfile%,,Max
		WinWait, AutoHotkey Help
		WinActivate, AutoHotkey Help
		WinWaitActive, AutoHotkey Help
		Sendplay,% IndexShortcut
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

/*
	Searches for Ahk Help file
*/
Search4AhkHelp(){
	
	if FileExist( helpfile := Substr(A_ahkpath, 1, Instr(A_ahkpath, "\", false, 0)) "Autohotkey.chm" )
		return helpfile
	else
	{
		FileSelectFile, selfile,,,Select Autohotkey Help file,Autohotkey Help(Autohotkey.chm)
		return selfile
	}
}