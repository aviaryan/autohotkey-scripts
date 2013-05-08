/*
ProgramName = Anywhere Clipper
ProgramVersion = 3
Author = Avi Aryan
Special Thanks = Sean
****************************************************
IMPORTANT
####################################################################################
The Clipper.dll ( renamed as Gflax.dll ) can be downloaded from the link. 
https://dl.dropboxusercontent.com/u/116215806/Products/BlogTemp/GflaxDLL.7z
####################################################################################
.......................
INSTRUCTIONS
***************************************************
1. Tap PrintScreen to capture whole Screen.
2. To Capture selected area of Screen,tapPrintScreen (PrimaryKey), then hold Left Mouse button (Secondary Key) and then select the area you want to capture.
   Release to capture.
3. By Default, Run After Finish is enabled which opens the Captures directory after you take the Screenshot.
4. By Default, Resize Prompt is enables which enables you to resize your clipped picture on the go!!.
......................

Happy Clipping!
Enjoy!!

*/
SetWorkingDir, %a_scriptdir%
ProgramName = Extreme Clipper
ProgramVersion = 3
Author = Avi Aryan

IfNotExist, %A_ScriptDir%/Settings.ini
{
iniwrite,jpg,Settings.ini,Main,Extension_To_Save_in
iniwrite,100,Settings.ini,Main,Quality_of_clips
iniwrite,1,Settings.ini,Main,Open_Capture_Directory_After_Finish
iniwrite,1,Settings.ini,Main,Resize_Clip_After_Capturing
iniwrite,PrintScreen,Settings.ini,Keys,PrimaryKey
IniWrite,LeftMousebutton,Settings.ini,Keys,SecondaryKey
}
;-----------------------CONFIGURE--------------------------------------------------------------------
IniRead,extension,Settings.ini,Main,Extension_To_Save_in
IniRead,qualityofpic,Settings.ini,Main,Quality_of_clips
IniRead,runafterfinish,Settings.ini,Main,Open_Capture_Directory_After_Finish
IniRead,resizeprompt,Settings.ini,Main,Resize_Clip_After_Capturing
IniRead,PrimaryHotkey,Settings.ini,Keys,PrimaryKey
IniRead,SecondaryHotkey,Settings.ini,Keys,SecondaryKey

Menu, Tray, Nostandard
Menu, Tray, Add, %ProgramName%, blog
Menu, Tray, Add, %Author%, me
Menu, Tray, Add
Menu, Tray, Add, Help, help
Menu, Tray, Add
Menu, Tray, Add, Quit, quit
Menu, Tray, Default, %ProgramName%

IfEqual,resizeprompt,0
	resizeprompt := 
else
	resizeprompt := True

IfEqual,runafterfinish,0
	runafterfinish := 
else
	runafterfinish := True

PrimaryHotkey := (HParse(PrimaryHotkey) == "") ? ("PrintScreen") : (Hparse(PrimaryHotkey))
SecondaryHotkey := (HParse(SecondaryHotkey) == "") ? ("LButton") : (Hparse(SecondaryHotkey))
RunWait, regsvr32.exe /s "%A_scriptdir%/clipper.dll"
OnExit, quit

