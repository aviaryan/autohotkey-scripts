/*
HTML Tagger v0.2
	by Avi Aryan

Licensed under Apache License v2.0

#### BASICS ####
	Select Text you want to apply tags to.
	Hold Ctrl, then tap H to cycle between different Items OR tags available
	Release Ctrl to apply
	While holding Ctrl, tap X to cancel Tag operation
	While holding Ctrl, tap D to delete Tooltip active item

	Use Win+H to show a GUI which will enable you to add more tag items to the program.

See Documentation at :- 
	avi-aryan.github.io/ahk/tools/htmltag.html

*/

HtmlTag_AutoExec()
TagObjIndex := 1

;---- CONFIGURE -----------------------------------------------------

Hotkey, ^h, Tag_Cycle, On 		;Main hotkey (DONT CHANGE)
#h::Tag_AddGui()			;Hotkey to show Tag Adding GUI (CHANGEABLE)

;--------------------------------------------------------------------
return

HtmlTag_AutoExec(){
	global

	;NOTES
	;Comment F - Delim `n Textp `n CaretP
	SetWorkingDir, %A_ScriptDir%
	#SingleInstance force
	Menu, Tray, Icon,% A_ProgramFiles "\Internet Explorer\iexplore.exe"

	Ini := new AhkIni("HtmlTag.ini")

	if !Ini.Read()
	{
		Ini.write("Main", "<h1>", "<h1>|</h1>", " ", "The comments linked to keys contain Delimiter and TextPoint")
		Ini.write("Main", "<code>", "<code>|</code>")		;No Delimchar, Textpoint, Caret setting means default behaviour
		Ini.write("Main", "<a>_-_Select link", "<a href=""|""></a>", "|`n1`n3")		;3 for <--link-->	">	
		Ini.Save()
	}
	;Read from Ini

	Keylist := Ini.read("Main") , TagObj := {}
	loop, parse, Keylist, `n, `r
		TagObj[A_index] := A_LoopField

}

Tag_Cycle:
	ToolText := "`n`nNEXT to come --" , MaxNum := TagObj.MaxIndex()
	SetTimer, Tag_Lwinup, 60
	Hotkey, ^x, Tag_Cancel, On
	Hotkey, ^d, Tag_Cancel, On

	loop 5
		ToolText .= "`n`t" TagObj[ (TagObjIndex+A_index) > MaxNum ? TagObjIndex+A_Index-MaxNum : TagObjIndex+A_index]

	Tooltip,% " " TagObj[TagObjIndex] ToolText
	TagObjIndex+=1
	if ( TagObjIndex > MaxNum )
		TagObjIndex := 1
	return

Tag_Lwinup:
	if !GetKeyState("Ctrl")
	{
		ToolTip
		TagObjIndex := TagObjIndex=1 ? TagObj.MaxIndex() : TagObjIndex-1

		temp_val := ini.read("Main", TagObj[TagObjIndex], temp_com)
		p1 := "|" , p2 := 1 , p3 := 0

		loop, parse, temp_com, `n, `r
			p%A_index% := A_LoopField

		HtmlTag(temp_val, p1, p2, p3)
		SetTimer, Tag_Lwinup, Off
	}
	return

Tag_Cancel:
	if Instr(A_ThisHotkey, "^x")
		ToolTip, HTMLTagging Cancelled !
	else
	{
		Tooltip, Item Deleted !
		Ini.Delete("Main", TagObjIndex=1 ? TagObj[Temp := TagObj.MaxIndex()] : TagObj[Temp := TagObjIndex-1]) , Ini.Save()
		TagObj.Remove(Temp)
	}

	SetTimer, Tag_Lwinup, Off
	Hotkey, ^x, Tag_Cancel, Off
	Hotkey, ^d, Tag_Cancel, Off

	TagObjIndex := 1
	sleep, 700
	ToolTip
	return

;++++++++++++++++++++++
;HTMLTag() function   +
;++++++++++++++++++++++

