/*
#####################################
Context Sensitive Help by Avi Aryan #
v0.4                                #
#####################################
*/

#SingleInstance, force
SetWorkingDir, %A_scriptdir%

if !FileExist("Autohotkey.chm")		;Searching for Help file
{
	RegRead, ovar, HKLM, SOFTWARE\AutoHotkey, InstallDir
	if !FileExist(ovar "\Autohotkey.chm")
	{
		FileSelectFile, selfile,,,Select Autohotkey Help file,Autohotkey Help(Autohotkey.chm)
		Helpfile := selfile
	}
	else
		Helpfile := ovar "\Autohotkey.chm"
}
else
	Helpfile := "Autohotkey.chm"


;--- CONFIGURE -------------------------------------------------

F1::RunHelp(Helpfile)		;The shortcut key

;--- XXXXXXXXX -------------------------------------------------

RunHelp(Helpfile){

	BlockInput, Sendandmouse
	oldclip := ClipboardAll
	Send, +{End}^c
	copiedcode1 := Clipboard	;rightside
	Send, {Home}+{End}^c{Right}
	copiedcode2 := Clipboard
	leftofcaret := Substr(copiedcode2, 1, Instr(copiedcode2, copiedcode1, false, 0)-1) 	;leftside
	
	if ( ( !Instr(copiedcode1, " ") ? Strlen(copiedcode1) : Instr(copiedcode1, " ") ) > ( !Instr(copiedcode1, "(") ? Strlen(copiedcode1) : Instr(copiedcode1, "(") ) )
		needles := "=|+|-|*|?|:|(|% |%	|\|/|,"		;added /\,
	else
		needles := "=|+|-|*|?|:|(|% |%	"
	
	copiedcode := Ltrim( (temp_pos := SuperInstr(leftofcaret, needles, 0, false, 0)) ? Substr(leftofcaret, temp_pos+1) : leftofcaret )
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
