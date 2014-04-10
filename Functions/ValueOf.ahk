/*
Super Variables processor by Avi Aryan

	Overcomes the limitation of a single level ( return %var% ) in nesting variables
	The function can nest as many levels as you want
	Run the Example to get going

Updated 10/4/14

EXAMPLE -------------------------------------------

*/

;variable := "some_value"
;msgbox % valueof("%variable%")
;some_value := "Some_another_value"
;some_another_value := "a_unique_value"
;a_unique_value := "A magical value. Ha Ha Ha Ha"
;msgbox,% "%%%%variable%%%% (4 times)`t" ValueOf("%%%%variable%%%%")

;;works with objects Too

;obj := {}
;obj["key"] := "value"
;msgbox % valueOf("%obj.key%")
;msgbox % valueOf("%some_%obj.key%%")        ;==== value of some_value
;return

Valueof(VarinStr){
global
local Midpoint, emVar, $j, $n
	loop,
	{
		StringReplace, VarinStr, VarinStr,`%,`%, UseErrorLevel
		Midpoint := ErrorLevel / 2
		if Midpoint = 0
			return ( emvar := VarinStr )
		emVar := Substr(VarinStr, Instr(VarinStr, "%", 0, 1, Midpoint)+1, Instr(VarinStr, "%", 0, 1, Midpoint+1)-Instr(VarinStr, "%", 0, 1, Midpoint)-1)

		if Instr(emVar, ".")
		{
			loop, parse, emVar,`.
				$j%A_index% := Trim(A_LoopField) , $n := A_index-1
			if $n=1
				emVar := %$j1%[$j2]
			if $n=2
				emVar := %$j1%[$j2][$j3]
		} 
		else emVar := %emVar%

		VarinStr := Substr(VarinStr, 1, Instr(VarinStr, "%", 0, 1, Midpoint)-1) emVar Substr(VarinStr, Instr(VarinStr, "%", 0, 1, Midpoint+1)+1)
	}
}