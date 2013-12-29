/*
################################################################
MY MISCELLANEOUS FUNCTIONS LIBRARY          
	Avi Aryan
	avi.uco.im/ahk             
	Licensed under Apache License v2.0         
################################################################
*/

msgbox % listfunc(A_ScriptFullPath)
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Gets default registered icon for an extension
	Eg - GetIconforext(".ahk")
Note - The icon path is not returned in pure-form but of the form     <path>, <icon index>

*/

GetIconforext(ext){
    RegRead, ThisExtClass, HKEY_CLASSES_ROOT, %ext%
    RegRead, DefaultIcon, HKEY_CLASSES_ROOT, %ThisExtClass%\DefaultIcon
	IfEqual, Defaulticon
	{
		Regread, Application, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%ext%\UserChoice, Progid
		IfNotEqual, Application
			Regread, DefaultIcon, HKCR, %Application%\DefaultIcon
	}
    Return DefaultIcon
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Base to Number and Number to Base conversion
;Base = 16 for HexaDecimal , 2 for Binary, 8 for Octal and 10 for our own number system

Number2Base(N, base=16){
	loop % baseLen:=base<10?Ceil((10/base)*Strlen(N)):Strlen(N)
		D:=Floor(N/(T:=base**(baseLen-A_index))),H.=!D?0:(D>9?Chr(D+87):D),N:=N-D*T
	return Ltrim(H,"0")
}

Base2Number(H, base=16){
	S:=Strlen(H),N:=0
	loop,parse,H
		N+=((A_LoopField*1="")?Asc(A_LoopField)-87:A_LoopField)*base**(S-A_index)
	return N
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;getParams()
;	Extract individual params from a single number
;
;	Params are sum of 2 powers . Each power of 2 will denote a unique option . So params can be 2,4,8,16,32....
;	Users will add them to get their preferred option and getParams() will extract what their options are.
;----------------------------------------------------------------------------------------------------------

/*
v := 2 + 16 + 128 + 1024
msgbox % v
msgbox % getParams(v)
*/

getParams(sum){
	static a := 1
	while sum>0
		loop
		{
			a*=2
			if (a>sum)
			{
				a/=2,p.=Round(a)" ",sum-=a,a:=1
				break
			}
		}
	return Substr(p,1,-1)
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Gets the path of active folder . 

GetFolder()
{
	WinGetClass,var,A
	If var in CabinetWClass,ExplorerWClass,Progman
	{
		IfEqual,var,Progman
			v := A_Desktop
		else
		{
			winGetText,Fullpath,A
			loop,parse,Fullpath,`r`n
			{
				IfInString,A_LoopField,:\
				{
					StringGetPos,pos,A_Loopfield,:\,L
					Stringtrimleft,v,A_loopfield,(pos - 1)
					break
				}
			}
		}
	return v
	}
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; Lists User made functions in a file
; msgbox % listfunc(A_scriptfullpath)

listfunc(file){
	fileread, z, % file
	StringReplace, z, z, `r, , All			; important
	z := RegExReplace(z, "mU)""[^`n]*""", "") ; strings
	z := RegExReplace(z, "iU)/\*.*\*/", "") ; block comments
	z := RegExReplace(z, "m);[^`n]*", "")  ; single line comments
	p:=1 , z := "`n" z
	while q:=RegExMatch(z, "iU)`n[^ `t`n,;``\(\):=\?]+\([^`n]*\)[ `t`n]*{", o, p)
		lst .= Substr( RegExReplace(o, "\(.*", ""), 2) "`n"
		, p := q+Strlen(o)-1

	Sort, lst
	return lst
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*
Add data to a line of a file . Replaces that line if replace = true

	FileAtline("myfile.txt", "This will be added to line 9", 9, true)
*/

Fileatline(file, what, linenum, replace=true){
loop
{
	FileReadLine,readline,%file%,%A_index%
	if Errorlevel = 1
		lineended := true , readline := ""

	if !(A_index == linenum)
		filedata .= readline . "`r`n"
	else
		filedata .= ( replace ? "" : readline ) what "`r`n"

	if (A_index >= linenum) and lineended
		break
}
StringTrimRight,filedata,filedata,2
FileDelete, %file%
FileAppend, % Rtrim(filedata, "`r`n"), %file%
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Runs a web-site . Eliminates issues with running the site using the traditional method.

BrowserRun(site){
	RegRead, OutputVar, HKCR, http\shell\open\command 
	IfNotEqual, Outputvar
	{
		StringReplace, OutputVar, OutputVar,"
		SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive
		run,% OutDir . "\" . OutNameNoExt . ".exe" . " """ . site . """"
	}
	else
		run,% "iexplore.exe" . " """ . site . """"	;internet explorer
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
				pos := var ? var : pos
		if ( pos == Strlen(Hay) )
			return 0
	}
	else
	{
		if Needles=
			return Strlen(Hay)
		loop, parse, Needles,|
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Concatenate a string n - times without using loop
Concatenate(string, ntimes){
	return ntimes<1 ? "" : (ntimes<2 ? string : string Concatenate(string, ntimes-1)) 
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Reverse a string
ReverseAKAFlip(string){
	return, Strlen(string) < 2 ? Substr(string,1) : Substr(string,0) ReverseAKAFlip(Substr(string,1,-1))
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Copy.com Direct Link Generator (Parsing)
;Throw in the Copied link from the web browser and to gives you the direct download link
CopydotcomParser(link){
	return RegExReplace(link, "i)(.*)www.(.*)/s(.*)(\?download=1)+", "$1$2$3")
}
