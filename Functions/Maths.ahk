/*
MATHS LIBRARY
by Avi Aryan
Thanks to hd0202, Uberi, sinkfaze and justme for valuable suggestions and ideas.
v 2.0
------------------------------------------------------------------------------

##############################################################################
FUNCTIONS
##############################################################################
See Help - http://www.avi-win-tips.blogspot.com/2013/05/maths.html
##############################################################################

* Solve(Expression, AHK=false) --- Solves a Mathematical expression.
  Use Pow(number, n) [provided below] in place of ** in Solve() 
  Solve() supports infinetly large numbers and its +-/* is powered by the respective custom functions below (when AHK is false(default)) so no need to use 
  them in Solve().
  Solve() supports functions() . Solve() supports Nesting via [] brackets ( not () )
  
* Evaluate(number1, number2) --- +/- massive numbers . Supports Real Nos (Everything)
* Multiply(number1, number2) --- multiply two massive numbers . Supports everything
* Divide(Dividend, Divisor) --- Divide two massive numbers . Supports everything
* Roots("Coefficients") - Roots of a poly function 
* Greater(number1, number2, trueforequal=false) --- compare two massive numbers 
* Prefect(number) --- convert a number to most suitable form. like ( 002 to 2 ) and ( 000.5600 to 0.56 )
* fact(number) --- factorial of a number . supports large numbers 
* Pow(number, power) --- power of a number . supports large numbers and powers
* ModG(Dividend, Divisor) --- Mod() . Supports large numbers
* FloorG(number) --- Floor() . Supports large numbers

-----  BETTER PASS NUMBERS AS STRINGS FOR THE ABOVE FUNCTIONS ------------------
-----  SEE THE COMMENTED MSGBOX CODE BELOW TO UNRSTND WHAT I MEAN --------------

* UniquePMT(pattern, ID)	;gives the unique permutation possible .
	eg -> UniquePMT("abcd", 17) >>> 17th unique permutaion for abcd . 
	eg -> UniquePMT("ram,kam,shyam,nam", "All") >>> All permutations separated by linefeeds

* Antilog(number, basetouse=10) --- gives antilog of a number . basetouse can be "e" .
* nthRoot(number, n) ---- gives nth root of a number .
  nthroot(8, 3) gives cube root of 8 = 2

* logB(number, base) --- log of a number at a partcular base.
*/

;msgbox,% Divide("3426326","30")
;msgbox,% Divide("43.034934034904334", "89.3467436743", 10)
;msgbox,% Divide("0.00000000000001","0.0000000001")
;msgbox,% UniquePMT("abcdefghijklmnopqrstuvwxyz0123456789",12389898)
;msgbox,% ModG("-22","-7")
;msgbox,% Divide("232323","23")
;msgbox,% Divide("22","7", 100)
;msgbox,% Divide("48.45","19.45", 14)
;Send,% Divide("1200000","3")
;msgbox,% fact("38")
;msgbox,% roots("1,1,1,-3")
;msgbox,% UniquePMT("avi,annat,koiaur,aurkoi", "All")
;msgbox,% Solve("[28*45] - [45*28]", false)
;msgbox,% Evaluate("1280", "-1280")
;msgbox,% Roots("1,1,1,-3") ;xcube + xsq + x - 3 = 0
;MsgBox,% Solve("23898239238923.2382398923 + 2378237238.238239 - [989939.9939 * 892398293823]")

;var = sqrt(4) - [nthroot(17248,3) * antilog(0.3010)] * [892839.2382389 - 89238239.923]
;msgbox,% Solve(var)
;msgbox,% UniquePMT("abd", "All")
;msgbox,% Solve("Sqrt(4) * nthRoot(8, 3) * 2 * log(100) * antilog(0.3010) - 32")
;Msgbox,% Greater(18.789, 187)
;Send,% "`n" Divide("434343455677690909087534208967834434444.5656", "8989998989898909090909009909090909090908656454520")
;MsgBox,% Multiply("111111111111111111111111111111111111111111.111","55555555555555555555555555555555555555555555.555")
;MsgBox,% Prefect("00.002000")
;Msgbox,% nthroot(3.375, 3)
;Msgbox,% Evaluate("-28","-98.007")
;return

