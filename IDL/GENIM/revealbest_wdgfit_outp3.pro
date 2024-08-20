pro revealbest_wdgfit_outp3, inpstr, dist, numim=imnum, ds9=ds9, plthist=plthist

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
  print, 'ds9 '+'/data3/efeoztaban/outputs3/'+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'.fits'
  ENDIF

  IF plthist THEN BEGIN
        fitsfile='/data3/efeoztaban/outputs3/'+sdist+'/'+sdist1+'.'+sdist2+'_'+sclouds+'.fits'
     restore,'../../IDL/GENIM/trmap.sav'            ;restore generated image radius and polar angles
restore,'polwedgc_18_50.0000_80.0000.sav' ;fix this
restore,'rebin_chandra.sav'

  noa=wedstrc1.noa
  delr=wedstrc1.delr
  minr=wedstrc1.rmin
  limsn=inpstr[0].snlim
  
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

  
     
