/*
------------
HTML & CSS  |
------------
##########################################
HTML+CSS Helper by Avi Aryan             #
Works with all Editors                   #
v0.2                                     #
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

	cjconst := CjControl(2)

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

	if cjconst>0
		CjControl(1)
	
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
		Controlsettext, Edit1,, A       ;another attempt to empty index field
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

;Clipjump Controller Function to make the script configure Clipjump to bypass temporary items in Clipjump
;The function is fast and will not slow your script, so need to remove it.

CjControl(ByRef Code)
{
    global
    local IsExe, TargetScriptTitle, CopyDataStruct, Prev_DetectHiddenWindows, Prev_TitleMatchMode, Z, S

    if ! (IsExe := CjControl_check())
        return -1       ;Clipjump doesn't exist

	TargetScriptTitle := "Clipjump" (IsExe=2 ? ".ahk ahk_class AutoHotkey" : ".exe ahk_class AutoHotkey")

    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
    SizeInBytes := (StrLen(Code) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
    NumPut(&Code, CopyDataStruct, 2*A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    Z := 0

    while !Z
    {
        SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%
        Z := ErrorLevel
    }

    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%

    while !FileExist(A_temp "\clipjumpcom.txt")
       sleep 50
    FileDelete % A_temp "\clipjumpcom.txt"

    return 1        ;True
}

CjControl_check(){
    
    HW := A_DetectHiddenWindows , TM := A_TitleMatchMode
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    Process, Exist, Clipjump.exe
    E := ErrorLevel , A := WinExist("\Clipjump.ahk - ahk_class AutoHotkey")
    DetectHiddenWindows,% HW
    SetTitleMatchMode,% TM

    return E ? 1 : (A ? 2 : 0)
}