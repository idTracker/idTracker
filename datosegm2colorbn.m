% 30-Jan-2014 16:17:30 Evito que falle cuando frame tiene una sola capa
% 12-Dec-2013 17:19:50 Meto VideoReader
% APE 28 feb 13

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function datosegm=datosegm2colorbn(datosegm)

n_frames=10; % Hace la comprobación con 10 frames
ind_frames=equiespaciados(n_frames,size(datosegm.frame2archivovideo,1));
archivoabierto=0;
datosegm.blancoynegro=true;
blancoynegroseguro=false;
for c_frames=ind_frames(:)'
    if datosegm.blancoynegro && ~blancoynegroseguro
        archivo_act=datosegm.frame2archivovideo(c_frames,1);
        if archivo_act~=archivoabierto
            if ~isfield(datosegm,'MatlabVersion') || str2double(datosegm.MatlabVersion(1))<8
                if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_act) '.' datosegm.extension]))
                    obj=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_act) '.' datosegm.extension]);
                else
                    obj=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
                end
            else
                if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_act) '.' datosegm.extension]))
                    obj=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(archivo_act) '.' datosegm.extension]);
                else
                    obj=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
                end
            end
            archivoabierto=archivo_act;
        end
        frame_arch=datosegm.frame2archivovideo(c_frames,2);
        frame=read(obj,frame_arch);
        if size(frame,3)==1
            blancoynegroseguro=true;
        else
            if ~(all(all(frame(:,:,1)==frame(:,:,2))) && all(all(frame(:,:,3)==frame(:,:,2))))
                datosegm.blancoynegro=false;
            end
        end
    end
end % c_frames

if datosegm.blancoynegro
    disp('Video detected as b/w')
else
    disp('Video detected as color')
end