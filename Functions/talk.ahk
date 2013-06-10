/*
########################
talk v0.1			   #
by Avi Aryan		   #
##################################
Thanks to Autohotkey help file   #
================================ #
Licensed Under MIT License	     #
##################################

Points #

* See the examples to understand better.
  https://dl.dropboxusercontent.com/u/116215806/Products/MoreAHK/talk_examples.7z

* If a script using this function is running as exe, use		script := new talk("ScriptName.exe")	and not just the Scriptname.
* Note that script names are case - sensitive.		For a script named "MyScript" , use   new talk("MyScript")  and not  new talk("myscript")
* The runlabel() method waits for the label for the label to be completed in client script before returning.
* setvar() will create the variable in the client script if it does not exist.

Know That #
* The function uses only two global varaibles , talk_recvd and talk_talk
* Errorlevels for all methods will be added later

*/

class talk
{
	__New(Client){
		if ( Substr(Client, -2) == "exe" )
			this.Script := Client
		else
			this.Script := ( Substr(Client, -2) == "ahk" ) ? Client : Client ".ahk"
		OnMessage(0x4a, "talk_reciever")
	}

	setVar(Var, value){
		StringReplace,value,value,\,\\,All
		talk_send(value " \ " A_ScriptName " \ " "setvar" " \ " Var, this.Script)
	}
	
	getVar(Var){
		global
		talk_send(var " \ " A_ScriptName " \ " "getvar", this.Script)

		while (talk_recvd = "")
			sleep, 50
		talk_recvd := ""
		return talk_talk
	}

	;runlabel waits for the label in the client script to complete
	runlabel(label){
		global
		talk_send(label " \ " A_scriptname " \ " "runlabel", this.Script)

		while (talk_recvd = "")
			sleep, 50
		talk_recvd := ""
		return
	}
	
	terminate(){
		talk_send("terminate" " \ " A_scriptname " \ " "terminate", this.Script)
	}
}

;Function

talk_reciever(wParam, lParam){
	global
	local Data, Params, ScriptName, What, Param1, tosend
	
    Data := StrGet( NumGet(lParam + 2*A_PtrSize) )
	;Structure... Message \ SenderScriptName \ What \ Param1
	Params := Substr(Data, Instr(Data, " \ ")+3) , ScriptName := Substr(Params, 1, Instr(Params, " \ ")-1)

	What := Substr(Params, Instr(Params, " \ ")+3, Instr(Params, " \ ",false,1,2) - Instr(Params, " \ ") - 3)
	Param1 := Substr(Params, -(Strlen(Params) - Instr(Params, " \ ",false,0))+3)
	if what = 
		what := Param1		;incase of getvar
		
	Data := Substr(Data, 1, Instr(Data, " \ ")-1)

	if What = setvar
	{
		StringReplace,Data,Data,\\,\,All
		%Param1% := Data
		return
	}
	else if What = getvar
	{
		tosend := %Data%
		StringReplace,tosend,tosend,\,\\,All
		talk_send(tosend " \ " A_ScriptName " \ " "talk", ScriptName)
		return
	}
	else if What = talk
	{
		StringReplace,Data,Data,\\,\,All
		talk_recvd := 1 , talk_talk := Data
		return
	}
	else if What = runlabel
	{
		if islabel(Data)
			gosub, %Data%
		talk_send("runlabel" " \ " A_ScriptName " \ " "talk", ScriptName)
		return
	}
	else if What = terminate
		ExitApp
}

talk_send(ByRef StringToSend, ByRef TargetScriptTitle){
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%
    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
}