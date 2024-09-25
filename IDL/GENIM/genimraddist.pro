pro genimraddist, infile, noa, raddist, radm=mrad, maprt=trmap, newdust=newdust

;This program reads a FITS header and images, and find the surface brightness
;profile with generated images using APEX data
;plots the distribution and saves data to a structure
;
;
; INPUTS
;
; infile: FITS file with the generated apex images
; noa: number of radial rings
;
; OUTPUTS
;
; raddist: structure that carries information about the pie and the brightness
;
;
; OPTIONAL INPUTS
;
; radm: If set, multiples of this radius in arcsec will be used to
;           create profile, default=30''
; maptr: If fiven use the map directly (as mappolcoord takes time)
; newdust: If set, profiles are calculated using newdust method, so struct averages should be calculated
;
; USES
;
; idlastro library
; mappolcoord
;
; USED BY
;
; NONE
;

; CREATED by Emrah Kalemci, Mar 2024
;
; ADDED newdust option, September 2024
;
  
  IF NOT keyword_set(mrad) THEN mrad=30.
  IF NOT keyword_set(newdust) THEN newdust=0
  
;Read the fits file

image=readfits(infile, hdr,/silent)

;map the pixel coordinates to polar coordinates for the given central
;pos

pos=[248.5067, -47.393]
IF NOT keyword_set(trmap) THEN mappolcoord, hdr, pos, mapr, mapth ELSE BEGIN
   mapr=trmap.mapr
   mapth=trmap.mapth
ENDELSE



;create output structure

imgarr=intarr(2)
imgarr[0]=sxpar(hdr, 'NAXIS1')
imgarr[1]=sxpar(hdr, 'NAXIS2')

raddist=create_struct('infile',infile, 'noa',noa, 'mrad',mrad, $
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa),$
                      'sbr',fltarr(noa),'sbre',fltarr(noa) )

;pixel size
pixsz = 13.634845D
;pixel area
pixar=pixsz^2.
weight=1.

xx=where(mapr LT mrad,nonzero)  ;
IF nonzero EQ 0 THEN print, 0, 'no pixel inside rad' ELSE BEGIN
   raddist.areas[0]=(n_elements(xx)*pixar)
   IF newdust THEN raddist.sbr[0]=avg(image[xx]) ELSE raddist.sbr[0]=total(image[xx])/raddist.areas[0]
;poldist.sbre[0]=sqrt(total(image[xx])*weight)/poldist.areas[0] ;????
ENDELSE
   
FOR i=1, noa-1 DO BEGIN
   xx=where((mapr GE mrad*i) AND (mapr LT mrad*(i+1)),nonzero)
   IF nonzero EQ 0 THEN print, i, 'no pixel inside rad' ELSE BEGIN

   raddist.areas[i]=(n_elements(xx)*pixar)
   IF newdust THEN raddist.sbr[i]=avg(image[xx]) ELSE raddist.sbr[i]=total(image[xx])/raddist.areas[i]
;   print,i,nonzero,raddist.areas[i]
;poldist.sbre[0]=sqrt(total(image[xx])*weight)/poldist.areas[0] ;????
  ENDELSE
ENDFOR

   
END
