pro wrap_getchi2_radfit_all, outrchi2, radrange=rangerad, $
                             base_inpdir=inpdir_base, cloud_seq=seq_cloud
;This is a wrapper for radial array creation and fitting
;
;INPUTS
;
; NONE
;
;OUTPUTS
;
; outwrhi2: an output structure with cloud and fit information
;
; OPTIONAL INPUTS
;
; rdel: delta radius of wedges
; rangerad:  radius range for fitting
; base_inpdir: directory where the generated images are
; cloud_seq: one can force near or far of each cloud
;
; USES
;
; wrap_getchi2_radfit
;
; USED BY
;
;NONE
;
; COMMENTS
;
; Created by EK, July 2024
; Adding inpdir as an outside option
; September 2024 fixed magic number in determining distances from string
; added cloud_seq keyword
;

  IF NOT keyword_set(rangerad) THEN rangerad=[60.,300.]
  IF NOT keyword_set(inpdir_base) THEN inpdir_base='/data3/efeoztaban/E2_simulations_corrected/'

  IF NOT keyword_set(seq_cloud) THEN seq_cloud=''
  

;  inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'

  IF seq_cloud EQ '' THEN nitems=32768 ELSE BEGIN
  astr=strsplit(seq_cloud,'?',/extract)
  nastr=total(strlen(astr))
  nitems=long(32768/(nastr+1))
ENDELSE

  

outrchi1=create_struct('dist',0.,'clouds',intarr(nitems,15L),$
                       'norm',fltarr(nitems),$
                        'back',fltarr(nitems),'rchi',fltarr(nitems),$
                        'tchi',fltarr(nitems),'radrange',rangerad)

  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outrchi1=replicate(outrchi1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     nelrd=n_elements(resdir)
     resdist=strsplit(resdir[nelrd-1],'_',/extract) 
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_radfit,dist,outstr,radrange=rangerad,$
                         base_inpdir=inpdir_base,$
                         cloud_seq=seq_cloud,/silent
     outrchi1[i].dist=dist
     FOR j=0L, nitems-1L DO BEGIN
        outrchi1[i].clouds[j,*]=outstr[j].clouds
        outrchi1[i].norm[j]=outstr[j].norm
        outrchi1[i].tchi[j]=outstr[j].tchi
        outrchi1[i].back[j]=outstr[j].back
        outrchi1[i].rchi[j]=outstr[j].rchi
     ENDFOR
     print,dist, min(outstr.rchi)
  ENDFOR

outrchi2=outrchi1[sort(outrchi1.dist)]  
END

  
