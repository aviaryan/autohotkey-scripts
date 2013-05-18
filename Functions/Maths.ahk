/*
MATHS LIBRARY
by Avi Aryan
v 0.6 beta
------------------------------------------------------------------------------
http://www.avi-win-tips.blogspot.com
------------------------------------------------------------------------------

##############################################################################
MAIN FUNCTIONS
##############################################################################
* Evaluate(number1, number2) --- +/- massive numbers . Supports Real Nos (Everything)

* Multiply(number1, number2) --- multiply two massive numbers . Supports everything

* Divide(Dividend, Divisor) --- Divide two massive numbers . Supports everything

* Greater(number1, number2, trueforequal=false) --- compare two massive numbers . Should support everything
  true if number1 > number2
  false if number2 > number1
  blank if number1 = number2 (trueforequal = Default)
  true if number1 = number2 (trueforequal = true)
  
* Prefect(number) --- convert a number to most suitable form. like ( 002 to 2 ) and ( 000.5600 to 0.56 )

-----  BETTER PASS NUMBERS AS STRINGS FOR THE ABOVE FUNCTIONS ------------------
-----  SEE THE COMMENTED MSGBOX CODE BELOW TO UNRSTND WHAT I MEAN --------------

* Antilog(number) --- gives antilog of a number

* nthRoot(number, n) ---- gives nth root of a number .
  nthroot(8, 3) gives cube root of 8 = 2

* logB(base, number) --- log of a number at a partcular base.


*******************************************************************************
MISC
*******************************************************************************
* ReverseAKAFlip(string) --- Flips a string or number

* Toggle(boolean) --- Toggles a boolean value
*/

;MsgBox,% Divide("9999999999999999999999999999999999999999999999999", "5555555555555555555555555555555555555555555555555") ;- 1.8
;MsgBox,% Multiply("111111111111111111111111111111111111111111.111","55555555555555555555555555555555555555555555.555")
;MsgBox,% Prefect("00.002000")
;Msgbox,% nthroot(3.375, 3)
;Msgbox,% Evaluate("1111111111111111111111111111111111111","55555555555555555555555555.7878")
;return

