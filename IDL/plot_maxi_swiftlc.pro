pro plot_maxi_swiftlc, ps=ps, fname=namef, showchandra=showchandra, p2file=p2file, ismdust=ismdust

;This program plots the absorbed and unabsrbed 4U1630-47 fluxes for dust scattering halo calculations.
;
; INPUTS
;
; NONE - reads swiftinfo.txt for flux info
;
; OUTPUTS
;
; NONE - plots figures, and a text file
;
; OPTIONAL INPUTS
;
; ps: If set plot postscript
; fname: If set, give postcript name
; showchandra: IF set, show the chandra 
; p2file=p2file
; ismdust: if set use ismdust results
;
; USES
;
; NONE
;
; USED BY
;
; All DSH fitting codes for 4U 1630-47
;
; COMMENTS
;
; Rewritten by Emrah Kalemci to include unabsorbed fluxes
; September 2024
;
; adding the option of ismdust fits
; checking for possible overcalculation - only a factor of 5%
; ignoring poor fit values
;  

IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='maxi_swiftlc.eps'
IF NOT keyword_set(showchandra) THEN showchandra=0
IF NOT keyword_set(p2file) THEN p2file=0
IF NOT keyword_set(ismdust) THEN ismdust=0


IF ps THEN BEGIN
   set_plot,'ps'
   device,/color
   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
   device, ysize = 12.
   ;device, xsize = 12.0
   !p.font=0
   device,/times
ENDIF ELSE BEGIN
   device, decomposed=0
   loadct, 5
ENDELSE


;READ and PLOT MAXI LIGHT CURVE 2-4 keV

sed_data=read_csv('/Users/ekalemci/TOOLS/DSH_codes/IDL/glcbin24.0h_regbg_hv0.csv') ;hate magic names
mjdm=sed_data.field1
m24=sed_data.field4
e24=sed_data.field5
;m410=sed_data.field6
;e410=sed_data.field7

;readcol,'J1634-473_g_lc_1day_all.dat', mjdm, m220,e220, m24,e24, m410, e410, m1020, e1020

;CHANDRA OBSERVATION DATE
chand=57789.4

IF showchandra THEN nyr=[1e-6,1.8] ELSE nyr=[1e-5,1.8]

ploterror,mjdm-50000.,m24,e24,psym=4,/nohat,xr=[7600,7800],$
          xtitle='Time (MJD-50000 days)',$
          ytitle='ph cm!E-2!N s!E-1!N',charsize=2.,/ylog,yr=nyr,/ystyle


;swift data

IF ps THEN oplc=0 ELSE oplc=255

IF ismdust THEN fswinfo='swiftinfo_ismd.txt' ELSE fswinfo='swiftinfo.txt'

readcol,'/Users/ekalemci/TOOLS/DSH_codes/IDL/'+fswinfo, obsid, sd0, f24, f2232, nha, nhw, tin, uf2232, uf1523, uf325

;additional swift data during decay

sdates=[57769.845,57771.775,57773.237,57777.35]
sflux24=[0.00110, 0.000471,0.000305,0.000076]
sflux15=[0.00165,0.000772,0.000494,0.000124]
sflux2232=[0.00238,0.00081,0.00061,0.00012]
sflux1523=[0.00306,0.00098,0.00084,0.00017]
sflux325=[0.00217,0.00100,0.00071,0.00012]

IF ismdust THEN BEGIN
     sflux24=[0.00100, 0.000397,0.000275,0.000059]
;     sflux15=[0.00165,0.000772,0.000494,0.000124]
     sflux2232=[0.00331,0.00117,0.00082,0.00017]
     sflux1523=[0.00482,0.00148,0.00106,0.00021]
     sflux325=[0.00291,0.00133,0.00090,0.00020]
ENDIF


plotsym,0,/fill

;absorbed
oplot,sd0-50000.,f24, psym=8,color=oplc
oplot,sdates-50000.,sflux24,psym=8,color=oplc

plotsym,0

;unbsorbed
oplot,sd0-50000.,uf2232, psym=8,color=oplc
;oplot,sd0-50000.,uf1523, psym=4,color=oplc


;plot chandra date, only if not showing Chandra flux
IF NOT showchandra THEN oplot,[chand,chand]-50000.,10^(!y.crange),color=oplc,line=2,thick=2


;plot MAXI absorbed
t0=57625.  ;start of outburst
;tl=57761.  ;end of dates that we use maxi data
tl=57754

delt=tl-t0
xx=where((mjdm GT t0) AND (mjdm LT tl))

time=indgen(floor(tl-t0)) ;get maxi part

m24[2157:2159]=0.285  ; average out some stupid data
m24[2182:2183]=0.18
m24[2169]=0.25
F=interpol(m24[xx],mjdm[xx],time+t0) ; interpolate maxi data per day
;oplot,time+t0,F,color=0
;from MJD 57755 to 57780 add exponential decay


;plot exponential decay
edecay=0.30
dd=findgen(36)+1 ; decay almost all the way to Chandra data (2 days before)
Foft_add=F[n_elements(F)-1L]*exp(-dd*edecay) ;
Foft=[F,Foft_add]
;plot ubsorbed exponential decay
oplot,t0+indgen(floor(tl-t0)+36)-50000.,Foft,color=oplc


;calculate unabsorbed based on unabsorbed swift

;ignore 00031224026, 00031224027
;ccfactor=avg(f24[1:22])/avg(F[10:55]) ; cross correlation factor

