pro rebin_chandra, enind, outim, outerr, ps=ps, fname=namef, $
  explim=limexp, siglim=limsig, remoutlier=remoutlier, backcor=backcor, $
  silent=silent, outcts=ctsout, maxthresh=threshmax, induse=useind

;this program rebins the chandra image to match with the APEX and
;generated images

;INPUTS
;
; enind: index representing energy range
;
;OUTPUTS
;
;outim: rebinned image
;
;OPTIONAL INPUTS
;
; ps: if set generate a postscript image
; fname: if set use given filename
; explim: exposure map limit between 0 and 1.
; siglim: point source significance limit
; remoutlier: if set remove outlier bright pixels
; backcor: If set apply a background correction from the radial
;profiles
; silent: If set do not print warnings and information
; maxthresh: threshold for removing outlier
;
; USES
;
; -
;
;USED BY
;
; All fitting programs use output of rebin_chandra
;
;LOGS
;
;Created by Emrah Kalemci, Apr 2024
;
;Adding background correction and silent keyword
;
;en3 needs remoutlier, and not clearing central point source
;we should use sum, not average. We should also output count based
;image (to calculate errors later)
;
; output cnts to calculate errors
;
; an error in indexing fixed
;
; September 2024: error calculation is erronous!! because I am finding the error; after subtracting background, correcting. This does not affect polar and wedge; fitting as they recalculate errors, but they need to be fixed as well.
  
  
  strix=strtrim(string(enind+1),1)
  IF NOT keyword_set(ps) THEN ps=0
  IF NOT keyword_set(namef) THEN namef='rebinned_en'+strix+'.eps'
  IF NOT keyword_set(limexp) THEN limexp=0.5
  IF NOT keyword_set(limsig) THEN limsig=10.
  IF NOT keyword_set(remoutlier) THEN remoutlier=0
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(backcor) THEN backcor=0

  
loadct,5
IF ps THEN begin
   set_plot,'ps'
   device,/color
   device,/encapsulated
   device,filename=namef
   device,ysize=10
   device,xsize=15
   !p.font=0
   device,/times
ENDIF else device,decomposed=0

;READ image

;load Chandra images
  
 fluximc6='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c6/band'+strix+'_flux.img'
 fluximc7='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c7/band'+strix+'_flux.img'

;load exposure maps to determine unwanted regions

 fexpm6='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c6/band'+strix+'_thresh.expmap'
 fexpm7='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c7/band'+strix+'_thresh.expmap'

;load thresh images to calculate errors

 fcc6='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c6/band'+strix+'_thresh.img'
 fcc7='~/CHANDRA/4U1630_expoc/fluxrgb_eq5_deflare_c7/band'+strix+'_thresh.img'

 
; load example APEX image

 genim='../../IDL/new_image_3D.fits' ;MAGIC, fix later

 ;useful variables
 cpix=0.492                      ;arcsec
 apix=13.635
 c7_source_pos=[576.17747, 867.84582] ;Chandra
 c6_source_pos=[515.177,-173.1543] 
 genim_pos=[24.878014, 26.938874] ;APEX


;background parameters
;magic numbers from radial profile fits
; backc7=[[1.34421e-09,1.63009e-10],[1.46026e-09,1.81123e-10],[1.39829e-09,1.74786e-10]]
; backc6=[[8.04757e-10,1.46928e-10],[8.88917e-10,1.62293e-10],[1.01533e-09,1.58567e-10]]
backc7=[[1.1994871e-09,2.0880390e-10],[1.2262101e-09,2.3598423e-10],[1.3671821e-09,2.4168595e-10]]*(cpix^2)*27.*27.
backc6=[[1.0735030e-09,2.4004254e-10],[1.1047544e-09,2.6039310e-10],[1.1217958e-09,2.4479591e-10]]*(cpix^2)*27.*27.

 
;generated image parameters
gim=readfits(genim, hdg, NaNvalue=0)
xgmax=sxpar(hdg,'NAXIS1')
ygmax=sxpar(hdg,'NAXIS2')

;create output image and error
outim=dblarr(xgmax,ygmax)
outerr=dblarr(xgmax,ygmax)
ctsout=fltarr(xgmax,ygmax)

cim7=readfits(fluximc7, hd7, NanValue=0)
xmax7=sxpar(hd7,'NAXIS1')
ymax7=sxpar(hd7,'NAXIS2')

