% 29-Apr-2014 10:35:20 Elimino encriptación
% 21-Dec-2013 19:36:20 Hago que no guarde nada en segm, para ahorrarme
% salvarlo cada segm. ATENCIÓN: AHORA menores NO SE GUARDA EN NINGÚN SITIO,
% NI TAMPOCO LAS MATRICES id
% 20-Dec-2013 15:19:19 Hago que por defecto no guarde menores_cell. Además
% hago que no tenga que cargar segm para saber qué frames están ya
% identificados
% 18-Dec-2013 14:47:24 Meto el número máximo de frames por trozo
% 05-Sep-2013 21:29:32 Hago que pueda funcionar con vídeos anteriores a la
% encriptación
% 01-Jun-2013 11:35:57 Añado encriptación
% 08-May-2013 19:01:20 Hago que guarde en un archivo fuera de segm menores e id
% 23-Apr-2013 12:50:25 Voy a volver a meter el sistema de ahorro de tiempo no identificando todos los frames en trozos largos. Pero como puede ser un infierno, 
% lo hago en trozos2mancha2id_ahorratiempo
% 19-Sep-2012 11:40:35 Hago que no realice comparaciones en vídeos de un
% solo pez.
% 08-May-2012 20:48:04 Corrijo para que no falle cuando sólo haya un pez.
% Es un parche muy cutre, debería hacerlo mejor para que no haga cálculos a
% lo bobo.
% 07-Mar-2012 17:57:14 Arreglo bugs que había arreglado en el ordenador de
% Robert.
% APE 24 feb 12 Viene de trozos2id_trozos

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% ATENCIÓN: AHORA NI menores NI LAS MATRICES id SE GUARDAN EN NINGÚN SITIO.
% EN SU DÍA VALÍAN
% PARA ESTIMAR LA PROBABILIDAD DE LAS ASIGNACIONES. AHORA NO LOS USO, PERO
% PODRÍAN SER ÚTILES EN ALGÚN MOMENTO.

function mancha2id=trozos2mancha2id(datosegm,trozos,solapos,indvalidos,referencias,difminima,quitaborde,h_panel)

if nargin<6 || isempty(difminima)
    difminima=20; % Es el mínimo número de frames independientes que tiene que haber entre el ganador y el segundo para considerar que la identificación es segura.
end

if nargin<7 || isempty(quitaborde)
    quitaborde=false;
end
if nargin<8
    h_panel=[];
end

if ~isempty(h_panel)
    set(h_panel.waitIdentification,'XData',[0 0 .01 .01])
    set(h_panel.textowaitIdentification,'String',[num2str(round(.01*100)) ' %'])
end

% Carga resultados de pasadas anteriores
if ~isempty(dir([datosegm.directorio 'mancha2id.mat']))
    load([datosegm.directorio 'mancha2id.mat'])
    identificaciones=variable;
    mancha2id=identificaciones.mancha2id;
    if isfield(identificaciones,'identificados')
        identificados=identificaciones.identificados;
    else
        identificados=mancha2id>0;
    end
    clear identificaciones
else
    mancha2id=zeros(size(trozos));
    identificados=false(size(trozos));
end

n_trozos=max(trozos(:));
% Selecciona los frames de cada trozo que identificará
if ~isfield(datosegm,'max_framesportrozo') || isempty(datosegm.max_framesportrozo)
    datosegm.max_framesportrozo=Inf;
end
load([datosegm.directorio 'npixelsyotros.mat']);
npixelsyotros=variable;
load([datosegm.directorio 'indiv.mat'])
indiv=variable;
identificables=npixelsyotros.segmbuena & indiv & (~quitaborde | ~npixelsyotros.borde);
for c_trozos=1:n_trozos
    ind=find(trozos==c_trozos);
    if length(ind)>=datosegm.max_framesportrozo
        [frame,mancha]=ind2sub(size(trozos),ind);
        [frame,orden]=sort(frame);
        ind=ind(orden);
        n_puestos=0;
        solapos_ultimo=-Inf;
        solapos_max=max(solapos(ind));
        for c_frames=1:length(frame)
            margen_solapos=(solapos_max-solapos(ind(c_frames)))/(datosegm.max_framesportrozo-n_puestos); % Recalculo el margen cada vez
            if solapos(ind(c_frames))-solapos_ultimo<margen_solapos
                identificables(ind(c_frames))=false;
            elseif identificables(ind(c_frames))
                n_puestos=n_puestos+1;
                solapos_ultimo=solapos(ind(c_frames));
            end
        end % c_frames
    end % if hay que identificarlos todos
end % c_trozos

maxvistos=8;

nframes_min=difminima;


tam_trozos=size(trozos);
idtrozos=NaN(n_trozos,datosegm.n_peces);
n_archivos=size(datosegm.archivo2frame,1);
segmc=cell(1,n_archivos);
trozosquedan=1:n_trozos;
quedan=true(1,n_trozos);
mancha2pez=NaN(size(trozos));
archivoescoba=1;
archivo_act=0;
archivosabiertos=false(1,n_archivos);
c_trozos=0;
trozostotales=length(trozosquedan);
trozosquedan_ant=trozostotales;
n_frames=size(datosegm.frame2archivo,1);
menores_cell=cell(size(trozos,1),1);
id_cell=cell(size(trozos,1),1);
% Si sólo hay un pez, evito que haga las comparaciones
if datosegm.n_peces==1
    vueltas=2;
else
    vueltas=[1 2];