ccfactor=avg([f24[2:4],f24[13:15]])/avg([F[10:14],F[28:34]])
abf2=avg(uf2232[1:22])/avg(f24[1:22]) ; absorption factor for E2
abf1=avg(uf1523[1:22])/avg(f24[1:22])
abf3=avg(uf325[1:22])/avg(f24[1:22])

UFnew_E2=F*ccfactor*abf2
UFnew_E1=F*ccfactor*abf1
UFnew_E3=F*ccfactor*abf3


;from 57625 to 57635
UF0_E2=UFnew_E2[0:10]
UF0_E1=UFnew_E1[0:10]
UF0_E3=UFnew_E3[0:10]


d0=t0+findgen(11)
oplot, d0-50000., UF0_E2, color=oplc, line=2, thick=3


;oplot, d0-50000., UF0_E1, color=oplc, line=1, thick=1
;oplot, d0-50000., UF0_E3, color=oplc, line=1, thick=1

;from 57636 to 57682
d1=57636.+findgen(47)

xx=where(f24 LT 0.3)

;UF1_E2=interpol(uf2232[1:22],sd0[1:22],d1) 
;UF1_E1=interpol(uf1523[1:22],sd0[1:22],d1) 
;UF1_E3=interpol(uf325[1:22],sd0[1:22],d1) 

UF1_E2=interpol(uf2232[xx],sd0[xx],d1) 
UF1_E1=interpol(uf1523[xx],sd0[xx],d1) 
UF1_E3=interpol(uf325[xx],sd0[xx],d1) 


oplot,d1-50000., UF1_E2, color=oplc, line=2, thick=3
;oplot,d1-50000., UF1_E1, color=oplc, line=1, thick=1
;oplot,d1-50000., UF1_E1, color=oplc, line=1, thick=1


;from 57683 to 57753

UF2_E2=UFnew_E2[58:128]
UF2_E1=UFnew_E1[58:128]
UF2_E3=UFnew_E3[58:128]


d2=t0+58.+findgen(71)

oplot, d2-50000.,UF2_E2,color=oplc,line=2,thick=3
;oplot, d2-50000.,UF2_E1,color=oplc,line=1,thick=2
;oplot, d2-50000.,UF2_E3,color=oplc,line=1,thick=2


;the swift decay part

;E2
oplot,sdates-50000.,sflux2232,psym=8, color=oplc

Foft_add2_E2=1.2*UFnew_E2[n_elements(Fnew)-1L]*exp(-dd*edecay)
oplot,tl-50000.+dd-1L, Foft_add2_E2, color=oplc, line=2, thick=3

UF3_E2=Foft_add2_E2

;E1
;plotsym,3,/fill
;oplot,sdates-50000.,sflux1523,psym=8, color=oplc

Foft_add2_E1=1.2*UFnew_E1[n_elements(Fnew)-1L]*exp(-dd*edecay)
;oplot,tl-50000.+dd-1L, Foft_add2_E1, color=oplc, line=1, thick=1

UF3_E1=Foft_add2_E1


;E3
;plotsym,4,/fill
;oplot,sdates-50000.,sflux325,psym=8, color=oplc

Foft_add2_E3=1.2*UFnew_E3[n_elements(Fnew)-1L]*exp(-dd*edecay)
;oplot,tl-50000.+dd-1L, Foft_add2_E3, color=oplc, line=1, thick=1

UF3_E3=Foft_add2_E3



d3=tl+dd-1L

UFF_E2=[UF0_E2,UF1_E2,UF2_E2,UF3_E2]
UFF_E1=[UF0_E1,UF1_E1,UF2_E1,UF3_E1]
UFF_E3=[UF0_E3,UF1_E3,UF2_E3,UF3_E3]

datef=[d0,d1,d2,d3]

;CHANDRA data NOT BACKGROUND CORRECTED

;NH=13 abun wilm
CF24=4.98e-6
CUF2232=1.14e-5
CUF1523=1.84e-5
CUF325=1.15E-5

;NH=8 abun angr
CF24=4.98e-6
CUF2232=1.05e-5
CUF1523=1.62e-5
CUF325=1.11E-5

;NH9 abun ang back corrected
CF24=4.6e-6
CUF2232=0.97e-5
CUF1523=1.52e-5
CUF325=1.01E-5

oplot, [1.,1]*chand-50000., [1.,1]*CF24, psym=5
oplot, [1.,1]*chand-50000., [1.,1]*CUF2232, psym=1
oplot, [1.,1]*chand-50000., [1.,1]*CUF1523, psym=2
oplot, [1.,1]*chand-50000., [1.,1]*CUF325, psym=4


edec=0.3
xxx=dindgen(37)
oplot,xxx+7753.4,13.0e-2*exp(-xxx*edec)

;;;;;;
;print to file


IF p2file THEN BEGIN
IF ismdust THEN prfile='1630_allflux_ismdust.txt' ELSE $
   prfile='1630_allflux.txt'
   openw,1,prfile
   FOR i=0,N_ELEMENTS(datef)-1 DO BEGIN
      printf,1,strtrim(string(datef[i]),1)+' '+$
          strtrim(string(UFF_E1[i]),1)+' '+$
          strtrim(string(UFF_E2[i]),1)+' '+$
          strtrim(string(UFF_E3[i]),1)
   ENDFOR
close,1

ENDIF


END