expm7=readfits(fexpm7, ehd7, NanValue=0)
;resclae expm
expm7=expm7/max(expm7)

cc7=readfits(fcc7, chd7, NanValue=0)

cim6=readfits(fluximc6, hd6, NanValue=0)
xmax6=sxpar(hd6,'NAXIS1')
ymax6=sxpar(hd6,'NAXIS2')

expm6=readfits(fexpm6, ehd6, NanValue=0)
expm6=expm6/max(expm6)

cc6=readfits(fcc6, chd6, NanValue=0)

;ltv1=sxpar(hd,'LTV1') ;not sure these are useful
;ltv2=sxpar(hd,'LTV2') ;not sure these are useful

;record ignored pixels
igpix1=0L        ;pixels to be ignored because they are outside the Chandra FOV

igpix2=0L        ;pixels to be ignored because of low exposure

zctpix=0L        ;pixels still having zero counts after rebinning

vp7=0L                          ; valid pixel
vp6=0L
useind=0L

;eliminate point sources

;read full_broad_outfile_2.fits
sfile='../CHANDRA_RADIAL/full_broad_outfile_2.fits'
sig=loadcol(sfile,'SRC_SIGNIFICANCE',ext=1)
xp=loadcol(sfile,'X',ext=1)
yp=loadcol(sfile,'Y',ext=1)

;make a cut on source significance
xx=where(sig gt limsig)

;convert physical X, Y to image X,Y source centers
;remove associated apex pixel flux and errors at 9x9 chandra pixel

FOR i=0, n_elements(xx)-1 DO BEGIN
   IF NOT silent THEN print,xx[i], xp[xx[i]], yp[xx[i]]
       ;c6 physical to image
   c6x=floor(xp[xx[i]]-4075.+518.+0.5)
   c6y=floor(yp[xx[i]]-4697.+438.+0.5)
        ;c7 physical to image
   c7x=floor(xp[xx[i]]-4072.+576.+0.5)
   c7y=floor(yp[xx[i]]-4086.+867.+0.5)

   IF ((c6x LT xmax6-5) AND (c6y LT ymax6-5) AND (c6x GT 5) AND (c6y GT 5)) THEN BEGIN
      IF NOT silent THEN print,'source '+string(xx[i])+' at chip 6'
      cim6[c6x-4:c6x+4,c6y-4:c6y+4]=0
   ENDIF

   IF ((c7x LT xmax7-5) AND (c7y LT ymax7-5) AND (c7x GT 5) AND (c7y GT 5)) THEN BEGIN
      IF NOT silent THEN print,'source '+string(xx[i])+' at chip 7'
      cim7[c7x-8:c7x+8,c7y-8:c7y+8]=0
   ENDIF
ENDFOR

; start with c7, includes source, easier

FOR i=0, xgmax-1 DO BEGIN
   FOR j=0, ygmax-1 DO BEGIN
      iv=i+j*xgmax
    ;calculate chip boundaries - this is
    ;the 0,0 point, left bottom corner;
      
      cxs=floor(0.5+c7_source_pos[0]+((i+0.5)-genim_pos[0])*(apix/cpix))
      cys=floor(0.5+c7_source_pos[1]+((j+0.5)-genim_pos[1])*(apix/cpix))
      IF ((cxs LT 0) OR (cys LT 0) OR (cxs GE xmax7-27) OR (cys GE ymax7-27)) THEN BEGIN
         igpix1=[igpix1,iv]
         IF NOT silent THEN print, i, j, cxs, cys, ' ignored pixel'
      ENDIF ELSE BEGIN
         vp7=[vp7,iv] ;valid within boundary
         chexpm=avg(expm7[cxs:cxs+27,cys:cys+27])
         IF chexpm LT limexp THEN BEGIN
            IF NOT silent THEN print, i, j, ' less than limit exposure'
            igpix2=[igpix2,iv]
         ENDIF ELSE BEGIN
            outim[i,j]=total(cim7[cxs:cxs+27,cys:cys+27]) ;to be corrected

            IF backcor THEN BEGIN
               soutimij=outim[i,j] ;save the originial value
               outim[i,j]=outim[i,j]-backc7[0,enind]
            ENDIF
            
            tcts=total(cc7[cxs:cxs+27,cys:cys+27])
            useind=[useind,iv]
            IF NOT silent THEN print, i, j, cxs, cxs+27, cys, cys+27
            IF tcts EQ 0 THEN BEGIN
               IF NOT silent THEN print, i, j, ' 0 counts in bin?'
               zctpix=[zctpix,iv]
            ENDIF ELSE BEGIN
               errat=sqrt(tcts)/tcts
               outerr[i,j]=soutimij*errat
               ctsout[i,j]=tcts
            ENDELSE
         ENDELSE
      ENDELSE
   ENDFOR