Evaluate(number1, number2, prefect=true){	;Dont set Prefect false, Just forget about it.
;Processing
IfInString,number2,--
	count := 2
else IfInString,number2,-
	count := 1
else
	count := 0
IfInString,number1,-
	count+=1
;
n1 := number1
n2 := number2
StringReplace,number1,number1,-,,All
StringReplace,number2,number2,-,,All
;Decimals
dec1 := (Instr(number1,".")) ? ( StrLen(number1) - InStr(number1, ".") ) : (0)
dec2 := (Instr(number2,".")) ? ( StrLen(number2) - InStr(number2, ".") ) : (0)

if (dec1 > dec2){
	dec := dec1
	loop,% (dec1 - dec2)
		number2 .= "0"
}
else if (dec2 > dec1){
	dec := dec2
	loop,% (dec2 - dec1) 
		number1 .= "0"
}
else
	dec := dec1
StringReplace,number1,number1,.
StringReplace,number2,number2,.
;Processing
;Add zeros
if (Strlen(number1) >= StrLen(number2)){
	loop,% (Strlen(number1) - strlen(number2))
		number2 := "0" . number2
}
else
	loop,% (Strlen(number2) - strlen(number1))
		number1 := "0" . number1

n := strlen(number1)
;
if count not in 1,3		;Add
{
loop,
{
if (carry)
	digit := SubStr(number1,1 - A_Index, 1) + SubStr(number2, 1 - A_index, 1) + 1
else
	digit := SubStr(number1,1 - A_Index, 1) + SubStr(number2, 1 - A_index, 1)

if (A_index == n){
	sum := digit . sum
	break
}

if (digit > 9){
	carry := true
	digit := SubStr(digit, 0, 1)
}
else
	carry := false

sum := digit . sum
}
;Giving sign
if (Instr(n2,"-") and Instr(n1, "-"))
	sum := "-" . sum
}
;SUBTRACT ******************
elsE
{
;Compare numbers for suitable order
numbercompare := Greater(number1, number2)
if !(numbercompare){
	mid := number2
	number2 := number1
	number1 := mid
}
loop,
{	
if (borrow)
	digit := SubStr(number1,1 - A_Index, 1) - 1 - SubStr(number2, 1 - A_index, 1)
else
	digit := SubStr(number1,1 - A_Index, 1) - SubStr(number2, 1 - A_index, 1)

if (A_index == n){
	StringReplace,digit,digit,-
	sum := digit . sum
	break
}

if (Instr(digit, "-")){
	borrow:= true
	digit := 10 + digit		;4 - 6 , then 14 - 6 = 10 + (-2) = 8
}
else
	borrow := false

sum := digit . sum
}
;End of loop ;Giving Sign
;sum := LTrim(sum, "0")
;
If InStr(n2,"--"){
	if (numbercompare)
		sum := "-" . sum
}else If InStr(n2,"-"){
	if !(numbercompare)
		sum := "-" . sum
}else IfInString,n1,-
	if (numbercompare)
		sum := "-" . sum
}
;End of Subtract - Sum
;End
if ((Ltrim(sum, "0") = "") or (sum == "-"))
	sum := 0
;Including Decimal
If (dec)
	if (sum)
		sum := SubStr(sum,1,StrLen(sum) - dec) . "." . SubStr(sum,1 - dec)
;Prefect
if (prefect)
	return, Prefect(sum)
else
	return, sum
}

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Antilog(number){
IfInString,number,-
{
loop
{
	number+=A_Index
	IfNotInString,number,-
	{
	negative := A_Index
	break
	}
}
}
;Negative management

StringGetPos,dotpos,number,.
if (dotpos == -1){
	chrstc := number
	mantsa := 0.0000
}
else{
	StringLeft,chrstc,number,%dotpos%
	StringTrimLeft,mantsa,number,%dotpos%
	mantsa := "0" . mantsa
	if (Strlen(mantsa) > 6)
		StringLeft,mantsa,mantsa,6
	else
		loop,% (6 - Strlen(mantsa))
			mantsa .= "0"
}

if mantsa between 0 and 0.3009
	param := 0.9995	;Making suitable with param increment factor (Below)
else if mantsa between 0.3009 and 0.4770
	param := 1.99
else if mantsa between 0.4770 and 0.6019
	param := 2.99
else if mantsa between 0.6019 and 0.6988
	param := 3.99
else if mantsa between 0.6988 and 0.7780
	param := 4.99
else if mantsa between 0.7780 and 0.8449
	param := 5.99
else if mantsa between 0.8449 and 0.9029
	param := 6.99
else if mantsa between 0.9029 and 0.9541
	param := 7.99
else
	param := 8.99
limit := param + 1.01

loop, 
{
param := param + 0.0005
if (Substr(log(param),1,6) == mantsa)
	break
if (param >= limit){
	param :=
	break
}
}
;param generated
IfNotEqual,param
{
intofactor := 1
If (negative == "")
{
loop,% (chrstc)
	intofactor := intofactor * 10
return,% Prefect(param * intofactor)
}
;Negative
else
{
loop,% (negative)
	intofactor := intofactor * 10
return,% Prefect(param / intofactor)
}
}
;return only if param not equal to ""
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Multiply(number1, number2){
;Getting Sign
positive := true
if (Instr(number2, "-"))
	positive := false
if (Instr(number1, "-"))
	positive := Toggle(positive)
StringReplace,number1,number1,-
StringReplace,number2,number2,-
; Removing Dot
dec := (InStr(number1,".")) ? (StrLen(number1) - InStr(number1, ".")) : (0)
IfInString,number2,.
	dec := dec + StrLen(number2) - Instr(number2, ".")
StringReplace,number1,number1,.
StringReplace,number2,number2,.
; Multiplying
number2 := ReverseAKAFlip(number2)
;Reversing for suitable order
product := "0"
Loop,parse,number2
{
;Getting Individual letters
row := "0"
zeros := ""
if (A_loopfield)
	loop,% (A_loopfield)
		row := Evaluate(row, number1)
else
	loop,% (Strlen(number1) - 1)	;one zero is already 5 lines above
		row .= "0"

loop,% (A_index - 1)	;add suitable zeroes to end
	zeros .= "0"
row .= zeros
product := Evaluate(product, row, false)
}
;Give Dots
if (dec){
	product := SubStr(product,1,StrLen(product) - dec) . "." . SubStr(product,1 - dec)
	product := Prefect(product)
}
;Give sign
if !(positive)
	product := "-" . product
return, product
}

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Divide(number1, number2){
;Getting Sign
positive := true
if (Instr(number2, "-"))
	positive := false
if (Instr(number1, "-"))
	positive := Toggle(positive)
StringReplace,number1,number1,-
StringReplace,number2,number2,-
;Checking if possible with AHK Only
;Case 1 n2 >= n1
if Greater(number2, number1, true)
	if (number1 / number2 != "0.000000")	;As per v1.1.09
		return,% ( (positive) ? ("") : ("-") ) . Prefect(number1 / number2)
;Case 2 n1 > n2
if Greater(number1, number2)
	if !(Strlen(number1 / number2) > 25)	;As per tests, the greatest correct length seemed to be 26 (in non-dec denominator). We dont want 26.
		return,% ( (positive) ? ("") : ("-") ) . Prefect(number1 / number2)
;
;If anything reaches here, it's because number2 > |999999| or so.
if (Strlen(number2) > 6)	;do this only if required
	number2 := Substr(number2, 1, Strlen(number2) - (Strlen(number2) - Instr(number2, ".") + 1))	;remove decs

Intmd := Multiply(number1, 1 / SubStr(number2, 1, 6))
if (Strlen(number2) > 6){
	
	if Instr(Intmd, "."){
	numofzeros := Strlen(number2) - 6
	Intmd := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" . Intmd
	dotpoint := Instr(Intmd, ".")
	StringReplace,Intmd,Intmd,.
	Intmd := SubStr(Intmd, 1, dotpoint - numofzeros - 1) . "." . SubStr(Intmd, dotpoint - numofzeros)
	}else{
	numofzeros := Strlen(number2) - 6
	Intmd := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" . Intmd
	Intmd := Substr(Imtmd, 1, StrLen(Intmd) - numofzeros) . "." . SubStr(Intmd, StrLen(Intmd) - numofzeros + 1)
	}
}
Intmd := Prefect(Intmd)

if !(positive)
	Intmd := "-" Intmd
return, Intmd
}

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Greater(number1, number2, trueforequal=false){
IfInString,number2,-
	IfNotInString,number1,-
		return, true
IfInString,number1,-
	IfNotInString,number2,-
		return, false

if (Instr(number1, "-") and Instr(number2, "-"))
	bothminus := true

if (Strlen(number1) > Strlen(number2))
	return,% (bothminus) ? (false) : (true)
else if (Strlen(number2) > Strlen(number1))
	return,% (bothminus) ? (true) : (false)
else{
stop := StrLen(number1)
loop,
{
	if (SubStr(number1,A_Index, 1) > Substr(number2,A_index, 1))
		return,% (bothminus) ? (false) : (true)
	else if (Substr(number2,A_index, 1) > SubStr(number1,A_Index, 1))
		return,% (bothminus) ? (true) : (false)
	
	if (a_index == stop){
		if (trueforequal)
			return, true
		break
	}
}
}

}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Prefect(number){
number .= ""	;convert to string if needed
if Instr(number, "-"){
	StringReplace,number,number,-
	negative := true
}

if Instr(number, "."){
loop,
	if Instr(number, "0") = 1	;managing left hand side
		StringTrimLeft,number,number,1
	else
		break

if (Substr(number,1,1) == ".")	;if num like	.6767
	number := "0" number

number := Rtrim(number, "0")
if (Substr(number, 0) == ".")	;like 456.
	StringTrimRight,number,number,1

return,% (negative) ? ("-" . number) : (number)
} ; Non-decimal below
else
{
if (number != 0)
	return,% (negative) ? ("-" . Ltrim(number, "0")) : (Ltrim(number, "0"))
else
	return, 0
}
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

LogB(number, base){
IfNotInString,base,-
	IfNotInString,number,-
		return,% Prefect(log(number) / log(base))
}

nthRoot(number, n){
if Instr(number, "-")
{
	StringReplace,number,number,-
	if (Mod(n, 2) == 0)		;check for even
		return
	sign := "-"
}

logy := (1 / n) * log(number)	;y = x^1/n
return,% sign . Prefect(antilog(logy))
}

;################# NON - MATH FUNCTIONS ###################################

Toggle(bool){
return,% (bool) ? (false) : (true)
}
ReverseAKAFlip(string){
loop,% Strlen(string)
	flip .= Substr(string, 1 - A_index, 1)
return,% flip
}