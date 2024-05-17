pro plotmaxi_triggerxf, drange, ps=ps, fname=namef, efold=folde, today=dtoday

IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='plotmaxi_triggerxf.eps'
IF NOT keyword_set(lowe) THEN lowe=0
IF NOT keyword_set(dtoday) Then dtoday=58398.5

if ps then begin
   set_plot, 'ps' 
   device,/color
;   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
   device, ysize = 12.
   ;device, xsize = 12.0
   !p.font=0
   device,/times
;   backc=0
   uc=0
endif else begin
   device,decomposed=0
   uc=255
endelse

readcol,'J1634-473_g_lc_1day_all.dat', mjdm, m220,e220, m24,e24, m410, e410, m1020, e1020

;sed_data=read_csv('glcbin24.0h_regbg_hv0.csv')
;mjdm=sed_data.field1
;m220=sed_data.field2
;e220=sed_data.field3;
;m24=sed_data.field4
;e24=sed_data.field5
;m410=sed_data.field6
;e410=sed_data.field7
;m1020=sed_data.field8
;e1020=sed_data.field9

xx=where((mjdm gt drange[0]) AND (mjdm lt drange[1]))

rate=m410[xx]
e_rate=e410[xx]

dnew=mjdm[xx]-mjdm[xx[0]]

hr=m410/m24
hrx=hr[xx]

;stop
yrx=[2e-11,3e-8]

derr=fltarr(n_elements(dnew))
xtit='Date (MJD-'+strtrim(string(mjdm[xx[0]]),1)+')'

;flux 2-10 4.98 unabs. 2.13 abs.   webpimms predict 1.6!!!
; nh correction, multiply webpimms by 2.13/1.6
;0.1 cts/s/cm-2 maxi then 4.98 unabs = 0.1*2.13/1.6 cts
;corr=4.98e-9*1.6/(0.213)


;corr=6.6e-9/0.14

;using maxi response
;absorbed maxi 4-10 = 0.16 ph/cm2/s = 5.1e-9 unabs 2-10
corr_sw=5.1e-9/0.16

;using prev maxi spectrum
;0.48 corres 11.37
corr_ma=11.37e-9/0.48

;hypothet 0.9, 0.035 = 1.58
corr_hy=1.58e-9/0.035

corr=corr_sw


plot, dnew, rate*corr, psym=3, xrange=[0.,max(dnew)+40.], yrange=yrx,$
 /xstyle,/ystyle,xtitle=xtit, ytitle='Unabsorbed Flux',$
           chars=1,/ylog

;ploterror, dnew, rate*corr, derr, e_rate*corr, xrange=[0.,max(dnew)+40.], $
 ;          yrange=yrx,/nohat,$
 ;          /xstyle,/ystyle,xtitle=xtit, ytitle='Calculated Flux',$
 ;          psym=5, chars=1,/ylog,err_col=255

oploterror, dnew, rate*corr, derr, e_rate*corr, $
            /nohat, err_col=uc, psym=5



;oplot,[!x.crange[0],!x.crange[1]],[0.25,0.25],col=0

hhh=findgen(max(dnew)*5)
l1fit=[0.3*corr/exp(41.5D*folde),folde]
oplot,hhh,l1fit[0]*exp(hhh*l1fit[1]),col=uc

;sorry for magic number do swift only

foldes=-0.2
l1fits=[5.33e-9/exp(47.0D*foldes),foldes]
;oplot,hhh,l1fits[0]*exp(hhh*l1fits[1]),col=255,line=2


;find where it hits target
tarr1=1.1e-10/0.7
tarr2=0.2*1.1e-10/0.7

oplot,[!x.crange[0],!x.crange[1]],[tarr1,tarr1],col=uc
oplot,[!x.crange[0],!x.crange[1]],[tarr2,tarr2],col=uc


;dtarget1=alog(tarr*1.4/l1fit[0])/(l1fit[1])
;dtarget2=alog(tarr*0.3/l1fit[0])/(l1fit[1])
;trigval1=l1fit[0]*exp(l1fit[1]*(dtarget1-15.))
;trigval2=l1fit[0]*exp(l1fit[1]*(dtarget2-15.))
;print,dtarget1,dtarget2
;print,trigval1,trigval2
;oplot,[!x.crange[0],!x.crange[1]],trigval1*[1.,1.]*corr,col=0,line=2
;oplot,[!x.crange[0],!x.crange[1]],trigval2*[1.,1.]*corr,col=0,line=2
;print,-1./l1fit[1]


oplot,58416-[mjdm[xx[0]],mjdm[xx[0]]],10^(!y.crange),col=uc
print,58416-[mjdm[xx[0]],mjdm[xx[0]]],10^(!y.crange)

;arrow, dtoday-mjdm[xx[0]], 0.002, dtoday-mjdm[xx[0]], 0.001, col=0,/data

;dd=findgen(20)
;oplot,54.+dd,0.1*exp(-dd/4.),col=0
;print,0.2*exp(-dd/4.)

boxc,58416-mjdm[xx[0]], 10^(!y.crange[0]),!x.crange[1],10^(!y.crange[1]),100
xyouts, 0.9, 0.2,'No Chandra Visibility',color=0,orientation=90.,$
         size=1.5,/normal
xyouts, 0.3, 0.25,'Chandra Target',color=uc,$
         size=2.5,/normal

;swift

plotsym, 0, /fill

swift210=[[5.10,0.13],[3.50,0.08],[3.88,0.10]]*1D-9
dates=[58397.6,58399.5,58401.4]-mjdm[xx[0]]
oploterror,dates,swift210[0,*],swift210[1,*], psym=8, col=uc,/nohat
;oplot,[58397.6,58397.6]-mjdm[xx[0]],[5.33e-9,5.33e-9],psym=8, color=0
;oplot,[58399.5,58399.5]-mjdm[xx[0]],[3.64e-9,3.64e-9],psym=8, color=0

;oplot,[58397.6,58397.6]-mjdm[xx[0]],[5.1e-9,5.1e-9],psym=8, color=0
;oplot,[58399.5,58399.5]-mjdm[xx[0]],[3.64e-9,3.64e-9],psym=8, color=0





;postscript later

;1.47 e-9 = 0.14 cts/s

IF ps THEN BEGIN
   device,/close
   set_plot,'ps'
ENDIF

; NOTE TO SELF for next proposal use Tomsick, the exponential time
; scale decay is around 3.5 - 4 days. Need a larger Maxi/swift trigger
;                             time. swift flux should have been higher
;                             either for the worst case scenario

END
