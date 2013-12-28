/*
Function: centres v0.01
	by Avi Aryan

returns incentre , centroid , circumcentre and orthocentre of a triangle in 2d system
can also return eqn of euler line when no parameter in "r" is passed i.e 2nd param is blank
*/

;p:=centres([[4, 0], [-2, 4], [0, 6]], "o")
;msgbox % "Orthocentres - `n x=" p.1 "`n y=" p.2
;return

;-------------------- Function ----------------------
; r := i = incentres
; m = centroid
; c = circumcentre
; o = orthocentre
; leave r blank to return eqn of euler line

centres(z, r:=""){
	mx := (z.1.1+z.2.1+z.3.1)/3 , my := (z.1.2+z.2.2+z.3.2)/3 	;medians done
	s := ( c := sqrt( (z.2.1 - z.1.1)**2 + (z.2.2-z.1.2)**2 ) ) + ( a := sqrt( (z.3.1-z.2.1)**2 + (z.3.2-z.2.2)**2 ) )
		+ ( b := sqrt( (z.3.1-z.1.1)**2 + (z.3.2-z.1.2)**2 ) )
	ix := (a*z.1.1+b*z.2.1+c*z.3.1)/s , iy := (a*z.1.2+b*z.2.2+c*z.3.2)/s 	; incentres done
	midx_a := (z.3.1+z.2.1)/2 , midy_a := (z.3.2+z.2.2)/2 , slp_a := -1*(z.3.1-z.2.1)/(z.3.2-z.2.2) 	;perpendicular slope
	cc_a := midy_a-(slp_a*midx_a)  		; b = y - mx
	midx_b := (z.3.1+z.1.1)/2 , midy_b := (z.3.2+z.1.2)/2 , slp_b := -1*(z.3.1-z.1.1)/(z.3.2-z.1.2)
	cc_b := midy_b-(slp_b*midx_b) 		; b = y - mx
	cx := (cc_b-cc_a)/(slp_a-slp_b) , cy := cc_a + (slp_a*cx) 	; y := b+mx --- circumcentres done
	oc_a := z.1.2-(slp_a*z.1.1) 	; b = y - mx
	oc_b := z.2.2-(slp_b*z.2.1)
	ox := (oc_a-oc_b)/(slp_b-slp_a) , oy := oc_a + (slp_a*ox) 	; orthocentres done
	if r in m,i,c,o
		return [Round(%r%x), Round(%r%y)]
	else return "y=" Round(m:=(oy-cy)/(ox-cx)) "x+" Round(oy-m*ox)
}