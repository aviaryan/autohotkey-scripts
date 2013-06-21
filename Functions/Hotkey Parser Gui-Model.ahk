;GUI using Hparse()

Gui, Add, Text,x0 y0 h100 w400, Write your hotkey in the edit box. Then click on Button to save`nLike Ctrl + Alt + x
Gui, Add, Edit, x0 y100 h30 w400 veditcontrol,
Gui, Add, Button, x0 y150 h30 w100 , Save_Hotkey

gosub, loadfromini

Gui, sHOW,w400 h200,Hparse() Save and load example
return


loadfromini:	;load settins from ini
	If FileExist("hparseini.ini")
	{
		IniRead, variable, hparseini.ini, Hotkeys, hotkey
		variable := Hparse_rev(variable)	;-- convert to user format
		GuiControl,, editcontrol,% variable
	}
	return
	
buttonSave_hotkey:
	Gui, submit, nohide		;Submit editcontrol's contents to variable
	hk := Hparse(editcontrol)	;Get the hotkey in ahk format
	if hk = 
		msgbox, The hotkey entered is invalid
	else
	{
		IniWrite,%hk%,hparseini.ini, Hotkeys, hotkey
	msgbox,% "The entered hotkey  " hk "  has been saved to ini`nClose the gui and see the settings file. Then open the gui back to load the settings in correct format"
	}
	return

GuiClose:
ExitApp

#include, hotkeyparser.ahk