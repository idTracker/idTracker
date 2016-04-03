% 23-Dec-2013 22:02:12 Añado dist_max
% 24-Apr-2013 18:31:28 Hago que si se puede el mapa se guarde en uint16 o uint32, lo que haga falta
% 13-Oct-2011 17:20:41 Cambio for a parfor, y añado que tenga en cuenta
% segmbuena.
% 15-Aug-2011 18:49:06 Añado la posibilidad de meter el umbral manualmente
% 10-Aug-2011 16:45:21 Cambio el umbral a .85 para ser consistente con
% avi2miniframes
% 15-Jun-2011 14:13:11 Añado reduceresol
% APE 14 jun 11 Viene de segm2segm_mapas

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function segm=segm2segm_mapas_general(segm,reduceresol,umbral,dist_max)

if nargin<2 
    reduceresol=[];
end
if nargin<3 || isempty(umbral)
    umbral=.85;
end
if nargin<4
    dist_max=[];
end

n_frames=length(segm);
segm(n_frames).mapas=cell(0);
parfor c_frames=1:n_frames
%     fprintf('%g,',c_frames)
    segm(c_frames).mapas=cell(1,length(segm(c_frames).pixels));
    for c_peces=1:size(segm(c_frames).centros,1);
        if segm(c_frames).segmbuena(c_peces)
            segm(c_frames).mapas{c_peces}=frame2mapas(segm(c_frames).miniframes{c_peces},segm(c_frames).intensmed,umbral,reduceresol,dist_max);
            if max(segm(c_frames).mapas{c_peces}(:))<intmax('uint16')
                segm(c_frames).mapas{c_peces}=uint16(segm(c_frames).mapas{c_peces});
            elseif max(segm(c_frames).mapas{c_peces}(:))<intmax('uint32')
                segm(c_frames).mapas{c_peces}=uint32(segm(c_frames).mapas{c_peces});
            end
        else
            segm(c_frames).mapas{c_peces}=[];
        end
    end
end