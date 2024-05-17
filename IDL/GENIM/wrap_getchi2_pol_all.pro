pro wrap_getchi2_pol_all, outpchi2

  outstr1=create_struct('dist',0.,'clouds',intarr(32768L,15L),$
                        'norm',fltarr(32768L),$
                        'tchi',fltarr(32768L))
  inpdir_base='/home/efeoztaban/ahmet_code/outputs3/'
  Result = FILE_SEARCH(inpdir_base, '*_*0',count=ndir)

  outpchi2=replicate(outstr1,ndir)

  FOR i=0, n_elements(result)-1 DO BEGIN
     dirname=result[i]
     resdir=strsplit(dirname,'/',/extract)
     resdist=strsplit(resdir[4],'_',/extract)
     dist=fix(resdist[0])+(fix(resdist[1])/100.)
     
     wrap_getchi2_pol,dist,outstr,/silent
     outpchi2[i].dist=dist
     FOR j=0L, 32767L DO BEGIN
        outpchi2[i].clouds[j,*]=outstr[j].clouds
        outpchi2[i].norm[j]=outstr[j].norm
        outpchi2[i].tchi[j]=outstr[j].tchi
     ENDFOR
     print,dist, min(outstr.tchi)
  ENDFOR

END

  
