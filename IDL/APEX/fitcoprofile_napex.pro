pro fitcoprofile_napex, spe, vel, outpar, $
                  ps=ps, fname=namef, rbnpar=parrbn

;This program fits and plots CO J=1-0 map with multiple gausses saves
;important results like integrated velocities and near and far distances
;
; INPUTS
;
; spe: input spectra
; vel: velocities
;
; OUTPUTS
;
; outpar: structure that holds information on gauss profiles,
;integrated profiles, and near and far distances
;
; OPTIONAL INPUTS
;
; ps: IF set postscript plot
; fname: base name for postscript plots
; rbnpar: rebin parameter, default=1
;
; USES
;
; IDL FITS routines
; mpcurvefit
; gaussfits
; 
; USED BY
;
; None
;
; Logs
;
; Created by EK Jan 2023
;

IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='CO_ngaussfits.eps'
;IF NOT keyword_set(parrbn) THEN parrbn=1.


;Read parameters from the FITS file


IF ps THEN BEGIN
   set_plot, 'ps'
   device,/color
   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
   device, ysize = 16.
   device, xsize = 25.0
   !p.font=0
   device,/times
   pcol=0
ENDIF ELSE BEGIN
   device,decomposed=0
   loadct,0
   window, 2, retain=2, xsize=600, ysize=400
   pcol=255
ENDELSE


cs=1.5
nvel=n_elements(v)

IF keyword_set(parrbn) THEN BEGIN
   velr=rebin(vel,nvel/parrbn)
   sper=rebin(spe,nvel/parrbn);/1000. 
ENDIF ELSE BEGIN
   velr=vel
   sper=spe;/1000.
ENDELSE


IF NOT ps THEN plot,velr,sper,xr=[-150,0],psym=10, yr=[-0.2,max(sper)*1.2],$
     xtitle='v!Dlsr!N (km s!E-1!N)', ytitle='T!Dmb!N',charsize=cs,/ystyle,$
     color=pcol,/xstyle


;Make negative temperatures 0

tofit=sper
xx=where(tofit LT 0.)
tofit[xx]=0.

;create model

;the program I use take FWHM as inputs, but the plotting uses sigma

 ; region 1

a15 = [0.7,-100.,1.5]
a14 = [1.,-105.,1.2]
a13 = [.6,-109.5,.8]
a12 = [0.2,-115.,1.]
a11 = [0.4,-117.,0.9]


 ; region 2 (main region)

a21 = [3.2,-80.,3.6]
a22 = [0.9,-73.,1.5]
a23 = [.8,-68.,2.2]
a24 = [.3,-61.5,1.2]
a25 = [.5,-57,1.4]
;a26 = [.3,-65,.7]

                                ; region 3

a31 = [.5,-47.8,1.]
a32 = [.5,-42.5,1.]
a33 = [1.2,-39.,1.5]
a34 = [0.5,-34.,1.1]

;region 4

a41 = [1.5,-20.1,1.05]
   
a = [a11,a12,a13,a14,a15,a21,a22,a23,a24,a25,a31,a32,a33,a34,a41]
afit=a

ngauss=15

siginds=indgen(ngauss)*3+2          ;gaussian uses sigma, not width
afit[siginds]=afit[siginds];*2.355

;a=[a11,a12,a13, a21,a22,a23,a24]


IF NOT ps THEN BEGIN
   datai=dblarr(ngauss+1,n_elements(velr))

   FOR i=0,ngauss-1 DO BEGIN
      datai[i,*] = gaussian(velr,a[i*3:i*3+2])
      datai[ngauss,*]=datai[ngauss,*]+datai[i,*]
      oplot,velr,datai[i,*],line=2
   ENDFOR
   oplot, velr, datai[ngauss,*],line=1
ENDIF


    ; specify 4 regions
nregions = 4
wregions4=where((velr GE -23.) AND (velr LE -17.))
wregions3=where((velr GE -57.) AND (velr LT -30.))
wregions2=where((velr GE -95.) AND (velr LT -57.))
wregions1=where((velr GE -120.) AND (velr LT -95.))

regions=[[min(wregions1),max(wregions1)],[min(wregions2),max(wregions2)],$
            [min(wregions3),max(wregions3)],[min(wregions4),max(wregions4)]]

;    regions = [[-125,-95],[-95,-50],[-50,-25],[-25,-10]]
;inits = [[a11],[a12],[a13],[a21],[a22],[a23],[a24],[a31],[a32],[a33],[a41]]

