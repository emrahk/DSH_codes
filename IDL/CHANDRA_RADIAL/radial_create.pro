pro radial_create,  chim, chimbc, cchim, useind, trmap, noa, delr, radstr, $
                  ps=ps, fname=namef, plrads=plrads

;This program creates radial profiles of Chandra data with the given delta r
; For each radial bin, it calculates S/N ratio in Chandra
;
;INPUTS
;
; chim: rebinned chandra image, not background corrected
; chimbc: rebinned chandra image, background corrected
; cchim: counts from chandra image
; useind: valid indices in the chandra image
; trmap: use the precalculated radius and theta angles in the image
; delr: delta r
; noa: number of annuli
;
; OUTPUTS
; radstr: a structure that includes radial profile info
;
; OPTIONAL INPUTS
;
; ps: postscript (TBI)
; fname: name of postscript file (TBI)
; plrads: IF set plot radial profile over chandra image
;
; USES
;
; USED BY
;
; APEX and CHANDRA analysis radial distribution codes
;
; CREATED by Emrah Kalemci, Sep 2024
;

  
IF NOT keyword_set(ps) THEN ps=0
IF NOT keyword_set(namef) THEN namef='profile.eps'
IF NOT keyword_set(plrads) THEN plrads=0


;map the pixel coordinates to polar coordinates for the given central
;pos

pos=[248.5067, -47.393]

;create output structure

mapr=trmap.mapr
mapth=trmap.mapth

;pixel size
pixsz = 13.634845D
;pixel area
pixar=pixsz^2.

radstr=create_struct('noa',noa, 'mrad', delr, $
                      'mapr', mapr, 'mapth', mapth, 'areas',fltarr(noa),$
                     'sbr',fltarr(noa),'sbre',fltarr(noa),$
                     'sn',fltarr(noa))

;indices=replicate(-1,noa*500)

indices=intarr(noa,500)
for i=0,noa*500L-1L DO indices[i]=-1

IF plrads THEN BEGIN
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

imrange=[0,max(chimbc,/nan)]
xrange_im=[248.64055,248.3720]
yrange_im=[-47.49124,-47.2942946]
plotimage, chimbc,imgxrange=xrange_im,$
           imgyrange=yrange_im,range=imrange ;,noerase$
;           background=backc,axiscolor=axc

plotsym,0,/fill
colindex=0
ENDIF


FOR ri=0, noa-1 DO BEGIN

   rads=[ri*delr,(ri+1)*delr]
   
   xx=where((mapr GE rads[0]) AND (mapr LT rads[1]))

   yy=cgsetintersection(xx,useind,count=nyy,indices_a=ixx)
   
      IF nyy LE 1 THEN BEGIN
          print, rads[0], 'no intersection between useind and given wedge parameters'
          ENDIF ELSE BEGIN
          
          indices[ri,0:nyy-1]=yy
          radstr.areas[ri]=(nyy*pixar)
                                ;nyy includes negative values!!!
          radstr.sbr[ri]=total(chimbc[yy])/radstr.areas[ri] ; this is now surface brightness, still needs checking
          tcts=total(cchim[yy])
          timsb=total(chim[yy])/radstr.areas[ri]

          IF tcts GT 0. THEN BEGIN
             nerrat=1./sqrt(tcts)
;             wedstr.sbre[ai,ri]=abs(wedstr.sbr[ai,ri]*nerrat) ;This
;             is incorrect
             radstr.sbre[ri]=abs(timsb)*nerrat
             
             radstr.sn[ri]=sqrt(tcts)
             ENDIF
             
          IF plrads THEN BEGIN
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


END
  






  
