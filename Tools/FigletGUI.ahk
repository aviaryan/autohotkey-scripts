/*
 _____ _       _      _      ____ _   _ ___ 
|  ___(_) __ _| | ___| |_  / ___| | | |_ _|
| |_  | |/ _` | |/ _ \ __|| |  _| | | || | 
|  _| | | (_| | |  __/ |_ | |_| | |_| || | 
|_|   |_|\__, |_|\___|\__| \____|\___/|___|
         |___/                              
|_     
|_)\/
   / 
                                         
,---.      o    ,---.                    
|---|.    ,.    |---|,---.,   .,---.,---.
|   | \  / |    |   ||    |   |,---||   |
`   '  `'  `    `   '`    `---|`---^`   '
                          `---'          
v 0.0.0.1 beta
*/

;/ OPTIMIZATIONS
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir
#NoEnv
#NoTrayIcon
ListLines, Off
;//

;/VARS
global VERSION := "0.0.0.1b" , AUTHOR := "Avi Aryan" , HOMEPAGE := "http://aviaryan.github.io/ahk/tools/figletgui.html"
;//

if !FileExist("figlet.exe") {
	MsgBox, 16, Warning, Figlet.exe not found.`nPlease refer to the respactive website/manual.
	run % HOMEPAGE
	Exitapp
}

FileCreateDir, temp
Fgui()
return

getOutputfromFiglet(text, font="", options=""){
	if Instr(text, "`n") {
		FileDelete, temp\i.txt
		FileAppend, % text, temp\i.txt
		while !FileExist("temp\i.txt")
			sleep 10
		text := " -n < temp\i.txt"
	}
	else text := """" text """"

	FileDelete, temp\o.txt
	if font
		options .= " -f " font
	RunWait, % ComSpec " /c figlet.exe " text " " options " >temp\o.txt",, Hide
	FileRead, out, temp\o.txt
	FileDelete, temp\o.txt
	return out
}

Fgui(){
	global selfont, seloptions, theinput, theoutput, opwidth, zoomlevel
	static t_inputlbl, t_inputgb, t_copybtn

	wt := A_ScreenWidth/1.7
	ht := A_ScreenHeight/1.5

	Gui, fgui:New
	Gui, fgui:Default
	Gui, Margin, 7, 7
	Gui, Font, s14
	Gui, Add, Text, section, FigletGUI
	Gui, Font, s10
	Gui, Add, Button, % "x" wt-63 " yp gabout w70", About  	;+7 in x for the margin
	Gui, Font, s12
	Gui, Add, Groupbox, % "xs y+10 w" wt " h200 vt_inputgb", Input
		GuiControlGet, t_inputgb, fgui:pos
		outputL := ht - (t_inputgby + t_inputgbh) - 30 	; constant for accumulating button
	Gui, Font, s9
	Gui, Add, Text, xp+10 yp+30 section, Font:
	Gui, Add, DropDownList, x+5 yp-2 vselfont gfontChanged, % getFontList()
	Gui, Add, Text, x+30 yp+2, Output max Col Width
	Gui, Add, Edit, x+5 yp-2 w50 vopwidth goptionsChanged, 9999
	Gui, Add, Text, x+30 yp+2, Other Options
	Gui, Add, Edit, x+5 yp-2 vseloptions goptionsChanged,
	Gui, Add, Text, xs y+20 vt_inputlbl, Input Text
		GuiControlGet, t_inputlbl, fgui:pos
		inputL := 200 - t_inputlbly - t_inputlblh + 20 		; margins in gb
	Gui, Add, Edit, % "xp y+5 h" inputL " w" wt-20 " vtheinput +multi ginputChanged",  	;-20 as 10 from both sides

	Gui, Font, s12
	Gui, Add, Groupbox, % "xs-10 y+30 Section h" outputL " w" wt, Output
	Gui, Font, s6, Courier New
	Gui, Font, s6, Consolas
	Gui, Add, Edit, % "xp+10 yp+30 w" wt-20 " h" outputL-40 " vtheoutput +multi +HScroll +VScroll" 
	Gui, Font, s10, Arial
	Gui, Add, Button, % "xp-10 y+20 gcopyOutput vt_copybtn", % "Copy to Clipboard"
		;GuiControlGet, t_copybtn, fgui:pos
		sliderl := wt-160
	Gui, Add, Text, % "yp x" sliderl, Zoom
	Gui, Add, Slider,% "vzoomlevel yp Tooltip Range10-200 w120 gzoomChanged AltSubmit x" sliderl+40, 60
	Gui, Show,, FigletGUI
	return

fguiGuiClose:
	Gui, fgui:Destroy
	ExitApp
	return

zoomChanged:
	Gui, fgui:submit, nohide
	gui, fgui:Font, % "s" zoomlevel/10, Consolas
	GuiControl, fgui:Font, theoutput
	return

optionsChanged:
fontchanged:
inputChanged:
	Gui, fgui:Submit, nohide
	GuiControl, fgui:, theoutput, % getOutputfromFiglet(theinput, selfont, seloptions " -w9999")
	return

copyOutput:
	Gui, fgui:Submit, nohide
	Clipboard := theoutput
	return

}

about:
	MsgBox, 64, FigletGUI, A Gui Wrapper for Figlet by Avi Aryan.`nversion %version%`n`nSpecial thanks to tmplinshi for sharing his knowledge.
	return

getFontList(){
	loop, fonts\*.flf
		s .= "|" Substr(A_LoopFileName,1,-4)
	return s
}

;/-------------------------------------------------------------------------------------------

getControlInfo(type="button", text="", ret="w", fontsize="", fontmore=""){
	static test
	Gui, wasteGUI:New
	Gui, wasteGUI:Font, % fontsize, % fontmore
	Gui, wasteGUI:Add, % type, vtest, % text
	GuiControlGet, test, wasteGUI:pos
	Gui, wasteGUI:Destroy
	if ret in x,y,w,h
		return % ("test" ret)
}