ENDFOR

vp7=vp7[1:n_elements(vp7)-1]
igpix1=igpix1[1:n_elements(igpix1)-1]
igpix2=igpix2[1:n_elements(igpix2)-1]
zctpix=zctpix[1:n_elements(zctpix)-1]
useind=useind[1:n_elements(useind)-1]

;stop
print, 'c7 ',n_elements(vp7)

FOR i=0, xgmax-1 DO BEGIN
   FOR j=0, ygmax-1 DO BEGIN
    ;calculate chip boundaries - this is
    ;the 0,0 point, left bottom corner;
      igv=i+j*xgmax
      cxs=floor(0.5+c6_source_pos[0]+((i+0.5)-genim_pos[0])*(apix/cpix))
      cys=floor(0.5+c6_source_pos[1]+((j+0.5)-genim_pos[1])*(apix/cpix))
      IF ((cxs LT 0) OR (cys LT 0) OR (cxs GE xmax6-27) OR (cys GE ymax6-27)) THEN BEGIN
         cpr=where(igpix1 eq igv, ncpr)
         ival=where(vp7 eq igv, nvp)
         IF (ncpr+nvp) eq 0 THEN igpix1=[igpix1,igv]
         IF NOT silent THEN print, i, j, cxs, cys, ' ignored pixel'
      ENDIF ELSE BEGIN
         vp6=[vp6,igv]
         cpr=where(igpix1 eq igv, ncpr)
         IF ncpr eq 1 THEN igpix1[cpr]=-1
         chexpm=avg(expm6[cxs:cxs+27,cys:cys+27])
         IF chexpm LT limexp THEN BEGIN
            IF NOT silent THEN print, i, j, ' less than limit exposure'
            cpr=where(igpix2 eq igv, ncpr) 
         IF ncpr eq 0 THEN igpix2=[igpix2,igv]
      ENDIF ELSE BEGIN
         outim[i,j]=total(cim6[cxs:cxs+27,cys:cys+27]) ;to be corrected

         IF backcor THEN BEGIN
            soutimij=outim[i,j]
            outim[i,j]=outim[i,j]-backc6[0,enind]
         ENDIF
            
         tcts=total(cc6[cxs:cxs+27,cys:cys+27])
         chui=where(useind eq igv, nui)
         IF nui EQ 0 THEN useind=[useind,igv]
            IF tcts LE 0 THEN BEGIN
               IF NOT silent THEN print, i, j, ' 0 counts in bin?'
               cpr=where(zctpix eq igv, ncpr) 
         IF ncpr eq 0 THEN zctpix=[zctpix,igv]
            ENDIF ELSE BEGIN
               errat=sqrt(tcts)/tcts
               outerr[i,j]=soutimij*errat
               ctsout[i,j]=tcts
            ENDELSE
         ENDELSE
   ENDELSE
   ENDFOR
ENDFOR

vp6=vp6[1:n_elements(vp6)-1]

nz=where(igpix1 GE 0)
igpix1=igpix1[nz]

print, 'c6 ',n_elements(vp6)

;IF useavg THEN imgscl=bytscl(combimg,min=0, max=sclmax) ELSE imgscl=bytscl(combimg)

;imgscl=bytscl(outim)
;imgsclrbn=rebin(imgscl, xgmax*10, ygmax*10) ; BE CAREFUL, THIS PROVIDES SMOOTHING

;tv,imgsclrbn

IF remoutlier THEN BEGIN
   IF NOT keyword_set(threshmax) THEN threshmax=0.95*max(outim)
   ol=where(outim GT threshmax, nol) ;magic numbersqw6780-='/
   IF nol GT 0. THEN outim[ol]=0.
                                ;add to not used in fitting
ENDIF


IF backcor THEN imrange=[0,max(outim,/nan)] ELSE imrange=[min(outim,/nan),max(outim,/nan)]
plotimage, outim,imgxrange=[248.64055,248.3720],$
           imgyrange=[-47.49124,-47.2942946],range=imrange ;,noerase$
;           background=backc,axiscolor=axc

END

