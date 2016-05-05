pro lc

readcol,'planet_au.txt',f='(A,F,F)', n_p, a_p0, r_p0,/silent

el = read_csv('sat_elem.csv')
; el.FIELD01 = moon name
; el.FIELD02 = moon a

ph = read_csv('sat_phys_par.csv')
; ph.FIELD01 = moon name
; ph.FIELD04 = moon r


;-- brute force match the moon names
;   if no exact match, use first 5 chars
;-> match to ph
mph = findgen(n_elements(ph.field01))
mel = fltarr(n_elements(ph.field01))-1
for n = 3l,n_elements(ph.field01)-1 do begin
   x = where((ph.field01)[n] eq (el.field01))
   if x[0] eq -1 then begin
      ; trim all spaces out
      ; make lowercase
      ; try literal match again
      s1 = strtrim((ph.field01)[n], 2)
      s2 = strtrim(el.field01, 2)
      
      x = where(strmid(s1,0,5) eq strmid(s2,0,5))
   endif

   mel[n] = x[0]
endfor



;-- arrays i'll need:
; - r_p
; - a_p
; - r_m
; - a_m

r_m = (ph.field04)[mph]
a_m = (el.field02)[mel]
p_m = (ph.field11)[mph]
moon = (ph.field01)[mph]

remove,where(mel eq -1), r_m, a_m, p_m, moon
remove,where(p_m eq ''), r_m, a_m, p_m, moon

r_m = float(r_m)
a_m = float(a_m)

r_p = r_m*0.
a_p = a_m*0.

for n=2,8 do $
   r_p[where(p_m eq n_p[n])] = r_p0[n]

for n=2,8 do $
   a_p[where(p_m eq n_p[n])] = a_p0[n]


;-- calc angular size of Sun from planet
theta_sun = (!R_Sun / (a_p*!AU)) * 2. * !RADEG

;-- calc angular size from planet surface
theta_moon = (r_m / (a_m - r_p)) * 2. * !RADEG



set_plot,'X'
plotstuff,/set,/silent
loadct,39,/silent
!p.font=0


theta_diff = abs(theta_sun - theta_moon)/theta_sun
ok = where(theta_diff lt 0.1)
oj = where(theta_diff lt 0.2)


set_plot,'ps'

device,filename='sun_moon.eps',/encap,/color,/inch,xsize=9,ysize=6.65
plot, theta_sun, theta_moon,psym=8,symsize=2,/xlog,/ylog,$
      xtitle='!7Angular Diameter of Sun (deg)',$
      ytitle='!7Angular Diameter of Satellite (deg)',$
      xtickname=['10!u-2!n','10!u-1!n','10!u0!n'],$
      yrange=[1d-6,5],/ysty
oplot, theta_sun, theta_moon, psym=8, color=90,symsize=1.5



loadct,0,/silent
oplot,[1d-5,1d5],[1d-5,1d5],thick=3,linestyle=1
xyouts,/data, 0.2, 1d-3,'!7Sun larger in sky',color=90,orient=10
xyouts,/data, 0.2, .9, '!7Satellite larger in sky',color=90,orient=10

loadct,39,/silent

xyouts,/data,theta_sun[172]*1.05,theta_moon[172]*0.9,moon[172],charsize=1,color=21


xyouts,/data,theta_sun[0]*1.05,theta_moon[0]*0.9,moon[0],charsize=1,color=250
xyouts,/data,theta_sun[ok[1]]*1.05,theta_moon[ok[1]]*1.1,moon[ok[1]],charsize=1,color=250

xyouts,/data,theta_sun[ok[2]]*1.05,theta_moon[ok[2]]*0.75,moon[ok[2]],charsize=1,color=250
xyouts,/data,theta_sun[ok[3]]*1.05,theta_moon[ok[3]]*0.9,moon[ok[3]],charsize=1,color=250

xyouts,/data,(!R_sun / (a_p0[2:*]*!AU)) * 2. * !RADEG*0.9,$
       fltarr(7)+2d-6,n_p[2:*],orient=90,color=60,charsize=1
device,/close



; print,moon[where(theta_moon ge 0.4)]


set_plot,'X'
stop
end
