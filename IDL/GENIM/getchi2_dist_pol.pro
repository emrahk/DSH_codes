pro getchi2_dist_pol, inpdir, dist, outstr, poldistc, trmap, radrange=rangerad, ano=noa

;This program collects data from the given distance and writes
;normalization factors and total chi2 to a structure

;INPUTS
;
;inpdir: input directory
;dist: distance of the source in kpc
;poldistc: profile to compare with
;trmap: calculated theta r structure
;
;OUTPUTS
;
;outstr: output structure with near far distance info, normalization
;and chi2
;
; OPTIONAL INPUTS
;
; radrange: radius range to calculate xi2
; ano: number of angels
;
;
; USES
;
;getchi2_pol_fitsingle
;
;USED BY
;
; COMMENTS
;
;Created by Emrah Kalemci
; June 2024
;

  IF NOT keyword_set(rangerad) THEN rangerad=[90.,250.]
  IF NOT keyword_set(noa) THEN noa=12

  
;create structure  
  outstr1=create_struct('dist',dist,'clouds',intarr(15),'norm',0.,'tchi',0.,'back',0.)


;find all files
  fitsfiles = FILE_SEARCH(inpdir,'*.fits',count=nfiles)
  outstr=replicate(outstr1,nfiles)

FOR i=0L, nfiles-1L DO BEGIN
         ;perform calculation
   genimpoldist,fitsfiles[i],noa,poldist,radlim=limrad,maprt=trmap
   getchi2_pol_fitsingle, poldistc, poldist, res, totchi2, $
                   plt=plt, radrange=rangerad
   outstr[i].norm=res[0]
   outstr[i].back=res[1]
   outstr[i].tchi=totchi2
   ;get cloud info
   fparts=fitsfiles[i].Split('/')
   fname=fparts(n_elements(fparts)-1)
   unds = fname.IndexOf('_')
   cldstext=fname.substring(unds+1,unds+15)
   FOR j=0,14 DO outstr[i].clouds[j]=fix(cldstext.charat(j))
ENDFOR

END
