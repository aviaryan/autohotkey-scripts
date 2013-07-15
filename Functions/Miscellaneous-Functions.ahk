/*
################################################################
MY MISCELLANEOUS FUNCTIONS LIBRARY          
	Avi Aryan
	avi-aryan.github.io/Autohotkey.html                 
	Licensed under Apache License v2.0         
################################################################
*/

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
