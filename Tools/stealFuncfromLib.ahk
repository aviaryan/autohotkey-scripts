/*

stealFunc v0.01
	by Avi Aryan (http://avi.uco.im)

steals only the needed functions from a function library or script

EXAMPLE USAGE-
	Clipboard := stealFunc("Gdip_Startup`nGdip_SetBitmaptoClipboard`nGdip_CreateBitmapFromFile`nGdip_DisposeImage`nGdip_Shutdown", "<path_to_gdip_lib>")

*/

; gui function is at the very last - remove if not needed
stealFunc_gui()
return


stealFunc(funcs, file){
	flist := stealFunc_listfunc(file, z)
	included := " " , stolen := ""
	loop, parse, funcs, `n
		stealFunc_extractfunc(z, A_LoopField, flist, stolen, included)
	return stolen
}

stealFunc_IsDefault(func){ ; not using IsFunc()
	static l := " Abs ACos Asc ASin ATan Ceil Chr Cos DllCall Exception Exp FileExist Floor GetKeyState IL_Add IL_Create IL_Destroy InStr IsFunc IsLabel Ln Log LV_Add "
	. "LV_Delete LV_DeleteCol LV_GetCount LV_GetNext LV_GetText LV_Insert LV_InsertCol LV_Modify LV_ModifyCol LV_SetImageList Mod NumGet NumPut OnMessage RegExMatch "
	. "RegExReplace RegisterCallback Round SB_SetIcon SB_SetParts SB_SetText Sin Sqrt StrLen SubStr Tan TV_Add TV_Delete TV_GetChild TV_GetCount TV_GetNext TV_Get "
	. "TV_GetParent TV_GetPrev TV_GetSelection TV_GetText TV_Modify TV_SetImageList VarSetCapacity WinActive WinExist Trim LTrim RTrim FileOpen StrGet StrPut StrPut "
	. "GetKeyName GetKeyVK GetKeySC IsByRef IsObject ObjInsert ObjInsert ObjInsert ObjRemove ObjMinIndex ObjMaxIndex ObjSetCapacity ObjSetCapacity "
	. "ObjGetCapacity ObjGetAddress ObjNewEnum ObjAddRef ObjRelease ObjHasKey ObjClone "
	return Instr(l, A_Space func A_Space)
}

stealFunc_listfunc(file, byref compactfile="")
{
	z := compactfile := stealFunc_compactFile(file)
	z := RegExReplace(z, "mU)""[^`n]*""", "") ; strings
	z := RegExReplace(z, "m);[^`n]*", "")  ; single line comments
	z := RegExReplace(z, "`n( |`t)+", "`n") 	; trim
	z := RegExReplace(z, "if [^`n\)]{", "") 	; remove to not match cases like    	if var = {   -  idea is safe as funcs dont contain spaces
	z := RegExReplace(z, "[^:]=[^`n\)]{", "") 		; var={somethind} - not match obj := {something}
	p:=1 , z := "`n" z
	while q:=RegExMatch(z, "iU)`n[^ `t`n,;``\(\):=\?]+\([^`n]*\)(\s)*\{", o, p)
	{
		if Instr(o, "while(") = 2
		{ ; while is not a func - 2 as while will be after `n
			p := q+Strlen(o)-1
			continue
		}

		str := Substr(z, 1, q) 		; get part before func
		StringReplace, str, str, `n, `n, UseErrorLevel
		start_lineno := ErrorLevel 		; get func start line no
		str := Substr(z, q+1) 		; part after func
		ob := {} , ob["{"] := ob["}"] := 0 	; obj to store {} counts
		loop, parse, str
		{
			if A_LoopField in {,}
			{
				ob[A_LoopField] += 1
				if ob["{"] == ob["}"]
				{
					cp := A_index
					break
				}
			}
		}
		str2 := Substr(str, 1, cp) 		; string containing the function
		cb_pos := Instr(str2, "`n", 0, 0) 		; pos of `n closing the function
		str2 := Substr(str2, 1, cb_pos) 	; string till the linefeed
		StringReplace, str2, str2, `n, `n, UseErrorLevel 		; count `n in string
		end_lineno_rel := ErrorLevel 	; relative ending point
		end_lineno := start_lineno + end_lineno_rel 		; real ending point

		lst .= "`n" Substr( RegExReplace(o, "\(.*", ""), 2) " " start_lineno " " end_lineno
		, p := q+Strlen(o)-1
	}
	return lst "`n" 		; append `n to make a systematic strcuture
}

; compacts file - removes comments
; set file as "some text" to make the function take it as file content
stealFunc_compactFile(file){
	if FileExist(file)
		FileRead, z, % file
	else z := file
	StringReplace, z, z, `r, , All
	return z := RegExReplace(z, "iU)`n/\*.*`n\*/", "") ; block comments
}

; extracts functions from compact file
stealFunc_extractfunc(compactfile, fname, flist, byref stolen, byref included){
	if (Instr(included, " " fname " ")) or (!Instr(flist, "`n" fname " ")) or (stealFunc_IsDefault(fname))		; if func is added
		return

	coords := Substr(flist, Instr(flist, "`n" fname " ")+1) , coords := Substr(coords, Instr(coords, " ")+1, Instr(coords, "`n")-Instr(coords, " ")-1) 	; get func line nos
	s := Substr(coords, 1, Instr(coords, " ")-1) 	; start line no
	e := Substr(coords, Instr(coords, " ")+1) 	; end line no
	r := Substr(compactfile, sp:=Instr(compactfile, "`n", 0, 1, s-1)+1, Instr(compactfile, "`n", 0, 1, e-1)-sp+2) 	; the func extracted between line numbers
	stolen := stolen "`n" r , included .= fname " "
	; recursive processing
	rs := Substr(r, Instr(r,"`n")+1)
	rs := RegExReplace(rs, "mU)""[^`n]*""", "") ; strings
	rs := RegExReplace(rs, "m);[^`n]*", "")  ; single line comments  -- block comment is already removed
	p := 1
	while q:=RegExMatch(rs, "iU)[^ !`t`n,;``\(\):=\?]+\(.*\)", o, p)
	{
		fn := Trim(RegExReplace(o, "\(.*", ""))
		p := q+Strlen(o)-1
		if ( fn == "" ) or stealFunc_IsDefault(fn)
			Continue
		stealFunc_extractfunc(compactfile, fn, flist, stolen, included)
	}
}

