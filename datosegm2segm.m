% 29-Apr-2014 10:22:16 Elimino encriptación
% 08-Apr-2014 12:42:21 Hago que guarde el mapa promedio y no solo los
% puntos del mapa donde hay información
% 08-Feb-2014 18:23:44 Añado el nuevo cálculo de los centros
% 23-Dec-2013 22:03:48 Añado dist_max para los mapas
% 12-Dec-2013 17:06:23 Hago que use VideoReader cuando la versión de Matlab
% es nueva
% 02-Dec-2013 20:54:44 Arreglo un bug que daba un fallo cuando en un frame
% no aparecía ningún bicho.
% 23-Aug-2013 11:39:04 Quito la distinción por extensión (que en realidad
% ya estaba desactivada)
% 05-Jul-2013 09:49:40 Hago que intente leer los ficheros de golpe aunque
% el vídeo no esté grabado en el laboratorio (comprobando con los primeros
% archivos)
% 18-Jun-2013 19:18:23 Añado mancha2centro
% 10-Jun-2013 14:41:52 Añado el log, y quito keyboards
% 01-Jun-2013 10:55:26 Añado encriptación
% 13-May-2013 09:50:49 Pongo el try-catch alrededor del read, para que no se pare por fallos aleatorios
% 10-Apr-2013 17:08:46 Incluyo datosegm.interval
% 03-Apr-2013 19:20:28 Corrijo un bug que hacía que fallara cuando en un frame no había ninguna mancha
% 28-Feb-2013 12:02:18 Evito que use rgb2gray cuando el vídeo ya es en blanco y negro
% 27-Feb-2013 15:14:53 Hago que sólo lea de 1 en 1 cuando los archivos de vídeo no coinciden con los archivos de segm (lo cual indica que viene de un vídeo que no hemos grabado nosotros)
% 19-Feb-2013 12:47:04 Hago que lea el vídeo frame a frame. Es mucho más
% lento, pero evita problemas de sincronización cuando hay frames
% repetidos.
% 26-Jan-2013 11:23:59 Añado la posibilidad de reutilizar
% 25-Jan-2013 17:32:41 Hago que cargue video de 10 frames en 10 frames,
% para que no sature la memoria
% 25-Jan-2013 12:35:50 Hago que funcione cuando los archivos de vídeo son
% más largos que los segms
% 28-Nov-2012 12:23:33 Quito inputs, porque todo está ya en datosegm. Además anulo usaresta.
% Además meto la interacción con el panel.
% 23-Nov-2012 08:46:14 Meto el cambio de contraste en avi2segm
% 12-Nov-2012 17:46:49 Saco de aquí la adquisición del roi, y la mando a datosegm2roi
% 10-Nov-2012 16:12:47 Hago que use mmread en vez de mmreader cuando no es un .avi
% 15-Oct-2012 19:11:58 Corrijo para que busque tam_mapas en todas las
% manchas y no sólo en la primera.
% 31-Jul-2012 09:30:15 Añado la posibilidad de excluir una zona para el
% cálculo de intensmed
% 07-Mar-2012 17:46:29 Corrijo un bug en la línea 91, que había corregido
% en el ordenador de Robert.
% 16-Feb-2012 10:39:29 Añado la posibilidad de invertir el contraste
% 31-Jan-2012 19:59:07 Añado la posibilidad de roi circular
% 18-Nov-2011 11:03:58 Añado el roi
% 10-Nov-2011 18:01:05 Cambio avi2miniframes por avi2segm. Esto hace que la
% segmentación en el caso de usar videomedio pase a utilizar exclusivamente
% la diferencia entre el videomedio y el vídeo.
% 09-Nov-2011 14:53:09 Corrijo un error cambiando segm por segm_nue
% 17-Oct-2011 12:19:00 Añado el cálculo del solapamiento y los mapas
% 13-Oct-2011 17:25:06 Cambio segm1 a segm_1
% 06-Oct-2011 11:00:13 Añado n_manchas
% 22-Aug-2011 15:26:51 Añado background substraction con videomedio
% APE 15 ago 11 Viene de directorio2segm_trozos

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% roi=-1 es para elegir roi cuadrada, roi=-2 es para elegir roi circular.
% Una vez elegida, cuando tiene 4 elementos es roi cuadrada, y si es de 3 es
% circular (el orden es [x0 y0 R])

