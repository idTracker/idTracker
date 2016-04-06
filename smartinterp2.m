% 01-Mar-2014 01:01:33 Incorporo una segunda vuelta, metiéndose otra vez en los gaps
% entre frames con recentrado. Es parecido a lo que hacía antes de "soltar"
% los frames intermedios y reinterpolarlos.
% APE 24 feb 14 Viene de smartinterp

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [mancha2pez,mancha2centro,tiporefit]=smartinterp2(datosegm,trozos,tray,mancha2pez,mancha2centro,solapan,h_panel)


% Prepara cosas
n_frames=size(tray,1);
n_peces=size(tray,2);
segm=cell(1,size(datosegm.archivo2frame,1));
segmeros(n_frames).pixels={};
segmeros(n_frames).manchasegm=[];
segmeros(n_frames).pez2mancha=[];


% Cálculo de velocidades típicas
x=mancha2centro(:,:,1);
y=mancha2centro(:,:,2);
vel=[];
n_trozos=max(trozos(:));
for c_trozos=1:n_trozos
    ind=find(trozos==c_trozos);
    [frame,mancha]=ind2sub(size(trozos),ind);
    [frame,orden]=sort(frame);
    ind=ind(orden);
    vel=[vel ; sqrt(diff(x(ind)).^2+diff(y(ind)).^2)];
end 
vel=sort(vel);
datosegm.umbral_vel=vel(round(.99*length(vel)));

% % Crea anclas
% anclas=NaN(n_frames,n_peces,2);
% for c_peces=1:n_peces
%     inicios=find(~isnan(tray(1:end-1,:,1)) & isnan(tray(2:end,:,1)));
%     finales=find(isnan(tray(1:end-1,:,1)) & ~isnan(tray(2:end,:,1)))+1;
%     if finales(1)<inicios(1)
%         finales=finales(2:end);
%     end
%     if inicios(end)>finales(end)
%         inicios=inicios(1:end-1);
%     end
%     for c_gaps=1:length(inicios)
%         anclas(inicios(c_gaps)+1:finales(c_gaps),c_peces,1)=inicios(c_gaps);
%         anclas(inicios(c_gaps)+1:finales(c_gaps),c_peces,2)=finales(c_gaps);
%     end % c_gaps
% end % c_peces


tiporefit=zeros(n_frames,n_peces,'uint8');
seguir=true;
ignorar=false(n_frames,n_peces);
% ignorar(1:1000,:)=true;
while seguir
    seguir=false;
    gapazo=find(all(~isnan(tray(:,:,1)) & ~ignorar,2),1,'first');
    gapazo=gapazo+find(any(isnan(tray(gapazo+1:end,:,1)),2),1,'first');
    if ~isempty(gapazo)        
        finalgapazo=find(all(~isnan(tray(gapazo(1)+1:end,:,1)),2),1,'first');
        if ~isempty(finalgapazo)
            gapazo(2)=gapazo(1)+finalgapazo-1;
        end
    end
    disp(gapazo)
    
    if length(gapazo)==2
        
        if ~isempty(h_panel)
            progreso=.2+.8*gapazo(1)/n_frames;
            set(h_panel.waitFillGaps,'XData',[0 0 progreso progreso])
            set(h_panel.textowaitFillGaps,'String',[num2str(round(progreso*100)) ' %'])
        end
        
        % Borro segmeros y segm
        ultimoarchivo=datosegm.frame2archivo(max([1 gapazo(1)-1]),1);
        for c_archivos=1:ultimoarchivo
            segm{c_archivos}=[];
        end
        for c_frames=1:gapazo(1)-1
            segmeros(c_frames).pixels={};
            segmeros(c_frames).manchasegm=[];
            segmeros(c_frames).pez2mancha=[];
        end
        
%         % Creo segmeros en los extremos por si hace falta
%         for c_frames=gapazo+[-1 1]
%             if isempty(segmeros(c_frames).pez2mancha)
%                 try
%                 [segmeros(c_frames),segm]=segm2segmeros(datosegm,mancha2pez,segm,c_frames);
%                 catch
%                     keyboard
%                 end
%             end
%         end
        
        seguir=true;
        extremos=gapazo;
        sentido=-1;
        repitelado=false;
        tiporefit_old=tiporefit;
        while extremos(2)>=extremos(1)
            if ~repitelado
                sentido=-sentido;
            end
            repitelado=false;
            c_frames=extremos(1.5-sentido/2);
            fprintf('%g,',c_frames)
