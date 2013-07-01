/*
Super Variables processor by Avi Aryan

	Overcomes the limitation of a single level ( return %var% ) in nesting variables
	The function can nest as many levels as you want
	Run the Example to get going

EXAMPLE -------------------------------------------

	variable := "some_value"
	some_value := "Some_another_value"
	some_another_value := "a_unique_value"
	a_unique_value := "A magical value. Ha Ha Ha Ha"
	msgbox,% "%%%variable%%%`t`t" ValueOf("%%%variable%%%") "`n`nvariable`t`t" Valueof("variable")

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