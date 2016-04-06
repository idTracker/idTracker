// APE 30 may 11 Viene de sumaelementosplus2

// (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

#include "mex.h"
#include "stdio.h"

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
  double *tam_hist, *ind_fil, *ind_col, *intensrestas, *intenssumas, *distbin, *cerca, *mapas_out, *frame_act;
//   int mrows, ncols;
  int n_pixels, c1, c2, ind_act, indfil_dist, indcol_dist, dist_max, ind_dist, n_elemsrodaja, n_elems;
  
  /* Check for proper number of arguments. */
  if (nrhs != 7) {
    mexErrMsgTxt("7 inputs required.");
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
  n_pixels = mxGetM(prhs[1]);
  dist_max = mxGetM(prhs[5])-1;
  
//   plhs[0] = mxDuplicateArray(prhs[0]);
//   printf ("%i \n",n_ind);
  
  
  
  /* Assign pointers to each input and output. */
  tam_hist = mxGetPr(prhs[0]);
  ind_fil = mxGetPr(prhs[1]);
  ind_col = mxGetPr(prhs[2]);
  intensrestas = mxGetPr(prhs[3]);
  intenssumas = mxGetPr(prhs[4]);  
  distbin = mxGetPr(prhs[5]);
  cerca = mxGetPr(prhs[6]);
//   frame_act=mxGetPr(prhs[7]);
//   tam_hist1 = mxGetPr(prhs[7]);  
//   n_elemsrodaja = mxGetPr(prhs[8]);    
  
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
//               printf("%lf",cerca[ind_dist]);
//               mexErrMsgTxt("caca");
              if (cerca[ind_dist]==1){                  
                  ind_act = floor(abs(intensrestas[c1]-intensrestas[c2])) + tam_hist[0]*(distbin[ind_dist]-1); // Aquí está transformándose de double a int.
                  mapas_out[ind_act]=mapas_out[ind_act]+1;
                  ind_act = n_elemsrodaja + floor(abs(intenssumas[c1]+intenssumas[c2])) + tam_hist[0]*(distbin[ind_dist]-1); // Aquí está transformándose de double a int. El -1 es porque en C los índices empiezan en 0
                  mapas_out[ind_act]=mapas_out[ind_act]+1;
              }
          }
      }
  }

//   for (c=0; c<n_ind; c++){
//           
// //       printf ("%i \n",ind_act);
// //       mapas_out[c]=ind[c];
//   }
  
  
//   ind_int = ind;
//   printf ("%i \n\n",ind_int);
  
//   for (c=0; c<10; c++){
//       printf ("%lf \n",ind[c]);
// //       mapas_out[c]=ind[c];
//   }
  
  /* Call the timestwo subroutine. */
//   mapas_out[0] = sumadora(mapas,ind);
}