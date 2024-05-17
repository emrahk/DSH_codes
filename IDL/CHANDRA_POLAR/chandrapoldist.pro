pro chandrapoldist, infile, noa, poldistc, radlim=limrad, expof=fexpo, corb=corb, backpos=posback, backr=rback, brate=rateb, expthresh=threshexp
  
;This program reads a FITS header and images, and find the brightness
;in the given pie area by number of polar angles and radius limits. It
;plots the distribution and saves data to a structure
;
;
; INPUTS
;
; infile: FITS file with the apex images
; noa: number of polar angles for pies
;
; OPTIONAL INPUTS
;
; radlim: If set use the given radii for the annulus, default
;[100,200] asec
; expof: If set use the given exposure map file and apply a correction
; expthresh: If set use the given threshold for exposure map correction
; 
; corb: IF set do background correction  
; backpos : center position to obtain background/arcsec^2, in physical units!
; rpos: side of square region (to simplify calculations)
; brate: if given use this background counts per asec2
;
; OUTPUTS
;
; poldistc: structure that carries information about the pie and the brightness
;
; USES
;
; idlastro library
; mappolcoord
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Jan 2023
;
; 7 Feb 2023 Fixed surface brightness definition and added error
;
; added exposure map corrections, 3 March 2023
; added background calculation
; eliminating point source is not urgent, TBD
;
  
   IF NOT keyword_set(limrad) THEN limrad=[100., 200.]
   IF NOT keyword_set(posback) THEN posback=[930,1285]
   IF NOT keyword_set(rback) THEN rback=80.
   ; alternative backg: posback=[608,1802], rback=65
   IF NOT keyword_set(threshexp) THEN threshexp=0.02
   IF NOT keyword_set(corb) THEN corb=0
 
;Read the fits file

im=readfits(infile, hdr)


;exposure map correction, probably not necessary for polar dist

imgarr=intarr(2)
imgarr[0]=sxpar(hdr, 'NAXIS1')
imgarr[1]=sxpar(hdr, 'NAXIS2')

;match exposure map pixel scales
expocor=fltarr(imgarr)

IF keyword_set(fexpo) THEN BEGIN
   expoim=readfits(fexpo)
   expocor=expoim/max(expoim)
   for i=0L,(imgarr[0]/4)-1L do for j=0L,(imgarr[1]/4)-1L do expocor_ext[4*i:(4*i+3),4*j:(4*j+3)]=expocor[i,j]
   nzi=where((im NE 0) AND (expocor GT threshexp))
ENDIF ELSE BEGIN
   expocor[*,*]=1.
   nzi=where(im NE 0)
ENDELSE

;map the pixel coordinates to polar coordinates for the given central
;pos



pos=[248.5067, -47.393]
mappolcoordc, hdr, nzi, pos, maprc, mapthc ; this takes long, better to run it once and save the resulting values?

;stop
;create output structure


poldistc=create_struct('infile',infile, 'noa',noa, 'radlim', limrad, $
                      'mapr', maprc, 'mapth', mapthc, 'areas',fltarr(noa),$
                      'sbr',fltarr(noa),'sbre',fltarr(noa),'nzi',nzi, 'normb',0. )

;;pixel size
pix = 0.492D
;;pixel area
;pixar=pixsz^2.

wedge_area=!PI*(limrad[1]^2.-limrad[0]^2.)/float(noa)

poldistc.areas=replicate(wedge_area,noa)    ;exposure correction not implemented in area calculation, not necessary for areas<250''
FOR i=0, noa-1 DO BEGIN
   anglr=360./noa
   angles=[i*anglr,(i+1)*anglr]
   xx=where((maprc GE limrad[0]) AND (maprc LT limrad[1]) AND $
            (mapthc GE angles[0]) AND (mapthc LT angles[1]))
;   poldistc.areas[i]=(n_elements(xx)*pixar)
   poldistc.sbr[i]=total(im[nzi[xx]])/poldistc.areas[i] ;
   ;error through poisson statistics
   errf=sqrt(n_elements(xx))/n_elements(xx)
      poldistc.sbre[i]=poldistc.sbr[i]*errf
ENDFOR

IF corb THEN BEGIN
   
   ;check if the background region is within bounds
   IF ((posback[0]-rback) LT 0) THEN BEGIN
      print, 'background region x lower limit is out of bounds'
      x0back=0
   ENDIF ELSE x0back=posback[0]-rback

   IF ((posback[0]+rback) GE imgarr[0]) THEN BEGIN
      print, 'background region x upper limit is out of bounds'
      x1back=imgarr[0]-1
   ENDIF ELSE x1back=posback[0]+rback

      IF ((posback[1]-rback) LT 0) THEN BEGIN
      print, 'background region y lower limit is out of bounds'
      y0back=0
   ENDIF ELSE y0back=posback[1]-rback

   IF ((posback[1]+rback) GE imgarr[1]) THEN BEGIN
      print, 'background region y upper limit is out of bounds'
      y1back=imgarr[1]-1
   ENDIF ELSE y1back=posback[1]+rback

      
   totb=total(im[x0back:x1back,y0back:y1back])
   backarea=(x1back-x0back)*(y1back-y0back)*pix^2. ;ihhhh need to check this
   normb=totb/backarea
   xx=where((im[x0back:x1back,y0back:y1back] NE 0.),nhits)
   errf=sqrt(nhits)/float(nhits)
   normb_err=normb*errf
  IF keyword_set(rateb) THEN BEGIN
     normb=rateb
     normb_err=rateb*errf
   ENDIF

   print, 'normalized background per arcsec^2: ', normb, normb_err
  
ENDIF ELSE BEGIN
   normb=0.
   normb_err=0.
ENDELSE

poldistc.normb=normb


END