function [datosegm,solapamiento,npixels,segmbuena,borde,mancha2centro,max_bwdist,bwdist_centro,max_distacentro]=datosegm2segm(datosegm,handles)

camposhandles={'ejes','lienzo_manchas','lienzo_mascara','frame','waitSegmentation','textowaitSegmentation','Segmentation','text_nmanchas','ejes_tams'};

if ~isfield(datosegm,'interval')
    datosegm.interval=[1 size(datosegm.frame2archivo,1)];
end
if ~isfield(datosegm,'dist_max_mapas')
    datosegm.dist_max_mapas=[];
end

if nargin<2
    handles=[];
else
    for c_campos=1:length(camposhandles)
        if ~isfield(handles,camposhandles{c_campos}) || ~ishandle(handles.(camposhandles{c_campos}))
            handles=[];
        end
    end % c_campos
end
if ~isempty(handles)
    title(handles.ejes,'Performing segmentation...')
end
usaresta=false;

n_archivos=size(datosegm.archivo2frame,1);
n_frames=size(datosegm.frame2archivo,1);
datosegm.n_manchas=NaN(n_frames,1);
cframes_tot=0;
solapamiento=cell(1,n_frames);
npixels=zeros(n_frames,1); % Los ceros marcarán que no hay mancha
mancha2centro=npixels;
max_bwdist=npixels;
bwdist_centro=npixels;
areamayor=npixels;
areacore=npixels;
max_distacentro=npixels;
segmbuena=false(n_frames,1);
borde=segmbuena;
indvalidos=uint64(0);
c_mapaspromediados=0;
segm=[];
if ~isfield(datosegm,'videosbuenos')
    datosegm.videosbuenos=0;
end
videoabierto=0;
for c_archivos=1:n_archivos
    if isempty(handles)
        fprintf('%g,',c_archivos)
    end
%     fprintf(datosegm.id_log,'%g(',c_archivos);
    if ~datosegm.reutiliza.Segmentation || isempty(dir([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos) '.mat']))
%         if strcmpi(datosegm.extension,'avi')
            listaframes_act=datosegm.archivo2frame(c_archivos,:);
            listaframes_act=listaframes_act(listaframes_act>0);
            traqueaframes=listaframes_act>=datosegm.interval(1) & listaframes_act<=datosegm.interval(2);
            datos_video=datosegm.frame2archivovideo(listaframes_act,:);
            datos_video=datos_video(datos_video(:,1)>0,:);
            archivo_video=unique(datos_video(:,1));
            frames_video=datos_video(:,2);
            %             if length(archivo_video)>1
            %                 disp('Esto no debería haber pasado')
            %                 keyboard
            %             end
            if archivo_video~=videoabierto
                if ~isfield(datosegm,'MatlabVersion') || str2double(datosegm.MatlabVersion(1))<8
                    if archivo_video>1 || ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_video) '.' datosegm.extension]))
                        obj=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_video) '.' datosegm.extension]);
                    else
                        obj=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
                    end
                else
                    if archivo_video>1 || ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_video) '.' datosegm.extension]))
                        obj=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_video) '.' datosegm.extension]);
                    else
                        obj=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
                    end
                end
                videoabierto=archivo_video;
            end
%             fprintf(datosegm.id_log,'obj');
            %             video=zeros([datosegm.tam 1 length(frames_video)],'uint8');
%             inicio=0;
            %             if any(datosegm.frame2archivovideo(:)~=datosegm.frame2archivo(:))
            %                 fprintf(datosegm.id_log,',archivolargo');
            %                 for c_frames=frames_video(1):frames_video(end) % Es muy lento ir de 1 en 1, pero si no nos arriesgamos a que haya problemas cuando hay frames repetidos
            %                     if traqueaframes(inicio+1)
            % %                         n_fallos=0;
            % %                         while n_fallos<5
            % %                             try
            %                                 fprintf(datosegm.id_log,',%g-',c_frames);
            %                                 video_act=read(obj,c_frames);
            %                                 fprintf(datosegm.id_log,'%g',c_frames);
            % %                             catch me
            % %                                 me
            % %                                 n_fallos=n_fallos+1;
            % %                                 pause(1)
            % %                             end
            % %                         end % while pocos fallos
            %                         if size(video_act,3)==3 && isfield(datosegm,'blancoynegro') && ~datosegm.blancoynegro
            %                             video_act(:,:,1)=rgb2gray(video_act);
            %                         end
            %                         fprintf(datosegm.id_log,',gris');
            %                         inicio=inicio+1;
            %                         video(:,:,:,inicio)=video_act(:,:,1,:);
            %                         clear video_act
            %                         fprintf(datosegm.id_log,',cleared');
            %                     end
            %                 end
            %             else % Si el vídeo está grabado por nosotros, lo carga de una sola vez para ir más rápido