;-----------------------End--------------------------------------------------------------------------
#NoEnv
#SingleInstance force
SetBatchLines, -1
CoordMode, Mouse, Screen
CustomColor = EEAA99
Gui, Color, CB2322
gui, +Lastfound +AlwaysOnTop -Caption +ToolWindow
WinSet, TransColor, %CustomColor% 50
Menu, Tray, Tip, %programname% by %author%
;
gui, 2:+AlwaysonTop +ToolWindow
Gui, 2:Font, S16 CDefault Bold, Verdana
Gui, 2:Add, Text, x2 y0 w560 h30 +Center, Extreme-Clipper Resizer by Avi
Gui, 2:Font, S12 CRed Bold, Verdana
Gui, 2:Add, Text, x2 y70 w110 h20 , Original
Gui, 2:Font, S10 CBlue Bold, Verdana
Gui, 2:Add, Text, x152 y40 w110 h20 +Center, height
Gui, 2:Add, Text, x402 y40 w110 h20 +Center, width
Gui, 2:Font, S12 CGreen Bold, Verdana
Gui, 2:Add, Text, x2 y120 w110 h20 , Custom
Gui, 2:Add, Text, x2 y170 w120 h40 , By Percent`n(Of Original)
Gui, 2:Font, S10 CBlack, Verdana
Gui, 2:Add, Edit, x152 y70 w110 h20 +ReadOnly voright, 
Gui, 2:Add, Edit, x402 y70 w110 h20 +ReadOnly vorigwt, 
Gui, 2:Add, Edit, x152 y120 w110 h20 vnewht, 
Gui, 2:Add, Edit, x402 y120 w110 h20 vnewwt, 
Gui, 2:Add, Edit, x152 y170 w110 h30 vpercy gpercych, 
Gui, 2:Add, Edit, x402 y170 w110 h30 vpercx gpercxch, 
Gui, 2:Font, S12 CRed, Verdana
Gui, 2:Add, Button, x412 y260 w100 h30 , Cancel
Gui, 2:Add, Button, x40 y260 w100 h30 , Done

Hotkey,%PrimaryHotkey%,capture,On
return
;*=====================================================================================================================

capture:
gosub, varclean
Hotkey,%SecondaryHotkey%,justtofool,On

IfNotExist, Captures
	FileCreateDir, Captures
loop
{
IfnotExist, Captures\ScreenShot%a_index%.%extension%
{
filename = Captures\ScreenShot%a_index%.%extension%
break
}
}

KeyWait,%SecondaryHotkey%, D T1
if errorlevel = 0
{
MouseGetPos,initialx,initialy
SetTimer,guimover,100
KeyWait,%SecondaryHotkey%
Hotkey,%SecondaryHotkey%,justtofool,Off
sleep, 120																		;Should use 100, but just to be safe..!
SetTimer,guimover,off
gui, hide
MouseGetPos,finalx,finaly
if (!(isright))
{
	intmdx := finalx
	finalx := initialx
	initialx := intmdx
}
if (!(isdown))
{
	intmdy := finaly
	finaly := initialy
	initialy := intmdy
}

CaptureScreen(initialx, initialy, finalx, finaly, (finalx - initialx), (finaly - initialy), False, fileName, qualityofpic)
if (resizeprompt)
	gosub, resizer
if !(proceed)
	FileDelete, %filename%
else
	DoResize(filename, newwt, newht)
}
else
{
	Hotkey,%SecondaryHotkey%,justtofool,Off
	SysGet, initialx, 76
	SysGet, initialy, 77
	SysGet, finalx, 78
	SysGet, finaly, 79

CaptureScreen(initialx, initialy, finalx, finaly, (finalx - initialx), (finaly - initialy), False, fileName, qualityofpic)
if (resizeprompt)
	gosub, resizer
if !(proceed)
	FileDelete, %filename%
else
	DoResize(filename, newwt, newht)
}

If (runafterfinish)
{
if (proceed)
{
IfWinNotExist,Captures ahk_class CabinetWClass
	run, %a_scriptdir%/Captures
else
	WinActivate, Captures ahk_class CabinetWClass
}
}
EmptyMem()
return

/*
SUBS==========================================================================|
*/

guimover:
MouseGetPos,tempx,tempy
width := tempx - initialx
height := tempy - initialy
IfGreater,tempx,%initialx%
	isright := true
else
	isright := false
IfGreater,tempy,%initialy%
	isdown := true
else
	isdown := false

If !(isright)
	width := initialx - tempx
If !(isdown)
	height := initialy - tempy

;Anti-Movement Handling  :)
if (!(isright) and !(isdown))
	gui, show, x%tempx% y%tempy% h%height% w%width%
	else if (!(isright))
		gui, show, x%tempx% y%initialy% h%height% w%width%
		else if (!(isdown))
			gui, show, x%initialx% y%tempy% h%height% w%width%
			else
				gui, show, x%initialx% y%initialy% h%height% w%width%
return

resizer:
Gui, 2:Show, w566 h308, Extreme Clipper Resizer
WinActivate, Extreme Clipper Resizer
GuiControl, 2:,oright,% finaly - initialy
GuiControl, 2:,origwt,% finalx - initialx
GuiControl, 2:,newht,% finaly - initialy
GuiControl, 2:,newwt,% finalx - initialx
WinWaitClose, Extreme Clipper Resizer
return

percych:
percxch:
gui, 2:submit, nohide
newwt := (percx*origwt)/100
newht := (percy*oright)/100
gosub, decimalrem
GuiControl, 2:,newwt,%newwt%
GuiControl, 2:,newht,%newht%
return

2ButtonDone:
proceed := true
gui, 2:submit,hide
return

2guiclose:
2buttoncancel:
proceed := false
newht = 
newwt = 
gui, 2:hide
return

decimalrem:
StringGetPos,pos,newht,.,L
StringLeft,newht,newht,%pos%
StringGetPos,pos,newwt,.,L
StringLeft,newwt,newwt,%pos%
return

varclean:
proceed := true
newht = 
newwt = 
return

justtofool:
return

;**************************************COMPILED*****************************************
blog:
run, http://www.avi-win-tips.blogspot.com
return
me:
run, https://github.com/Avi-Aryan
return
help:
run, %A_ScriptDir%/Help Files/FAQ and Usage.html
return
quit:
RunWait, regsvr32.exe /u /s "%A_scriptdir%/clipper.dll"
ExitApp
return

DoResize(filename, width, height){
try{
gfx := ComObjCreate("GflAx.GflAx")
gfx.LoadBitmap(filename)
gfx.Resize(width + 0, height + 0)
gfx.savebitmap(filename)
ObjRelease(gfx)
Emptymem()
}
catch{
MsgBox, 16, WARNING, Looks like Clipper.dll isn't present in Extreme Clipper's directory or the program hasn't got enough administrative rights. `nTry re-downloading the package or running the program as Administrator
}
}