;-------------------------------- GUI -----------------------------------
; remove if not needed

stealFunc_gui(){
	global list, file, out

	w := A_ScreenWidth / 2
	Gui, stealFunc:new
	Gui, font, s12 Bold
	Gui, Add, Text, x0 y0, StealFunc
	Gui, font, s10 Normal
	Gui, Add, Text, y+20 x7 w150, List of functions to extract
	Gui, Add, Edit, % "x+10 w" w-200 " vlist +multi r5", 
	Gui, Add, Text, y+30 x7 w150, Input script file (Drop)
	Gui, Add, Edit, % "x+10 w" w-200 " vfile"
	Gui, Add, Text, y+30 x7 w150, Output
	Gui, Add, Edit, % "x+10 w" w-200 " vout +multi r10"
	Gui, Add, Button, x7 y+40, Start
	Gui, font, s9, Consolas
	Gui, Show, w%w%, stealFunc
	return

stealFuncGuiClose:
	Exitapp
	return

stealFuncButtonStart:
	Gui, stealFunc:submit, nohide
	if FileExist(file)
	{
		out := stealFunc(list, file)
		GuiControl, stealFunc:, out, % out
	}
	else Msgbox, Enter a valid script file path
	return

stealFuncGuiDropFiles:
	loop, parse, A_GuiEvent, `n
	{
		file := A_loopfield
		break
	}
	GuiControl, stealFunc:, file, % file
	return


}