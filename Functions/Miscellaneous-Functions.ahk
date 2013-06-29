/*
################################################################
MY MISCELLANEOUS FUNCTIONS LIBRARY
Avi Aryan
http://www.avi-win-tips.blogspot.com
################################################################

Copyright 2013 Avi Aryan  
  
Licensed under the Apache License, Version 2.0 (the "License");  
you may not use this file except in compliance with the License.  
You may obtain a copy of the License at  
  
http://www.apache.org/licenses/LICENSE-2.0  
  
Unless required by applicable law or agreed to in writing, software  
distributed under the License is distributed on an "AS IS" BASIS,  
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
See the License for the specific language governing permissions and  
limitations under the License.  

#################################################################
TERMS
=================================================================
• USAGE
Feel totally free to use these functions in your scripts . However, if you feel these functions are a lifesaver for your project, an acknowledgement would 
be appreciated.

• DISTRIBUTION
Distribution is only allowed as long as sufficient credits are provided to the original author (me).
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

/*
Super Variables processor
	Overcomes the limitation of a single level ( return %var% ) in nesting variables
	The function can nest as many levels as you want
	Run the Example to get going

EXAMPLE -------------------------------------------

	variable := "some_value"
	some_value := "Some_another_value"
	some_another_value := "a_unique_value"
	a_unique_value := "A magical value. Ha Ha Ha Ha"
	msgbox,% ValueOf("%%%variable%%%")

---------------------------------------------------

*/

Valueof(VarinStr){
global
local Midpoint, emVar
	loop,
	{
		StringReplace, VarinStr, VarinStr,`%,`%, UseErrorLevel
		Midpoint := ErrorLevel / 2
		if Midpoint = 0
			return emvar := %VarinStr%
		emVar := Substr(VarinStr, Instr(VarinStr, "%", 0, 1, Midpoint)+1, Instr(VarinStr, "%", 0, 1, Midpoint+1)-Instr(VarinStr, "%", 0, 1, Midpoint)-1)
		VarinStr := Substr(VarinStr, 1, Instr(VarinStr, "%", 0, 1, Midpoint)-1) %emVar% Substr(VarinStr, Instr(VarinStr, "%", 0, 1, Midpoint+1)+1)
	}
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
