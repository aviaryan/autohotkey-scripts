SetWorkingDir %A_ScriptDir%

;THE FILE CONTAINS 2 EXAMPLES OF using GroupSort.ahk
;Look at both of them

;======================= EXAMPLE 1 ==================================
names =
(
avi
kshitij
prasun
doctor
)

subjects =
(
comp
phe
bio_bad
bio_good
)

places =
(
r nag
b sam
b rod
b nat
)

Obj := [names, subjects, places]		;make a object

students := new GroupSort(Obj)		;create a GroupSort object
msgbox % students.fetch("1,2") "`n`n" students.fetch(3)		;Using fetch() , strings

retobj := students.Sort() 		;Using Sort() , returns sorted thing in object (same like the way in which it was inserted)
for k,v in retobj
	x .= v "`n`n"
msgbox % x

;======================== EXAMPLE 2 -======================================

numbers =
(
1
3
4
9
16
100
)

sqroots =
(
+-1
doesn't have a natural sq. root
+-2
+-3
+-4
+-10
)

msgbox,% new GroupSort( obj := [numbers, sqroots] ).fetch() 		;WILL RETURN SORTING IN STRING FORMAT

msgbox,% "Sorting in numeric format`n`n" new GroupSort( obj, "N").fetch()
return


#Include GroupSort.ahk