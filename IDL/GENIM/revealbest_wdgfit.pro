pro revealbest_wdgfit, inpstr, dist, numim=imnum, ds9=ds9, plthist=plthist, dirbase=basedir

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
; dirbase: If set use the given directory
;
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
;Created by EK, July 2024
; Add plotting the distribution and the fit later
;

  IF NOT keyword_set(imnum) THEN imnum=1
  IF NOT keyword_set(ds9) THEN ds9=0
  IF NOT keyword_set(plthist) THEN plthist=0
  IF NOT keyword_set(basedir) THEN basedir='/data3/efeoztaban/E2_simulations/corrected/'
;rename input structure to keep original

  usestr=inpstr

  yy=where(usestr.dist eq dist)

  ;Find the minimum

  tchi=usestr[yy].tchi

  discard=where(tchi LE 2., ndis)

  IF ndis NE 0 THEN tchi[discard]=10000 ;just set an arbitrary large number

  mintchi = where(tchi eq min(tchi),nmin)
  sclouds=''
  sdist1=strtrim(string(floor(dist)),1)
  ssp=strsplit(string(dist),'.',/extract)
  sdist2=strmid(ssp[1],0,2)
  sdist=sdist1+'_'+sdist2
  
  IF nmin GT 1 THEN BEGIN
     print, 'There are '+string(nmin)+'minima'
     FOR i=0, nmin-1 DO BEGIN
        sclouds=''
        FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[mintchi[i],j]),1)
        PRINT, sclouds
        tchi[mintchi[i]]=10000
     ENDFOR
  ENDIF ELSE BEGIN
      sclouds=''
      FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[mintchi,j]),1)
      PRINT, sclouds
      tchi[mintchi]=10000
   ENDELSE

  IF ds9 THEN BEGIN
     ;spawn,'ds9 '+'home/efeoztaban/ahmet_code/outputs3/'+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'.fits'  
  print, 'ds9 '+basedir+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'E2.fits'
  ENDIF

  IF plthist THEN BEGIN
        fitsfile=basedir+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'E2.fits'
        restore,'trmap.sav'    ;restore generated image radius and polar angles

        

restore,'rebin_chandra.sav'

  noa=inpstr[0].noa[0]
  delr=inpstr[0].delr
  minr=inpstr[0].radlim
  limsn=inpstr[0].snlim

  snoa=strtrim(string(noa),1)
  sdelr=strsplit(strtrim(string(delr),1),'.',/extract)
  srlim=strsplit(strtrim(string(minr),1),'.',/extract)
  consav='polwedgc_'+snoa+'_'+sdelr[0]+'_'+srlim[0]+'.sav'  
  ;restore,'polwedgc_18_50.0000_80.0000.sav' ;fix this
  restore,consav
  
  wedge_create_genim,fitsfile,useind1,trmap, noa, delr, gwedstr,$
                      rmin=minr, /silent
   getchi2_wdg_fitsingle, wedstrc1, gwedstr, res, totchi2, $
                          /plt, snlim=limsn

  ENDIF
  
     
  IF imnum GT 1 THEN BEGIN

     FOR k=1, imnum DO BEGIN
        
        mintchi = where(tchi eq min(tchi),nmin)
  
        IF nmin GT 1 THEN BEGIN
           print, 'There are '+string(nmin)+'minima in minima '+string(k)
           FOR i=0, nmin-1 DO BEGIN
              sclouds=''
              FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[mintchi[i],j]),1)
              PRINT, k, sclouds
              tchi[mintchi[i]]=10000
           ENDFOR
        ENDIF ELSE BEGIN
           sclouds=''
           FOR j=0, 14 do sclouds=sclouds+strtrim(string(usestr[yy].clouds[mintchi,j]),1)
           PRINT, k, sclouds
           tchi[mintchi]=10000
        ENDELSE
     ENDFOR
  ENDIF
  
END

  
     