%             fprintf(datosegm.id_log,',archivoscortos');
            if any(traqueaframes)
                if datosegm.videosbuenos>=0
                clear video
%                 fprintf(datosegm.id_log,',r-');
                nframes_trozos=100; % Lo cargo de 100 en 100 frames para no saturar la memoria
                frame_act=0;
                video=zeros([datosegm.tam 1 length(frames_video)],'uint8');
                while frame_act<length(frames_video)                                   
                    ultimoframe=min([frame_act+nframes_trozos length(frames_video)]);
                    try
                        video_act=read(obj,[frames_video(frame_act+1) frames_video(ultimoframe)]);
                    catch % A veces (en la peli Movie.avi de Ruilong) da un error diciendo "The frame index requested is beyond the end of the file". Y parece que se resuelve leyendo el primer frame, y volviendo a intentarlo
                        read(obj,1);
                        video_act=read(obj,[frames_video(frame_act+1) frames_video(ultimoframe)]);
                    end
%                     fprintf(datosegm.id_log,'r');
                    if size(video_act,3)==3 && isfield(datosegm,'blancoynegro') && ~datosegm.blancoynegro
                        for c_frames=1:size(video_act,4)
                            video_act(:,:,1,c_frames)=rgb2gray(video_act(:,:,:,c_frames));
                        end
                    end
%                     fprintf(datosegm.id_log,',gris');
                    video(:,:,:,frame_act+1:ultimoframe)=video_act(:,:,1,:);
                    clear video_act
                    frame_act=ultimoframe;
                end % while quedan trozos
                end % if se puede leer el vídeo entero (o no lo sabemos todavía)
                
                % Comprueba que los frames coinciden cuando los cogemos
                % uno a uno               
                if datosegm.videosbuenos==0 % Si todavía no se ha comprobado, se comprueba si los vídeos se pueden leer de una vez
                    for cframes_comprueba=equiespaciados(10,length(frames_video))
                        frame_act=read(obj,frames_video(cframes_comprueba));
                        if size(frame_act,3)==3 && isfield(datosegm,'blancoynegro') && ~datosegm.blancoynegro                        
                            frame_act=rgb2gray(frame_act);                       
                        end
                        frame_act=frame_act(:,:,1);
                        if any(any(any(frame_act~=video(:,:,:,cframes_comprueba))))
                            datosegm.videosbuenos=-1;                            
                        end
                    end % cframes_comprueba           
                    if datosegm.videosbuenos<0
                        disp('Parece que hay que leer los vídeos frame a frame')
                    else
                        disp('Parece que se pueden leer todos los frames de golpe')
                        datosegm.videosbuenos=1;
                    end
                end
                
                % Si hace falta, lee el vídeo frame a frame
                if datosegm.videosbuenos<0
                    clear video
                    video=zeros([datosegm.tam 1 length(frames_video)],'uint8');
                    inicio=0;                    
%                     fprintf(datosegm.id_log,',archivolargo');
                    for c_frames=frames_video(1):frames_video(end) % Es muy lento ir de 1 en 1, pero si no nos arriesgamos a que haya problemas cuando hay frames repetidos
%                         fprintf(datosegm.id_log,',%g-',c_frames);
                        video_act=read(obj,c_frames);
%                         fprintf(datosegm.id_log,'%g',c_frames);
                        if size(video_act,3)==3 && isfield(datosegm,'blancoynegro') && ~datosegm.blancoynegro
                            video_act(:,:,1)=rgb2gray(video_act);
                        end
%                         fprintf(datosegm.id_log,',gris');
                        inicio=inicio+1;
                        video(:,:,:,inicio)=video_act(:,:,1,:);
                        clear video_act
%                         fprintf(datosegm.id_log,',cleared');
                    end
                end
            else
                video=ones([datosegm.tam 1 length(frames_video)],'uint8');
            end
            %             end
