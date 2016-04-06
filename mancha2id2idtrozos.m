% 15-Mar-2012 10:02:22 Añado mancha2borde, que sólo debe usarse para
% arreglar fallos de programas anteriores
% APE 24 feb 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% El uso de mancha2borde no debería ser necesario en general. Sólo sirve
% para los casos en los que avi2segm se haya ejecutado antes del fix del 14
% de marzo de 2012.

function idtrozos=mancha2id2idtrozos(datosegm,trozos,solapos,mancha2id,mancha2borde)

if nargin<5 || isempty(mancha2borde)
    mancha2borde=false(size(trozos));
end

n_trozos=max(trozos(:));
% n_frames=size(datosegm.frame2archivo,1);
idtrozos=NaN(n_trozos,datosegm.n_peces);
for c_trozos=1:n_trozos
    ind=find(trozos==c_trozos & ~mancha2borde);
    if ~isempty(ind)
        try
        [idtrozos(c_trozos,:),mat_id]=idmanchas2idtrozo(datosegm,mancha2id(ind),solapos(ind));
        catch
            keyboard
        end
    end
end % c_trozos

% % disp('GUARNING!! TAL Y COMO ESTÁ, JAMÁS CALCULA NUEVAS IDENTIFICACIONES!!')
% while ~isempty(trozosquedan) %&& trozostotales-length(trozosquedan)<800 % HAY QUE QUITAR ESTE LÍMITE DE TROZOS   
%     length(trozosquedan)
%     c_trozos=0;
%     c_mapas=0;
%     n_mapasporvuelta=500;
%     archivoframemancha=NaN(n_mapasporvuelta,3);
%     mapas_act=NaN([datosegm.tam_mapas n_mapasporvuelta]);
% %     if length(trozosquedan)==trozosquedan_ant
% %         keyboard
% %     end
%     trozosquedan_ant=length(trozosquedan);
%     while c_mapas<n_mapasporvuelta && c_trozos<length(trozosquedan)% && trozostotales-length(trozosquedan)<50 % HAY QUE QUITAR ESTE LÍMITE DE TROZOS % Acumula 1000 mapas para aprovechar la paralelización de comparamapas
% %          trozostotales-length(trozosquedan)
%         c_trozos=c_trozos+1;
%         saltatrozo=false;
%         trozo_act=trozosquedan(c_trozos);
%         ind=find(trozos==trozo_act);
%         solapos_act=solapos(ind);
%         [frames,manchas]=ind2sub(tam_trozos,ind);
%         [frames,orden]=sort(frames);
%         manchas=manchas(orden);
%         solapos_act=solapos_act(orden);
%         nframes_act=length(ind);
%         % Si el trozo tiene más de 1000 frames, usa los primeros 1000. Que
%         % ya está bien, y si no va a necesitar cargar demasiados segm a la
%         % vez.
%         if nframes_act>1000
%             nframes_act=1000;
%             frames=frames(1:1000);
%             manchas=manchas(1:1000);
%             solapos_act=solapos_act(1:1000);
%         end
%         archivosabiertos_act=archivosabiertos;
%         archivosabiertos_act(datosegm.frame2archivo(frames(1:nframes_act),1))=1;
% %         trozosquedan(1:10)
%         
%             % Encuentra los candidatos a
%             % identificaciones
%             buenos=false(1,nframes_act);
%             cogidos=buenos;
%             bienid=cogidos;
%             %         imagesc(trozos)
%             %         drawnow
%             for c_frames=1:nframes_act
%                 archivo_act=datosegm.frame2archivo(frames(c_frames),1);
%                 frame_arch=datosegm.frame2archivo(frames(c_frames),2);
%                 if isempty(segmc{archivo_act}) 
%                     if sum(archivosabiertos_act)<8
%                     fprintf('(%g),',archivo_act)
%                     load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)],'segm')
%                     archivosabiertos(archivo_act)=1;
%                     segmc{archivo_act}=segm;
%                     clear segm
%                     % Guardamos una copia de seguridad de idtrozos
%                     save([datosegm.directorio 'idtrozos_seguridad'],'idtrozos')
%                     else
%                         saltatrozo=true;
% %                         trozo_act
%                     end
%                 end
%                 if ~saltatrozo
%                     if ~isfield(segmc{archivo_act},'identificado') || isempty(segmc{archivo_act}(frame_arch).identificado)
%                         segmc{archivo_act}(frame_arch).identificado=false(1,length(segmc{archivo_act}(frame_arch).pixels));
%                     end
%                     %                 segmc{archivo_act}(frame_arch).segmbuena(manchas(c_frames)) && segmc{archivo_act}(frame_arch).indiv(manchas(c_frames)) && ~segmc{archivo_act}(frame_arch).identificado(manchas(c_frames)) && (~quitaborde || ~segmc{archivo_act}(frame_arch).borde(manchas(c_frames)))
%                     buenos(c_frames)=segmc{archivo_act}(frame_arch).segmbuena(manchas(c_frames)) && segmc{archivo_act}(frame_arch).indiv(manchas(c_frames)) && (~quitaborde || ~segmc{archivo_act}(frame_arch).borde(manchas(c_frames)));
%                     cogidos(c_frames)=segmc{archivo_act}(frame_arch).identificado(manchas(c_frames));
%                     bienid(c_frames) = cogidos(c_frames) && sum(segmc{archivo_act}(frame_arch).id(manchas(c_frames),:)>0)==1; % Significa que los dos mapas se pusieron de acuerdo.
%                 end % if no hay que saltar el trozo
%             end % c_frames
%             if ~saltatrozo
%                 quedanbuenos=find(buenos & ~cogidos);
%                 n_quedanbuenos=length(quedanbuenos);
%                 buenos=find(buenos);
%                 %             n_buenos=length(buenos);
%                 % Hace la identificación del trozo con las identificaciones que
%                 % estuvieran hechas de antes.
% %                 if trozo_act==203
% %                     keyboard
% %                 end
%                 [idtrozos(trozo_act,:),nvistos,nposibles,mat_id]=trozo2idtrozo(datosegm,segmc,trozos,solapos,trozo_act,quitaborde);
% %                 if trozo_act==141
% %                     clf
% %                     subplot(1,2,1)
% %                     imagesc(mat_id)
% %                     subplot(1,2,2)
% %                     plot(nvistos)
% %                     hold on
% %                     plot(nposibles,'r')
% %                     keyboard
% %                 end
%                 % Comprueba si el trozo está bien identificado (o todo lo bien que
%                 % se puede)
%                 id_sort=sort(idtrozos(trozo_act,:),'descend');
%                 if ~any(nvistos<maxvistos & nposibles>0) || id_sort(1)-id_sort(2)>=difminima 
%                     [m,pez_act]=max(idtrozos(trozo_act,:));
%                     mancha2pez(trozos==trozo_act)=pez_act;
%                     %                 imagesc(mancha2pez')
%                     %                 drawnow
%                     trozos(trozos==trozo_act)=0;
%                     trozosquedan(trozosquedan==trozo_act)=[];
%                     c_trozos=c_trozos-1; % Hay que hacer esto porque hemos eliminado un elemento de trozosquedan
%                     % Va guardando y borrando los archivos que ya no serán necesarios
%                     frameescoba=find(sum(trozos,2)~=0,1,'first');
%                     archivoescoba=datosegm.frame2archivo(frameescoba,1);
%                     for c_archivos=1:archivoescoba-1
%                         if ~isempty(segmc{c_archivos})
%                             fprintf('[%g]',c_archivos)
%                             segm=segmc{c_archivos};
%                             save([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos)],'segm','-v6')
%                             segmc{c_archivos}=[];
%                             archivosabiertos(c_archivos)=0;
%                         end
%                     end
%                 else
%                     % Si no está bien identificado, coge los mapas para
%                     % identificarlo
%                     %                 if n_buenos>nframes_min
%                     quedan(trozo_act)=true;
%                     if max(solapos_act)>difminima % Si hay posibilidad de hacerlo bien, coge un cierto número de frames
%                         indices=equiesprand_solapos(min([n_quedanbuenos nframes_min]),solapos_act(buenos),cogidos(buenos),bienid(buenos));
%                     else % Si no hay esperanza de hacerlo bien, coge los necesarios para superar el umbral
%                         indices=equiesprand_solapos(-maxvistos,solapos_act(buenos),cogidos(buenos),bienid(buenos));
%                         %                     trozo_act
%                         %                     indices
%                         %                     pause
%                         %                     keyboard
%                     end                   
% %                     if trozo_act==38
% %                         indices
% %                     end
%                     %                 indices=equiespaciados_solapos(min([n_quedanbuenos nframes_min]),solapos_act(buenos),cogidos(buenos));
%                     indices=buenos(indices); % Para volver a ponerlo referido al trozo entero
%                     n_indices=length(indices);
%                     %                 indices=equiespaciados(min([n_buenos nframes_min]),n_buenos);
%                     %                 buenos=buenos(indices);
%                     %                 n_buenos=length(buenos);
%                     %                 end
%                     % Va acumulando mapas para calcular los errores. Lo hago así para aprovechar
%                     % la paralelización de comparamapas.
%                     for c_indices=1:n_indices
%                         archivo_act=datosegm.frame2archivo(frames(indices(c_indices)),1);
%                         frame_arch=datosegm.frame2archivo(frames(indices(c_indices)),2);
%                         c_mapas=c_mapas+1;
%                         archivoframemancha(c_mapas,:)=[archivo_act frame_arch manchas(indices(c_indices))];
%                         mapas_act(:,:,:,c_mapas)=segmc{archivo_act}(frame_arch).mapas{manchas(indices(c_indices))};
%                     end % c_frames
%                 end % if no hay que volver sobre el trozo
%             end % if no hay que saltar el trozo
% %             if saltatrozo
% %                 trozo_act
% %                 pause
% %             end
% %         end % if no hay que irse muy lejos
%     end % while no llegamos a 1000 manchas
%     mapas_act=mapas_act(:,:,:,1:c_mapas);
%     archivoframemancha=archivoframemancha(1:c_mapas,:);
% %     fprintf('Comparando...')
% c_mapas
%     menores=comparamapas(mapas_act,referencias,indvalidos);
%     ultimotrozo=c_trozos;   
% %     fprintf('Hecho.\n')
% %     trozosquedan(1:10)
%     % Hace las identificaciones para cada frame, y vuelve a meter la información en segm
%     for c_mapas=1:size(mapas_act,4)
%         arch=archivoframemancha(c_mapas,1);
%         fr=archivoframemancha(c_mapas,2);
%         manch=archivoframemancha(c_mapas,3);
%         if ~isfield(segmc{arch},'menores') || isempty(segmc{arch}(fr).menores)
%             segmc{arch}(fr).menores=cell(1,length(segmc{arch}(fr).pixels));
%         end
%         if ~isfield(segmc{arch},'id') || isempty(segmc{arch}(fr).id)
%             segmc{arch}(fr).id=zeros(length(segmc{arch}(fr).pixels),datosegm.n_peces);
%         end
%         menores_act=squeeze(menores(c_mapas,:,:));
%         segmc{arch}(fr).menores{manch}=menores_act;
%         [m,ind]=min(menores_act,[],2);
%         for c=1:2
% %             try                
%             segmc{arch}(fr).id(manch,ind(c))=segmc{arch}(fr).id(manch,ind(c))+.5; % Así quedará un 1 en los que los dos mapas se pongan de acuerdo, y 0.5 si no se ponen de acuerdo
% %             catch
% %                 keyboard
% %             end
%         end
%         segmc{arch}(fr).identificado(manch)=true;
%     end % c_mapas        
% end % while quedan trozos