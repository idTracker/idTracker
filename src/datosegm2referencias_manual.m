% APE, 14 oct 2014

% This program is prepared to use the mancha2pez coming from a manual
% correction with idPlayer


function refs=datosegm2referencias_manual(datosegm,man2pez,interval)

load([datosegm.directorio 'trozos.mat'])
tr=variable;
load([datosegm.directorio 'intervalosbuenos.mat'])
ib=variable;
refs.referencias=cell(1,datosegm.n_peces);
refs.listamapas=cell(1,datosegm.n_peces);
trozos_act=tr.trozos(interval(1):interval(2),:);
trozos_act=unique(trozos_act(:))';

% We open file by file for memory issues
for c_files=1:size(datosegm.archivo2frame,1)    
    archivoabierto=0;
    for c_trozos=trozos_act
        ind=find(tr.trozos==c_trozos);
        [frame,mancha]=ind2sub(size(tr.trozos),ind);
        if any(frame>=interval(1) & frame<=interval(2))
            pez=unique(man2pez.mancha2pez(ind));
            if length(pez)==1 && any(~isnan(pez))
                [frame,orden]=sort(frame);
                mancha=mancha(orden);
                ind=ind(orden);
                frame=frame(ib.manchasbuenas(ind));
                mancha=mancha(ib.manchasbuenas(ind));
                for c_frames=1:length(frame)
                    archivo_act=datosegm.frame2archivo(frame(c_frames),1);
                    if archivo_act==c_files
                        if archivo_act~=archivoabierto
                            archivo_act
                            load([datosegm.directorio 'segm_' num2str(archivo_act) '.mat'])
                            segm=variable;
                            archivoabierto=archivo_act;
                        end
                        frame_arch=datosegm.frame2archivo(frame(c_frames),2);
                        try
                            if ~isempty(segm(frame_arch).mapas{mancha(c_frames)})
                                refs.referencias{pez}(:,:,:,end+1)=segm(frame_arch).mapas{mancha(c_frames)};
                                refs.listamapas{pez}(1,end+1)=frame(c_frames);
                                refs.listamapas{pez}(2,end+1)=mancha(c_frames);
                                %refs.listampas(pez)(:)
                            end
                        catch
                            keyboard
                        end
                    end % if we are in the right file
                end
            else
                if any(~isnan(pez))
                    disp(['Fragment ' num2str(c_trozos) ' has more than one fish (' num2str(pez') '). Skipping this fragment'])
                end
                
            end
        end
    end
end % c_files
tams=cellfun(@(x) size(x,4),refs.referencias);
for c_peces=1:length(refs.referencias)
    refs.referencias{c_peces}=refs.referencias{c_peces}(:,:,:,equiespaciados(min(tams),tams(c_peces)));
    refs.listamapas{c_peces} =refs.listamapas{c_peces}(:,equiespaciados(min(tams),tams(c_peces)));
end
%refs.listamapas=[];
disp(['Total numbers of references: ' num2str(tams)])
disp(['Final number of references: ' num2str(min(tams))])