%                 fprintf(datosegm.id_log,',read');
                %             size(video)
                %         else
                %             obj=mmread([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(c_archivos) '.' datosegm.extension]);
                %             n_frames=length(obj.frames);
                %             video=zeros(obj.height,obj.width,3,n_frames,'uint8');
                %             for c_frames=1:n_frames
                %                 video(:,:,:,c_frames)=obj.frames(c_frames).cdata;
                %             end
%             end
            segm_nue=avi2segm(video,datosegm,usaresta,datosegm.roi,traqueaframes);
%             fprintf(datosegm.id_log,',segm');
            segm_nue=segm2segm_centros(datosegm,segm_nue);
            segm_nue=segm2segm_mapas_general(segm_nue,datosegm.reduceresol,datosegm.umbral(1),datosegm.dist_max_mapas);
%             fprintf(datosegm.id_log,',transf');
            
            % Busca mapas para sacar tam_mapas
            if ~isfield(datosegm,'tam_mapas')
                c_frames=1;
                while (isempty(segm_nue(c_frames).mapas) || all(cellfun(@(x) isempty(x),segm_nue(c_frames).mapas))) && c_frames<length(segm_nue) % Avanza hasta que hay un mapa
                    c_frames=c_frames+1;
                end
                vacios=cellfun(@(x) isempty(x),segm_nue(c_frames).mapas);
                if ~isempty(segm_nue(c_frames).mapas) && ~all(vacios)
                    ind_mancha=find(~vacios,1);
                    datosegm.tam_mapas=size(segm_nue(c_frames).mapas{ind_mancha});
                end
            end % Si no está buscado todavía.
%             fprintf(datosegm.id_log,',tam');
            % indvalidos
            for c_frames=1:length(segm_nue)
                for c_peces=1:length(segm_nue(c_frames).mapas)
                    if segm_nue(c_frames).segmbuena(c_peces)
                        if max(indvalidos)<intmax('uint64')
                            indvalidos=indvalidos+uint64(segm_nue(c_frames).mapas{c_peces});
                            c_mapaspromediados=c_mapaspromediados+1;
                        else % Si está saturado, solo actualizamos los que no tengan nada de informacion
                            indvalidos(indvalidos==0 & segm_nue(c_frames).mapas{c_peces}>0)=1;
                        end
                    end
                end
            end % c_frames
%             indvalidos=double(indvalidos>0);
%             fprintf(datosegm.id_log,',indval');
            for c_frames=1:length(segm_nue)-1
                if c_frames<length(segm_nue)
                    segm_nue(c_frames).pixels_sig=segm_nue(c_frames+1).pixels;
                end
            end % c_frames
        else
%             fprintf(datosegm.id_log,'reuse');
            segm_old=segm;
            load([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos) '.mat'])
            segm=variable;
            segm_nue=segm;
            segm=segm_old;
            clear segm_old
            video=zeros(datosegm.tam,'uint8');
        end % if no reutiliza
        if ~isempty(handles)
            frame=double(video(:,:,1,end));
            frame=frame/segm_nue(end).intensmed;
            set(handles.frame,'CData',frame)
            lienzo=zeros(datosegm.tam);
            for c_manchas=1:length(segm_nue(end).pixels)
                lienzo(segm_nue(end).pixels{c_manchas})=.5;
            end
            set(handles.lienzo_manchas,'AlphaData',lienzo)
            set(handles.text_nmanchas,'String',[num2str(length(segm_nue(end).pixels)) ' blobs detected. Sizes:'])
            hold(handles.ejes_tams,'off')
            for c_manchas=1:length(segm_nue(end).pixels)
                plot(handles.ejes_tams,length(segm_nue(end).pixels{c_manchas})*[1 1],[0 1],'k','LineWidth',2)
                hold(handles.ejes_tams,'on')
            end
            plot(handles.ejes_tams,datosegm.umbral_npixels*[1 1],[0 1],'r','LineWidth',2)
            set(handles.ejes_tams,'YTick',[],'YLim',[0 1],'TickDir','out')
            set(handles.waitSegmentation,'XData',[0 0 c_archivos/n_archivos c_archivos/n_archivos])
            set(handles.textowaitSegmentation,'String',[num2str(round(c_archivos/n_archivos*100)) ' %'])
            drawnow
