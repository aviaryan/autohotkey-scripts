;Excel ClipboardAll fix
;by Avi Aryan
;===========================
;===========================
;USE
;When fetching ClipboardAll value, use ClipboardAll() instead of ClipboardAll
;It should be noted that this function is suitable for use in any condition, whether Excel is active or not.

;z := ClipboardAll()
;Clipboard := z
;return

ClipboardAll(){

	if WinActive("ahk_class XLMAIN")
	{
		Gui, foolgui: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
		Gui, foolgui: Show, NA, foolgui
		WinActivate, foolgui
		j := 1
	}
	tempC := ClipboardAll

	if j
		Gui, foolgui:Destroy

	return tempC
}