
load('segm/datosegm.mat')
datosegm=variable;
%load('segm/mancha2pez.mat')
load('segm/mancha2pez_manual.mat')
man2pez=variable;
%interval=[1 900];
load('segm/trozos.mat')
trozos=variable.trozos;
solapos=variable.solapos;
load('segm/npixelsyotros.mat')
segmbuena=variable.segmbuena;
borde=variable.borde;
load('segm/indiv.mat')
indiv=variable;
%%
intervalosbuenos=datosegm2intervalosbuenos_manual(datosegm,trozos,solapos,indiv,segmbuena,borde,datosegm.primerframe_intervalosbuenos,1);
%%
variable=intervalosbuenos;
save segm/intervalosbuenos.mat variable;
load('segm/intervalosbuenos.mat')
load('segm/datosegm.mat')
datosegm=variable;
%load('segm/mancha2pez.mat')
load('segm/mancha2pez_manual.mat')
man2pez=variable;
refs=datosegm2referencias_manual(datosegm,man2pez,[1 108806]);
refs=datosegm2referencias_manual(datosegm,man2pez,[1 10000]);
variable=refs;
save segm/referencias.mat variable
%%
load('segm/datosegm.mat')
datosegm=variable;
load('segm/trozos.mat')
trozos=variable.trozos;
solapos=variable.solapos;
load('segm/mancha2pez_manual.mat')
man2pez=variable;
mancha2id=man2pez.mancha2pez;
idtrozos=mancha2id2idtrozos(datosegm,trozos,solapos,mancha2id);
probtrozos=idtrozos2probtrozos(idtrozos);
for(c_trozos=1:size(idtrozos,1))
    %idtrozos(c_trozos,:)
    %probtrozos(c_trozos,:)
    %sum(probtrozos(c_trozos,:))
    if( sum(idtrozos(c_trozos,:)>0)==1)
        temp=idtrozos(c_trozos,:);
        temp(temp==0)=NaN;
        temp(temp>0)=1.00000;
        probtrozos(c_trozos,:)=temp;
    end
end
%%
load('segm/datosegm.mat')
datosegm=variable;
load('segm/trozos.mat')
trozos=variable.trozos;
solapos=variable.solapos;
load('segm/idtrozos.mat')
probtrozos=variable.probtrozos;
if(isfield(datosegm,'manualreferences'))
    prob_corrected=prob_manual_correction(datosegm,trozos,solapos,probtrozos);
end
load([datosegm.directorio 'conectanconviven.mat'])%Daniel, checking here
[mancha2pez,trozo2pez,probtrozos_relac]=probtrozos2identidades(trozos,probtrozos,conviven)
%% counter!!

load('segm/intervalosbuenos.mat')
intervalosbuenos=variable;
load('segm/datosegm.mat')
datosegm=variable;
%load('segm/mancha2pez.mat')
load('segm/mancha2pez_manual.mat')
man2pez=variable;
ref

