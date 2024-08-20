pro getchi2_dist_wdg, inpdir, dist, outstr, wdgdistc, trmap, useind, $
                      snlim=limsn, silent=silent, wdgnof=nofwdg

;This program collects data from the given distance and writes
;normalization factors and total chi2 to a structure

;INPUTS
;
;inpdir: input directory
;dist: distance of the source in kpc
;wdgdistc: profile to compare with
;trmap: calculated theta r structure
;
;OUTPUTS
;
;outstr: output structure with near far distance info, normalization
;and chi2
;
; OPTIONAL INPUTS
;
; snlim: if set limit the sn ratio
;
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
  
;create structure  
  outstr1=create_struct('dist',dist,'clouds',intarr(15),$
                        'norm',0.,'tchi',0.,'back',0.,'rchi',0.,'snlim',limsn)


;find all files
  fitsfiles = FILE_SEARCH(inpdir,'*.fits',count=nfiles)
  outstr=replicate(outstr1,nfiles)

  noa=wdgdistc.noa
  delr=wdgdistc.delr
  minr=wdgdistc.rmin

FOR i=0L, nfiles-1L DO BEGIN
         ;perform calculation
   wedge_create_genim,fitsfiles[i],useind,trmap, noa, delr, gwedstr,$
                      rmin=minr, silent=silent
   getchi2_wdg_fitsingle, wdgdistc, gwedstr, res, totchi2, $
                   plt=plt, snlim=limsn, wdgnof=nofwdg
   outstr[i].norm=res[0]
   outstr[i].back=res[1]
   outstr[i].tchi=totchi2
   outstr[i].rchi=totchi2/(nofwdg-2.)
   ;get cloud info
   fparts=fitsfiles[i].Split('/')
   fname=fparts(n_elements(fparts)-1)
   unds = fname.IndexOf('_')
   cldstext=fname.substring(unds+1,unds+15)
   FOR j=0,14 DO outstr[i].clouds[j]=fix(cldstext.charat(j))
ENDFOR

END
