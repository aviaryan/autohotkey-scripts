/*
++++++++++++++++++++++
Math_Functions v0.13  +
-----------------------
by Avi Aryan          +
++++++++++++++++++++++

Math_Functions is a collection of useful mathematical functions for general usage.

++++++++++++++++++++++++++++
CREDITS  (Alphabetically)  +
++++++++++++++++++++++++++++
A v i
Lazzlo

############################
LINKS
############################

Scientific Maths (Maths.ahk) - https://github.com/Avi-Aryan/Avis-Autohotkey-Repo/blob/master/Functions/Maths.ahk

*/

;#include %A_ScriptDir%/maths.ahk
;##################################################

/*
quadratic(x1, x2, a, b, c) // cubic(x1, x2, x3, a, b, c, d)     BY Lazzlo

   x1 = Byref variable to store 1st root
   x2 = Byref variable to store 2nd root
   x3 = Byref variable to store 3rd root
   
   a = first coefficient in the eqn
   .....
   d = fourth coefficient in the eqn

Returns >
   Returns the number of roots possible
*/

quadratic(ByRef x1, ByRef x2, a,b,c) { ; -> #real roots {x1,x2} of ax**2+bx+c
   i := fcmp(b*b,4*a*c,63) ; 6 LS bit tolerance
   If (i = -1) {
      x1 := x2 := ""
      Return 0
   }
   If (i = 0) {
      x1 := x2 := -b/2/a
      Return 1
   }
   d := sqrt(b*b - 4*a*c)
   x1 := (-b-d)/2/a
   x2 := x1 + d/a
   Return 2
}

cubic(ByRef x1, ByRef x2, ByRef x3, a,b,c,d) { ; -> #real roots {x1,x2,x3} of ax**3+bx**2+cx+d
   Static pi23:=2.094395102393195492, pi43:=4.188790204786390985
   x := -b/3/a                                 ; Nickalls method
   y := ((a*x+b)*x+c)*x+d
   E2:= (b*b-3*a*c)/9/a/a
   H2:= 4*a*a*E2*E2*E2

   i := fcmp(y*y,H2, 63)

   If (i = 1) { ; 1 real root
      q := sqrt(y*y-H2)
      x1 := x + nthRoot((-y+q)/2/a, 3) + nthRoot((-y-q)/2/a, 3)
      x2 := x3 := ""
      Return 1
   }
   If (i = 0) { ; 3 real roots (1 or 2 different)
      If (fcmp(H2,0, 63) = 0) { ; root1 is triple...
         x1 := x2 := x3 := x
         Return 1
      } ; h <> 0                : root2 is double...
      E := nthRoot(y/2/a, 3) ; with correct sign
      x1 := x - E - E
      x2 := x3 := x + E
      Return 2
   } ; i = -1   : 3 real roots (different)...
   t := acos(-y/sqrt(H2)) / 3
   E := 2*sqrt(E2)
   x1 := x + E*cos(t)
   x2 := x + E*cos(t+pi23)
   x3 := x + E*cos(t+pi43)
   Return 3
}

;##################################################

/*
Roots(expression)     BY Avi Aryan

   expression = STRING containing CSV of coefficients in a polynomial

Returns >
   the Comma - separated roots of (expression)

Notes >
   * Requires Scientific Maths lib (Maths.ahk) .
   * Not dependable at all as it uses a smart loop to find roots.
     Use quadratic() and cubic() functions where they are possible.
*/

Roots(expression){		;Enter a, b, c for quad. eqn ------  a, b, c, d for cubic eqn. and so on

   static sm_solve := "SM_Solve"             ; var to hold the foreign function

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
	
		limit := limit + Abs(A_loopfield) , nofterms := A_index
	}

	loop % (nofterms - 1)	;not including contsant
		term .= Substr(coff%A_index%, 1, 1) "(" Substr(coff%A_index%,2) . " * SM_Pow(x, " . (nofterms - A_index) . ")" ")"
	
	term .= coff%nofterms% , plot := limit
	
	if (limit / (nofterms-1) < 8)	;if roots are within short range, slow down
		speed := defaultspeed := 0.2 , incomfac := "0.00" , lessfac := "0.01"
	else
		speed := defaultspeed := 1 , incomfac := "0.0" , lessfac := "0.05"

	positive := true
	StringReplace,expression,term,x,%plot%,All	;getting starting value

	if Instr(%sm_solve%(expression, 1), "-")
		positive := false

	while (plot >= -limit)	;My theorem - Safe Range
	{
		StringReplace,expression,term,x,%plot%,All
		fx := %sm_solve%(expression, true)	;Over here ... Uses the AHK processes for faster results
	
		if (speed == defaultspeed){
			if (fx == "0"){
				roots .= Prefect(plot) . ","
				positive := !positive , plot-=speed
				if (Instr(roots, ",", false, 1, nofterms - 1))	;if all roots have already been found, go out
					break
				continue
			}
		}
		else{
			compare := Substr(Ltrim(fx, "-"),1,4)
			if ((Instr(compare,incomfac) == 1) or compare+0 < lessfac+0)
				{
				roots .= Prefect(plot) . ","
				speed := defaultspeed , positive := !positive , plot-=speed
				if (Instr(roots, ",", false, 1, nofterms - 1))
					break
				continue
				}
			}

		if (positive){
			if (Instr(fx,"-")){
				plot+=defaultspeed , positive := !positive , speed := 0.01	;Lower the value, more the time and accurateness
				continue
			}
		}else{
			if !(Instr(fx, "-")){
				plot+=defaultspeed , positive := !positive , speed := 0.01
				continue
			}
		}
		plot-=speed
	}
	return, Rtrim(roots, ",")
}


