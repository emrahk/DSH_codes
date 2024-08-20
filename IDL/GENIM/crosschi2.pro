pro crosschi2, str1, str2, restr, showim=showim, sm=sm

;This program takes two structures with chi2 distributions and finds
;the minimum of the intersection by multiplying (or if sm chosen,
;summing).

;INPUTS
;
; str1: input structure 1 carrying cloud information and total chi2
; str2: input structure 2 carrying cloud information and total chi2
;
;
;OUTPUTS
;
; restr: a structure with distance, image number and cloud information
;
;OPTIONAL INPUTS
;
; showim: if set write the command to show the image with the lowest
;chi2
; sm: If set, sum instead of multiply, warning, reduced chi2 must be
;used for this option
;
; USED BY
;
; NONE
;
; USES
;
; NONE
;
; COMMENTS
;
; Created by Emrah Kalemci June 2024
;
;

IF NOT keyword_set(sm) THEN sm=0
IF NOT keyword_set(showim) THEN showim=0  
  
;Find common distances

intd1=fix(str1.dist*10)
intd2=fix(str2.dist*10)
result=cgsetintersection(intd1,intd2, count=ncount, indices_a=i1,indices_b=i2, success=success)

restr0=create_struct('dist',0.,'chi1',0.,'chi2',0.,'intchi',0.,'clouds',intarr(15))
intchi=1d9

IF success THEN BEGIN

   FOR i=0, n_elements(i1)-1 DO BEGIN
      IF sm THEN temp_intchi=(str1[i1[i]].tchi+str2[i2[i]].tchi) ELSE $
          temp_intchi=(str1[i1[i]].tchi*str2[i2[i]].tchi)
      minv=min(temp_intchi)
;      IF minv LT intchi THEN BEGIN
         intchi=minv
         xx=where(temp_intchi eq minv)
         nelxx=n_elements(xx)
         IF nelxx eq 1 THEN BEGIN
              restr=restr0
              restr.dist=str1[i1[i]].dist
              restr.chi1=str1[i1[i]].tchi[xx]
              restr.chi2=str2[i2[i]].tchi[xx]
              restr.intchi=minv
              restr.clouds=str1[i1[i]].clouds[xx,*]
              IF showim THEN BEGIN
                 sclouds=''
                 sdist1=strtrim(string(floor(restr.dist)),1)
                 ssp=strsplit(string(restr.dist),'.',/extract)
                 sdist2=strmid(ssp[1],0,2)
                 sdist=sdist1+'_'+sdist2
                 FOR k=0, 14 do sclouds=sclouds+strtrim(string(restr.clouds[k]),1)
                 ;PRINT, sclouds
                 print,'ds9 '+'/home/efeoztaban/ahmet_code/outputs3/'+sdist+'/'+sdist1+ $
                       '.'+sdist2+'_'+sclouds+'.fits '+strtrim(string(intchi,1))
              ENDIF
           ENDIF ELSE BEGIN
              restr=replicate(restr0,nelxx)
              FOR j=0,nelxx-1 DO BEGIN
                 restr[j].dist=str1[i1[i]].dist
                 restr[j].chi1=str1[i1[i]].tchi[xx[j]]
                 restr[j].chi2=str2[i2[i]].tchi[xx[j]]
                 restr[j].intchi=minv
                 restr[j].clouds=str1[i1[i]].clouds[xx[j],*]
              ENDFOR
           ENDELSE
        ;ENDIF
   ENDFOR
   
ENDIF ELSE print,'No intersection found in distances given in the structure'

END

