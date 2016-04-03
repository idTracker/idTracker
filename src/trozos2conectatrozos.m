% 15-Dec-2013 16:12:12
% 15-Mar-2012 11:56:03 Corrijo un bug en el cálculo de solapan
% 13-Mar-2012 20:41:01 Añado solapan
% APE 10 feb 2012

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% conectan se hace con el criterio de que un trozo acabe y otro empiece
% poco después.
% solapan se hace con el criterio más estricto de que la última mancha del
% trozo saliente solape con la primera del entrante.

function [conectan,conviven,solapan]=trozos2conectatrozos(trozos,solapamiento)

margen_frames=3; % Número de frames de margen para pillar bichos que desaparezcan, o que se hayan unido momentáneamente a otros
n_trozos=max(trozos(:));
% try
conectan=sparse(false); conectan(n_trozos,n_trozos)=false; % Es mejor hacerlo así para que no se vaya de memo
% catch
%     keyboard
% end
conviven=conectan;
solapan=conectan;
n_frames=size(trozos,1);
inicios=NaN(1,n_trozos);
finales=NaN(1,n_trozos);
inicios(trozos(1,trozos(1,:)>0))=1;
activos=false(1,n_trozos);
activos(trozos(1,trozos(1,:)>0))=true;
for c_frames=1:n_frames
    trozos_act=trozos(c_frames,trozos(c_frames,:)>0);
    conviven(trozos_act,trozos_act)=true;
    actuales=false(1,n_trozos);
    actuales(trozos_act)=true;
    nuevos=~activos & actuales;
    viejos=activos & ~actuales;
    inicios(nuevos)=c_frames;
    if c_frames>1
        finales(viejos)=c_frames-1;
    end
    activos(:)=false;
    activos(trozos_act)=true;
    if mod(c_frames,1000)==0
        fprintf('%g,',c_frames)
    end
end % c_frames
finales(activos)=n_frames;

fprintf('\n')
for c_trozos=1:n_trozos
    conectan(c_trozos,inicios>finales(c_trozos) & inicios<finales(c_trozos)+margen_frames)=true;
    % Solapan por delante
    if inicios(c_trozos)>1
        mancha_act=trozos(inicios(c_trozos),:)==c_trozos;
        manchas_solapan=solapamiento{inicios(c_trozos)-1}(:,mancha_act)>0;
        trozos_solapan=trozos(inicios(c_trozos)-1,manchas_solapan);
        solapan(c_trozos,trozos_solapan)=true;
    end
    % Solapan por detrás
    if finales(c_trozos)<n_frames && any(trozos(finales(c_trozos)+1,:)>0)
        mancha_act=trozos(finales(c_trozos),:)==c_trozos;
        manchas_solapan=solapamiento{finales(c_trozos)}(mancha_act,:)>0;
        trozos_solapan=trozos(finales(c_trozos)+1,manchas_solapan);
        try
        solapan(c_trozos,trozos_solapan)=true;
        catch
            keyboard
        end
        if mod(c_trozos,100)==0
            fprintf('%g,',c_trozos)
        end
    end
end % c_trozos
fprintf('\n')
conectan=conectan | conectan';