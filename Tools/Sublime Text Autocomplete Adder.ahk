; INSTRUCTIONS ##########################################
;Sublime-Text Autocomplete Adder
;By Avi Aryan
;
;Tested with Sublime-Text 2
;Absolutely No guaranty
;Make sure to create a backup before going
;Don't worry about Duplicates, they will not be added again.
;########################################################
;Write your completes in listed form, one auto-complete in a line.

;You can also drag files which has list of auto-completes to get its
;contents.
;########################################################
;See Also - http://www.autohotkey.com/board/topic/91066-sublime-4-autohotkey/
;########################################################

SetWorkingDir, %a_scriptdir%
SetBatchLines, -1

;********************************************
Menu,Tray,NoStandard
Menu,Tray,Tip,ST Auto-Complete Adder by Avi Aryan
Menu,Tray,Add,My Blog,blog
Menu,Tray,Add
Menu,Tray,Add,Quit,quit
Menu,Tray,Default,My Blog

Gui, Font, S11 CRed, Consolas
Gui, Add, Text, x2 y0 w490 h30 vfiledrop, Drag a (.sublime-completions file) here
Gui, Font, s9
Gui, Add, Edit, x2 y30 w490 h40 vfilepath +Disabled +Wrap, <<<<DRAG>>>>>
Gui, font, s11
Gui, Add, Text, x2 y70 w490 h20 , Drag a file on edit box to load the lists
Gui, Add, Text, x2 y90 w500 h30 , Duplicates will not be added
Gui, Font, S10 CBlack, Verdana
Gui, Add, Edit, x2 y130 w490 h420 vlist,Your List should be typed here.`nOne Completion/line`n`nlike----`n`nrun`nparse`nbuild`nargs`n....
Gui, Add, Button, x192 y560 w90 h30 , Add
Gui, Show, w501 h597, Avis Sublime-Text Autocomplete Adder
return
 
GuiClose:
ExitApp
 
ButtonAdd:
Gui,submit,nohide

IfnotEqual,filepath,<<<<DRAG>>>>>
{
FileRead,filetoadd,%filepath%
SplitPath,filepath,,dir,,name
FileCopy,%filepath%,%dir%/%name%_old.sublime-completions,1
 
StringGetPos,closingbracket,filetoadd,],R
StringLeft,firstpart,filetoadd,%closingbracket%
StringTrimLeft,secondpart,filetoadd,%closingbracket%
StringGetPos,posofcurly,firstpart,},R
posofcurly+=1
StringLeft,firstpart,firstpart,%posofcurly%
firstpart = %firstpart%,
 
loop,parse,list,`n
{
StringReplace,loopsave,a_loopfield,",,All    						;Dont use " in completions
IfNotEqual,loopsave
	IfNotInString,firstpart,{ "trigger": "%loopsave%"
		firstpart = %firstpart%`r`n%a_tab%%a_tab%{ "trigger": "%loopsave%", "contents": "%loopsave%" },
}
 
StringTrimright,firstpart,firstpart,1
filetoadd = %firstpart%`r`n%secondpart%
FileDelete,%filepath%
FileAppend,%filetoadd%,%filepath%
MsgBox, 64, Hello, Completions Added!`n`nA backup of original file created as --`n%dir%/%name%_old.sublime-completions
filetoadd = 
firstpart = 
secondpart = 
GuiControl,,list,
}
else
	MsgBox, 16, WTF, First drag a (.sublime-completions) file
return
 
GuiDropFiles:
IfEqual,A_GuiControl,list
{
Loop, parse, A_GuiEvent, `n
{
    FileRead,contents,%a_loopfield%
    Break
}
Gui, submit, nohide
GuiControl,,list,%list%`n%contents%
}

If A_GuiControl in filedrop,filepath
{
Loop, parse, A_GuiEvent,`n
{
    Guicontrol,,filepath,%A_loopfield%
    Break
}
}
return

blog:
run, "http://www.avi-win-tips.blogspot.com"
return
quit:
Exitapp
return