;SM_Solve4Roots()

;##################################################

/*

UniquePmt(series, ID, Delimeter)        BY Avi Aryan

   series = (Delimeter) separated items whose Unique Permutation is to be extracted
   ID = denotes the nth permutaion to be returned
         ID = "" gives all possible permutations
   Delimeter = Char which separates the (series)

+Desc >
   Gives the Unique Permutation of a collection of Objects with respect to a number
   
Returns >
   Unique permutation of series with respect to (ID)
   
Notes >
   The function will fail for larger series (number of items > 17) . For that use the SM_UniquePmt() function included in Maths.ahk [See intro for link]

*/

UniquePmt(series, ID="", Delimiter=","){

   if Instr(series, Delimiter)
      loop, parse, series,%Delimiter%
         item%A_index% := A_LoopField , last := lastbk := A_Index
   else
   {
      loop, parse, series
         item%A_index% := A_loopfield
      last := lastbk := Strlen(series) , Delimiter := ""
   }

   if (ID == "")			;Return all possible permutations
   {
      fact := fac(last)
      loop,% fact
         toreturn .= UniquePmt(series, A_index) . "`n"
      return, Rtrim(toreturn, "`n")
   }
   
   posfactor := (Mod(ID, last) == "0") ? last : Mod(ID, last)
   incfactor := (Mod(ID, last) == "0") ? Floor(ID / last) : Floor(ID / last) + 1

   loop,% last
   {
      posfactor := !(tempmod := Mod(posfactor + incfactor - 1, last)) ? last : tempmod
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

;##################################################

/*
nthRoot(number, n)      BY Avi Aryan

   number = The number whose root is to extracted
   n = which root to be extracted
   
Returns >
   the (n)-th root of (number)
*/

nthRoot(number, n){
   if Instr(number, "-")
   {
      number := Substr(number,2)
      if !Mod(n, 2)		;check for even
         return
      sign := "-"
   }
   return sign . Round(number**(1/n))
}

;##################################################

/*
Prefect(number)         BY Avi Aryan
   number = any number

Returns >
   The perfect form of representing that (number)
*/

Prefect(number){
   if !Instr(number, ".")
      return Round(number)
   else
   {
      if number<0
         number := Substr(number,2) , neg := "-"
      number := Trim(number, "0")
      if (Substr(number,1,1) == ".")	;if num like	.6767
         number := "0" number
      if (Substr(number, 0) == ".")	;like 456.
         number := Substr(number, 1, -1)
      return neg number
   }
}

;##################################################

/*
dec2frac(number)                    by Avi Aryan
   Converts decimal to fraction

Returns >
   space separated values of numerator and denominator
*/

dec2frac(number){
   if !( dec_pos := Instr(number, ".") )
      return number

   n_dec_digits := Strlen(number) - dec_pos , dec_num := Substr(number, dec_pos+1)
   , base_num := Substr(number, 1, dec_pos-1)

   t := 1
   loop % n_dec_digits   
      t .= "0"

   numerator := base_num*t + dec_num , denominator := t
   HCF := GCD(numerator, denominator)
   numerator /= HCF , denominator /= HCF

   return Round(numerator) " " Round(denominator)
}

;##################################################

/*
MIN(a1,a2,a3...,a10) // MAX(a1,a2,a3...,a10)        BY Lazzlo

   a1 = first number
   a2 = second number
   ......
   a10 = tenth number

Returns >
   the number which is smallest // largest
*/

MIN(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="") {
   Loop 9
      If (x%A_Index% <> "" && x > x%A_Index%) ; ignore blanks
          x:= x%A_Index%
   Return x
}

MAX(x,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="") {
   Loop 9
      If (x < x%A_Index%)
          x:= x%A_Index%
   Return x
}

;##################################################

/*
GCD(a,b)           BY Lazzlo

   a = first number
   b = second number

Returns >
   the Greatest Common Divisor/Highest common factor of the two numbers
*/

GCD(a,b) {
   Return b=0 ? Abs(a) : GCD(b, mod(a,b))
}

;##################################################

/*
Antilog(number, base)       BY Avi Aryan

   number = Number for which antilog is to be found
   base = base to be used in the process
   
Returns >
   the antilog of number (number) calculated by using base (base)
*/

Antilog(number, basetouse=10){
   oldformat := A_FormatFloat
   SetFormat, float, 0.16

   if basetouse = e
      basetouse := 2.71828182845905
   toreturn := basetouse ** number
   SetFormat, floatfast, %oldformat%
   return, toreturn
}

;#################################################

/*
IsPrime(N)        By Avi

   Returns 1 if the number is prime 
*/

IsPrime(n) {         ;by kon
    if (n < 2)
        return, 0
    else if (n < 4)
        return, 1
    else if (!Mod(n, 2))
        return, 0
    else if (n < 9)
        return 1
    else if (!Mod(n, 3))
        return, 0
    else {
        r := Floor(Sqrt(n))
        f := 5
        while (f <= r) {
            if (!Mod(n, f))
                return, 0
            if (!Mod(n, (f + 2)))
                return, 0
            f += 6
        }
        return, 1
    }
}

;IsPrime(N){
;   if N in 2,3,5,7
;      return 1
;   else if !Mod(Lst := Substr(N, 0), 2) or (Lst = 5) or !Mod(N,3) or ( Mod(N-1, 6) && Mod(N+1, 6) )
;      return 0

;   Frt := Floor( Floor(Sqrt(N)) / 10 )

;   loop % Frt+1
;   {
;      if !Mod(N, A_index*10-7)  ;-10+3
;         return 0
;      if !Mod(N, A_index*10-3)  ;-10+7
;         return 0
;      if !Mod(N, A_index*10-9)   ;-10+1
;        if A_index >1
;          return 0
;   }
;   return 1
;}


;##################################################

/*
Choose(n,k)         BY Lazzlo
   
*/

Choose(n,k) {   ; Binomial coefficient
   p := 1, i := 0, k := k < n-k ? k : n-k
   Loop %k%                   ; Recursive (slower): Return k = 0 ? 1 : Choose(n-1,k-1)*n//k
      p *= (n-i)/(k-i), i+=1  ; FOR INTEGERS: p *= n-i, p //= ++i
   Return Round(p)
}

;##################################################

/*
Fib(n)            BY Lazzlo
   n = nth term in fibonacci series

Returns >
   The (n)-th number in fibonacci series (The series starts from 1)
*/

Fib(n) {        ; n-th Fibonacci number (n < 0 OK, iterative to avoid globals)
   a := 0, b := 1
   Loop % abs(n)-1
      c := b, b += a, a := c
   Return n=0 ? 0 : n>0 || n&1 ? b : -b
}

;##################################################

/*
Fac(n)          BY Lazzlo
   n = number

Returns >
   The factorial of (n)
*/

fac(n) {
   Return n<2 ? 1 : n*fac(n-1)
}

;##################################################

/*
LogB(number, base)          BY Avi Aryan

   number = number
   base = base of log

Returns >
   Log of (number) to the base (base)
*/

LogB(number, base){
   if ( number >= 0 AND base > 0 )
      return Round(log(number) / log(base))
}

;##################################################

/*
Trigometric_Functions(x)        BY Lazzlo

   x = angle in radians
   
Returns >
   The corresponding Trignometric value
*/

cot(x) {        ; cotangent
   Return 1/tan(x)
}
acot(x) {       ; inverse cotangent
   Return 1.57079632679489662 - atan(x)
}
atan2(x,y) {    ; 4-quadrant atan
   Return dllcall("msvcrt\atan2","Double",y, "Double",x, "CDECL Double")
}

sinh(x) {       ; hyperbolic sine
   Return dllcall("msvcrt\sinh", "Double",x, "CDECL Double")
}
cosh(x) {       ; hyperbolic cosine
   Return dllcall("msvcrt\cosh", "Double",x, "CDECL Double")
}
tanh(x) {       ; hyperbolic tangent
   Return dllcall("msvcrt\tanh", "Double",x, "CDECL Double")
}
coth(x) {       ; hyperbolic cotangent
   Return 1/dllcall("msvcrt\tanh", "Double",x, "CDECL Double")
}

asinh(x) {      ; inverse hyperbolic sine
   Return ln(x + sqrt(x*x+1))
}
acosh(x) {      ; inverse hyperbolic cosine
   Return ln(x + sqrt(x*x-1))
}
atanh(x) {      ; inverse hyperbolic tangent
   Return 0.5*ln((1+x)/(1-x))
}
acoth(x) {      ; inverse hyperbolic cotangent
   Return 0.5*ln((x+1)/(x-1))
}

;############################################################################################################################################################

fcmp(x,y,tol) {
   Static f
   If (f = "") {
      VarSetCapacity(f,162)
      Loop 324
         NumPut("0x"
. SubStr("558bec83e4f883ec148b5510538b5d0c85db568b7508578b7d148974241889542410b9000000807f"
. "137c0485f6730d33c02bc68bd91b5d0c89442418837d14007f137c0485d2730d33c02bc28bf91b7d1489442410"
. "8b7424182b7424108b45188bcb1bcff7d8993bd17f187c043bc677128b4518993bca7f0a7c043bf0770433c0eb"
. "183bdf7f117c0a8b44241039442418730583c8ffeb0333c0405f5e5b8be55dc3"
, 2*A_Index-1,2), f, A_Index-1, "Char")
   }
   Return DllCall(&f, "double",x, "double",y, "Int",tol, "CDECL Int")
}


