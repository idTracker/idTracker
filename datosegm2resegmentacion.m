% 25-Feb-2014 16:55:04 Evito que vuelva por trozos que ya se han resegmentado
% APE 14 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [datosegm,npixelsyotros,solapamiento,trozos,solapos,conectan,conviven,solapan,indiv]=datosegm2resegmentacion(datosegm,handles)

if nargin<2
    handles=[];
end

if ~isempty(handles)
    title(handles.ejes,'Re-segmenting...')
end

load([datosegm.directorio 'trozos.mat']);
trozos=variable.trozos;
load([datosegm.directorio 'npixelsyotros.mat']);
npixelsyotros=variable;
if ~isfield(npixelsyotros,'resegmentado')
    npixelsyotros.resegmentado=false(size(trozos));
end
load([datosegm.directorio 'solapamiento.mat'])
solapamiento=variable;
load([datosegm.directorio 'indiv.mat'])
indiv=variable;
load([datosegm.directorio 'conectanconviven.mat'])
trozo2indiv=indiv2trozosindiv(indiv,trozos);

max_bwdist_act=npixelsyotros.max_bwdist;
max_bwdist_act(~indiv)=NaN;
max_bwdist_act(max_bwdist_act==0)=NaN;
max_bwdist_act=min(max_bwdist_act,[],2); % Así coge el más pequeño de cada frame
max_bwdist_act=max_bwdist_act(~isnan(max_bwdist_act));
umbral_bwdist=median(max_bwdist_act)/datosegm.ratio_bwdist;
datosegm.umbral_bwdist_resegmentacion=umbral_bwdist;

n_trozos=length(trozo2indiv);
n_frames=size(trozos,1);
segm=cell(1,size(datosegm.archivo2frame,1));
cambios=false(size(datosegm.frame2archivo,1),1);

ultimoframeresegmentado=find(any(npixelsyotros.resegmentado,2),1,'last');
trozosquedan=true(1,n_trozos);
if ~isempty(ultimoframeresegmentado)
    if ultimoframeresegmentado<n_frames
        ultimoframeresegmentado=ultimoframeresegmentado+1; % Doy margen para que se cargue los trozos con los que solapa
    end
    trozoshechos=trozos(1:ultimoframeresegmentado,:);
    trozoshechos=unique(trozoshechos(:));
    trozoshechos=trozoshechos(trozoshechos>0);    
    trozosquedan(trozoshechos)=false;
