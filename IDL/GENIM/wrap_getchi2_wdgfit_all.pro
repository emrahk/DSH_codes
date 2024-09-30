pro wrap_getchi2_wdgfit_all, outwchi2, $
                             rdel=delr, limrad=radlim, ano=noa, $
                             snlim=limsn, base_inpdir=inpdir_base,$
                             cloud_seq=seq_cloud, newdust=newdust

;This is a wrapper for wedge array creation and fitting
;
;INPUTS
;
; NONE
;
;OUTPUTS
;
; outwchi2: an output structure with cloud and fit information
;
; OPTIONAL INPUTS
;
; rdel: delta radius of wedges
; limrad: starting radius
; ano: number of angles to divide 360 degrees
; snlim: signal to noise ratio to include in fitting
; base_inpdir: directory where the generated images are
; cloud_seq: one can force near or far of each cloud
; newdust: If set use averages? to be compatible with newdust cross sections
;
; USES
;
; wrap_getchi2_wdgfit
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
; added newdust keyword
;
  
  IF NOT keyword_set(delr) THEN delr=50.
  IF NOT keyword_set(radlim) THEN radlim=90.
  IF NOT keyword_set(noa) THEN noa=18
  IF NOT keyword_set(limsn) THEN limsn=7.
  IF NOT keyword_set(inpdir_base) THEN inpdir_base='/data3/ekalemci/DSH_Analysis/dsh_limited_v0/'
  IF NOT keyword_set(seq_cloud) THEN seq_cloud=''
  IF NOT keyword_set(newdust) THEN newdust=0
  
  IF seq_cloud EQ '' THEN nitems=32768 ELSE BEGIN
  astr=strsplit(seq_cloud,'?',/extract)
  nastr=total(strlen(astr))
  nitems=long(32768/(nastr+1))
ENDELSE

    
  outstr1=create_struct('dist',0.,'clouds',intarr(nitems,15L),$
                        'norm',fltarr(nitems), 'back',fltarr(nitems),$
                        'delr',delr,'radlim',radlim,$
                        'tchi',fltarr(nitems),'snlim',limsn,'noa',noa,$
                        'rchi',fltarr(nitems),'nofwdg',0)
  

  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outwchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     nelrd=n_elements(resdir)
     resdist=strsplit(resdir[nelrd-1],'_',/extract) 
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_wdgfit,dist,outstr,/silent,snlim=limsn,wdgnof=nofwdg,$
                         rdel=delr, limrad=radlim, ano=noa, $
                         base_inpdir=inpdir_base, newdust=newdust
                         
     outwchi1[i].dist=dist
     outwchi1[i].nofwdg=nofwdg
     FOR j=0L, nitems-1L DO BEGIN
        outwchi1[i].clouds[j,*]=outstr[j].clouds
        outwchi1[i].norm[j]=outstr[j].norm
        outwchi1[i].tchi[j]=outstr[j].tchi
        outwchi1[i].back[j]=outstr[j].back
        outwchi1[i].rchi[j]=outstr[j].rchi
     ENDFOR
     print,dist, min(outstr.rchi)
  ENDFOR

outwchi2=outwchi1[sort(outwchi1.dist)]  
END

  
