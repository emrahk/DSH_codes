pro fitnormbkg, infile, chan_rebin, chan_rebin_err, useind, res, chi2
  ;this program reads a single generate image and
  ;fits normalization and background

;INPUTS
;
;inpfile: input file
;chan_rebin: rebinned chandra image
;chan_rebin_err: error in rebinned chandra image
;useind: indices to use in fitting
;
;OUTPUTS
;
;res: fit result, normalization, background
;chi2: chi2 value of the fit
;
;OPTIONAL INPUTs
;
;?
;
;USES
;
;getnormbgk, MPFITFUN
;
;USED BY
;
;?? A wrapper that collects images and prepares images
;
;COMMENTS
;
;Created by EK APR 2024
;

COMMON myVars, genim
  
;read input image

genim=readfits(infile, hdr)


;use the indices to avoid problematic regions
ygmax=43
;newyzc=zctpix mod ygmax
;newxzc=(zctpix-newyzc)/ygmax

data_x=indgen(35)+7
data_y=indgen(35)+7
data_z=chan_rebin[7:41,7:41]
data_e=chan_rebin_err[7:41,7:41]

cimavg=avg(data_z)
gimavg=avg(genim[7:41,7:41])

p0=[cimavg/gimavg,5D-11]
;do we need myparinfo? yes, background cannot be zero
nparam = 2
myparinfo = REPLICATE({fixed:0, limited:[1,0], limits:[0.0,0.0]}, nparam)
myparinfo[1].limited=[1,1]
myparinfo[1].limits=[0.,avg(chan_rebin[21:27,23:29])]

;model_fit = MPFITFUN('getnormbkg', data_x, data_y, data_e, p0, $
;                     perror=errorp,bestnorm=normbest, best_resid=residbest)


model_fit = MPFIT2DFUN('getnormbkg', data_x, data_y, data_z, data_e, p0, $
                       perror=errorp,bestnorm=normbest, best_resid=residbest,$
                      parinfo=myparinfo, yfit=fity, status=status)

chi2=normbest
res=model_fit
;some verification

END
