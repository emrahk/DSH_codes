pro wdg_singlefits, inpfile, wdgdistc, trmap, useind, $
                    snlim=limsn, silent=silent, wdgnof=nofwdg, $
                    backlim=limback, addnoise=noiseadd

;This program collects data from a single fits file perform a fit and
;writer results

;INPUTS
;
;inpfile: input fitsfile
;wdgdistc: profile to compare with
;trmap: calculated theta r structure
;
;OUTPUTS
;
;plot and fit result
;
; OPTIONAL INPUTS
;
; snlim: if set limit the sn ratio
; backlim: of set use the given background limits
; addnoise: add constant noise
;
; OPTIONAL OUTPUTS
;
; wdgnof: number of wedges in the fit
;
; USES
;
;getchi2_wdg_fitsingle
;
;USED BY
;
; COMMENTS
;
;Created by Emrah Kalemci
; June 2024
;

  IF NOT keyword_set(snlim) THEN snlim=7.
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(limback) THEN limback=[-0.3,0.9]
  IF NOT keyword_set(noiseadd) THEN noiseadd=0.

  noa=wdgdistc.noa
  delr=wdgdistc.delr
  minr=wdgdistc.rmin


   wedge_create_genim,inpfile,useind,trmap, noa, delr, gwedstr,$
                      rmin=minr, /silent
   getchi2_wdg_fitsingle, wdgdistc, gwedstr, res, totchi2, $
                          /plt, snlim=limsn, wdgnof=nofwdg, $
                          backlim=limback, addnoise=noiseadd
   print,'FIT result',res[0],res[1]
   print,'REDUCED CHI2=',totchi2/(nofwdg-2.)

END
