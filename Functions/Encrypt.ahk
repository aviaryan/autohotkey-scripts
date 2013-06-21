/*

###############################################
Encrypt() - Password protected Text Encryption
by Avi Aryan
v 0.3
#############################

NOTES
*  Pass should be only alphabets. No case senstive
*  Max Pass Length = 24 characters

PLEASE SEE
*  Requires Scientific Maths lib
*  The Crypt algorithm changes with version. So, the function stores version number in the encrypted text (from v0.3) and notifies you when you are using a
   older/newer version for the cryption.
	Version History -  		https://github.com/avi-aryan/Avis-Autohotkey-Repo/commits/master/Functions/Encrypt.ahk

*/

;msgbox,% var1 := Encrypt("autohotkey_l", "lexikos")
;msgbox,% Decrypt(var1, "lexikos") ;<--- gives autohotkey_l
;msgbox,% Decrypt(var1, "lexiko")   ;<--- s missing and you r dead
;msgbox,% Encrypt("today tommorow and yesterday", "blackdog")
;msgbox,% var2 := Encrypt("you are awesome, asshole !", "kalakutta")
;msgbox,% Decrypt(var2, "kalakutt") ;<--- gives wrong output
;return

Encrypt(text, password){

	letters := "abcdefghijklmnopqrstuvwxyz0123456789-,. "	;40 . no limit here but still
	parsedlist := PassCrypt(password, letters, convindex, carryindex)
	Loop
	{
		toreturn .= Crypt(letters, parsedlist, Substr(text, 1, convindex))
		parsedlist := Substr(parsedlist, 1-carryindex) SubStr(parsedlist, 1, -1*carryindex)
		text := Substr(text, convindex+1)
		if ( text == "" )
			return toreturn "03"	;03 is version . Not using a global
	}
}

Decrypt(text, password){

	letters := "abcdefghijklmnopqrstuvwxyz0123456789-,. "	;40 . no limit here but still
	parsedlist := PassCrypt(password, letters, convindex, carryindex)
	
	if ( Substr(text, -1) != "03" )
		return
	else
		text := Substr(text, 1, -2)
	
	Loop
	{
		toreturn .= Crypt(parsedlist, letters, Substr(text, 1, convindex))
		parsedlist := Substr(parsedlist, 1-carryindex) SubStr(parsedlist, 1, -1*carryindex)
		text := Substr(text, convindex+1)
		if ( text == "" )
			return toreturn
	}
}

/*
PassCrypt()
	Generates Random sequence from a password
*/

PassCrypt(password, letters, Byref convindex, Byref carryindex){

	if password is not alpha
		return
	alphalist := Substr(letters, 1, 26)	;first 26 should be alphas

	loop,parse,alphalist
		StringReplace,password,password,%A_loopfield%,%A_index%,All	;Convert to numeric format
	
	convindex := Substr(password, 1, 1) , carryindex := ( Substr(password, 0) == "0" ) ? 1 : Substr(password, 0)
	return SM_uniquePMT(letters, password, "|")
}

/*
Crypt()
	Responsible for Find and Replace
*/

Crypt(baselist, parsedlist, text){

	reschars := "¢¤¥¦§©ª«®µ¶"
	loop, parse, reschars
	{
		if !Instr(text, A_LoopField)
		{
			conv_char := A_LoopField
			break
		}
	}

	loop, parse, baselist
		StringReplace,text,text,%A_loopfield%,%A_loopfield%%conv_char%,All	;a_
	
	loop, parse, parsedlist
	{
		from_baselist := Substr(baselist, A_index, 1)
		StringReplace,text,text,%from_baselist%%conv_char%,%A_LoopField%,All
	}
	return text
}

;#Include, %A_ScriptDir%/Maths/Maths.ahk
