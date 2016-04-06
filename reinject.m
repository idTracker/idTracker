
load('segm/datosegm.mat')
datosegm=variable;
load('segm/mancha2pez.mat')
man2pez=variable;
interval=[1 900];
load('segm/trozos.mat')
trozos=variable.trozos;
solapos=variable.solapos;
load('segm/npixelsyotros.mat')
segmbuena=variable.segmbuena;
borde=variable.borde;
load('segm/indiv.mat')
indiv=variable;
intervalosbuenos=datosegm2intervalosbuenos(datosegm,trozos,solapos,indiv,segmbuena,borde,datosegm.primerframe_intervalosbuenos,1);
variable=intervalosbuenos;
save segm/intervalosbuenos.mat variable;
refs=datosegm2referencias_manual(datosegm,man2pez,[1 82852]);
variable=refs
save segm/referencias.mat variable
