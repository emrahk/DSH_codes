pro wrap_getchi2_wdgfit_all_13CO, outwchi2, $
                             rdel=delr, limrad=radlim, ano=noa, snlim=limsn

  IF NOT keyword_set(delr) THEN delr=50.
  IF NOT keyword_set(radlim) THEN radlim=90.
  IF NOT keyword_set(noa) THEN noa=18
  IF NOT keyword_set(limsn) THEN limsn=7.
  
  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),'norm',fltarr(32768L),$
                        'back',fltarr(32768),'delr',delr,'radlim',radlim,$
                        'tchi',fltarr(32768L),'snlim',limsn,'noa',noa,'rchi',fltarr(32768),'nofwdg',0)
  
  inpdir_base='/data3/efeoztaban/E2_simulations_13CO_corrected/'
  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outwchi1=replicate(outstr1,ndir)
 
  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     resdist=strsplit(resdir[n_elements(resdir)-1],'_',/extract)
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_wdgfit,dist,outstr,/silent,snlim=limsn,wdgnof=nofwdg, base_inpdir=inpdir_base
     outwchi1[i].dist=dist
     outwchi1[i].nofwdg=nofwdg
     FOR j=0L, 32767L DO BEGIN
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

  
