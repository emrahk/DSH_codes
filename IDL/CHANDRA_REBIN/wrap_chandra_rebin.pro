pro wrap_chandra_rebin
  
  rebin_chandra,2,outim2,outerr2,/silent,$
                /remoutlier, maxthresh=1.25e-6
  
  rebin_chandra,1,outim1,outerr1,/silent
  
  rebin_chandra,0,outim0,outerr0,/silent

  rebin_chandra,2,outim2bc,outerr2bc,/silent,/backcor,outcts=ctsout2,$
                /remoutlier, maxthresh=1.25e-6,induse=useind2
  
  rebin_chandra,1,outim1bc,outerr1bc,/silent,/backcor,outcts=ctsout1,$
                induse=useind1
  
  rebin_chandra,0,outim0bc,outerr0bc,/silent,/backcor,outcts=ctsout0,$
                induse=useind0

  outimbc_total=outim0bc+outim1bc+outim2bc
  outim_total=outim0+outim1+outim2
  outcts_total=ctsout0+ctsout1+ctsout2
  err_frac=sqrt(outcts_total)/outcts_total
  outerr_total=outim_total*err_frac
  outim_total=outimbc_total ;not to change all other programs

  useind_total=useind0

  imrange=[0,max(outim_total,/nan)]
  plotimage, outim_total,imgxrange=[248.64055,248.3720],$
             imgyrange=[-47.49124,-47.2942946],range=imrange

  cpix=0.492
  backc7=[[1.1994871e-09,2.0880390e-10],[1.2262101e-09,2.3598423e-10],[1.3671821e-09,2.4168595e-10]]*(cpix^2)*27.*27.
  backc6=[[1.0735030e-09,2.4004254e-10],[1.1047544e-09,2.6039310e-10],[1.1217958e-09,2.4479591e-10]]*(cpix^2)*27.*27.
  
  save,outim2,outim2bc,outerr2bc,useind2, outim1,outim1bc,outerr1bc,useind1, $
       outim0,outim0bc,outerr0bc,useind0, outim_total, outerr_total, $
       useind_total, ctsout0, ctsout1, ctsout2, backc6, backc7, cpix, $
       filename='rebin_chandra.sav'

END