Solve(expression, ahk=false){
StringReplace,expression,expression,%A_space%,,All	;The tricky part :-D
StringReplace,expression,expression,%A_tab%,,All
; More Reps
expression := Fixexpression(expression)
; Solving Brackets first
posofb := 0
loop,
{
loop,
{
	posofb := Instr(expression, "[",false,1,A_index)
	if !(Instr(expression, "[",false,1,A_index + 1)){
		if (posofb)
		{
			get := Solve( Substr(expression, posofb + 1, Instr(expression, "]", false, posofb, 1) - posofb - 1) , ahk )	;solve the bracket
			expression := Fixexpression( Substr(expression, 1, posofb - 1) . get . Substr(expression, Instr(expression, "]", false, posofb, 1) + 1) )
		}
		else
			break
	}
}
;Primary Loop
if !(Instr(expression, "["))
	break
}
;Changing +,-... in expressions to something different    ¢¤¥¦    =    +-*/

loop,
{
	if !(Instr(expression, "(")){
	StringReplace,expression,expression,+,¢,All
	StringReplace,expression,expression,-,¤,All
	StringReplace,expression,expression,*,¥,All
	StringReplace,expression,expression,/,¦,All
	StringReplace,expression,expression,\,¦,All
	reserve .= expression
	break
	}
	temp := Substr(expression, 1, Instr(expression, "(")) ;till  4+2 + sin(
	StringReplace,temp,temp,+,¢,All
	StringReplace,temp,temp,-,¤,All
	StringReplace,temp,temp,*,¥,All
	StringReplace,temp,temp,/,¦,All
	StringReplace,temp,temp,\,¦,All
	temp2 := SubStr(expression, Instr(expression, "(") + 1, Instr(expression, ")") - Instr(expression, "("))
	reserve .= temp . temp2
	expression := Substr(expression,Instr(expression, ")")+ 1)
}
;
expression := reserve

loop, parse, expression,¢¤¥¦
{
;Check for functions -- 
firstch := Substr(A_loopfield, 1, 1)
if firstch is not Integer
	{
	fname := Substr(A_LoopField, 1, Instr(A_loopfield,"(") - 1)	;extract func
	ffeed := Substr(A_loopfield, Instr(A_loopfield, "(") + 1, Instr(A_loopfield, ")") - Instr(A_loopfield, "(") - 1)	;extract func feed
	loop, parse, ffeed,`,
		{
		StringReplace,feed,A_loopfield,",,All
		feed%A_index% := feed
		totalfeeds := A_index
		}
	if totalfeeds = 1
		number := %fname%(feed1)
	else if totalfeeds = 2
		number := %fname%(feed1, feed2)
	else if totalfeeds = 3
		number := %fname%(feed1, feed2, feed3)
	else if totalfeeds = 4
		number := %fname%(feed1, feed2, feed3, feed4)	;Add more like this if needed
	}
	else
		number := A_LoopField
;Perform the previous assignment routine
if (char != ""){
	if (Ahk){
	if char = ¢
		solved := solved + (number)
	else if char = ¤
		solved := solved - (number)
	else if char = ¦
		solved := solved / (number)
	else if char = ¥
		solved := solved * (number)
	}else{
	if char = ¢
		solved := Evaluate(solved, number)
	else if char = ¤
		solved := Evaluate(solved,"-" . number)
	else if char = ¦
		solved := Divide(solved, number)
	else if char = ¥
		solved := Multiply(solved, number)
	}
}
if solved = 
	solved := number

char := Substr(expression, Strlen(A_loopfield) + 1,1)
expression := Substr(expression, Strlen(A_LoopField) + 2)	;Everything except number and char
}
return, Prefect(solved)
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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
digit := SubStr(number1,1 - A_Index, 1) + SubStr(number2, 1 - A_index, 1) + (carry ? 1 : 0)

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
numbercompare := Greater(number1, number2, true)
if !(numbercompare){
	mid := number2
	number2 := number1
	number1 := mid
}
loop,
{
digit := SubStr(number1,1 - A_Index, 1) - SubStr(number2, 1 - A_index, 1) + (borrow ? -1 : 0)

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
return, Prefect ? Prefect(sum) : sum
}

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Antilog(number, basetouse=10){
oldformat := A_FormatFloat
SetFormat, float, 0.16

if basetouse = e
	basetouse := 2.71828182845905
toreturn := basetouse ** number
SetFormat, floatfast, %oldformat%
return, toreturn
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

Divide(number1, number2, length=10){
;Getting Sign
positive := true
if (Instr(number2, "-"))
	positive := false
if (Instr(number1, "-"))
	positive := Toggle(positive)
StringReplace,number1,number1,-
StringReplace,number2,number2,-
;Perfect them
number1 := Prefect(number1) , number2 := Prefect(number2)
;Remove Decimals
dec := 0
if Instr(number1, ".")
	dec := - (Strlen(number1) - Instr(number1, "."))	;-ve as when the num is multiplied by 10, 10 is divided
if Instr(number2, ".")
	dec := Strlen(number2) - Instr(number2, ".") + dec + 0
StringReplace,number1,number1,.
StringReplace,number2,number2,.

number1 := Ltrim(number1, "0") , number2 := Ltrim(number2, "0")
decimal := dec , num1 := number1 , num2 := number2	;These wiil be used to handle point insertion

n1 := Strlen(number1) , n2 := StrLen(number2) ;Stroring n1 & n2 as they will be used heavily below
;Widen number1
loop,% n2 + length
	number1 .= "0"
coveredlength := 0 , dec := dec - n2 - length , takeone := false
;Start
while(number1 != "")
{
	times := 0 , below := "" , lendivide := 0 , n1fromleft := (takeone) ? Substr(number1, 1, n2+1) : Substr(number1, 1, n2)

	if Greater(n1fromleft, number2, true)
	{
		todivide := n1fromleft
		loop, 10
		{
			num2temp%A_index% := Multiply(number2, A_index)
			if !(Greater(todivide, num2temp%A_index%, true)){
				lendivide := (takeone) ? n2 + 1 : n2
				times := A_index - 1 , below := num2temp%times%
				break
			}
		}
		if (n1 >= coveredlength)
			res .= zeroes_r
	}
	else
	{
		todivide := SubStr(number1, 1, n2+1)	; :-P (takeone) will not be needed here
		loop, 10
		{
			num2temp%A_index% := Multiply(number2, A_index)
			if !(Greater(todivide, num2temp%A_index%, true)){
				lendivide := n2 + 1
				times := A_index - 1 , below := num2temp%times%
				break
			}
		}
		if (coveredlength != 0)
			if (n1 == coveredlength)	;if all nums have been bought down, time for decimal no Zero
				res .= zeroes_r
			else if (n1 >= (coveredlength+1))
				res .= zeroes_r "0"
	}
	res .= times , coveredlength+=(lendivide - Strlen(remainder))	;length of previous remainder will add to number1 and so is not counted
	remainder := Evaluate(todivide, "-" below)

	if remainder = 0
		remainder := ""
	number1 := remainder . Substr(number1, lendivide + 1)

	if Greater("0", remainder, true)
	{
		zeroes_k := ""
		loop,% Strlen(number1)
			zeroes_k .= "0"
		if (number1 == zeroes_k){
			StringTrimRight,number1,number1,1
			number1 := "1" . number1
			res := Multiply(res, number1)
			break
		}
	}
	if times = 0
		break

	zeroes_r := "" , takeone := false
	if (remainder == "") {
		loop,
		{
			if (Instr(number1, "0") == "1")
				zeroes_r .= "0" , number1 := Substr(number1, 2) , coveredlength+=1
			else
				break
		}
	}
	if (Strlen(remainder) == n2 and n1 > coveredlength)
		takeone := true
	else
		loop,% n2 - StrLen(remainder) - 1
			zeroes_r .= "0"
}
;Putting Decimal points"

if (dec < 0)
{
	oldformat := A_formatfloat
	SetFormat,float,0.16e
	Divi := Substr(num1,1,15) / Substr(num2,1,15) ; answer in decimals
	decimal := decimal + Strlen(Substr(num1,16)) - Strlen(Substr(num2,16))

	if (Instr(divi,"-"))
		decimal := decimal - Substr(divi,-1) + 1
	else
		decimal := decimal + Substr(divi,-1) + 1

	if (decimal > 0)
		res := Substr(res, 1, decimal) . "." . Substr(res, decimal + 1)
	else if (decimal < 0){
		loop,% Abs(decimal)
			zeroes_e .= "0"
		res := "0." zeroes_e res
	}
	else
		res := "0." res

	SetFormat,float,%oldformat%
}
else
{
	num := "1"
	loop,% dec
		num .= "0"
	res := Multiply(Prefect(res), num)
}
return, ( (positive) ? "" : "-" ) . Prefect(res)
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Roots(expression){		;Enter a, b, c for quad. eqn ------  a, b, c, d for cubic eqn. and so on
StringReplace,expression,expression,%A_space%,,All
StringReplace,expression,expression,%A_tab%,,All
;eqn, limit
limit := 0
loop, parse, expression,`,	;get individual coffs
{
	if !(Instr(A_Loopfield, "+") or Instr(A_loopfield, "-"))
		coff%A_index% := "+" A_loopfield
	else
		coff%A_index% := A_loopfield
	
	limit := limit + Abs(A_loopfield)
	nofterms := A_index
}

loop,% (nofterms - 1)	;not including contsant
	term .= Substr(coff%A_index%, 1, 1) "[" Substr(coff%A_index%,2) . " * Pow(x, " . (nofterms - A_index) . ")" "]"
term .= coff%nofterms%

plot := limit
if (limit / (nofterms-1) < 8)	;if roots are within short range, slow down
	speed := defaultspeed := 0.2 , incomfac := "0.00" , lessfac := "0.01"
else
	speed := defaultspeed := 1 , incomfac := "0.0" , lessfac := "0.05"

positive := true
StringReplace,expression,term,x,%plot%,All	;getting starting value
if Instr(Solve(expression), "-")
	positive := false

while (plot >= -limit)	;My theorem - Safe Range
{
	StringReplace,expression,term,x,%plot%,All
	fx := Solve(expression, true)	;Over here ... Uses the AHK processes for faster results
	
	if (speed == defaultspeed){
		if (fx == "0"){
			roots .= Prefect(plot) . ","
			positive := Toggle(positive) , plot-=speed
			if (Instr(roots, ",", false, 1, nofterms - 1))	;if all roots have already been found, go out
				break
			continue
			msgbox,% plot
		}
	}
	else{
		compare := Substr(Ltrim(fx, "-"),1,4)
		if ((Instr(compare,incomfac) == 1) or compare+0 < lessfac+0)
			{
			roots .= Prefect(plot) . ","
			speed := defaultspeed , positive := Toggle(positive) , plot-=speed
			if (Instr(roots, ",", false, 1, nofterms - 1))
				break
			continue
			}
		}

	if (positive){
		if (Instr(fx,"-")){
			plot+=defaultspeed , positive := Toggle(positive) , speed := 0.01	;Lower the value, more the time and accurateness
			continue
		}
	}else{
		if !(Instr(fx, "-")){
			plot+=defaultspeed , positive := Toggle(positive) , speed := 0.01
			continue
		}
	}
	plot-=speed
}
return, Rtrim(roots, ",")
}
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

UniquePmt(series, ID=1, Delimiter=","){
if Instr(series, Delimiter)
	loop, parse, series,%Delimiter%
		item%A_index% := A_LoopField , last := lastbk := A_Index
else{
	loop, parse, series
		item%A_index% := A_loopfield
	last := lastbk := Strlen(series)	; Multilined for speed
}
; The theory
if ID = All			;Return all possible permutations
{
	fact := fact(last)
	loop,% fact
		toreturn .= UniquePmt(series, A_index) . "`n"
	return, Rtrim(toreturn, "`n")
}
posfactor := (ModG(ID, last) == "0") ? last : ModG(ID, last)
incfactor := (ModG(ID, last) == "0") ? FloorG(Divide(ID,last)) : FloorG(Divide(ID,last)) + 1

loop,% last
{
	tempmod := ModG(posfactor + incfactor - 1, last)	;should be faster
	posfactor := (tempmod == "0") ? last : tempmod 	;Extraction point
	res .= item%posfactor% . Delimiter , item%posfactor% := ""

	loop,% lastbk
		if (item%A_index% == "")
			plus1 := A_index + 1 , item%A_index% := item%plus1% , item%plus1% := ""

	last-=1
	if (posfactor > last)
		posfactor := 1
}
return, Rtrim(res, Delimiter)
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
number1 := Prefect(number1) , number2 := Prefect(number2)
; Manage Decimals
dec1 := (Instr(number1,".")) ? ( StrLen(number1) - InStr(number1, ".") ) : (0)
dec2 := (Instr(number2,".")) ? ( StrLen(number2) - InStr(number2, ".") ) : (0)

if (dec1 > dec2)
	loop,% (dec1 - dec2)
		number2 .= "0"
else if (dec2 > dec1)
	loop,% (dec2 - dec1) 
		number1 .= "0"

StringReplace,number1,number1,.
StringReplace,number2,number2,.
; Compare Lengths
if (Strlen(number1) > Strlen(number2))
	return,% (bothminus) ? (false) : (true)
else if (Strlen(number2) > Strlen(number1))
	return,% (bothminus) ? (true) : (false)
else	;The final way out
{
stop := StrLen(number1)
loop,
{
	if (SubStr(number1,A_Index, 1) > Substr(number2,A_index, 1))
		return,% (bothminus) ? (false) : (true)
	else if (Substr(number2,A_index, 1) > SubStr(number1,A_Index, 1))
		return,% (bothminus) ? (true) : (false)
	
	if (a_index == stop)
		return, (trueforequal) ? true : false
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
ModG(dividend, divisor){
;Signs
positive := true
if (Instr(divisor, "-"))
	positive := false
if (Instr(dividend, "-"))
	positive := Toggle(positive)
StringReplace,dividend,dividend,-
StringReplace,divisor,divisor,-

Remainder := dividend
;Calculate no of occurances
if Greater(dividend, divisor, true){
	div := Divide(dividend, divisor)
	div := Instr(div, ".") ? SubStr(div, 1, Instr(div, ".") - 1) : 0
	if div = 0
		Remainder := 0
	else
		Remainder := Evaluate(dividend,"-" Multiply(divisor, div))
}
return, ( Positive ? "" : "-" ) . Remainder
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

FloorG(number){
number := Prefect(number)
if Instr(number, "-")
{
	if Instr(number,".")
		return, Evaluate(Substr(number, 1, Instr(number, ".") - 1), -1)
	else
		return, number
}
else
	return, (Instr(number, ".")) ? Substr(number, 1, Instr(number, ".") - 1) : number
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
return,% sign . Prefect(antilog( (1/n) * log(number) ))
}

fact(number){
return, (number+0<2) ? 1 : Multiply(number, fact(number-1))
}

Pow(number, power){
if (power < 1)
	return, nthRoot(number, power)
else{
	multiple := 1
	loop, %power%
		multiple := Multiply(multiple, number)
	return, multiple
}
}
;################# NON - MATH FUNCTIONS #######################################
;################# RESERVED ###################################################

FixExpression(expression){
StringReplace,expression,expression,--,+,All
StringReplace,expression,expression,-+,-,All
StringReplace,expression,expression,+-,-,All
StringReplace,expression,expression,++,+,All

if (Substr(expression, 1, 1) != "+" or Substr(expression, 1, 1) != "-")
	expression := "+" expression
loop,
{
if Instr(expression, "*-"){
	fromleft := Substr(expression, 1, Instr(expression, "*-"))
	StringGetPos,posplus,fromleft,+,R
	StringGetPos,posminus,fromleft,-,R
	if (posplus > posminus)
		fromleft := Substr(fromleft, 1, posplus) "-" Substr(fromleft, posplus + 2)
	else
		fromleft := Substr(fromleft, 1, posminus) "+" Substr(fromleft, posminus + 2)
	expression := fromleft . Substr(expression, Instr(expression, "*-") + 2)
}else if Instr(expression, "/-"){
	fromleft := Substr(expression, 1, Instr(expression, "/-"))
	StringGetPos,posplus,fromleft,+,R
	StringGetPos,posminus,fromleft,-,R
	if (posplus > posminus)
		fromleft := Substr(fromleft, 1, posplus) "-" Substr(fromleft, posplus + 2)
	else
		fromleft := Substr(fromleft, 1, posminus) "+" Substr(fromleft, posminus + 2)
	expression := fromleft . Substr(expression, Instr(expression, "/-") + 2)
}else if Instr(expression, "\-"){
	fromleft := Substr(expression, 1, Instr(expression, "\-"))
	StringGetPos,posplus,fromleft,+,R
	StringGetPos,posminus,fromleft,-,R
	if (posplus > posminus)
		fromleft := Substr(fromleft, 1, posplus) "-" Substr(fromleft, posplus + 2)
	else
		fromleft := Substr(fromleft, 1, posminus) "+" Substr(fromleft, posminus + 2)
	expression := fromleft . Substr(expression, Instr(expression, "\-") + 2)
}else if Instr(expression, "x-"){
	fromleft := Substr(expression, 1, Instr(expression, "x-"))
	StringGetPos,posplus,fromleft,+,R
	StringGetPos,posminus,fromleft,-,R
	if (posplus > posminus)
		fromleft := Substr(fromleft, 1, posplus) "-" Substr(fromleft, posplus + 2)
	else
		fromleft := Substr(fromleft, 1, posminus) "+" Substr(fromleft, posminus + 2)
	expression := fromleft . Substr(expression, Instr(expression, "x-") + 2)
}else
	break
}
StringReplace,expression,expression,--,+,All
StringReplace,expression,expression,-+,-,All
StringReplace,expression,expression,+-,-,All
StringReplace,expression,expression,++,+,All
return, expression
}

Toggle(bool){
return,% (bool) ? (false) : (true)
}
ReverseAKAFlip(string){
loop,% Strlen(string)
	flip .= Substr(string, 1 - A_index, 1)
return, flip
}