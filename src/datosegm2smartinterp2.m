% 29-Apr-2014 10:25:30 Elimino encriptación
% APE 25 feb 14 Viene de datosegm2smartinterp

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [mancha2pez,mancha2centro]=datosegm2smartinterp2(datosegm,h_panel)

if nargin<2
    h_panel=[];
end

if ~isempty(h_panel)
    set(h_panel.waitFillGaps,'XData',[0 0 .1 .1])
    set(h_panel.textowaitFillGaps,'String',[num2str(round(sum(.1)*100)) ' %'])
end


load([datosegm.directorio 'trozos.mat'])
trozos=variable.trozos;
load([datosegm.directorio 'npixelsyotros.mat'])
npixelsyotros=variable;
mancha2centro=npixelsyotros.mancha2centro;

if isempty(dir([datosegm.directorio 'mancha2pez_autocorr.mat']))
    % trozo2pez_anul=datosegm2anulainterpolables(datosegm);
    load([datosegm.directorio 'conectanconviven.mat'])
    load([datosegm.directorio 'mancha2pez.mat'])
    trozo2pez_orig=variable.trozo2pez;
    probtrozos_relac=variable.probtrozos_relac;
    trozo2pez_autocorr=buscasaltos(trozos,trozo2pez_orig,probtrozos_relac,mancha2centro,conviven);
    clear variable
    variable.mancha2pez=NaN(size(trozos));
    for c_trozos=1:length(trozo2pez_autocorr);
        variable.mancha2pez(trozos==c_trozos)=trozo2pez_autocorr(c_trozos);
    end
    variable.trozo2pez=trozo2pez_autocorr;
    variable.probtrozos_relac=probtrozos_relac;
    save([datosegm.directorio 'mancha2pez_autocorr.mat'],'variable')
end

if ~isempty(h_panel)
    set(h_panel.waitFillGaps,'XData',[0 0 .2 .2])
    set(h_panel.textowaitFillGaps,'String',[num2str(round(sum(.1)*100)) ' %'])
end

if 0 && ~isempty(dir([datosegm.directorio 'mancha2pez_nogaps.mat']))
    load([datosegm.directorio 'mancha2pez_nogaps.mat'])   
else
    load([datosegm.directorio 'mancha2pez_autocorr.mat'])
end
mancha2pez=variable.mancha2pez;

datosegm.max_bwdist=NaN(1,datosegm.n_peces);
mancha2pez_act=mancha2pez(:,1:size(trozos,2));
mancha2pez_act(~(trozos>0))=NaN;
for c_peces=1:datosegm.n_peces
    max_bwdist_act=npixelsyotros.max_bwdist(mancha2pez_act==c_peces);
    max_bwdist_act=max_bwdist_act(max_bwdist_act>0); % Esto solo hace falta cuando hay parte del vídeo sin centros actualizados
    datosegm.max_bwdist(c_peces)=median(max_bwdist_act);
    cosa_act=npixelsyotros.max_distacentro(mancha2pez_act==c_peces);
    cosa_act=cosa_act(cosa_act>0);
    datosegm.umbrales_maxdistacentro(c_peces)=median(cosa_act);
end

if isfield(variable,'mancha2centro')
    mancha2centro=variable.mancha2centro;
else
    load([datosegm.directorio 'npixelsyotros.mat'])
    mancha2centro=variable.mancha2centro;
end
if ~isfield(variable,'probtrozos_relac')
    load([datosegm.directorio 'mancha2pez_autocorr.mat'])
end
probtrozos_relac=variable.probtrozos_relac;
clear variable
load([datosegm.directorio 'conectanconviven'])
trayectorias=mancha2pez2trayectorias(datosegm,mancha2pez,trozos,[],mancha2centro);
[mancha2pez,mancha2centro,tiporefit]=smartinterp2(datosegm,trozos,trayectorias,mancha2pez,mancha2centro,solapan,h_panel);
clear variable
variable.mancha2pez=mancha2pez;
variable.mancha2centro=mancha2centro;
variable.trozo2pez=mancha2pez2trozo2pez(mancha2pez,trozos);
variable.probtrozos_relac=probtrozos_relac;
variable.tiporefit=tiporefit;
save([datosegm.directorio 'mancha2pez_nogaps.mat'],'variable')