end
trozosquedan(trozo2indiv)=false;
trozosquedan=find(trozosquedan);
for c_trozos=trozosquedan
%     if ~trozo2indiv(c_trozos)
        fprintf(['\nTrozo ' num2str(c_trozos) ':'])
        for sentido=[-1 1]
            solapan_act=find(solapan(c_trozos,:));
            solapan_act=solapan_act(sentido*solapan_act<sentido*c_trozos);
            % Comprueba que los que solapan no solapan con nadie más
            bien=true;
            for c_solapan=1:length(solapan_act)
                solapan2=find(solapan(solapan(c_solapan),:));
                if sum(sentido*solapan2<sentido*solapan(c_solapan))>1 
                    bien=false;
                end
            end % c_solapan
            % Si todo está bien, intenta la resegmentación
            if any(solapan_act) && bien && all(trozo2indiv(solapan_act))
                frames=find(any(trozos==c_trozos,2));
                frame_act=abs(min(sentido*frames));
                resegmentado=true;
                while ~isempty(frame_act) && frame_act>1 && frame_act<n_frames && resegmentado && any(trozos(frame_act,:)==c_trozos) % frame_act está vacío cuando se ha resegmentado el cruce entero en sentido contrario
                    fprintf('%g,',frame_act)
                    resegmentado=false;
                    archivo_act=datosegm.frame2archivo(frame_act,1);
                    if isempty(segm{archivo_act})
                        load([datosegm.directorio 'segm_' num2str(archivo_act)])
                        segm{archivo_act}=variable;
                        if ~isfield(segm{archivo_act},'resegmentado')
                            segm{archivo_act}(1).resegmentado=[];
                        end
                    end
                    frame_arch=datosegm.frame2archivo(frame_act,2);
                    frame_antes=frame_act-sentido;
                    archivo_antes=datosegm.frame2archivo(frame_antes,1);
                    if isempty(segm{archivo_antes})
                        load([datosegm.directorio 'segm_' num2str(archivo_antes)]);
                        segm{archivo_antes}=variable;
                        if ~isfield(segm{archivo_act},'resegmentado')
                            segm{archivo_act}(1).resegmentado=[];
                        end
                    end
                    framearch_antes=datosegm.frame2archivo(frame_antes,2);
                    mancha=trozos(frame_act,:)==c_trozos;
                    pixels=segm{archivo_act}(frame_arch).pixels{mancha};
                    [pixels,distancias]=pixels2bwdist(pixels,datosegm.tam,false);
                    lienzo=false(datosegm.tam);
                    lienzo(pixels(distancias>umbral_bwdist))=true;
                    manchas=bwconncomp(lienzo);
                    relaciones=false(length(solapan_act),length(manchas.PixelIdxList));
                    
                    if sentido==1
                        solapamiento_act=segm{archivo_antes}(framearch_antes).solapamiento;
                    else
                        solapamiento_act=segm{archivo_act}(frame_arch).solapamiento';
                    end
                    manchasolapan=find(solapamiento_act(:,mancha));
                    for c_solapan=1:length(manchasolapan)
                        lienzo=false(datosegm.tam);
                        lienzo(segm{archivo_antes}(framearch_antes).pixels{manchasolapan(c_solapan)})=true;
                        for c_manchas=1:length(manchas.PixelIdxList)
                            relaciones(c_solapan,c_manchas)=any(lienzo(manchas.PixelIdxList{c_manchas}));
                        end % c_manchas
                    end % c_solapan                    
                    if all(any(relaciones,2)) && max(sum(relaciones,1))==1 
                        resegmentado=true;
                        cambios(frame_act-1:frame_act+1)=true;
                        nuevosindices=[find(mancha) length(segm{archivo_act}(frame_arch).pixels)+(1:length(solapan_act)-1)];
                        for c_nuevas=1:length(solapan_act)
                            segm{archivo_act}(frame_arch).pixels{nuevosindices(c_nuevas)}=[];
                            for c_submanchas=find(relaciones(c_nuevas,:))
                                segm{archivo_act}(frame_arch).pixels{nuevosindices(c_nuevas)}=[segm{archivo_act}(frame_arch).pixels{nuevosindices(c_nuevas)} ; manchas.PixelIdxList{c_submanchas}];
                            end
                            trozos(frame_act,nuevosindices(c_nuevas))=trozos(frame_antes,manchasolapan(c_nuevas));
                        end % c_nuevasmanchas
                        segm{archivo_act}(frame_arch).segmbuena(nuevosindices)=false;
                        segm{archivo_act}(frame_arch).borde(nuevosindices)=segm{archivo_act}(frame_arch).borde(mancha);
                        segm{archivo_act}(frame_arch).miniframes(nuevosindices)=cell(1,length(nuevosindices));
                        segm{archivo_act}(frame_arch).mapas(nuevosindices)=cell(1,length(nuevosindices));
                        segm{archivo_act}(frame_arch).errores_indiv(nuevosindices)=NaN;
                        segm{archivo_act}(frame_arch).indiv(nuevosindices)=true;
                        segm{archivo_act}(frame_arch).identificado(nuevosindices)=false;
                        if isfield(segm{archivo_act},'menores')
                            if isempty(segm{archivo_act}(frame_arch).menores)
                                segm{archivo_act}(frame_arch).menores=cell(1,length(segm{archivo_act}(frame_arch).pixels));
                            end
                            segm{archivo_act}(frame_arch).menores(nuevosindices)=cell(1,length(nuevosindices));
                        end
                        segm{archivo_act}(frame_arch).resegmentado(nuevosindices)=true;
                        if isfield(segm{archivo_act},'id')
                            segm{archivo_act}(frame_arch).id(nuevosindices,:)=0;
                        end
                        
                        % Recalcula centros y otros
                        segm{archivo_act}(frame_arch)=segm2segm_centros(datosegm,segm{archivo_act}(frame_arch));
                        % Recalcula el solapamiento
                        cont=3;
                        for c_frames=frame_act+1:-1:frame_act-1
                            archivo_act=datosegm.frame2archivo(c_frames,1);
                            if isempty(segm{archivo_act})
                                load([datosegm.directorio 'segm_' num2str(archivo_act)])
                                segm{archivo_act}=variable;
                                if ~isfield(segm{archivo_act},'resegmentado')
                                    segm{archivo_act}(1).resegmentado=[];
                                end
                            end
                            frame_arch=datosegm.frame2archivo(c_frames,2);
                            segm_solap(cont).pixels=segm{archivo_act}(frame_arch).pixels;                            
                            cont=cont-1;
                        end
                        segm_solap(1).pixels_sig=segm_solap(2).pixels;
                        segm_solap(2).pixels_sig=segm_solap(3).pixels;
                        segm_solap=segm_solap(1:2);
                        segm_solap=segm2segm_solapamiento(segm_solap,datosegm);
                        cont=0;
                        for c_frames=frame_act-1:frame_act
                            archivo_act=datosegm.frame2archivo(c_frames,1);
                            frame_arch=datosegm.frame2archivo(c_frames,2);
                            cont=cont+1;
                            segm{archivo_act}(frame_arch).solapamiento=segm_solap(cont).solapamiento;
                        end
                        clear segm_solap
                    end % if se puede resegmentar
                    frame_act=frame_act+sentido;
                end % while sigue avanzando
            end % if todos los que solapan son trozos individuales
        end % sentido
