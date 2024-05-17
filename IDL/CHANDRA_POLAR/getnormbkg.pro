function getnormbkg, X, Y, p      ;p=[norm, back]

  COMMON myVars, genim

  im2fit=genim[X,Y]
  
  RETURN, (P[0]*im2fit)+P[1]

END


  
