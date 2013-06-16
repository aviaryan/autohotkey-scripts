/*
#####################################
Context Sensitive Help by Avi Aryan #
v0.1                                #
#####################################
*/

;--- CONFIGURE -------------------------------------------------
F1::RunHelp()

;--- XXXXXXXXX -------------------------------------------------

#SingleInstance, force
SetWorkingDir, %A_scriptdir%

RunHelp(Helpfile="Autohotkey.chm"){
	BlockInput, Sendandmouse
	
	oldclip := ClipboardAll
	Send, +{End}^c
	copiedcode1 := Clipboard
	Send, {Home}+{End}^c{Right}
	copiedcode2 := Clipboard
	leftofcaret := Substr(copiedcode2, 1, Instr(copiedcode2, copiedcode1, false, 0)-1)
	copiedcode := Ltrim( (temp_pos := SuperInstr(leftofcaret, "=|+|-|*|?|:|(|% |%	", 0, false, 0)) ? Substr(leftofcaret, temp_pos+1) : leftofcaret )
	copiedcode .= copiedcode1
	comand := RegExReplace(copiedcode, "([A-Z]*)(,|`t| |\()(.*)", $1)
	BlockInput, off
	Clipboard := oldclip
	;;Running
	IfNotEqual, comand
	{
		Run, %Helpfile%,,Max
		WinWait, AutoHotkey Help
		WinActivate, AutoHotkey Help
		WinWaitActive, AutoHotkey Help
		Sendplay, !n
		SendPlay, !w%comand%{enter}
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