inits = [[afit[0:2]],[afit[3:5]],[afit[6:8]],[afit[9:11]],[afit[12:14]],$
         [afit[15:17]],[afit[18:20]],[afit[21:23]],[afit[24:26]],$
         [afit[27:29]],[afit[30:32]],[afit[33:35]],[afit[36:38]],$
         [afit[39:41]],[afit[42:44]]];,[afit[45:47]]]

max_iters = 800
    
p = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0,0]}, ngauss*3) 
                       ; 42 = 14 gauss * 3 parameter per guass

;limit some unphysical parameters
;    p[*].value = afit
    ;p[2].limited=[0,1]
    ;p[2].limits=[0.,4.]
    ;p[22].limited=[1,1]
    ;p[22].limits=[-66.,-67.]
 ;   p[23].limited=[0,1]
 ;   p[23].limits=[0.,1.]
   ; p[26].limited=[0,1]
   ; p[26].limits=[0.,1.]
   ; p[29].limited=[0,1]
   ; p[29].limits=[0.,1.]
   ; p[32].limited=[0,1]
   ; p[32].limits=[0.,1.]
    
    ; hold the first gaussians height fixed
  ;  p[0].fixed = 1

                                ; find all the fits at once
 
   yfit = gauss_fits(velr,tofit,nregions,regions,inits,ngauss,max_iters,coefficients,errors,quiet=1);,parinfo=p,quiet=1)

;    print,coefficients
;    print,errors
    ; unwrap the results and plot them


plot,velr,sper,xr=[-130,-10],psym=10, yr=[-0.2,max(sper)*1.2],$
     xtitle='v!Dlsr!N (km s!E-1!N)', ytitle='T!Dmb!N',charsize=cs,/ystyle,$
     color=pcol,/xstyle

;prepare the output file
;cname: cloud name
;gpar: gauss fit parameters
;gparerr: gauss fit errors
;gint: integrated profile and its error
;vlsr: to be able to plot from the output
;l and b galactic l and b values

l=336.911
b=0.250231

outpar=create_struct('cname',strarr(ngauss),'gpar',dblarr(3,ngauss),$
                     'gparerr',dblarr(3,ngauss),'gint',dblarr(2,ngauss),$
                      'Tmb',spe,'vlsr',vel,'l',l,'b',b,$
                     'neardist',dblarr(2, ngauss),'fardist',dblarr(2,ngauss))


;plot and populate outpar
    
an=coefficients ; fit results
siginds=indgen(15)*3+2 ;gaussian uses sigma, not width
an[siginds]=an[siginds]/2.355 ;convert to sigma
errors[siginds]=errors[siginds]/2.355
dataf=dblarr(ngauss+1,n_elements(velr))

;for far and near distances
lu=(360.-l)*!PI/180.  ; in radians
Ro=8.5D
Vo=220D
tp=Ro*cos(lu)
Vc=Vo
;Vr=Ro*sin(lu) * ((Vc/R) - (Vo/Ro))
;(Vr/(Ro*sin(lu))) + (Vo/Ro) = Vc/R
;R=Vc/((Vr/(Ro*sin(lu))) + (Vo/Ro))
;dR=sqrt(R^2.-(Ro*sin(lu))^2.)


FOR i=0,ngauss-1 DO BEGIN
    dataf[i,*] = gaussian(velr,an[i*3:i*3+2])
    dataf[ngauss,*]=dataf[ngauss,*]+dataf[i,*]
    oplot,velr,dataf[i,*],line=2
    txtp='MC'+strtrim(string(floor(an[i*3+1]+0.5)),1)
    xyouts,an[i*3+1]-3,an[i*3]+0.2,txtp,charsize=0.9
    outpar.cname[i]=txtp
    outpar.gpar[*,i]=an[i*3:i*3+2]
    outpar.gparerr[*,i]=errors[i*3:i*3+2]
    outpar.gint[0,i]=an[i*3]*sqrt(!PI)*sqrt(2)*an[i*3+2]
    errf=((errors[i*3]/an[i*3])+(errors[i*3+2]/an[i*3+2]))/sqrt(2.)
    outpar.gint[1,i]=outpar.gint[0,i]*errf
    R=Vc/((abs(an[i*3+1]))/(Ro*sin(lu)) + (Vo/Ro))
    dR=sqrt(R^2.-(Ro*sin(lu))^2.)
    outpar.neardist[0,i]=tp-dR
    outpar.fardist[0,i]=tp+dR
ENDFOR
oplot, velr, dataf[ngauss,*]


IF ps THEN BEGIN
   device,/close
   set_plot,'x'
ENDIF



END
