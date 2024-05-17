pro getchi2_pol_dist, inpdir, dist, outstr, poldistc, trmap, radlim=limrad

;This program collects data from the given distance and writes
;normalization factors and total chi2 to a structure for polar fits

;INPUTS
;
;inpdir: input directory
;dist: distance of the source in kpc
;poldistc: chandra profile structure to compare with
;trmap: calculated theta r structure
;
;OUTPUTS
;
;outstr: output structure with near far distance info, normalization
;and chi2
;
; OPTIONAL INPUTS
;
; radlim: the range in arcsecond for radii
;
; USES
;
;getchi2_pol_single
;
;USED BY
;
; COMMENTS
;
;Created by Emrah Kalemci
; March 2024
;


IF NOT keyword_set(limrad) THEN limrad=[80., 250.]
  
;create structure  
  outstr1=create_struct('dist',dist,'clouds',intarr(15),'norm',0.,'tchi',0.)


;find all files
  fitsfiles = FILE_SEARCH(inpdir,'*.fits',count=nfiles)
  outstr=replicate(outstr1,nfiles)

noa=poldistc.noa
  
FOR i=0L, nfiles-1L DO BEGIN
         ;perform calculation
   genimpoldist,fitsfiles[i],noa,poldistg,radlim=limrad,maprt=trmap
   getchi2_pol_single, poldistc, poldistg, totchi2, normpar=parnorm
   outstr[i].norm=parnorm
   outstr[i].tchi=totchi2
   ;get cloud info
   fparts=fitsfiles[i].Split('/')
   fname=fparts(n_elements(fparts)-1)
   unds = fname.IndexOf('_')
   cldstext=fname.substring(unds+1,unds+15)
   FOR j=0,14 DO outstr[i].clouds[j]=fix(cldstext.charat(j))
ENDFOR

END
