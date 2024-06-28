pro chandrapoldist_rebin, chim, cchim, useind, trmap, noa, poldistc, radlim=limrad
  
;This program reads a rebinned chandra image file, and find the brightness
;in the given pie area by number of polar angles and radius limits. It
;plots the distribution and saves data to a structure
;
;
; INPUTS
;
; chim: chandra image
; cchim: counts from chandra image
; useind: valid indices in the chandra image
; trmap: use the precalculated radius and theta angles in the image
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
;
; USES
;
; idlastro library
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Jun 2024
;
;
;

  IF NOT keyword_set(limrad) THEN limrad=[80., 250.]
 
;map the pixel coordinates to polar coordinates for the given central
;pos

pos=[248.5067, -47.393]

;create output structure

mapr=trmap.mapr
mapth=trmap.mapth

poldistc=create_struct('noa',noa, 'radlim', limrad, $
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa),$
                      'sbr',fltarr(noa),'sbre',fltarr(noa) )

;pixel size
pixsz = 13.634845D
;pixel area
pixar=pixsz^2.

;get cts for proper error calculation

;not necessary anymore, we are using previously created totals

;nzi=where(chim GT 0.) ;What about negative values!!! ignore them for now
;tcts=fltarr(49,53)
;tcts[nzi]=(1./errat[nzi]^2.)

FOR i=0, noa-1 DO BEGIN
   anglr=360./noa
   angles=[i*anglr,(i+1)*anglr]
   xx=where((mapr GE limrad[0]) AND (mapr LT limrad[1]) AND $
            (mapth GE angles[0]) AND (mapth LT angles[1]))

   yy=cgsetintersection(xx,useind,count=nyy)
   IF nyy eq 0 THEN BEGIN
      print, 'no intersection between useind and given wedge parameters'
      stop
   ENDIF
   
   poldistc.areas[i]=(nyy*pixar)
   ;nyy includes negative values!!!
   poldistc.sbr[i]=total(chim[yy])/poldistc.areas[i] ; this is now surface brightness, still needs checking
   tcts=total(cchim[yy])
   nerrat=1./sqrt(tcts)
   poldistc.sbre[i]=poldistc.sbr[i]*nerrat ;This needs checking
ENDFOR



END
