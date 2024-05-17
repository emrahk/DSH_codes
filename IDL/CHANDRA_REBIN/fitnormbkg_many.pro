pro fitnormbkg_many, dist, chan_rebin, chan_rebin_err, outstr



;dist=11.5                       ;
inpdir_base='~/GENIM/'
;inpdir_base='../../efe_ahmed_analysis/NEWGEN/'
sdist=strtrim(string(dist),1)
res=strsplit(sdist,'.',/extract)
dstring1=res[0]
dstring2=strmid(res[1],0,2)
dists=dstring1+'_'+dstring2
inpdir=inpdir_base+dists

outstr1=create_struct('dist',dist,'clouds',intarr(15),'res',[0.,0.],'tchi',0.)


;find all files
  fitsfiles = FILE_SEARCH(inpdir,'*.fits',count=nfiles)
  outstr=replicate(outstr1,nfiles)

FOR i=0L, nfiles-1L DO BEGIN
         ;perform calculation
   fitnormbkg, fitsfiles[i], chan_rebin, chan_rebin_err, useind, res, chi2
   outstr[i].res=res
   outstr[i].tchi=chi2
   ;get cloud info
   fparts=fitsfiles[i].Split('/')
   fname=fparts(n_elements(fparts)-1)
   unds = fname.IndexOf('_')
   cldstext=fname.substring(unds+1,unds+15)
   FOR j=0,14 DO outstr[i].clouds[j]=fix(cldstext.charat(j))
ENDFOR

END
