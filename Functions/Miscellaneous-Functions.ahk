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

;Get default registered icon for an extension
;Eg - GetIconforext(".ahk")
;Note - The icon path is not returned in pure-form but of the form     <path>, <icon index>

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

;Get path of active folder . 

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
return, v
}
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Add data to a line of a file . Replaces that line

Fileatline(file, what, linenum, replace=true){
loop
{
	FileReadLine,readline,%file%,%A_index%
	if Errorlevel = 1
		lineended := true , readline := ""

	if !(A_index == linenum)
		filedata .= readline . "`r`n"
	else
		if (replace)
			filedata .= what . "`r`n"
		else
			filedata .= readline what "`r`n"

	if (A_index >= linenum)
		if (lineended)
			break
}
StringTrimRight,filedata,filedata,2
FileDelete, %file%
FileAppend, % Rtrim(filedata, "`r`n"), %file%
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Run a web-site . Eliminates issues with running the site using the traditional method.

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
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Send text on the basis of characters/second
;Eg -->
;Clipboard := "dfhkjdfkdfjkdfjkdfjdfkjdfkdf"
;SendperSec(Clipboard, 7)	;Sends 7 characters from clipboard per second

Sendpersec(Data, Chs, persist=true){
if (persist)
	BlockInput, On
sleeptime := (1000 / Chs) - 10	;-10 to be more accurate, to counter-effect the time consumed in loop
IfLess,sleeptime,1
    sleeptime := 1
loop,
{
StringLeft,tosend,Data,1
Send, %tosend%
sleep,%sleeptime%
StringTrimLeft,Data,Data,1
IfEqual,Data
    break
}

BlockInput, Off
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;Concatenate a string n - times without using loop
Concatenate(string, ntimes){
return, (ntimes<2) ? string : string . Concatenate(string , ntimes-1)
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

