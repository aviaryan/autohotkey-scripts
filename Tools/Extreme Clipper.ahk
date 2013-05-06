/*
ProgramName = Anywhere Clipper
ProgramVersion = 3
Author = Avi Aryan
Special Thanks = Sean
****************************************************
IMPORTANT
####################################################################################
The complete package with the Clipper.dll can be downloaded from my site . 
http://avi-win-tips.blogspot.in/2013/05/extremeclipper.html
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
#Include, HotkeyParser.ahk