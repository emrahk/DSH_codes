pro apexpoldist, infile, noa, poldist, radlim=limrad, radwght=radwght
  
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
; OUTPUTS
;
; poldist: structure that carries information about the pie and the brightness
;
;
; OPTIONAL INPUTS
;
; radlim: the range in arcsecond for radii
; radwght: IF set, apply weighting by the distance3 from the center
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

  IF NOT keyword_set(limrad) THEN limrad=[80., 250.]
  IF NOT keyword_set(radwght) THEN radwght=0
 
;Read the fits file

images=readfits(infile, hdr)

;map the pixel coordinates to polar coordinates for the given central
;pos

pos=[248.5067, -47.393]
mappolcoord, hdr, pos, mapr, mapth

;create output structure

nimages=sxpar(hdr, 'NAXIS3')
imgarr=intarr(2)
imgarr[0]=sxpar(hdr, 'NAXIS1')
imgarr[1]=sxpar(hdr, 'NAXIS2')

poldist=create_struct('infile',infile, 'noa',noa, 'radlim', limrad, $
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa),$
                      'sbr',fltarr(nimages,noa),'sbre',fltarr(nimages,noa) )

;pixel size
pixsz = 13.634845D
;pixel area
pixar=pixsz^2.


FOR i=0, noa-1 DO BEGIN
   anglr=360./noa
   angles=[i*anglr,(i+1)*anglr]
   xx=where((mapr GE limrad[0]) AND (mapr LT limrad[1]) AND $
            (mapth GE angles[0]) AND (mapth LT angles[1]))
   poldist.areas[i]=(n_elements(xx)*pixar)

   IF radwght THEN BEGIN
           ;normalize with respect to radlim[0]
     ; FOR k=0, n_elements(xx)-1L DO BEGIN
      weight=(mapr[xx]/limrad[0])^(-3.)
   ENDIF ELSE weight=1.
   
   FOR j=0L, nimages-1L DO BEGIN
      poldist.sbr[j,i]=total(images[xx+(j*imgarr[0]*imgarr[1])]*weight)/poldist.areas[i] ; this is now surface brightness, still needs checking
      poldist.sbre[j,i]=sqrt(total(images[xx+(j*imgarr[0]*imgarr[1])]*weight))/poldist.areas[i]
   ENDFOR
ENDFOR

END
