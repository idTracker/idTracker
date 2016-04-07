% 24-Dec-2013 17:12:39 Hago que tome obj de datosegm.
% 12-Dec-2013 17:08:18 Hago que use VideoReader cuando la versi�n de Matlab
% es reciente
% 13-Aug-2013 12:06:34 Hago que use datosegm.mascara, en vez de
% recalcularla desde el roi
% 03-Jun-2013 16:47:03 Evito que abra todos los archivos al principio, creando una mega-variable obj.
% 10-Apr-2013 16:56:19 A�ado datosegm.interval
% 27-Feb-2013 20:04:29 Me doy cuenta de que la mediana tarda much�simo m�s que la media, y es lo que m�s est� tardando de la segmentaci�n. As� que pongo otra vez media para la normalizaci�n de intensidades.
% 11-Feb-2013 17:34:26 A�ado videomedio_cuentaframes
% 08-Feb-2013 17:25:07 Mejoro la forma en la que pasa de color a grayscale
% 25-Jan-2013 12:45:00 Hago que funcione con la nueva versi�n de datosegm
% que permite que segm est� troceado diferente que los v�deos
% 27-Nov-2012 19:48:51 A�ado la barra de progreso del panel
% 24-Nov-2012 14:24:49 Hago que pueda funcionar usando la figura del panel
% 12-Nov-2012 17:36:49 Cambio media por mediana para la normalizaci�n de cada frame. Hago que s�lo coja la parte de mascara_intensmed (antes estaba mal)
% 10-Nov-2012 19:09:07 Lo preparo para otras extensiones
% 24-Oct-2012 12:13:45 A�ado cambiacontraste
% 08-May-2012 20:28:17 Corrijo para que no falle cuando hay menos de
% nframes_media
% 25-Jan-2012 19:58:55 Anulo el c�lculo del umbral.
% 25-Jan-2012 19:34:19 A�ado el c�lculo del umbral. Adem�s simplifico la forma
% de elegir los frames, usando equiespaciados.
% APE 22 ago 11

% (C) 2014 Alfonso P�rez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Cient�ficas

% Este programa carga frame a frame en vez de v�deos completos. Esto hace
% que el proceso de carga sea como 4 veces m�s lento, pero tiene la ventaja
% de no necesitar tanta memoria.
%
% handles se refiere a los handles del panel (varible h). Puede simplemente no meterse.

function datosegm=datosegm2videomedio(datosegm,nframes_media,handles)

if nargin<2 || isempty(nframes_media)
    nframes_media=1000;
end

if ~isfield(datosegm,'interval')
    datosegm.interval=[1 size(datosegm.frame2archivo,1)];
end

camposhandles={'ejes','lienzo_manchas','lienzo_mascara','frame','waitBackground','textowaitBackground','Background'};
if nargin<3
    handles=[];
else % Comprueba que todos los handles est�n activos. Si no, los anula por seguridad.
    for c_campos=1:length(camposhandles)
        if ~isfield(handles,camposhandles{c_campos}) || ~ishandle(handles.(camposhandles{c_campos}))
            handles=[];
        end
    end % c_campos
end

if ~isempty(handles)
    title(handles.ejes,'Computing background...')
    set(handles.colorbar,'Visible','off')
    set(handles.lienzo_manchas,'Visible','off')
    set(handles.lienzo_mascara,'Visible','off')
end

n_archivos=size(datosegm.archivovideo2frame,1);
% for c_archivos=1:n_archivos
%     if strcmpi(datosegm.extension,'avi')
%         obj(c_archivos)=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(c_archivos) '.avi']);
%     end        
% end % c_archivos

c_frames=0;
n_frames=diff(datosegm.interval)+1;
if nframes_media>n_frames
    nframes_media=n_frames;
end
indices=equiespaciados(nframes_media,n_frames)+datosegm.interval(1)-1;
suma=zeros(datosegm.tam);
videomedio_cuentaframes=suma;
if isfield(datosegm,'mascara_intensmed') && ~isempty(datosegm.mascara_intensmed)
    mascara_intensmed=datosegm.mascara_intensmed;
else
    mascara_intensmed=datosegm.mascara;
