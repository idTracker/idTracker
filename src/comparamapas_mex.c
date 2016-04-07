 #include "mex.h"
#include "stdio.h"
#include "math.h"



void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *mapas, *mapas_ref, *indvalidos_restas, *indvalidos_sumas, *errores;

  int *tam, n_elems, n_framesref, n_indrestas, n_indsumas, c_refs, c_ind, ind_act, indval_act, anadido_ref;
  
  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    mexErrMsgTxt("4 inputs required.");
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments");
  }



  /* Create matrix for the return argument. */
  tam = mxGetDimensions(prhs[0]);
  n_elems=tam[0]*tam[1]*tam[2];  
  tam = mxGetDimensions(prhs[1]);
  n_framesref=tam[3];
  n_indrestas=mxGetM(prhs[2]);
  n_indsumas=mxGetM(prhs[3]);
  
  if (n_framesref==0 & n_elems>0){ 
      n_framesref=1;
  }
 
  

  mapas = mxGetPr(prhs[0]);
  mapas_ref = mxGetPr(prhs[1]);
  indvalidos_restas = mxGetPr(prhs[2]);
  indvalidos_sumas = mxGetPr(prhs[3]);  
  
     

  plhs[0] = mxCreateDoubleMatrix(2*n_framesref,1, mxREAL);
  


  errores = mxGetPr(plhs[0]);

  for (c_refs=0; c_refs<n_framesref; c_refs++){
      ind_act=2*c_refs;
      errores[ind_act]=0;
      anadido_ref=n_elems*c_refs;      
      for (c_ind=0; c_ind<n_indrestas; c_ind++){

          indval_act=indvalidos_restas[c_ind]-1;
          errores[ind_act] = errores[ind_act] + fabs(mapas[indval_act]-mapas_ref[anadido_ref+indval_act]);

      }

      ind_act=2*c_refs+1;
      errores[ind_act]=0;
      for (c_ind=0; c_ind<n_indsumas; c_ind++){
          indval_act=indvalidos_sumas[c_ind]-1;
          errores[ind_act] = errores[ind_act] + fabs(mapas[indval_act]-mapas_ref[anadido_ref+indval_act]);
      }
  }
}
