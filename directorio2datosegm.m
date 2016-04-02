% 21-Jul-2014 22:36:28 Hago que funcione en linux y mac, donde en vez de \
% se usa /
% 25-Dec-2013 17:22:50 Quito el último frame, que a veces da problemas (en
% el vídeo de hormigas de Andrew 
% Atta columbica -1-12-2013 -4cm chamber -experiment 1.mp4 se cuelga)
% 24-Dec-2013 14:04:16 Añado el waitbar. Además, hago que obj se guarde en
% datosegm
% 21-Dec-2013 12:54:06 Hago que pueda especificarse la extension
% 12-Dec-2013 15:45:18 Hago que use VideoReader si la versión es reciente
% 26-Aug-2013 11:13:26 Hago que si hay un solo video el nombre no tenga que empezar por 1.
% 23-Aug-2013 11:44:14 Anulo la distinción por extensión del archivo
% 28-Feb-2013 11:49:59 Hago que detecte si el vídeo es en color o en blanco y negro. Abortado.
% 21-Feb-2013 18:05:27 Corrijo un bug en la línea 76
% 25-Jan-2013 12:13:34 Hago que pueda leer vídeos largos, de modo que los
% trozos de segm no cubran un vídeo entero.
% 10-Nov-2012 16:32:42 Hago que use mmread si el archivo no es .avi
% APE 15 ago 11 Viene de directorio2segm_trozos

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function datosegm=directorio2datosegm(directorio,raizarchivo,directoriodestino,extension)

h=waitbar(0,'Reading video files','Name','Loading video');
hw=findobj(h,'Type','Patch');
set(hw,'EdgeColor',[.5 .5 .7],'FaceColor',[.5 .5 .7]) % changes the color of the waitbar

if nargin<3 || isempty(directoriodestino)
    directoriodestino=directorio; % Lo mete en el mismo directorio que el vídeo
end
if nargin<4 || isempty(extension)
    extension='*';
end

if ispc
    barra='\';
else
    barra='/';
end
if directorio(end)~=barra
    directorio(end+1)=barra;
end
if directoriodestino(end)~=barra
    directoriodestino(end+1)=barra;
end
c_archivos=1;
esta=dir([directorio raizarchivo num2str(c_archivos) '.' extension]);
n_archivos=length(dir([directorio raizarchivo '*.' extension]));
if isempty(esta)
    esta=dir([directorio raizarchivo '.' extension]);
    n_archivos=1;
end
c_frames=0;
c_segm=0;
datosegm.directorio=directoriodestino;
datosegm.directorio_videos=directorio;
datosegm.raizarchivo_videos=raizarchivo;
datosegm.extension=esta(1).name(end-2:end);
datosegm.MatlabVersion=version;
% datosegm.frame2archivo=NaN(n_frames,2);
% datosegm.archivo2frame=NaN(1,n_framesporarchivo); % Esta irá creciendo
nframesporsegm=500; % Número de frames que puede haber en cada segm. Se permitirá hasta el doble.
if ishandle(h)
    waitbar(1/(n_archivos+1),h,'Reading video files');
else
    error('idTracker:WindowClosed','Loading of video cancelled by user')
end
datosegm.obj=cell(1,n_archivos);
while ~isempty(esta)
    fprintf('%g,',c_archivos)       
    % Si hay muchos archivos, no guardo los obj en datosegm (cuando hay
    % muchos puede dar problemas, y además normalmente cuando hay muchos es
    % porque cada vídeo es corto, con lo que se tarda muy poco en generar
    % un nuevo obj).
    if c_archivos>100
        datosegm.obj=cell(1,n_archivos);
    end
    if ~isfield(datosegm,'MatlabVersion') || str2double(datosegm.MatlabVersion(1))<8
        if c_archivos>1 || ~isempty(dir([directorio raizarchivo num2str(c_archivos) '.' datosegm.extension]))
            datosegm.obj{c_archivos}=mmreader([directorio raizarchivo num2str(c_archivos) '.' datosegm.extension]);
        else
            datosegm.obj{c_archivos}=mmreader([directorio raizarchivo '.' datosegm.extension]);
        end
    else
        if c_archivos>1 || ~isempty(dir([directorio raizarchivo num2str(c_archivos) '.' datosegm.extension]))
            datosegm.obj{c_archivos}=VideoReader([directorio raizarchivo num2str(c_archivos) '.' datosegm.extension]);
        else
            datosegm.obj{c_archivos}=VideoReader([directorio raizarchivo '.' datosegm.extension]);
        end
    end
        nframes_act=get(datosegm.obj{c_archivos},'NumberOfFrames');        
    % Datos sobre el vídeo (no dependen de si segm está troceado por
    % dentro)
    datosegm.framerate(c_archivos)=get(datosegm.obj{c_archivos},'FrameRate');
    datosegm.frame2archivovideo(c_frames+1:c_frames+nframes_act,1)=c_archivos;
    datosegm.frame2archivovideo(c_frames+1:c_frames+nframes_act,2)=1:nframes_act;
    datosegm.archivovideo2frame(c_archivos,1:nframes_act)=c_frames+1:c_frames+nframes_act;
    % Datos sobre segm
    if nframes_act<nframesporsegm*2
        cortes=[0 nframes_act];
    else
        n_trozos=ceil(nframes_act/nframesporsegm);
        cortes=equiespaciados(n_trozos+1,nframes_act);   
        cortes(1)=0;
    end
    n_trozos=length(cortes)-1;
    for c_trozos=2:n_trozos+1
        c_segm=c_segm+1;
        nframes_trozo=diff(cortes(c_trozos-1:c_trozos));
        datosegm.frame2archivo(c_frames+1:c_frames+nframes_trozo,1)=c_segm;
        datosegm.frame2archivo(c_frames+1:c_frames+nframes_trozo,2)=1:nframes_trozo;
        datosegm.archivo2frame(c_segm,1:nframes_trozo)=c_frames+1:c_frames+nframes_trozo;
        c_frames=c_frames+nframes_trozo;
    end % c_trozos
    c_archivos=c_archivos+1;
    esta=dir([directorio raizarchivo num2str(c_archivos) '.' datosegm.extension]);
    if ishandle(h)
        waitbar(c_archivos/(n_archivos+1),h);
    else
        error('idTracker:WindowClosed','Loading of video cancelled by user')
    end
end 
c_archivos=c_archivos-1;
datosegm.obj=datosegm.obj(1:c_archivos); % Por si n_archivos estaba sobreestimado

% Elimino el último frame, que da problemas en algún vídeo
datosegm.archivovideo2frame(datosegm.frame2archivovideo(end,1),datosegm.frame2archivovideo(end,2))=0;
datosegm.frame2archivovideo=datosegm.frame2archivovideo(1:end-1,:);
datosegm.archivo2frame(datosegm.frame2archivo(end,1),datosegm.frame2archivo(end,2))=0;
datosegm.frame2archivo=datosegm.frame2archivo(1:end-1,:);

if ishandle(h)
    waitbar(1,h);
else
    error('idTracker:WindowClosed','Loading of video cancelled by user')
end
% if strcmpi(datosegm.extension,'avi')
    datosegm.tam=[get(datosegm.obj{end},'Height'),get(datosegm.obj{end},'Width')];
% else
%     datosegm.tam=[obj.height obj.width];
% end
% save([directoriodestino 'datosegm.mat'],'datosegm')
fprintf('\n')
close(h)