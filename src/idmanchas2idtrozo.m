% APE 24 feb 12 Viene de trozo2idtrozo

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [idtrozo,mat_id]=idmanchas2idtrozo(datosegm,ids,solapos)



% ind=find(trozos==trozo_act);
% solapos_act=solapos(ind);
% [frames,manchas]=ind2sub(size(trozos),ind);
% [frames,orden]=sort(frames);
% manchas=manchas(orden);
% solapos_act=solapos_act(orden);
nframes_act=length(ids);
solapos_max=floor(max(solapos)*10)/10+.5;
mat_id=sparse(nframes_act,solapos_max*10);
nvistos=zeros(1,solapos_max*10);
nposibles=nvistos;
% id_act=NaN(nframes_act,datosegm.n_peces);
for c_frames=1:nframes_act
    centro=floor(solapos(c_frames)*10);
    if ids(c_frames)>0
        try
            mat_id(c_frames,centro-4:centro+5)=ids(c_frames);
        catch
            keyboard
        end
        nvistos(centro-4:centro+5)=nvistos(centro-4:centro+5)+1;
    end    
end % c_frames

% Recuento
idtrozo=NaN(1,datosegm.n_peces);
buenos=nvistos>0;
for c_peces=1:datosegm.n_peces
    sumas=sum(mat_id==c_peces,1);
    idtrozo(c_peces)=sum(sumas(buenos)./nvistos(buenos))/10;
end % c_peces
% keyboard
% idtrozo=nansum(id_act==1,1); % Pongo el ==1 porque así no coge nada de información de los frames en los que los dos mapas no se pusieron de acuerdo.