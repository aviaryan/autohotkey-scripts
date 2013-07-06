/*
AhkIni v0.1
	by Avi Aryan
Licensed under Apache License v2.0 (See Readme.md)

###############################################################
Created as a complete replacement for the default Ini commands.
###############################################################

METHODS ############

	.Read(Section, Key, Byref Key_com="", ByRef Sec_com="")
	.Write(Section, Key, Value, Key_com="", Sec_com="")
	.Delete(Section, Key="")
	.Save()

POINTS #############

*	Run .Save() after making changes to save them in the ini
*	If in .Write() , space is specified in Key_com and Sec_com params , the comments will get deleted.
		Specifying the 2 params as empty wont change the comments.
	eg > Ini.write(Section, Key, value, A_space, " ")

*/

;~ SetWorkingDir,% A_scriptdir

;~ Ini := new AhkIni("black2.ini")
;~ ini.write("section1", "key1", "hithere", "keycomment`nline2`nline3")
;~ ini.write("section1", "key2", "hithere", "keycomment", "section1 comment")
;~ ini.write("section2", "key1", "hithere2", "keycomment2", "section2 comment")

;~ msgbox,% ini.read("section1", "key1", key, sec) "`n`n" key "`n`n" sec

;~ ini.Save()

;~ return

class AhkIni
{
	__New(IniFile)
	{
		this.file := {} , this.listing := {} , this.Inifile := Inifile , listct := 1 , trending_com := "top"
		
		if !FileExist(Inifile)
			FileAppend,% emptyvar,% Inifile
		
		this.listing[1] := "top_=com"

		loop, read,% IniFile
		{
			cl := Trim(A_loopreadline)
			if Instr(cl, "[") = 1
			{
				this.file[cl] := cl
				trending_com := cl "_" cl, trending_sec := cl
				
				this.listing[listct := listct+1] := cl	;section
				this.listing[listct := listct+1] := cl "_" cl "_=com" 		;section comment
			}
			else if Instr(cl, ";") = 1
			{
				cl := Trim( Substr(cl,2) )
		
				if ( com_bk != trending_com "_=com" )
					this.file[com_bk] := Substr( this.file[com_bk] , 1, -1)
				com_bk := trending_com "_=com"
				
				this.file[com_bk] .= cl "`n"
			}
			else if Instr(cl, "=")
			{
				key := Trim( Substr(cl, 1, Instr(cl, "=")-1) )
				value := Trim( Substr( cl, Instr(cl, "=")+1 ) )
				
				this.file[trending_sec "_" key] := value , trending_com := trending_sec "_" key
				this.file[trending_sec "_" key "_=com"] := ""
				
				this.listing[listct := listct+1] := trending_sec "_" key
				this.listing[listct := listct+1] := trending_sec "_" key "_=com"
 			}
		}
		
		this.file[com_bk] := Rtrim(this.file[com_bk], "`n")
	}

	Read(Section, Key, Byref Key_com="", ByRef Sec_com="")
	{
		Section := "[" Section "]"
		Key_com := this.file[Section "_" key "_=com"]
		Sec_com := this.file[Section "_" Section "_=com"]
		return this.file[Section "_" key]
	}

	Write(Section, Key, Value, Key_com="", Sec_com="")
	{
		Section := "[" Section "]"
		
		if ( this.file[Section] == "" )
		{
			listingct := this.listing.MaxIndex()
			this.listing[listingct+1] := Section
			this.listing[listingct+2] := Section "_" Section "_=com"
			this.listing[listingct+3] := Section "_" Key
			this.listing[listingct+4] := Section "_" key "_=com"
		}
		else if ( this.file[Section "_" Key] == "" )
		{
			for k, v in this.listing
				if Instr(v, Section) = 1
				{
					ins_index := A_Index+1		;insert +1 after this
					break
				}
				
			list_index := this.listing.maxindex()
			loop,% list_index - ins_index
				this.listing[list_index+3-A_index] := this.listing[list_index+1-A_index]
			
			this.listing[ins_index+1] := Section "_" Key
			this.listing[ins_index+2] := Section "_" Key "_=com"
		}
		
		this.file[Section] := Section
		if Sec_com = %A_space%
			this.file[Section "_" Section "_=com"] := ""
		else if Sec_com != 
			this.file[Section "_" Section "_=com"] := Sec_com

		this.file[Section "_" Key] := value
		
		if Key_com = %A_space%
			this.file[Section "_" Key "_=com"] := ""
		else if Key_com != 
			this.file[Section "_" Key "_=com"] := Key_com
		return
	}
	
	Delete(Section, Key="")
	{
		Section := "[" Section "]"
		if Key = 
		{
			for keyC, valueC in this.listing
				if Instr(valueC, Section) = 1
					R := this.file.Remove(valueC) , R := this.listing.Remove(keyC)
		}
		else
			R := this.file.Remove(Section "_" Key) , R := this.file.Remove(Section "_" Key "_=com")
	}
	
	Save()
	{
		FileDelete,% this.Inifile
		
		for k, v in this.listing
		{
			if ( ( temp := this.file[v] ) != "" )
			{
				if ( Substr(v, -4) == "_=com" )
				{
					loop, parse, temp, `n
						temp2 .= ";" A_LoopField "`n"
					temp2 := Substr(temp2, 1, -1)
					retfile .= "`n" temp2 , temp2 := ""
				}
				else if Instr(v, "]") == Strlen(v)
					retfile .= "`n`n" temp
				else
					retfile .= "`n" Substr(v, Instr(v, "]", 0, 0)+2) " = " temp
			}
		}
		FileAppend,% Trim(retfile, "`n"),% this.Inifile
		;return Trim(retfile, "`n")
	}
}