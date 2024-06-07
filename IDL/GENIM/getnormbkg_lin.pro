function getnormbkg_lin, X, p      ;p=[norm, back]

  COMMON myVars, inparr
  
  RETURN, (P[0]*inparr[X])+P[1]

END


  
