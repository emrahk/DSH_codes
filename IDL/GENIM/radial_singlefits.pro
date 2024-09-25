pro radial_singlefits, inpfile, nprof, trmap, $
                    silent=silent, radm=mrad, annum=numan,newdust=newdust,$
                    backlim=limback, addnoise=noiseadd, radrange=rangerad

;This program collects data from a single fits file perform a fit and
;writer results

;INPUTS
;
;inpfile: input fitsfile
;raddistc: profile to compare with
;trmap: calculated theta r structure
;
;OUTPUTS
;
;plot and fit result
;
; OPTIONAL INPUTS
;
; backlim: of set use the given background limits
; addnoise: add constant noise
; radm: delta theta
; annum: number of annulus
; radrange: radius range to fit
; newdust: if set use newdust 
;
; OPTIONAL OUTPUTS
;
; wdgnof: number of wedges in the fit
;
; USES
;
;getchi2_rad_fitsingle
;genimraddist
;
;USED BY
;
; COMMENTS
;
;Created by Emrah Kalemci
; Sep 2024
;

  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(limback) THEN limback=[-0.3,0.9]
  IF NOT keyword_set(noiseadd) THEN noiseadd=0.

  IF NOT keyword_set(mrad) THEN mrad=15
  IF NOT keyword_set(numan) THEN numan=22
  IF NOT keyword_set(rangerad) THEN rangerad=[30.,300.]
  IF NOT keyword_set(newdust) THEN newdust=0


   genimraddist,inpfile,numan,raddist,radm=mrad,maprt=trmap,newdust=newdust

    getchi2_rad_fitsingle, nprof, raddist, res, totchi2, $
                           /plt, radrange=rangerad
    
   ;getchi2_wdg_fitsingle, wdgdistc, gwedstr, res, totchi2, $
   ;                       /plt, snlim=limsn, wdgnof=nofwdg, $
   ;                       backlim=limback, addnoise=noiseadd
    print,'FIT result',res[0],res[1]
    noa=(rangerad[1]-rangerad[0])/mrad
   print,'REDUCED CHI2=',totchi2/(noa-2)

END
