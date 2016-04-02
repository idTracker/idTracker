% 29-Apr-2014 10:23:39 Elimino encriptación
% 01-Jun-2013 11:19:57 Añado encriptación. Ya no salvo la variable
% progreso.
% 08-May-2013 19:10:32 Hago que errores_indiv se guarde también fuera de segm
% 10-Apr-2013 19:24:33 Arreglo un bug que hacía que fallase cuando había un segm completamente vacío
% 29-Nov-2012 15:19:47 Corrijo. Antes los frames en los que había n_peces manchas no pasaban a indiv.
% 29-Nov-2012 12:47:10 Integro con el panel
% 23-Nov-2012 15:07:40 Hago que calcule indiv, y que lo guarde automáticamente.
% 19-Sep-2012 11:37:22 Lo preparo para que refs_indiv esté vacío, que
% ocurrirá en vídeos de un sólo pez.
% 02-Nov-2011 11:10:56 Corrijo el save, que estaba dentro del if y no
% debería. Quito el aviso de fallo en el último archivo, porque debió ser
% por esto.
% 20-Oct-2011 10:22:24 Añado reutiliza. Corrijo errores.
% 17-Oct-2011 15:54:07 Hago que compare los mapas de muchos en muchos para
% aprovechar la paralelización. Además hago que reutilice cuando ya se han
% hecho las comparaciones antes.
% APE 06 oct 11

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function indiv=datosegm2segm_indiv(datosegm,refs_indiv,handles)

if nargin<3
    handles=[];
end

camposhandles={'ejes','waitIndividualization','textowaitIndividualization','Individualization'};
if compruebahandles(handles,camposhandles)
    title(handles.ejes,'Finding individuals...')
end

reutiliza=false;

mat_validos=datosegm.indvalidos;
indvalidos{1}=find(mat_validos(:,:,1));
mat_validos(:,:,1)=false;
indvalidos{2}=find(mat_validos);

n_archivos=size(datosegm.archivo2frame,1);
n_frames=size(datosegm.frame2archivo,1);
indiv=false(n_frames,max(datosegm.n_manchas)); % 0 significa que no hay mancha. Se confunde con false, pero da igual.
errores_indiv=NaN(size(indiv));
progreso=0;
for c_archivos=1:n_archivos
    if isempty(handles)
        fprintf('%g,',c_archivos)
    end
    load([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos)])
    segm=variable;
    if ~isfield(segm,'indiv')
        segm(1).indiv=[];
    end
    c_mapas=0;
    framemancha=NaN(1000,2);
    mapas=NaN([datosegm.tam_mapas length(segm)*datosegm.n_peces]);
    for c_frames=1:length(segm)
        progreso=progreso+1;
        if ~reutiliza || ~isfield(segm,'indiv') || isempty(segm(c_frames).indiv)
            if length(segm(c_frames).mapas)==datosegm.n_peces
                segm(c_frames).errores_indiv=NaN(1,datosegm.n_peces);
                segm(c_frames).indiv=true(1,datosegm.n_peces);
            elseif ~isempty(refs_indiv)
%                 segm(frame_arch).errores_indiv=NaN(1,datosegm.n_manchas(c
%                 _frames));
                for c_manchas=1:size(segm(c_frames).centros,1)
                    if ~isempty(segm(c_frames).mapas{c_manchas})
                        c_mapas=c_mapas+1;
                        framemancha(c_mapas,:)=[c_frames,c_manchas];
                        mapas(:,:,:,c_mapas)=segm(c_frames).mapas{c_manchas};
%                         [menores,errores_act]=comparamapas(segm(frame_arch).mapas{c_manchas},{refs_indiv},indvalidos);
%                         segm(frame_arch).errores_indiv(c_manchas)=sum(min(errores_act{1},[],2));
                    end
                end % c_manchas
%                 segm(frame_arch).indiv=segm(frame_arch).errores_indiv<datosegm.umbral_errorindiv;
            else
                segm(c_frames).indiv=false(1,size(segm(c_frames).centros,1));
                segm(c_frames).errores_indiv=NaN(1,datosegm.n_peces);
            end
        end % if no está ya calculado
    end % c_frames
    n_mapas=c_mapas;
    if n_mapas>0
        mapas=mapas(:,:,:,1:n_mapas);
        [menores,errores_act]=comparamapas(mapas,{refs_indiv},indvalidos);
        errores=sum(min(errores_act{1},[],2),3);        
        for c_mapas=1:n_mapas
            segm(framemancha(c_mapas,1)).errores_indiv(framemancha(c_mapas,2))=errores(c_mapas);
            segm(framemancha(c_mapas,1)).indiv(framemancha(c_mapas,2))=errores(c_mapas)<datosegm.umbral_errorindiv;
%             indiv(datosegm.archivo2frame(c_archivos,framemancha(c_mapas,1)),framemancha(c_mapas,2))=errores(c_mapas)<datosegm.umbral_errorindiv;
        end % c_mapas        
    end
    for c_frames=1:length(segm)
        n_manchas=length(segm(c_frames).indiv);
        if n_manchas>0
            frame_act=datosegm.archivo2frame(c_archivos,c_frames);
            indiv(frame_act,1:n_manchas)=segm(c_frames).indiv;
            errores_indiv(frame_act,1:n_manchas)=segm(c_frames).errores_indiv;
        end
    end
    variable=indiv;
    save([datosegm.directorio 'indiv.mat'],'variable')
    variable=segm;
    save([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos)],'variable')
    if compruebahandles(handles,camposhandles)        
        set(handles.ejes_tams,'YTick',[],'YLim',[0 1],'TickDir','out')
        set(handles.waitIndividualization,'XData',[0 0 c_archivos/n_archivos c_archivos/n_archivos])
        set(handles.textowaitIndividualization,'String',[num2str(round(c_archivos/n_archivos*100)) ' %'])
        drawnow
    end    
end % c_archivos

if compruebahandles(handles,camposhandles)
    title(handles.ejes,'')
end