%             if c_frames==1224
%                 keyboard
%             end
            if any(isnan(tray(c_frames,:,1)))
                % Construye segmeros
                if isempty(segmeros(c_frames).pez2mancha)
                    [segmeros(c_frames),segm]=segm2segmeros(datosegm,mancha2pez,segm,c_frames);
                end % if hay que construir segmeros
                %         if c_frames==81
                %             keyboard
                %         end
                [pos,segmeros,tiporefit(c_frames,:)]=interpolaframe(datosegm,tray,segmeros,segm,mancha2pez,c_frames);
                %                     lienzo=false(datosegm.tam);
                %                     lienzo(cat(1,segmeros(c_frames).pixels{:}))=true;
                %                     clf
                %                     imagesc(lienzo)
                %                     hold on
                %                     plot(pos(:,1),pos(:,2),'.')
                %                     title(num2str(c_frames))
                %                     ginput(1);
                tray(c_frames,~isnan(pos(:,1)),:)=permute(pos(~isnan(pos(:,1)),:),[3 1 2]);
                % Guarda los resultados en mancha2pez, y de paso propaga los que
                % estén solos en un trozo
                for c_peces=1:n_peces
                    if ~any(mancha2pez(c_frames,:)==c_peces)
                        % Si está solo en una mancha erosionada, y la mancha
                        % erosionada viene de una sola mancha original, lo meto
                        % en todas las manchas del trozo correspondiente
                        manchaeros=segmeros(c_frames).pez2mancha(c_peces,:)==1;                        
                        if sum(manchaeros==1) && sum(segmeros(c_frames).pez2mancha(:,manchaeros))==1 && sum(segmeros(c_frames).manchasegm==segmeros(c_frames).manchasegm(manchaeros))==1
                            trozo=trozos(c_frames,segmeros(c_frames).manchasegm(manchaeros));
                            ind=find(trozo==trozos);
                            mancha2pez(ind)=c_peces;
                            [frame,mancha]=ind2sub(size(trozos),ind);
                            for c_xy=1:2
                                a=mancha2centro(:,:,c_xy);
                                tray(frame,c_peces,c_xy)=a(ind);
                                tiporefit(frame,c_peces)=1;
                            end                                                          
                        else
                            ind_nuevocentro=sum(mancha2centro(c_frames,:,1)>0)+1;
                            mancha2pez(c_frames,ind_nuevocentro)=c_peces;
                            mancha2centro(c_frames,ind_nuevocentro,:)=tray(c_frames,c_peces,:);
                            if size(trozos,2)<ind_nuevocentro
                                trozos(1,ind_nuevocentro)=0;
                            end
                        end
%                         if sum(mancha2pez(305,:)==5)>1
%                             keyboard
%                         end
                        % Si está solo en una mancha, repite por este lado
                        if sum(manchaeros==1) && sum(segmeros(c_frames).pez2mancha(:,manchaeros))==1                            
                            repitelado=true;
                        end
                    end
%                     if mancha2pez(1132,9)==2
%                         keyboard
%                     end
                end % c_peces                
            end % if hay que interpolar alguna
            extremos(1.5-sentido/2)=extremos(1.5-sentido/2)+sentido;            
        end % c_frames
        % Guarda resultados
        man2pez.mancha2pez=mancha2pez;
        man2pez.mancha2centro=mancha2centro;
        variable=man2pez;
        save([datosegm.directorio 'mancha2pez_nogaps.mat'],'variable')
        fprintf('\n')
        
        % Si ha habido recentrado, elimino los que no se han recentrado
        % para volver a traquearlos
        if sum(sum(tiporefit(gapazo(1):gapazo(2),:)==1))>sum(sum(tiporefit_old(gapazo(1):gapazo(2),:)==1))
            tray_act=tray(gapazo(1):gapazo(2),:,:);
            tiporefit_act=tiporefit(gapazo(1):gapazo(2),:,:);
            tray_act(repmat(tiporefit_act>=2,[1 1 2]))=NaN;
            tray(gapazo(1):gapazo(2),:,:)=tray_act;
        end        
    end % if hay gapazo
end

