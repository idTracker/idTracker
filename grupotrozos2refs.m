% 29-Apr-2014 10:39:25 Elimina encriptación
% 03-Sep-2013 19:33:04 Hago que si no existe el campo "encrypt", lea los archivos como antes
% 01-Jun-2013 11:27:20 Añado encriptación
% 07-Dec-2012 13:32:09 Evito que prealoque demasiada memoria
% APE 27 jul 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

%% Función que extrae mapas de referencias de un trozo determinado
function [referencias,framesescogidos]=grupotrozos2refs(datosegm,trozos,intervalosbuenos,grupo_act)

manchas_act=false(size(trozos));
tams=NaN(1,length(grupo_act));
c=0;
for c_trozos=grupo_act
    c=c+1;
    buenas=trozos==c_trozos & intervalosbuenos.manchasbuenas;
    tams(c)=sum(buenas(:));
    manchas_act(buenas)=true;
end
listaframes=find(any(manchas_act,2));
referencias=cell(1,datosegm.n_peces);
framesescogidos=cell(1,datosegm.n_peces);
tam_mapa=datosegm.tam_mapas;
for c_peces=1:datosegm.n_peces % Prealoco
    referencias{c_peces}=NaN(tam_mapa(1),tam_mapa(2),tam_mapa(3),tams(c_peces));
    framesescogidos{c_peces}=NaN(tams(c_peces),2);
end % c_peces
n_trozos=max(trozos(:));
trozo2pez=NaN(1,n_trozos);
for c_peces=1:datosegm.n_peces
    trozo2pez(grupo_act(c_peces))=c_peces;
end % c_peces
cframes_refs=zeros(1,datosegm.n_peces);
archivo_act=0;
for c_frames=listaframes(:)'
%     fprintf('%g,',c_frames)
    if datosegm.frame2archivo(c_frames,1)~=archivo_act
        clear segm
        archivo_act=datosegm.frame2archivo(c_frames,1);
        if isfield(datosegm,'encriptar')
            load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
            segm=variable;
        else
            load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
        end
    end
    frame_arch=datosegm.frame2archivo(c_frames,2);
    for c_manchas=find(manchas_act(c_frames,:))
        pez_act=trozo2pez(trozos(c_frames,c_manchas));
        cframes_refs(pez_act)=cframes_refs(pez_act)+1;
        referencias{pez_act}(:,:,:,cframes_refs(pez_act))=segm(frame_arch).mapas{c_manchas};
        framesescogidos{pez_act}(cframes_refs(pez_act),1:2)=[c_frames c_manchas];
    end % c_manchas    
end % c_frames
% % Recorto
% for c_peces=1:datosegm.n_peces
%     referencias{c_peces}=referencias{c_peces}(:,:,:,1:cframes_refs(c_peces));
%     framesescogidos{c_peces}=framesescogidos{c_peces}(1:cframes_refs(c_peces),:);
% end % c_peces