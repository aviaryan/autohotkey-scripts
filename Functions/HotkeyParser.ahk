/*
HParse()
© Avi Aryan
- www.avi-win-tips.blogspot.com

First Revision - 28/4/13
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
•No RegEx, so faster than it should be.

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
LiteRegexM(matchitem)
{

regX := ListGen("RegX")
keys := Listgen("Keys")
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

IfInString,matchitem,%A_loopfield%
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

}
; Extra Functions -----------------------------------------------------------------------------------------------------------------

Vanish(matchitem, character){
StringGetPos,pos,matchitem,%character%,L
StringTrimLeft,matchitem,matchitem,(pos + 1)
return, matchitem
}

ListGen(what){
; Better Edit this if you know what you are doing. Editing without understanding how HParse() works can cause improper results.
; The below are arranged on basis of their popularity for max. speed of the func().
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
N*p*D*t
N*p*D*v
N*p*M
N*p*A
N*p*S
N*p*E
l*b*t
r*b*t
m*b*t
s*l*k
c*l
n*l
p*s
c*t*b
pa*s
b*r*k
x*b*1
x*b*2
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
LButton
RButton
MButton
ScrollLock
CapsLock
NumLock
PrintScreen
CtrlBreak
Pause
Break
XButton1
XButton2
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
)
;<<<<<<<<<<<<<<<<END>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
return, Rvar
}