end
% mascara_intensmed=true(datosegm.tam);
% roi=datosegm.roi;
% if numel(roi)==4
%     roi=round(roi);
%     x=1:datosegm.tam(2);
%     y=1:datosegm.tam(1);
%     mascara_intensmed(:,x<min(roi(:,1)))=false;
%     mascara_intensmed(:,x>max(roi(:,1)))=false;
%     mascara_intensmed(y<min(roi(:,2)),:)=false;
%     mascara_intensmed(y>max(roi(:,2)),:)=false;
% elseif numel(roi)==3
%     X=repmat(1:datosegm.tam(2),[datosegm.tam(1) 1]);
%     Y=repmat((1:datosegm.tam(1))',[1 datosegm.tam(2)]);
%     mascara_intensmed=(X-roi(1)).^2 + (Y-roi(2)).^2<=roi(3)^2;
% end
archivoabierto=0;
for frame_act=indices
    archivo=datosegm.frame2archivovideo(frame_act,1);
    % Comprueba si hay que crear el objeto v�deo de nuevo
    crearobj=true;
    if isfield(datosegm,'obj') && ~isempty(datosegm.obj{archivo})
        try a=get(datosegm.obj{archivo}); crearobj=false; catch; end
    end
    if crearobj
        % Si son demasiados, borra los objetos de datosegm
        if isfield(datosegm,'obj') && sum(cellfun(@(x) ~isempty(x),datosegm.obj))>100
            datosegm.obj=cell(1,size(datosegm.archivo2frame,1));
        end
        if ~isfield(datosegm,'MatlabVersion') || str2double(datosegm.MatlabVersion(1))<8
            if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo) '.' datosegm.extension]))
                datosegm.obj{archivo}=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo) '.' datosegm.extension]);
            else
                datosegm.obj{archivo}=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
            end
        else
            if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo) '.' datosegm.extension]))
                datosegm.obj{archivo}=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo) '.' datosegm.extension]);
            else
                datosegm.obj{archivo}=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
            end
        end
        archivoabierto=archivo;
    end
    frame_arch=datosegm.frame2archivovideo(frame_act,2);
%     if strcmpi(datosegm.extension,'avi')
% try
        frame=read(datosegm.obj{archivo},frame_arch);
% catch
%     keyboard
% end
    %Daniel, dirt contrast correction       
        if size(frame,3)==3                        
            frame=colour_filter(frame);
            frame=frame(:,:,1);
        end
%     else
%         caca
%         obj=mmread([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo) '.' datosegm.extension],frame_arch);
%         frame=obj.frames.cdata;
%     end
    %             figure
    %             imagesc(frame)
    %             title(num2str([frame_act archivo frame_arch]))
    %             ginput(1);
    frame_doub=double(frame(:,:,1,1)); % Los dos unos deber�an ser innecesarios
    if datosegm.cambiacontraste
        frame_doub=255-frame_doub;
    end
    frame_doub=frame_doub/mean(frame_doub(mascara_intensmed));
    if all(~isnan(frame_doub(:))) % Porque en algunos v�deos hay alg�n frame raro que es todo negro
        suma = suma + frame_doub;
        videomedio_cuentaframes=videomedio_cuentaframes+(frame_doub<datosegm.umbral);
        c_frames=c_frames+1;
    end
    if mod(c_frames,10)==0
        if ~isempty(handles)
                set(handles.frame,'CData',suma)
                set(handles.waitBackground,'XData',[0 0 c_frames/nframes_media c_frames/nframes_media])
                set(handles.textowaitBackground,'String',[num2str(round(c_frames/nframes_media*100)) ' %'])
        else
            fprintf('%g,',c_frames)
            imagesc(suma)            
            %             colormap gray
            axis image
            colorbar
        end
        drawnow
        %             ginput(1);
        %             caca
    end
end % frame_act
datosegm.videomedio=suma/c_frames;
datosegm.videomedio_cuentaframes=videomedio_cuentaframes/c_frames;

if ~isempty(handles)
    set(handles.waitBackground,'XData',[0 0 c_frames/nframes_media c_frames/nframes_media])
    set(handles.textowaitBackground,'String',[num2str(round(c_frames/nframes_media*100)) ' %'])
    title(handles.ejes,'')
    set(handles.colorbar,'Visible','on')
    set(handles.lienzo_manchas,'Visible','on')
    set(handles.lienzo_mascara,'Visible','on')
    set(handles.Background,'Value',1)
end



% % C�lculo del umbral
% indices=round(mean([indices(1:end-1) ; indices(2:end)],1)); % Cojo los frames m�s alejados de los usados para el v�deo medio
% % Ahora cojo m�ximo 100 de estos frames
% if length(indices)>100
%     indices=indices(equiespaciados(100,length(indices)));
% end
% diferencias=NaN([size(frame_doub) length(indices)]);
% c_frames=0;
% X_filtro=-3:3;
% X_filtro=repmat(X_filtro,[length(X_filtro) 1]);
% filtro=exp(-(X_filtro.^2+X_filtro'.^2)/3);
% for frame_act=indices
%     c_frames=c_frames+1;
%     archivo=datosegm.frame2archivo(frame_act,1);
%     frame_arch=datosegm.frame2archivo(frame_act,2);
%     frame=read(obj(archivo),frame_arch);
%     %             figure
%     %             imagesc(frame)
%     %             title(num2str([frame_act archivo frame_arch]))
%     %             ginput(1);
%     frame_doub=double(frame(:,:,1,1));
%     frame_doub=frame_doub/mean(frame_doub(:));
%     diferencia=frame_doub-datosegm.videomedio; 
%     diferencias(:,:,c_frames)=filter2(filtro,diferencia);        
% end % frame_act
% hist(diferencia(:),200)
% hold on
% datosegm.umbral=-std(diferencias(:))*6; % Cojo 6 desvest.
% hold on
% ejes=axis;
% axis(ejes);
% plot(datosegm.umbral*[1 1],ejes(3:4),'k')
% if abs(nanmean(diferencias(:)))>abs(nanstd(diferencias(:)))
%     error('Algo muy chungo pasa')
% end
