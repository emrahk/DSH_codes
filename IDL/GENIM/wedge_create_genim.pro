pro wedge_create_genim,  infile, useind, trmap, noa, delr, gwedstr, $
                   rmin=minr, plwedges=plwedges, $
                  ps=ps, fname=namef,silent=silent, newdust=newdust

;This program creates wedges with the given delta r and delta phi and fills
;the image with the wedges.
;
;INPUTS
;
; genim: generated image
; useind: valid indices in the chandra image
; trmap: use the precalculated radius and theta angles in the image
; delr: delta r
; noa: number of angles to divide 360 degrees
;
; OUTPUTS
; gwedstr: a structure that includes wedge x,y points, S/N
;
; OPTIONAL INPUTS
;
; rmin: inner exclusion zone
; plwedges: overplot wedges on Chandra image (TBI)
; ps: postscript (TBI)
; fname: name of postscript file (TBI)
; silent: If set do not print any warning
; newdust: If set take averages as it is using 1/asec2 from newdust
;
; USES
;
; USED BY
;
; APEX and CHANDRA analysis polar distribution codes
;
; CREATED by Emrah Kalemci, Jun 2024
; sep 2024, added newdust parameter
;
;

IF NOT keyword_set(minr) THEN minr=80.
IF NOT keyword_set(plwedges) THEN plwedges=0
IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='gwedges.eps'
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

maxr=max(mapr)
nor=floor((maxr-minr)/delr + 0.5)
anglr=360./noa


gwedstr=create_struct('noa',noa, 'delr', delr, 'rmin',minr, $
                     'indices',intarr(noa,nor,500),$
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa,nor),$
                     'sbr',fltarr(noa,nor),'sbre',fltarr(noa,nor),$
                      'sn',fltarr(noa,nor))

;sbre, sn kept for now in case we find a way to calculate errors in
;the future

 gwedstr.indices=replicate(-1,noa*nor*500)

IF plwedges THEN BEGIN
    loadct,5
if ps then begin
   set_plot, 'ps'
   device,/color
;   loadct,5
   device,/encapsulated
   device, filename = namef
   device, yoffset = 2
   device, ysize = 20.
   device, xsize = 20.
   !p.font=0
   device,/times
   backc=0
   axc=0
endif

IF NOT ps THEN BEGIN
   window, 1, retain=2, xsize=600, ysize=600
   backc=0
   axc=255
   device,decomposed=0
ENDIF

cs=1.3

imrange=[0,max(genim,/nan)]
xrange_im=[248.64055,248.3720]
yrange_im=[-47.49124,-47.2942946]
plotimage, genim,imgxrange=xrange_im,$
           imgyrange=yrange_im,range=imrange ;,noerase$
;           background=backc,axiscolor=axc

plotsym,0,/fill
colindex=0
ENDIF


FOR ai=0, noa-1 DO BEGIN
   IF (ai mod 2) THEN colindex=1 ELSE colindex=0
   IF NOT silent THEN print,ai,colindex
  FOR ri=0, nor-1 DO BEGIN
   angles=[ai*anglr,(ai+1)*anglr]
   rads=[ri*delr,(ri+1)*delr]+minr
   
   xx=where((mapr GE rads[0]) AND (mapr LT rads[1]) AND $
            (mapth GE angles[0]) AND (mapth LT angles[1]))

   yy=cgsetintersection(xx,useind,count=nyy,indices_a=ixx)
   
      IF nyy LE 1 THEN BEGIN
          IF NOT silent THEN print, angles[0], rads[0], 'no intersection between useind and given wedge parameters'
          ENDIF ELSE BEGIN
          
          gwedstr.indices[ai,ri,0:nyy-1]=yy
          gwedstr.areas[ai,ri]=(nyy*pixar)
                                ;nyy includes negative values!!!
          IF newdust THEN gwedstr.sbr[ai,ri] = avg(genim[yy]) ELSE $
             gwedstr.sbr[ai,ri]=total(genim[yy])/gwedstr.areas[ai,ri] ; this is now surface brightness, still needs checking
;          tcts=total(cchim[yy])

;          IF tcts GT 0. THEN BEGIN
;             nerrat=1./sqrt(tcts)
;             wedstr.sbre[ai,ri]=wedstr.sbr[ai,ri]*nerrat ;This needs checking
;             wedstr.sn[ai,ri]=sqrt(tcts)
;             ENDIF
             
          IF plwedges THEN BEGIN
             sz=[49,53]
             xi=(yy mod sz[0])
             yi=(yy/sz[0])
             xs=(xrange_im[1]-xrange_im[0])/49.
             ys=(yrange_im[1]-yrange_im[0])/53.
             xv=xrange_im[0]+xi*xs+(xs/2.)
             yv=yrange_im[0]+yi*ys+(ys/2.)
             oplot,xv,yv,psym=8, color=15+colindex*220
             colindex=~colindex
           ENDIF
        ENDELSE             
      ENDFOR
ENDFOR


END
  






  
