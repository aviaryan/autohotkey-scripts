/*
MATHS LIBRARY
(C) Avi Aryan
v 0.1 beta
------------------------------------------------------------------------------
http://www.avi-win-tips.blogspot.com
------------------------------------------------------------------------------

##############################################################################
MAIN FUNCTIONS
##############################################################################
* Evaluate(number1, number2) --- +/- massive numbers . Supports Real Nos (Everything)

* Multiply(number1, number2) --- multiply two massive numbers . Supports everything

* Divide(Dividend, Divisor) --- Divide two massive numbers . Supports everything

* Greater(number1, number2) --- compare two massive numbers . Should support everything
  true if number1 > number2
  false if number2 > number1
  blank if number1 = number2
  
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
;MsgBox,% Evaluate("238928923823923823237238293823923923", "-239239802392309230239023923023902390239230923032923")
;return

Evaluate(number1, number2){
;Processing
IfInString,number2,--
	count := 2
else IfInString,number2,-
	count := 1
else
	count := 0
IfInString,number1,-
	count+=1
;Decimals
IfInString,number1,.
	dec1 := StrLen(number1) - InStr(number1, ".")
IfInString,number2,.
	dec2 := StrLen(number2) - Instr(number2, ".")
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
;
n1 := number1
n2 := number2
StringReplace,number1,number1,-,,All
StringReplace,number2,number2,-,,All

if (Strlen(number1) >= StrLen(number2)){
	loop,% (Strlen(number1) - strlen(number2))
		number2 := "0" . number2
}
else
	loop,% (Strlen(number2) - strlen(number1))
		number1 := "0" . number1

n := strlen(number1)
;Processing

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
else	;Subtract
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
sum := LTrim(sum, "0")
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
	param := 0.99
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
return,% (param * intofactor)
}
;Negative
else
{
loop,% (negative)
	intofactor := intofactor * 10
return,% (param / intofactor)
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
product := Evaluate(product, row)
}
;Give Dots
if (dec){
	product := SubStr(product,1,StrLen(product) - dec) . "." . SubStr(product,1 - dec)
	if Instr(product, "0.")
		product := "0" . LTrim(product, "0")
	else If InStr(product, ".")
		product := Ltrim(product, "0")
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
;If anything reaches here, it's because number2 > |999999| or so.
number2 := Substr(number2, 1,Strlen(number2) - Instr(number2, "."))	;remove decs
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
if Instr(Intmd,"0.")
	Intmd := "0" . Ltrim(Intmd, "0")
else if Instr(Intmd, ".")
	Intmd := Ltrim(Intmd, "0")

if !(positive)
	Intmd := "-" Intmd
return, Intmd
}

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Greater(number1, number2){
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
	
	if (a_index == stop)
		break
}
}

}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

LogB(number, base){
IfNotInString,base,-
	IfNotInString,number,-
		return, % (log(number) / log(base))
}

nthRoot(number, n){
logy := (1 / n) * log(number)	;y = x^1/n
return, antilog(logy)
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