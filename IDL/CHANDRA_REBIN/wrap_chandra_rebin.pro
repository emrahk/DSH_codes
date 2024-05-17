pro wrap_chandra_rebin
  
  rebin_chandra,2,outim2bc,outerr2bc,/silent,/backcor,outcts=ctsout2,$
                /remoutlier, maxthresh=1.25e-6,induse=useind2
  
  rebin_chandra,1,outim1bc,outerr1bc,/silent,/backcor,outcts=ctsout1,$
                induse=useind1
  
  rebin_chandra,0,outim0bc,outerr0bc,/silent,/backcor,outcts=ctsout0,$
                induse=useind0

  outim_total=outim0bc+outim1bc+outim2bc
  outcts_total=ctsout0+ctsout1+ctsout2
  err_frac=sqrt(outcts_total)/outcts_total
  outerr_total=outim_total*err_frac

  useind_total=useind0

  imrange=[0,max(outim_total,/nan)]
  plotimage, outim_total,imgxrange=[248.64055,248.3720],$
             imgyrange=[-47.49124,-47.2942946],range=imrange

  save,outim2bc,outerr2bc,useind2, outim1bc,outerr1bc,useind1, $
       outim0bc,outerr0bc,useind0, outim_total, outerr_total, useind_total, $
       filename='rebin_chandra.sav'

END
