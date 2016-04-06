#include "mex.h"
#include "stdio.h"




void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *tam_hist, *ind_fil, *ind_col, *intensrestas, *intenssumas, *distbin, *cerca, *mapas_out, *frame_act;
  int n_pixels, c1, c2, ind_act, indfil_dist, indcol_dist, dist_max, ind_dist, n_elemsrodaja, n_elems;
  
  /* Check for proper number of arguments. */
  if (nrhs != 7) {
    mexErrMsgTxt("7 inputs required.");
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments");
  }



  /* Create matrix for the return argument. */
  n_pixels = mxGetM(prhs[1]);
  dist_max = mxGetM(prhs[5])-1;
  
  
  
  
  /* Assign pointers to each input and output. */
  tam_hist = mxGetPr(prhs[0]);
  ind_fil = mxGetPr(prhs[1]);
  ind_col = mxGetPr(prhs[2]);
  intensrestas = mxGetPr(prhs[3]);
  intenssumas = mxGetPr(prhs[4]);  
  distbin = mxGetPr(prhs[5]);
  cerca = mxGetPr(prhs[6]);

  
  n_elemsrodaja=tam_hist[0]*tam_hist[1];
  n_elems=n_elemsrodaja*2;
  
  plhs[0] = mxCreateDoubleMatrix(n_elems,1, mxREAL);
  
  mapas_out = mxGetPr(plhs[0]);
  
  for (c1=0; c1<n_elems; c1++){
        mapas_out[c1]=0;
  }

  for (c1=0; c1<n_pixels; c1++){      
      for (c2=c1; c2<n_pixels; c2++){   
          indfil_dist=abs(ind_fil[c2]-ind_fil[c1]);
          indcol_dist=abs(ind_col[c2]-ind_col[c1]);
          if (indfil_dist<=dist_max && indcol_dist<=dist_max){
              ind_dist=indfil_dist+(dist_max+1)*indcol_dist;
              if (cerca[ind_dist]==1){                  
                  ind_act = floor(abs(intensrestas[c1]-intensrestas[c2])) + tam_hist[0]*(distbin[ind_dist]-1); 
                  mapas_out[ind_act]=mapas_out[ind_act]+1;
                  ind_act = n_elemsrodaja + floor(abs(intenssumas[c1]+intenssumas[c2])) + tam_hist[0]*(distbin[ind_dist]-1); 
                  mapas_out[ind_act]=mapas_out[ind_act]+1;
              }
          }
      }
  }


  
  /* Call the timestwo subroutine. */

}