EmptyMem(){
dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
}
;========================================FUNCTION=======================================
/*
 % -------------------------------------------------------------------------------------
 %	Screen Capture with Transparent Windows and Mouse Cursor Function by SEAN
 %
 %	http://www.autohotkey.com/forum/topic18146.html
 %
 %  This is a modified form of the function.For original function, see above link.
*/

CaptureScreen(inix, iniy, finx, finy, rt5, rt6, bCursor = False, sFile = "", nQuality = "")
{
	nL := inix
	nT := iniy
	nW := finx - inix
	nH := finy - iniy
	znW := rt5
	znH := rt6

	mDC := DllCall("CreateCompatibleDC", "Uint", 0)
	hBM := CreateDIBSection(mDC, nW, nH)
	oBM := DllCall("SelectObject", "Uint", mDC, "Uint", hBM)
	hDC := DllCall("GetDC", "Uint", 0)
	DllCall("BitBlt", "Uint", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", hDC, "int", nL, "int", nT, "Uint", 0x40000000 | 0x00CC0020)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	If	bCursor
		CaptureCursor(mDC, nL, nT)
	DllCall("SelectObject", "Uint", mDC, "Uint", oBM)
	DllCall("DeleteDC", "Uint", mDC)
	If	znW && znH
		hBM := Zoomer(hBM, nW, nH, znW, znH)
	If	sFile = 0
		SetClipboardData(hBM)
	Else	Convert(hBM, sFile, nQuality), DllCall("DeleteObject", "Uint", hBM)
}

CaptureCursor(hDC, nL, nT)
{
	VarSetCapacity(mi, 20, 0)
	mi := Chr(20)
	DllCall("GetCursorInfo", "Uint", &mi)
	bShow   := NumGet(mi, 4)
	hCursor := NumGet(mi, 8)
	xCursor := NumGet(mi,12)
	yCursor := NumGet(mi,16)

	VarSetCapacity(ni, 20, 0)
	DllCall("GetIconInfo", "Uint", hCursor, "Uint", &ni)
	xHotspot := NumGet(ni, 4)
	yHotspot := NumGet(ni, 8)
	hBMMask  := NumGet(ni,12)
	hBMColor := NumGet(ni,16)

	If	bShow
		DllCall("DrawIcon", "Uint", hDC, "int", xCursor - xHotspot - nL, "int", yCursor - yHotspot - nT, "Uint", hCursor)
	If	hBMMask
		DllCall("DeleteObject", "Uint", hBMMask)
	If	hBMColor
		DllCall("DeleteObject", "Uint", hBMColor)
}

Zoomer(hBM, nW, nH, znW, znH)
{
	mDC1 := DllCall("CreateCompatibleDC", "Uint", 0)
	mDC2 := DllCall("CreateCompatibleDC", "Uint", 0)
	zhBM := CreateDIBSection(mDC2, znW, znH)
	oBM1 := DllCall("SelectObject", "Uint", mDC1, "Uint",  hBM)
	oBM2 := DllCall("SelectObject", "Uint", mDC2, "Uint", zhBM)
	DllCall("SetStretchBltMode", "Uint", mDC2, "int", 4)
	DllCall("StretchBlt", "Uint", mDC2, "int", 0, "int", 0, "int", znW, "int", znH, "Uint", mDC1, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", 0x00CC0020)
	DllCall("SelectObject", "Uint", mDC1, "Uint", oBM1)
	DllCall("SelectObject", "Uint", mDC2, "Uint", oBM2)
	DllCall("DeleteDC", "Uint", mDC1)
	DllCall("DeleteDC", "Uint", mDC2)
	DllCall("DeleteObject", "Uint", hBM)
	Return	zhBM
}

Convert(sFileFr = "", sFileTo = "", nQuality = "")
{
	If	sFileTo  =
		sFileTo := A_ScriptDir . "\screen.bmp"
	SplitPath, sFileTo, , sDirTo, sExtTo, sNameTo

	If Not	hGdiPlus := DllCall("LoadLibrary", "str", "gdiplus.dll")
		Return	sFileFr+0 ? SaveHBITMAPToFile(sFileFr, sDirTo . "\" . sNameTo . ".bmp") : ""
	VarSetCapacity(si, 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "UintP", pToken, "Uint", &si, "Uint", 0)

	If	!sFileFr
	{
		DllCall("OpenClipboard", "Uint", 0)
		If	 DllCall("IsClipboardFormatAvailable", "Uint", 2) && (hBM:=DllCall("GetClipboardData", "Uint", 2))
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", hBM, "Uint", 0, "UintP", pImage)
		DllCall("CloseClipboard")
	}
	Else If	sFileFr Is Integer
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", sFileFr, "Uint", 0, "UintP", pImage)
	Else	DllCall("gdiplus\GdipLoadImageFromFile", "Uint", Unicode4Ansi(wFileFr,sFileFr), "UintP", pImage)

	DllCall("gdiplus\GdipGetImageEncodersSize", "UintP", nCount, "UintP", nSize)
	VarSetCapacity(ci,nSize,0)
	DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "Uint", &ci)
	Loop, %	nCount
		If	InStr(Ansi4Unicode(NumGet(ci,76*(A_Index-1)+44)), "." . sExtTo)
		{
			pCodec := &ci+76*(A_Index-1)
			Break
		}
	If	InStr(".JPG.JPEG.JPE.JFIF", "." . sExtTo) && nQuality<>"" && pImage && pCodec
	{
	DllCall("gdiplus\GdipGetEncoderParameterListSize", "Uint", pImage, "Uint", pCodec, "UintP", nSize)
	VarSetCapacity(pi,nSize,0)
	DllCall("gdiplus\GdipGetEncoderParameterList", "Uint", pImage, "Uint", pCodec, "Uint", nSize, "Uint", &pi)
	Loop, %	NumGet(pi)
		If	NumGet(pi,28*(A_Index-1)+20)=1 && NumGet(pi,28*(A_Index-1)+24)=6
		{
			pParam := &pi+28*(A_Index-1)
			NumPut(nQuality,NumGet(NumPut(4,NumPut(1,pParam+0)+20)))
			Break
		}
	}

	If	pImage
		pCodec	? DllCall("gdiplus\GdipSaveImageToFile", "Uint", pImage, "Uint", Unicode4Ansi(wFileTo,sFileTo), "Uint", pCodec, "Uint", pParam) : DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Uint", pImage, "UintP", hBitmap, "Uint", 0) . SetClipboardData(hBitmap), DllCall("gdiplus\GdipDisposeImage", "Uint", pImage)

	DllCall("gdiplus\GdiplusShutdown" , "Uint", pToken)
	DllCall("FreeLibrary", "Uint", hGdiPlus)
}

CreateDIBSection(hDC, nW, nH, bpp = 32, ByRef pBits = "")
{
	NumPut(VarSetCapacity(bi, 40, 0), bi)
	NumPut(nW, bi, 4)
	NumPut(nH, bi, 8)
	NumPut(bpp, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
	NumPut(0,  bi,16)
	Return	DllCall("gdi32\CreateDIBSection", "Uint", hDC, "Uint", &bi, "Uint", 0, "UintP", pBits, "Uint", 0, "Uint", 0)
}

SaveHBITMAPToFile(hBitmap, sFile)
{
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
	hFile:=	DllCall("CreateFile", "Uint", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44)<<16, "Uint", 6, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", &oi+24, "Uint", 40, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44), "UintP", 0, "Uint", 0)
	DllCall("CloseHandle", "Uint", hFile)
}

SetClipboardData(hBitmap)
{
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
	hDIB :=	DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+NumGet(oi,44))
	pDIB :=	DllCall("GlobalLock", "Uint", hDIB)
	DllCall("RtlMoveMemory", "Uint", pDIB, "Uint", &oi+24, "Uint", 40)
	DllCall("RtlMoveMemory", "Uint", pDIB+40, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44))
	DllCall("GlobalUnlock", "Uint", hDIB)
	DllCall("DeleteObject", "Uint", hBitmap)
	DllCall("OpenClipboard", "Uint", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "Uint", 8, "Uint", hDIB)
	DllCall("CloseClipboard")
}

Unicode4Ansi(ByRef wString, sString)
{
	nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2)
	DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize)
	Return	&wString
}