HtmlTag(Mask, DelimChar="|", Textpoint=1, Caret_withText=0){

	static clipjumpcall := IsFunc("CjControl") ? 1 : 0 , cj := "CjControl"		;Clipjump mamagement . Will not affect speed if Clipjump is not running
	;OR ClipjumpCommuniator.ahk is not included

	oldclip := ClipboardAll , T := clipjumpcall ? Cj.(0) : ""

	Clipboard := emptyvar
	Send, ^c
	sleep 100		;If the script fails to perform, increase this number

	if Clipboard =
	{
		T := clipjumpcall ? Cj.(1) : "" , Clipboard := oldclip
		return
	}

	If !Textpoint
		toSend := Clipboard

	loop, parse, Mask,% DelimChar, %A_space%%A_tab%
	{
		if startcount
			startcount+=Strlen(A_LoopField)
		ToSend .= A_LoopField
		if ( A_index == TextPoint )
			ToSend .= Clipboard , startcount := -Caret_withText+2
	}

	if Strlen(ToSend) > 100
	{
		Clipboard := ToSend 	;Clipboard may not work at all times, as a result it is used only when needed
		ClipWait
		Send, ^v
	}
	Else SendPlay % ToSend

	Clipboard := oldclip

	if Caret_withText
		Send % "{Left " startcount-1 "}"
	T := clipjumpcall ? Cj.(1) : ""
}

;-----------
;GUI

Tag_AddGui(){
	global
	static IsGuicreated
	;local IsGuicreated

	if !IsGuicreated
	{
		IsGuicreated := 1

		Gui, HtmlTag:New
		Gui, Font, s11, Arial
		Gui, Add, Text, x10 y10 w200 h40, LABEL
		Gui, Add, Text, xp yp+60 wp hp, Mask
		Gui, Add, Text, xp yp+60 wp hp, Text Point
		Gui, Add, Text, xp yp+60 wp hp, Caret Insertion point
		Gui, Add, Text, xp yp+60 wp hp, Delimeter
		Gui, Font, s10
		Gui, Add, Edit, xp+290 y10 w300 h20 vName, 
		Gui, Add, Edit, xp yp+60 wp hp vMask, <h1>|</h1>
		Gui, Add, Edit, xp yp+60 wp hp vTextP, 1
		Gui, Add, Edit, xp yp+60 wp hp vCaretP, 0
		Gui, Add, Edit, xp yp+60 wp hp VDelim, |

		Gui, Add, Button, xp-290 yp+100 w100 h30, Save
		Gui, Add, Button, xp+450 yp wp hp, Cancel

	}
	if !WinExist("HtmlTag Adder ahk_class AutoHotkeyGUI")
		Gui, HtmlTag:Show,, HtmlTag Adder
	Else
		Gui, HtmlTag:Hide
	return

HtmlTagButtonSave:
	Gui, HtmlTag:submit, Hide
	Ini.Write("Main", Name, Mask, Delim "`n" TextP "`n" CaretP) , Ini.Save()
	TagObj[TagObj.MaxIndex()+1] := Name
	return

HtmlTagButtonCancel:
	Gui, HtmlTag:Hide
	temp := "Name, Mask, Delim, TextP, CaretP"
	loop, parse, temp, `,
		Guicontrol, HtmlTag:,% A_LoopField
	return

}

;--------------- FUNCTIONS -----------------------------------------------------

#Include S:\Portables\AutoHotkey\My Scripts\Libraries\AhkIni.ahk   ;http://www.autohotkey.com/board/topic/95162-
#Include S:\Portables\AutoHotkey\My Scripts\ClipStep\ClipjumpCommunicator.ahk 	;(OPTIONAL)
;https://github.com/avi-aryan/Clipjump/blob/master/ClipjumpCommunicator.ahk

;------------ TEMP -------------------------

/*
Tag_MainGUI(){
	global
	static IsGuicreated
	local IsGuicreated

	if !IsGuicreated
	{
		Gui, MainTag:New
		Gui, Font, s12, Consolas
		Gui, Add, Edit, x10 y10 w400 h30 vSearchBox gHtml_search
		Gui, Font, s11, Arial

		Gui, Add, ListView, xp yp+60 wp r20 AltSubmit gHtmlLV VHtmlLV, Tag|Mask
		IsGuicreated := 1
	}

	if !WinExist("HtmlTag ahk_class AutoHotkeyGUI")
		Gui, MainTag:Show,, HtmlTag
	else Gui, MainTag:Hide

	return

Html_search:
	Gui, MainTag:Submit nohide
	return

}
*/