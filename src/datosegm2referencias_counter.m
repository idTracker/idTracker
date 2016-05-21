% APE, 14 oct 2014

% This program is prepared to use the mancha2pez coming from a manual
% correction with idPlayer


function refs=datosegm2referencias_counter(datosegm,man2pez,interval)

load([datosegm.directorio 'npixelsyotros.mat'])
segmbuena=variable.segmbuena;
load([datosegm.directorio 'trozos.mat'])
tr=variable;
load([datosegm.directorio 'intervalosbuenos.mat'])
ib=variable; 
refs.referencias=cell(1,datosegm.n_peces);
refs.listamapas=cell(1,datosegm.n_peces);
trozos_act=tr.trozos(interval(1):interval(2),:);
trozos_act=unique(trozos_act(:))';
counters=zeros(1,datosegm.n_peces);
% We open file by file for memory issues

    for c_trozos=trozos_act
        ind=find(tr.trozos==c_trozos);
        [frame,mancha]=ind2sub(size(tr.trozos),ind);
        if any(frame>=interval(1) & frame<=interval(2))
            %min(frame)
            %c_trozos
            pez=unique(man2pez.mancha2pez(ind));
            if length(pez)==1 && any(~isnan(pez))
                [frame,orden]=sort(frame);
                mancha=mancha(orden);
                ind=ind(orden);
                frame=frame(ib.manchasbuenas(ind));
                mancha=mancha(ib.manchasbuenas(ind));
                for c_frames=1:length(frame)                    
                    %[frame_b blob]=find(man2pez.mancha2pez(frame,:)==pez);
                    %[frame_bs I]=sort(frame_b);
                    %if(segmbuena(frame(c_frames),I(c_frames))==1)                  
                    counters(pez)=counters(pez)+1
                    refs.listamapas{pez}(end+1)=frame(c_frames);                    

                    %end
                end % if we are in the right file                
            else
                if any(~isnan(pez))
                    disp(['Fragment ' num2str(c_trozos) ' has more than one fish (' num2str(pez') '). Skipping this fragment'])
                end
                
            end
        end
    end

counters
tams=cellfun(@(x) size(x,4),refs.referencias);

%refs.listamapas=[];
disp(['Total numbers of references: ' num2str(tams)])
disp(['Final number of references: ' num2str(min(tams))])