end
for c_archivos=1:n_archivos
    fprintf('%g,',c_archivos)
    archivoabierto=false;
    nframes_act=sum(datosegm.archivo2frame(c_archivos,:)>0);
    mapas_act=NaN([datosegm.tam_mapas 2 nframes_act*datosegm.n_peces]); 
    faltanporidentificar=identificables & ~identificados;
    for c_vueltas=vueltas % En la primera vuelta acumula los mapas, y en la segunda mete los resultados de vuelta en segm
        c_mapas=0;
        for c_frames=1:nframes_act
            for c_manchas=find(faltanporidentificar(datosegm.archivo2frame(c_archivos,c_frames),:));
                %                 if identificables(datosegm.archivo2frame(c_archivos,c_frames),c_manchas) && ~identificados(datosegm.archivo2frame(c_archivos,c_frames),c_manchas)
                if ~archivoabierto % Lo abro aquí dentro para que sólo se abra si hace falta.
                    if isfield(datosegm,'encriptar')
                        load([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos)])
                        segm=variable;
                    else
                        load([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos)]);
                    end
                    if ~isfield(segm,'identificado') % Mantengo esto para que funcione el código más adelante, pero no se guardará (porque no guardo segm)
                        segm(1).identificado=[];
                    end
                    archivoabierto=true;
                end
                c_mapas=c_mapas+1;
                if c_vueltas==1 % La primera vuelta acumula mapas
                    mapas_act(:,:,:,c_mapas)=segm(c_frames).mapas{c_manchas};
                else % La segunda vuelta mete los resultados en segm y mancha2id
%                     if ~isfield(segm,'menores') || isempty(segm(c_frames).menores)
%                         segm(c_frames).menores=cell(1,length(segm(c_frames).mapas));
%                     end
                    if ~isfield(segm,'id') || isempty(segm(c_frames).id) % Mantengo esto para que funcione el código más adelante, pero no se guardará (porque no guardo segm)
                        segm(c_frames).id=zeros(length(segm(c_frames).mapas),datosegm.n_peces);
                    end
                    if datosegm.n_peces>1
                        menores_act=squeeze(menores(c_mapas,:,:)); % Cuando hay un solo pez, aquí las dimensiones no quedan como deben.
%                         segm(c_frames).menores{c_manchas}=menores_act;
                        [m,ind]=min(menores_act,[],2);
                    else
                        ind=ones(1,2);
                    end
                    segm(c_frames).id(c_manchas,:)=zeros(1,datosegm.n_peces);
                    for c=1:2
                        segm(c_frames).id(c_manchas,ind(c))=segm(c_frames).id(c_manchas,ind(c))+.5; % Así quedará un 1 en los que los dos mapas se pongan de acuerdo, y 0.5 si no se ponen de acuerdo
                    end
                    segm(c_frames).identificado(c_manchas)=true; % Mantengo esto para que funcione el código más adelante, pero no se guardará (porque no guardo segm)
                end % if primera vuelta
                % Ahora mete los resultados en mancha2id.
                if c_vueltas==2 && length(segm(c_frames).identificado)>=c_manchas && segm(c_frames).identificado(c_manchas)
                    ind=find(segm(c_frames).id(c_manchas,:)>0); % Lo suyo sería un ==1, pero lo dejo así de momento por compatibilidad con una versión que tenía un bug y ponía doses y treses.
                    if length(ind)==1
                        mancha2id(datosegm.archivo2frame(c_archivos,c_frames),c_manchas)=ind;
                    end % if identificación correcta
                    identificados(datosegm.archivo2frame(c_archivos,c_frames),c_manchas)=true;
                end
                %                 end % if mancha buena
                if c_vueltas==2 % Esto no hace falta que se ejecute para cada mancha. Pero no pasa nada, y es más fácil así.
                    if isfield(segm(c_frames),'menores') && isfield(datosegm,'guarda_menorescell') && datosegm.guarda_menorescell
                        menores_cell{datosegm.archivo2frame(c_archivos,c_frames)}=segm(c_frames).menores;
                    end
                    if isfield(segm(c_frames),'id') && isfield(datosegm,'guarda_menorescell') && datosegm.guarda_menorescell
                        id_cell{datosegm.archivo2frame(c_archivos,c_frames)}=sparse(segm(c_frames).id);
                    end
                end
            end % c_manchas
        end % c_frames
        if c_vueltas==1 && c_mapas>0
            mapas_act=mapas_act(:,:,:,1:c_mapas);
            menores=comparamapas(mapas_act,referencias,indvalidos);
            disp([c_archivos c_mapas])
        end % if primera vuelta
    end % c_vueltas
%     [c_archivos c_mapas]
    if c_mapas>0
        identificaciones.mancha2id=mancha2id;
        identificaciones.identificados=identificados;
        if isfield(datosegm,'guarda_menorescell') && datosegm.guarda_menorescell
            identificaciones.menores_cell=menores_cell;
            identificaciones.id_cell=id_cell;
        else
            identificaciones.menores_cell=[];
            identificaciones.id_cell=[];
        end
        if isfield(datosegm,'encriptar')
            variable=identificaciones;
            save([datosegm.directorio 'mancha2id'],'variable')
        else
            save([datosegm.directorio 'mancha2id'],'mancha2id','menores_cell','id_cell')
        end
        clear identificaciones
    end
    clear segm
    
    if ~isempty(h_panel)
        progreso=max([.01 c_archivos/n_archivos]);
        set(h_panel.waitIdentification,'XData',[0 0 progreso progreso])
        set(h_panel.textowaitIdentification,'String',[num2str(round(progreso*100)) ' %'])
    end
    
end % c_archivos

if ~isempty(h_panel)
    progreso=1;
    set(h_panel.waitIdentification,'XData',[0 0 progreso progreso])
    set(h_panel.textowaitIdentification,'String',[num2str(round(progreso*100)) ' %'])
end

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