Ansi4Unicode(pString)
{
	nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
	Return	sString
}
;#Include, HotkeyParser.ahk
/*
HParse()
© Avi Aryan
Page -http://avi-win-tips.blogspot.com/2013/04/hparse.html

Second Revision - 1/5/13
=================================================================
Extract Autohotkey hotkeys from user-friendly shortcuts reliably.
=================================================================

•The function handles spelling errors from users and tries to return the correct ahk hotkey for the corresponding shortcut as far as possible.
•It can manage totally invalid user shortcuts sent to it simply by eliminating the invalid part of the shortcut
•You can enable/disable [RemoveInvaild]  param if you want. Enabling (default) manages invalid parts by removing them, Disabling makes the return value blank when
 an invalid part in shortcut is occured. This blank return can be checked and used further to perform required measures.
•If possible the returned hotkey is tried to be kept in the standard without "ampersand" (&) format. If not possible it is returned in the correct (&) format. See the
 EXAMPLES below for more details.
•Standard User Shortcuts are by default meant to be separated by either the plus '+' or the dash '-' . eg -- Control + Alt + S , Control - S will work.
•User shortcut(s) such as  (X + Control)  will be converted to  (^x) and not (x^) via the [ManageOrder] Param which is enabled by default
•Shortcuts endings in modifiers are auto-detected and returned accordingly. eg -> (Control + Alt)  gives  ^Alt and not ^!
•No RegEx, so FASTER than it should be.
•Keys are arranged a/c popularity for maximum speed of the function.
•Supports all Autohotkey keys including Joystick Keys.

==========================================
EXAMPLES - Pre-Runs
==========================================

• Hparse("Contro + S")			;returns ^s
• Hparse("Cotrol + ass + S")		;returns ^s
• Hparse("Cntrol + ass + S", false)		;returns <blank>   	As 'ass' is out of scope and RemoveInvaild := false
• Hparse("Contrl + At + S")		;returns ^!s
• Hparse("LeftContrl + X")		;returns Lcontrol & X
• Hparse("Contrl + Pageup + S")		;returns <blank>  As the hotkey is invalid
• HParse("PagUp + Ctrl", true)		;returns  ^PgUp  	as  ManageOrder is true (by default)
• HParse("PagUp + Ctrl", true, false)		;returns  <blank>  	as ManageOrder is false and hotkey is invalid
• HParse("Pageup + Paegdown")		;returns  PgUp & PgDn	
• Hparse("Ctrl + Alt + Ctrl + K")		;returns  <blank> 	as two Ctrls are wrong
• HParse("Mbuttn + LControl", true)		;returns  Mbutton & LControl
• HParse("Control + Alt")		;returns  ^Alt and NOT ^!
• HParse("Ctrl + F1 + Nmpd1")		;returns <blank>	As the hotkey is invalid
• HParse("Prbitscreen + f1")		;returns	PrintScreen & F1
• HParse("Prbitscreen + yyy")		;returns	PrintScreen		As RemoveInvalid is enabled by default.
• HParse("f1+ browser_srch")		;returns	F1 & Browser_Search
• HParse("Ctrl + joy1")			;returns	Ctrl & Joy1

###################################################################
PARAMETERS - HParse()
-------------------------------
HParse(Hotkey, RemoveInvalid, ManageOrder)
###################################################################

• Hotkey - The user shortcut such as (Control + Alt + X) to be converted

• RemoveInvalid(true) - Remove Invalid entries such as the 'ass' from (Control + ass + S) so that the return is ^s. When false the function will return <blank> when an
  invalid entry is found.
  
• ManageOrder(true) - Change (X + Control) to ^x and not x^ so that you are free from errors. If false, a <blank> value is returned when the hotkey is found un-ordered.

*/

