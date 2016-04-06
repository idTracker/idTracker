// 24-Jan-2013 15:53:47 Hago que funcione aunque sólo haya un mapa en las referencias
// 07-Jun-2011 15:04:33 Lo cambio para que admita varios frames en mapas (primer argumento). Abortado. De momento haré el bucle en matlab
// APE 31 may 11 

// (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas
        
#include "mex.h"
#include "stdio.h"
#include "math.h"

// double sumadora(double mapas[],double ind[])
// {
//     int c, ind_act;
//     for (c=0; c<10; c++){
//         ind_act=ind[c];
//       printf ("%i \n",ind_act);
// //       mapas_out[c]=ind[c];
//   }
//   return 1;
// }


void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  double *mapas, *mapas_ref, *indvalidos_restas, *indvalidos_sumas, *errores;
//   int mrows, ncols;
  int *tam, n_elems, n_framesref, n_indrestas, n_indsumas, c_refs, c_ind, ind_act, indval_act, anadido_ref;
  
  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    mexErrMsgTxt("4 inputs required.");
  } else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments");
  }

//  /* The input must be a noncomplex scalar double.*/
//   mrows = mxGetM(prhs[0]);
//  ncols = mxGetN(prhs[0]);
//  if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
//      !(mrows == 1 && ncols == 1)) {
//    mexErrMsgTxt("Input must be a noncomplex scalar double.");
//  }

  /* Create matrix for the return argument. */
  tam = mxGetDimensions(prhs[0]);
  n_elems=tam[0]*tam[1]*tam[2];  
  tam = mxGetDimensions(prhs[1]);
  n_framesref=tam[3];
  n_indrestas=mxGetM(prhs[2]);
  n_indsumas=mxGetM(prhs[3]);
  
  if (n_framesref==0 & n_elems>0){ // Esto hace falta porque cuando sólo hay un mapa el tamaño de la cuarta dimensión (tam[3]) da 0 en vez de 1.
      n_framesref=1;
  }
 
  
//   plhs[0] = mxDuplicateArray(prhs[0]);
//   printf ("%i \n",n_ind);
  

//   
//   /* Assign pointers to each input and output. */
  mapas = mxGetPr(prhs[0]);
  mapas_ref = mxGetPr(prhs[1]);
  indvalidos_restas = mxGetPr(prhs[2]);
  indvalidos_sumas = mxGetPr(prhs[3]);  
  
     
// 
  plhs[0] = mxCreateDoubleMatrix(2*n_framesref,1, mxREAL);
  

//   
  errores = mxGetPr(plhs[0]);
// printf("%i\n",n_framesref);
  for (c_refs=0; c_refs<n_framesref; c_refs++){
      ind_act=2*c_refs;
//       printf("%i\n",n_indrestas);
//       mexErrMsgTxt("caca");
      errores[ind_act]=0;
      anadido_ref=n_elems*c_refs;      
      for (c_ind=0; c_ind<n_indrestas; c_ind++){
//           printf(".");
          indval_act=indvalidos_restas[c_ind]-1;
          errores[ind_act] = errores[ind_act] + fabs(mapas[indval_act]-mapas_ref[anadido_ref+indval_act]);
//           printf("%lf;",fabs(mapas[indval_act]-mapas_ref[anadido_ref+indval_act]));
      }
//       mexErrMsgTxt("caca");
      ind_act=2*c_refs+1;
      errores[ind_act]=0;
      for (c_ind=0; c_ind<n_indsumas; c_ind++){
          indval_act=indvalidos_sumas[c_ind]-1;
          errores[ind_act] = errores[ind_act] + fabs(mapas[indval_act]-mapas_ref[anadido_ref+indval_act]);
      }
  }
}