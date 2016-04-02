% 01-Feb-2014 16:19:30 Arreglo un bug que hacía que probtrayectorias
% saliera mal
% 20-Jan-2014 17:15:35 Hago que vaya más rápido. Ahora necesita
% mancha2centro siempre
% 06-Sep-2013 10:45:54 Hago que pueda funcionar con vídeos pre-encriptación
% 15-Jul-2013 13:06:53 Hago que use mancha2centro
% 13-Mar-2012 15:03:41 Añado el cálculo de probtrayectorias
% APE 7 oct 11

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [trayectorias,probtrayectorias]=mancha2pez2trayectorias(datosegm,mancha2pez,trozos,probtrozos_relac,mancha2centro)

n_frames=size(mancha2centro,1);
trayectorias=NaN(n_frames,datosegm.n_peces,2); 
probtrayectorias=NaN(n_frames,datosegm.n_peces);
x=mancha2centro(:,:,1);
y=mancha2centro(:,:,2);
for c_peces=1:datosegm.n_peces
    ind=find(mancha2pez==c_peces);
    [frame,mancha]=ind2sub(size(mancha2pez),ind);
    trayectorias(frame,c_peces,1)=x(ind);
    trayectorias(frame,c_peces,2)=y(ind);
    if nargout>=2 && ~isempty(probtrozos_relac)
        if size(trozos,2)<=size(mancha2pez,2) % Por si la interpolación ha hecho crecer mancha2pez
            trozos(1,size(mancha2pez,2))=0;
        end
        ind=find(mancha2pez==c_peces & trozos>0);
        [frame,mancha]=ind2sub(size(mancha2pez),ind);
        probtrayectorias(frame,c_peces)=probtrozos_relac(trozos(ind),c_peces);
    end
end % c_peces
