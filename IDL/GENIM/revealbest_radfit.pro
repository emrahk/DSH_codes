pro revealbest_radfit, inpstr, dist, useind, numim=imnum, $
                       ds9=ds9, plthist=plthist, dirbase=basedir, erange=rangee

;This program finds the minimum chi2 case image for the given
;distance.  If imnum is given it can find imnum images with the lowest
;chi2. If ds9 is set it plots the best file using ds9
;
;INPUTS
;
; inpstr: input strcture with tchi values
; dist: distance to be used
;
;OPTIONAL INPUTS
;
; numim: If set, find imnum images with minimum chi2
; ds9: If set, spawn the original image with ds9
; dirbase: If set use the given directory for generated imaged
; USES
;
; output of wrappers
;
; USED BY
;
; NONE
;
; COMMENTS
;
;Created by EK, June 2024
; Add plotting the distribution and the fit later
; adding basedir
; now uses rebinned chandra images
;

  IF NOT keyword_set(imnum) THEN imnum=1
  IF NOT keyword_set(ds9) THEN ds9=0
  IF NOT keyword_set(plthist) THEN plthist=0
  IF NOT keyword_set(basedir) THEN basedir='/data3/efeoztaban/E2_simulations_corrected/'
  IF NOT keyword_set(rangee) THEN rangee=2
  
;rename input structure to keep original

  usestr=inpstr

  yy=where(usestr.dist eq dist)

  ;Find the minimum

  rchi=usestr[yy].rchi

  discard=where(rchi LE 0.2, ndis)

  IF ndis NE 0 THEN rchi[discard]=10000 ;just set an arbitrary large number

  minrchi = where(rchi eq min(rchi),nmin)
  sclouds=''
  sdist1=strtrim(string(floor(dist)),1)
  ssp=strsplit(string(dist),'.',/extract)
  sdist2=strmid(ssp[1],0,2)
  sdist=sdist1+'_'+sdist2
  
  IF nmin GT 1 THEN BEGIN
     print, 'There are '+string(nmin)+'minima'
     FOR i=0, nmin-1 DO BEGIN
        sclouds=''
        FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[minrchi[i],j]),1)
        PRINT, i, sclouds
        PRINT, i, rchi[minrchi[i]],usestr[yy].norm[minrchi[i]],  usestr[yy].back[minrchi[i]]
        rchi[minrchi[i]]=10000
     ENDFOR
  ENDIF ELSE BEGIN
      sclouds=''
      FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[minrchi,j]),1)
      PRINT, sclouds
      PRINT, rchi[minrchi],usestr[yy].norm[minrchi],  usestr[yy].back[minrchi]
      rchi[minrchi]=10000
   ENDELSE

  IF ds9 THEN BEGIN
     ;spawn,'ds9 '+'home/efeoztaban/ahmet_code/outputs3/'+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'.fits'  
  print, 'ds9 '+basedir+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'E2.fits'
  ENDIF

  IF plthist THEN BEGIN
     rangerad=[30.,300.]        ;to be fixed later
     mrad=15
     noa=22
     fitsfile=basedir+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'E2.fits'
     restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles
;restore,'../../CHANDRA_POLAR/IDL_dev/prof_rgbc67mrad15_deflare_REG.sav' ;restore                          Chandra distribution, this is for 15'' radial bins

;     restore,'../../CHANDRA_POLAR/IDL_dev/prof_rgbc67mrad15_deflare_REG_c7inring_c6simexp.sav'
;     nprof=NPROF_IM2C67REGB
;     genimraddist,fitsfile,numan,raddist,radm=mrad,maprt=trmap
     restore,'rebin_chandra.sav'
     restore,'radprofc_29_15.sav'
     case rangee of
   1: BEGIN
      cradstr=radstrc0
      useind=useind0
   END
   2: BEGIN
      cradstr=radstrc1
      useind=useind1
   END
   3: BEGIN
      cradstr=radstrc2
      useind=useind2
   END
   4: BEGIN
      cradstr=radstrc_t
      useind=useind1
   END
ENDCASE
     radial_create_genim,  fitsfile, useind, trmap, noa, mrad, gradstr, $
                  silent=silent, newdust=newdust 
     getchi2_rad_fitsingle, cradstr, gradstr, res, totchi2, /plt, radrange=rangerad
  ENDIF
  
     
  IF imnum GT 1 THEN BEGIN

     FOR k=1, imnum DO BEGIN
        
;        minrchi = where(tchi eq min(tchi),nmin)
  
        IF nmin GT 1 THEN BEGIN
           print, 'There are '+string(nmin)+'minima in minima '+string(k)
           FOR i=0, nmin-1 DO BEGIN
              sclouds=''
              FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[minrchi[i],j]),1)
              PRINT, k, sclouds
              rchi[minrchi[i]]=10000 ;NOT SURE THIS IS CORRECT
           ENDFOR
        ENDIF ELSE BEGIN
           sclouds=''
           FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[minrchi,j]),1)
           PRINT, k, sclouds
           tchi[minrchi]=10000
        ENDELSE
     ENDFOR
  ENDIF
  
END

  
     