HParse(Hotkey,RemoveInvaild = true,ManageOrder = true)
{

loop,parse,Hotkey,+-,%a_space%
{
if (Strlen(A_LoopField) != 1)
{
	parsed := LiteRegexM(A_LoopField)
	If !(RemoveInvaild)
	{
		IfEqual,parsed
		{
			Combo = 
			break
		}
		else
			Combo .= " & " . parsed
	}
	else
		IfNotEqual,parsed
			Combo .= " & " . parsed
}
else
	Combo .= " & " . A_LoopField
}

non_hotkey := 0
IfNotEqual, Combo		;Convert the hotkey to perfect format
{
StringTrimLeft,Combo,Combo,3
loop,parse,Combo,&,%A_Space%
{
if A_Loopfield not in ^,!,+,#
	non_hotkey+=1
}
;END OF LOOP
if (non_hotkey == 0)
{
StringRight,rightest,Combo,1
StringTrimRight,Combo,Combo,1
IfEqual,rightest,^
	rightest = Ctrl
	else IfEqual,rightest,!
		rightest = Alt
		ELSE IfEqual,rightest,+
			rightest = Shift
			else rightest = LWin
Combo := Combo . Rightest
}
;Remove last non
IfLess,non_hotkey,2
{
	IfNotInString,Combo,Joy
	{
	StringReplace,Combo,Combo,%A_Space%&%A_Space%,,All
	temp := Combo
	loop,parse,temp
	{
	if A_loopfield in ^,!,+,#
	{
		StringReplace,Combo,Combo,%A_loopfield%
		_hotkey .= A_loopfield
	}
	}
	Combo := _hotkey . Combo
	
	If !(ManageOrder)				;ManageOrder
		IfNotEqual,Combo,%temp%
			Combo = 
	
	temp := "^!+#"		;just reusing the variable . Checking for Duplicates Actually.
	IfNotEqual,Combo
	{
	loop,parse,temp
	{
	StringGetPos,pos,Combo,%A_loopfield%,L2
	IF (pos != -1){
		Combo = 
		break
	}
	}
	}
	;End of Joy
	}
	else	;Managing Joy
	{
	StringReplace,Combo,Combo,^,Ctrl
	StringReplace,Combo,Combo,!,Alt
	StringReplace,Combo,Combo,+,Shift
	StringReplace,Combo,Combo,#,LWin
	StringGetPos,pos,Combo,&,L2
	if (pos != -1)
		Combo = 
	}
}
else
{
	StringGetPos,pos,Combo,&,L2
	if (pos != -1)
		Combo = 
}
}

return, Combo
}

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
LiteRegexM(matchitem, primary=1)
{

regX := ListGen("RegX", primary)
keys := Listgen("Keys", primary)
matchit := matchitem

loop,parse,Regx,`r`n,
{
curX := A_LoopField
matchitem := matchit
exitfrombreak := false

loop,parse,A_LoopField,*
{
if (A_index == 1)
	if (SubStr(matchitem, 1, 1) != A_LoopField){
		exitfrombreak := true
		break
	}

if (comparewith(matchitem, A_loopfield))
	matchitem := Vanish(matchitem, A_LoopField)
else{
		exitfrombreak := true
		break
	}
}

if !(exitfrombreak){
		linenumber := A_Index
		break
	}
}

IfNotEqual, linenumber
{
StringGetPos,pos1,keys,`n,% "L" . (linenumber - 1)
StringGetPos,pos2,keys,`n,% "L" . (linenumber)
return, Substr(keys, (pos1 + 2), (pos2 - pos1 - 1))
}
else
	return,% LiteRegexM(matchit, 2)
}
; Extra Functions -----------------------------------------------------------------------------------------------------------------

