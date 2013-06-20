/*

###############################################
Encrypt() - Password protected Text Encryption
by Avi Aryan
v 0.1
#############################

NOTES
*  Pass should be only alphabets. No case senstive
*  Max Pass Length = 24 characters

* Requires Maths.ahk (Scientific Maths lib)

*/

;msgbox,% Encrypt("autohotkey_l", "lexikos")

;var := Encrypt("autohotkey", "lexikos")
;msgbox,% Decrypt(var, "lexikos")	;-- should give back autohotkey
;msgbox,% Decrypt(var, "lexiko")	;-- s missing in lexikos and you are dead

;return

Encrypt(text, password){

	letters := "abcdefghijklmnopqrstuvwxyz0123456789-,. "	;40 . no limit here but still
	return Crypt(letters, PassCrypt(password, letters), text)
}

Decrypt(text, password){

	letters := "abcdefghijklmnopqrstuvwxyz0123456789-,. "	;40 . no limit here but still
	return Crypt(PassCrypt(password, letters), letters, text)
}

/*
PassCrypt()
	Generates Random sequence from a password
*/

PassCrypt(password, letters){

	if password is not alpha
		return
	alphalist := Substr(letters, 1, 26)	;first 26 should be alphas

	loop,parse,alphalist
		StringReplace,password,password,%A_loopfield%,%A_index%,All	;Convert to numeric format

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