function deltf, x, D, theta

  c=3D8                         ;m/s

  ntheta = (theta/3600D)*(!PI/180.)

  day=86400D                    ;s

  kpc = 3.09D19                 ;m

  deltat= x * D * kpc * (ntheta^2.) / (2 * c * (1-x)) ;s
  return, deltat/day
END