Vanish(matchitem, character){
StringGetPos,pos,matchitem,%character%,L
StringTrimLeft,matchitem,matchitem,(pos + 1)
return, matchitem
}

comparewith(first, second)
{
if first is Integer
	IfEqual,first,%second%
		return, true
	else
		return, false

IfInString,first,%second%
	return, true
else
	return, false
}

;######################   DANGER    ################################
;SIMPLY DONT EDIT BELOW THIS . MORE OFTEN THAN NOT, YOU WILL MESS IT.
;###################################################################
ListGen(what,primary=1){
if (primary == 1)
{
IfEqual,what,Regx
Rvar = 
(
L*c*t
r*c*t
l*s*i
r*s*i
l*a*t
r*a*t
S*p*c
C*t*r
A*t
S*f
W*N
t*b
E*r
E*s*c
B*K
D*l
I*S
H*m
E*d
P*u
p*d
l*b*t
r*b*t
m*b*t
up
d*n
l*f
r*t
F*1
F*2
F*3
F*4
F*5
F*6
F*7
F*8
F*9
F*10
F*11
F*12
N*p*Do
N*p*D*v
N*p*M*t
N*p*d*Ad
N*p*S*t
N*p*E*r
s*l*k
c*l
n*l*k
p*s
c*t*b
pa*s
b*r*k
x*b*1
x*b*2
z*z*z*z*callmelazybuthtisisaworkaround
)
;====================================================
;# Original return values below (in respect with their above positions, dont EDIT)
IfEqual,what,Keys
Rvar = 
(
LControl
RControl 
LShift
RShift
LAlt
RAlt
space
^
!
+
#
Tab
Enter
Escape
Backspace
Delete
Insert
Home
End
PgUp
PgDn
LButton
RButton
MButton
Up
Down
Left
Right
F1
F2
F3
F4
F5
F6
F7
F8
F9
F10
F11
F12
NumpadDot
NumpadDiv
NumpadMult
NumpadAdd
NumpadSub
NumpadEnter
ScrollLock
CapsLock
NumLock
PrintScreen
CtrlBreak
Pause
Break
XButton1
XButton2
A_lazys_workaround
)
}
else
{
;here starts the second preference list.
IfEqual,what,Regx
Rvar=
(
N*p*0
N*p*1
N*p*2
N*p*3
N*p*4
N*p*5
N*p*6
N*p*7
N*p*8
N*p*9
F*13
F*14
F*15
F*16
F*17
F*18
F*19
F*20
F*21
F*22
F*23
F*24
N*p*I*s
N*p*E*d
N*p*D*N
N*p*P*D
N*p*L*f
N*p*C*r
N*p*R*t
N*p*H*m
N*p*Up
N*p*P*U
N*p*D*l
J*y*1
J*y*2
J*y*3
J*y*4
J*y*5
J*y*6
J*y*7
J*y*8
J*y*9
J*y*10
J*y*11
J*y*12
J*y*13
J*y*14
J*y*15
J*y*16
J*y*17
J*y*18
J*y*19
J*y*20
J*y*21
J*y*22
J*y*23
J*y*24
J*y*25
J*y*26
J*y*27
J*y*28
J*y*29
J*y*30
J*y*31
J*y*32
B*_B*k
B*_F*r
B*_R*e*h
B*_S*p
B*_S*c
B*_F*t
B*_H*m
V*_M*e
V*_D*n
V*_U
M*_N*x
M*_P
M*_S*p
M*_P*_P
L*_M*l
L*_M*a
L*_A*1
L*_A*2

)
IfEqual,what,keys
Rvar=
(
Numpad0
Numpad1
Numpad2
Numpad3
Numpad4
Numpad5
Numpad6
Numpad7
Numpad8
Numpad9
F13
F14
F15
F16
F17
F18
F19
F20
F21
F22
F23
F24
NumpadIns
NumpadEnd
NumpadDown
NumpadPgDn
NumpadLeft
NumpadClear
NumpadRight
NumpadHome
NumpadUp
NumpadPgUp
NumpadDel
Joy1
Joy2
Joy3
Joy4
Joy5
Joy6
Joy7
Joy8
Joy9
Joy10
Joy11
Joy12
Joy13
Joy14
Joy15
Joy16
Joy17
Joy18
Joy19
Joy20
Joy21
Joy22
Joy23
Joy24
Joy25
Joy26
Joy27
Joy28
Joy29
Joy30
Joy31
Joy32
Browser_Back
Browser_Forward
Browser_Refresh
Browser_Stop
Browser_Search
Browser_Favorites
Browser_Home
Volume_Mute
Volume_Down
Volume_Up
Media_Next
Media_Prev
Media_Stop
Media_Play_Pause
Launch_Mail
Launch_Media
Launch_App1
Launch_App2

)
}
;<<<<<<<<<<<<<<<<END>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
return, Rvar
}