pro radial_create_genim,  infile, useind, trmap, noa, mrad, gradstr, $
                  silent=silent, newdust=newdust

;This program creates wedges with the given delta r and delta phi and fills
;the image with the wedges.
;
;INPUTS
;
; infile: generated image
; useind: valid indices in the chandra image
; trmap: use the precalculated radius and theta angles in the image
; noa: number of radial rings
; mrad: delta radius in arcsecond
;
; OUTPUTS
; gradstr: a structure that includes radial profiles
;
; OPTIONAL INPUTS
;
; silent: If set do not print any warning
; newdust: If set take averages as it is using 1/asec2 from newdust
;
; USES
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Sep 2024
;
;

IF NOT keyword_set(silent) THEN silent=0
IF NOT keyword_set(newdust) THEN newdust=0

;Read the fits file

genim=readfits(infile, hdr,/silent)

;create output structure

mapr=trmap.mapr
mapth=trmap.mapth

;pixel size
pixsz = 13.634845D
;pixel area
pixar=pixsz^2.


gradstr=create_struct('infile',infile,'noa',noa, 'mrad',mrad, $
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa),$
                     'sbr',fltarr(noa),'sbre',fltarr(noa))

;sbre, kept for now in case we find a way to calculate errors in
;the future

;Handle intial circle

xx=where(mapr LT mrad,nonzero)  ;
IF nonzero EQ 0 THEN print, 0, 'no pixel inside initial circle' ELSE BEGIN
   gradstr.areas[0]=(n_elements(xx)*pixar)
   IF newdust THEN gradstr.sbr[0]=avg(genim[xx]) ELSE gradstr.sbr[0]=total(genim[xx])/gradstr.areas[0]
;poldist.sbre[0]=sqrt(total(image[xx])*weight)/poldist.areas[0] ;????
ENDELSE
                      
FOR ri=1, noa-1 DO BEGIN
   rads=[ri*mrad,(ri+1)*mrad]
   
   xx=where((mapr GE mrad*ri) AND (mapr LT mrad*(ri+1)),nonzero)
   
   yy=cgsetintersection(xx,useind,count=nyy,indices_a=ixx)
   
   gradstr.areas[ri]=(nyy*pixar)
                                ;nyy includes negative values!!!
   IF newdust THEN gradstr.sbr[ri] = avg(genim[yy]) ELSE $
             gradstr.sbr[ri]=total(genim[yy])/gradstr.areas[ri] ; this is now surface brightness, still needs checking
;          tcts=total(cchim[yy])

ENDFOR


END
  






  