%             fprintf(datosegm.id_log,',show');
        end
        
        if c_archivos>1
            segm(end).pixels_sig=segm_nue(1).pixels;
            if ~datosegm.reutiliza.Segmentation || isempty(dir([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos-1) '.mat']))
                segm=segm2segm_solapamiento(segm,datosegm);
            end
%             fprintf(datosegm.id_log,',solap');
            for c_frames=1:length(segm)
                cframes_tot=cframes_tot+1;
                nmanchas_act=length(segm(c_frames).pixels);
                datosegm.n_manchas(cframes_tot)=nmanchas_act;
                npixels(cframes_tot,1:nmanchas_act)=cellfun(@(x) length(x),segm(c_frames).pixels);
                mancha2centro(cframes_tot,1:nmanchas_act,1:2)=segm(c_frames).centros;
                max_bwdist(cframes_tot,1:nmanchas_act)=segm(c_frames).max_bwdist;
                bwdist_centro(cframes_tot,1:nmanchas_act)=segm(c_frames).bwdist_centro;
                areamayor(cframes_tot,1:nmanchas_act)=segm(c_frames).areamayor;
                areacore(cframes_tot,1:nmanchas_act)=segm(c_frames).areacore;
                max_distacentro(cframes_tot,1:nmanchas_act)=segm(c_frames).max_distacentro;
                if nmanchas_act>0
                    segmbuena(cframes_tot,1:nmanchas_act)=segm(c_frames).segmbuena;
                    borde(cframes_tot,1:nmanchas_act)=segm(c_frames).borde;
                end
                solapamiento{cframes_tot}=segm(c_frames).solapamiento;
            end % c_frames
%             fprintf(datosegm.id_log,',otros');
            if ~datosegm.reutiliza.Segmentation || isempty(dir([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos-1) '.mat']))
                variable=segm;
                save([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos-1) '.mat'],'variable')
            end
%             fprintf(datosegm.id_log,',save');
        end
        clear video
        segm=segm_nue;
%         fprintf(datosegm.id_log,')');
    end % c_archivos
    segm=segm2segm_solapamiento(segm,datosegm);
    for c_frames=1:length(segm)
        cframes_tot=cframes_tot+1;
        nmanchas_act=length(segm(c_frames).pixels);
        datosegm.n_manchas(cframes_tot)=nmanchas_act;
        npixels(cframes_tot,1:nmanchas_act)=cellfun(@(x) length(x),segm(c_frames).pixels);
        mancha2centro(cframes_tot,1:nmanchas_act,1:2)=segm(c_frames).centros;
        max_bwdist(cframes_tot,1:nmanchas_act)=segm(c_frames).max_bwdist;
        bwdist_centro(cframes_tot,1:nmanchas_act)=segm(c_frames).bwdist_centro;
        areamayor(cframes_tot,1:nmanchas_act)=segm(c_frames).areamayor;
        areacore(cframes_tot,1:nmanchas_act)=segm(c_frames).areacore;
        max_distacentro(cframes_tot,1:nmanchas_act)=segm(c_frames).max_distacentro;
        if nmanchas_act>0
            segmbuena(cframes_tot,1:nmanchas_act)=segm(c_frames).segmbuena;
            borde(cframes_tot,1:nmanchas_act)=segm(c_frames).borde;
        end
        solapamiento{cframes_tot}=segm(c_frames).solapamiento;
    end % c_frames
    variable=segm;
save([datosegm.directorio datosegm.raizarchivo '_' num2str(c_archivos) '.mat'],'variable')
if isempty(handles)
    fprintf('\n')
else
    title(handles.ejes,'')
end
datosegm.mapamedio=double(indvalidos)/c_mapaspromediados;
if ~isfield(datosegm,'npixels_indvalidos') || datosegm.npixels_indvalidos==0 || datosegm.npixels_indvalidos==Inf;
    datosegm.indvalidos=indvalidos>0;
else
    datosegm.indvalidos_real=indvalidos>0;
    datosegm.indvalidos=false(size(indvalidos));
    for c_mapas=1:2
        capa=indvalidos(:,:,c_mapas);
        [s,orden]=sort(capa(:),'descend');
        ind=orden(1:datosegm.npixels_indvalidos);
        ind=ind(capa(ind)>0);
        lienzo=false(size(capa));
        lienzo(ind)=true;
        datosegm.indvalidos(:,:,c_mapas)=lienzo;
    end
end

datosegm.progreso.Segmentation=n_frames;