%     end % if trozo no individual
    % Va guardando todo lo que puede
    framesfaltan=any(trozos>c_trozos,2);
    framesfaltan(2:end)=framesfaltan(2:end) | framesfaltan(1:end-1); % Extiendo un frame por cada lado para mantener las anclas
    framesfaltan(1:end-1)=framesfaltan(1:end-1) | framesfaltan(2:end);
    terminados=true(1,size(datosegm.archivo2frame,1));
    terminados(datosegm.frame2archivo(framesfaltan,1))=false;
    llenos=cellfun(@(x) ~isempty(x),segm);
    algunoguardado=false;    
    if any(llenos & terminados)
        for c_guardar=find(llenos) % Guardo todos (y no solo los que han terminado), para asegurarme de que si se para a la mitad no haya inconsistencias
            f_act=datosegm.archivo2frame(c_guardar,:);
            f_act=f_act(f_act>0);
            if any(cambios(f_act))
                algunoguardado=true;
                % Actualiza npixelsyotros, solapamiento, etc.
                for c_frames=1:length(segm{c_guardar})
                    frametot=datosegm.archivo2frame(c_guardar,c_frames);
                    n_manchas=length(segm{c_guardar}(c_frames).pixels);
                    if ~isfield(segm{c_guardar},'resegmentado')
                        segm{c_guardar}(1).resegmentado=[];
                    end
                    % Actualiza npixelsyotros
                    for nombrecampo=fieldnames(npixelsyotros)'
                        campo=nombrecampo{1};
                        npixelsyotros.(campo)(frametot,:,:)=0;
                        if strcmp(campo,'mancha2centro')
                            npixelsyotros.mancha2centro(frametot,1:n_manchas,:)=permute(segm{c_guardar}(c_frames).centros,[3 1 2]);
                        elseif strcmpi(campo,'npixels')
                            npixelsyotros.npixels(frametot,1:n_manchas)=cellfun(@(x) length(x),segm{c_guardar}(c_frames).pixels);
                        else
                            if ~isempty(segm{c_guardar}(c_frames).(campo))
                                npixelsyotros.(campo)(frametot,1:length(segm{c_guardar}(c_frames).(campo)))=segm{c_guardar}(c_frames).(campo);
                            end                            
                        end
                    end % c_frames
                    % Actualiza solapamiento
                    solapamiento{frametot}=segm{c_guardar}(c_frames).solapamiento;
                    % Actualiza indiv
                    indiv(frametot,:)=false;
                    if ~isempty(segm{c_guardar}(c_frames).indiv)
                        indiv(frametot,1:length(segm{c_guardar}(c_frames).indiv))=segm{c_guardar}(c_frames).indiv;
                    end
                end % c_frames
                variable=segm{c_guardar};
                save([datosegm.directorio 'segm_' num2str(c_guardar) '.mat'],'variable')
%                 % Si hace falta, guarda el primer frame del siguiente segm, por se
%                 % acaso se cancela y luego los solapamientos no coinciden
%                 if c_guardar<length(terminados) && ~terminados(c_guardar+1) && llenos(c_guardar+1)
%                     segmsiguiente=cell(size(segm));
%                     segmsiguiente{c_guardar+1}=segm{c_guardar+1}(1);
%                     save([datosegm.directorio 'segm_siguiente.mat'],segmsiguiente)
%                 end
            end
            if terminados(c_guardar)
                segm{c_guardar}=[];
            end
        end % c_guardar
    end
    % Guarda npixelsyotros, indiv y solapamiento
    if algunoguardado
        variable=npixelsyotros;
        save([datosegm.directorio 'npixelsyotros.mat'],'variable')
        variable=indiv;
        save([datosegm.directorio 'indiv.mat'],'variable')
        variable=solapamiento;
        save([datosegm.directorio 'solapamiento.mat'],'variable')
    end
    if ~isempty(handles)        
        set(handles.waitResegmentation,'XData',[0 0 sum(trozosquedan<=c_trozos)/length(trozosquedan) sum(trozosquedan<=c_trozos)/length(trozosquedan)])
        set(handles.textowaitResegmentation,'String',[num2str(round(sum(trozosquedan<=c_trozos)/length(trozosquedan)*100)) ' %'])
        drawnow
    end
end % c_trozos

% if any(cellfun(@(x) ~isempty(x),segm))
%     disp('Esto no debería haber pasado')
%     keyboard
% end

% Recalcula trozos y conectanconviven
[trozos,solapos]=solapamiento2trozos(solapamiento,npixelsyotros.npixels,datosegm,npixelsyotros.mancha2centro);
trozo2indiv=indiv2trozosindiv(indiv,trozos);
[conectan,conviven,solapan]=trozos2conectatrozos(trozos,solapamiento);
save([datosegm.directorio 'conectanconviven.mat'],'conectan','conviven','solapan')
trozosolapos.trozos=trozos;
trozosolapos.solapos=solapos;
trozosolapos.trozo2indiv=trozo2indiv;
variable=trozosolapos;
save([datosegm.directorio 'trozos'],'variable')
variable=datosegm;
save([datosegm.directorio 'datosegm'],'variable')
variable=npixelsyotros;
save([datosegm.directorio 'npixelsyotros.mat'],'variable')
variable=indiv;
save([datosegm.directorio 'indiv.mat'],'variable')
variable=solapamiento;
save([datosegm.directorio 'solapamiento.mat'],'variable')
