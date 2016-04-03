% APE 18 mar 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function datosegm=datosegm2progreso(datosegm)

datosegm.progreso.Segmentation=0;
datosegm.progreso.Trozos=0;
datosegm.progreso.Individualization=0;
datosegm.progreso.Resegmentation=0;
datosegm.progreso.References=0;
datosegm.progreso.Identification=0;
datosegm.progreso.Trajectories=0;
datosegm.progreso.FillGaps=0;

% Background
datosegm.progreso.Background=double(isfield(datosegm,'videomedio') && ~isempty(datosegm.videomedio));
% Segmentation and rest of things
n_archivos=1;
while ~isempty(dir([datosegm.directorio 'segm_' num2str(n_archivos) '.mat']))
    n_archivos=n_archivos+1;
end
n_archivos=n_archivos-1;
n_frames=size(datosegm.frame2archivo,1);
if n_archivos>0
    narchivos_tot=size(datosegm.archivo2frame,1);
    datosegm.progreso.Segmentation=n_archivos/narchivos_tot;
    if n_archivos==narchivos_tot && ~isempty(dir([datosegm.directorio 'trozos.mat']))
        datosegm.progreso.Trozos=1;
        load([datosegm.directorio 'segm_' num2str(n_archivos) '.mat'])
        segm=variable;
        if isfield(segm,'indiv')
            datosegm.progreso.Individualization=1;
            if isfield(segm,'resegmentado')
                datosegm.progreso.Resegmentation=1;
                if ~isempty(dir([datosegm.directorio 'referencias.mat']))
                    datosegm.progreso.References=1;
                    if ~isempty(dir([datosegm.directorio 'mancha2id.mat']))
                        load([datosegm.directorio 'mancha2id.mat'])                        
                        man2id=variable;
                        datosegm.progreso.Identification=find(any(man2id.mancha2id>0,2),1,'last')/n_frames;     
                        if ~isempty(dir([datosegm.directorio 'trayectorias.mat'])) || ~isempty(dir([datosegm.directorio 'trajectories.mat']))                            
                            datosegm.progreso.Trajectories=1;
                            if ~isempty(dir([datosegm.directorio 'trajectories_nogaps.mat']))
                                datosegm.progreso.FillGaps=1;
                            end % if interpolación
                        end % if trayectorias                                          
                    end % if identificación
                end % if referencias
            end % if resegmentación
        end % if individualización
    end % if trozos
end % if segmentación

