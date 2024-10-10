function intvclxy, xp, yp, x, xb
  restore,'trmap.sav'
  r=trmap.mapr[xp,yp]
  th=trmap.mapth[xp,yp]
  delta=r*(x/xb)*(1-xb)/(1-x)
  xn=delta*cos(th*!PI/180.)
  yn=delta*sin(th*!PI/180.)
  pixsz = 13.634845D
  cpos=[23.878014,25.938874]    ; +1 for ds9 or matlab
  res=[cpos[0]+(xn/pixsz), cpos[1]+(yn/pixsz)]
  return, res
END
