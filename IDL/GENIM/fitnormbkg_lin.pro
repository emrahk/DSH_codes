pro fitnormbkg_lin, func2fit, fitfunc, useind, res, chi2, backlim=limback
      ;this program fits the given distribution by allowing a
                                ;normalization and background

;INPUTS
;
;inpfile: function to be fitted, with its errors from Chandra images
;fitfunc: fitting function from the generated image
;useind: indices to use in fitting
;
;OUTPUTS
;
;res: fit result, normalization, background
;chi2: chi2 value of the fit
;
;OPTIONAL INPUTs
;
;backlim: if set use the given limits for background
;
;USES
;
;getnormbgk_lin, MPFITFUN
;
;USED BY
;
;?? A wrapper that collects images and prepares images
;
;COMMENTS
;
;Created by EK MAY 2024
;

  IF NOT keyword_set(limback) THEN limback=[-0.3,0.9]
  
COMMON myVars, inparr
  
;read input distribution

cimavg=avg(func2fit[0,useind]) ; chandra file to be fitted
gimavg=avg(fitfunc[useind])  ;corresponding generated image

nm=cimavg/gimavg ;normalize first

newfunct2fit=func2fit[*,useind]*1D9 ;This is done to avoid too small numbers

inparr=fitfunc[useind]*1D9*nm


;chp*1D9 = gp*1D9*nm*NORM+BACK
;chp = gp*nm*norm+back*1D-9

p0=[0.95,0.05]

;do we need myparinfo? yes, background cannot be zero
nparam = 2
myparinfo = REPLICATE({fixed:0, limited:[1,0], limits:[0.0,0.0]}, nparam)
myparinfo[1].limited=[1,1]
myparinfo[1].limits=limback


model_fit = MPFITFUN('getnormbkg_lin', indgen(n_elements(useind)), $
                     newfunct2fit[0,*], $
                     newfunct2fit[1,*], p0, $
                     parinfo=myparinfo, $
                     perror=errorp,bestnorm=normbest, $
                     best_resid=residbest,/quiet)


;model_fit = MPFIT2DFUN('getnormbkg', data_x, data_y, data_z, data_e, p0, $
;                       perror=errorp,bestnorm=normbest, best_resid=residbest,$
;                      parinfo=myparinfo, yfit=fity, status=status)

chi2=normbest
res=fltarr(2)
res[0]=model_fit[0]*nm
res[1]=model_fit[1]*1D-9

;some verification

END
