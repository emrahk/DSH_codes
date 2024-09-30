pro getchi2_dist_wdg, inpdir, dist, outstr, wdgdistc, trmap, useind, $
                      snlim=limsn, silent=silent, wdgnof=nofwdg, $
                      cloud_seq=seq_cloud, newdust=newdust

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
; silent: if set do not produce any text output on screen
; cloud_seq: filter near and far on clouds
; newdust: IF set, use averates for newdust cross sections 
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
; Sep 2024 added cloud_seq
;

  IF NOT keyword_set(snlim) THEN snlim=7.
  IF NOT keyword_set(silent) THEN silent=0
  IF NOT keyword_set(seq_cloud) THEN seq_cloud=''
  IF NOT keyword_set(newdust) THEN newdust=0
  
;create structure  
  outstr1=create_struct('dist',dist,'clouds',intarr(15),$
                        'norm',0.,'tchi',0.,'back',0.,'rchi',0.,'snlim',limsn)

;find all files
  IF seq_cloud eq '' THEN tsq='*.fits' ELSE tsq='*_'+seq_cloud+'*fits'
  
  fitsfiles = FILE_SEARCH(inpdir,tsq,count=nfiles)
  outstr=replicate(outstr1,nfiles)

  noa=wdgdistc.noa
  delr=wdgdistc.delr
  minr=wdgdistc.rmin

FOR i=0L, nfiles-1L DO BEGIN
         ;perform calculation
   wedge_create_genim,fitsfiles[i],useind,trmap, noa, delr, gwedstr,$
                      rmin=minr, silent=silent, newdust=newdust
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
