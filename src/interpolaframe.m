% APE 24 feb 2014 Viene de interpolapeces

function [pos,segmeros,tiporefit]=interpolaframe(datosegm,tray,segmeros,segm,mancha2pez,frame)

% Prepara cosas
X=repmat(1:datosegm.tam(2),[datosegm.tam(1) 1]);
Y=repmat((1:datosegm.tam(1))',[1 datosegm.tam(2)]);


% Actualiza la interpolación, incluyendo meter los centros en las
% manchas
anchoalto=datosegm.tam([2 1]);
n_peces=size(tray,2);
pos=NaN(n_peces,2);
tiporefit=zeros(1,n_peces,'uint8'); % 0 = no tocado (ya estaba). 1 = mancha propia (recentrado). 2 = Recentrado con criterio de áreas. 3 = Acercado a la mancha. 4 = resultado de interpolación
anclas=NaN(n_peces,2);
anclacercana=NaN(1,n_peces);
for c_peces=find(isnan(tray(frame,:,1)))
    anclas(c_peces,1)=find(~isnan(tray(1:frame-1,c_peces,1)),1,'last');
    anclas(c_peces,2)=frame+find(~isnan(tray(frame+1:end,c_peces,1)),1,'first');
    [m,ind]=min(abs(anclas(c_peces,:)-frame));
    anclacercana(c_peces)=anclas(c_peces,ind);
    pos(c_peces,:)=squeeze(tray(anclas(c_peces,1),c_peces,:)+diff(tray(anclas(c_peces,:),c_peces,:),1,1)*((frame-anclas(c_peces,1))/diff(anclas(c_peces,:)))); 
    pos(c_peces,pos(c_peces,:)<1)=1;
    fuera=pos(c_peces,:)>anchoalto;
    pos(c_peces,fuera)=anchoalto(fuera);
    tiporefit(c_peces)=4;
    
    % Si queda fuera de las manchas, lo mete
    pixelcentro=sub2ind(datosegm.tam,round(pos(c_peces,2)),round(pos(c_peces,1)));
    manchadentro=cellfun(@(x) any(x==pixelcentro),segmeros(frame).pixels);
%     pixels_act=cat(1,segmeros.pixels{:});
    if ~any(manchadentro) && ~isempty(segmeros(frame).pixels)
        % Si hace falta, calcula segmeros del frame anlca cercano
        if isempty(segmeros(anclacercana(c_peces)).pez2mancha)
            [segmeros(anclacercana(c_peces)),segm]=segm2segmeros(datosegm,mancha2pez,segm,anclacercana(c_peces));
        end
        manchasolapa=cellfun(@(x) any(intersect(x,cat(1,segmeros(anclacercana(c_peces)).pixels{segmeros(anclacercana(c_peces)).pez2mancha(c_peces,:)}))),segmeros(frame).pixels);
        solapaalguna=true;
        if ~any(manchasolapa) % Si no solapa ninguna mancha, las consideramos todas
            solapaalguna=false;
            manchasolapa(:)=true;
        end
        manchasolapa=find(manchasolapa);
        [m,pixelcerca]=cellfun(@(x) min((X(x)-pos(c_peces,1)).^2+(Y(x)-pos(c_peces,2)).^2),segmeros(frame).pixels(manchasolapa));        
        [m,ind]=min(m);
        pixelcerca=pixelcerca(ind);
        manchacerca=manchasolapa(ind);
        pixelcerca=segmeros(frame).pixels{manchacerca}(pixelcerca);    
        m=sqrt(m);
%         pixelcentro=pixels_act(pixelcentro);        
        if ~isempty(m) && (solapaalguna || m<datosegm.umbral_vel || sqrt(sum((squeeze(tray(anclacercana(c_peces),c_peces,:))-[X(pixelcerca);Y(pixelcerca)]).^2))<datosegm.umbral_vel)
            pos(c_peces,:)=[X(pixelcerca) Y(pixelcerca)]';
            manchadentro=manchacerca;
            tiporefit(c_peces)=3;
        end
    end
    if any(manchadentro)
        segmeros(frame).pez2mancha(c_peces,manchadentro)=true;
    end
end % c_peces

% Recentra los que estén solos en una mancha
for c_peces=find(isnan(tray(frame,:,1)))
    if sum(segmeros(frame).pez2mancha(:,segmeros(frame).pez2mancha(c_peces,:)))==1
        pos(c_peces,1)=mean(X(segmeros(frame).pixels{segmeros(frame).pez2mancha(c_peces,:)}));
        pos(c_peces,2)=mean(Y(segmeros(frame).pixels{segmeros(frame).pez2mancha(c_peces,:)}));
        tiporefit(c_peces)=1;
    end % if está sola
end % c_peces

% % Recentra los que estén juntos en una mancha con el criterio de las distancias
% for c_manchas=1:length(segmeros.pixels)
%     peces_act=find(segmeros.pez2mancha(:,c_manchas)');
%     if length(peces_act)>1 && any(isnan(tray(frame,peces_act,1)))
%         peces_act=peces_act(isnan(tray(frame,peces_act,1))); % Elimino los fijos, y con ello debería eliminar la posibilidad de que un pez ocupe más de una mancha
%         tiporefit(peces_act)=2;
%         distacentros=NaN(length(segmeros.pixels{c_manchas}),datosegm.n_peces);
%         normadir=zeros(1,datosegm.n_peces);
%         normadir(peces_act)=Inf;
%         historia=NaN(5,datosegm.n_peces,2);
%         c_historia=0;
%         while any(normadir>2)
%             for c_peces=peces_act
%                 distacentros(:,c_peces)=sqrt((X(segmeros.pixels{c_manchas})-pos(c_peces,1)).^2+(Y(segmeros.pixels{c_manchas})-pos(c_peces,2)).^2);
%             end
%             c_historia=c_historia+1;
%             if c_historia>5
%                 c_historia=1;
%             end
%             [distmin,centrocercano]=nanmin(distacentros,[],2);
% %             lienzo=-ones(datosegm.tam);
% %                 lienzo(segmeros.pixels{c_manchas})=0;
%             for c_peces=peces_act
%                 if isnan(tray(frame,c_peces,1))
%                     lejanos_act=centrocercano==c_peces & distmin>datosegm.umbrales_maxdistacentro(c_peces);
% %                     lienzo(segmeros.pixels{c_manchas}(lejanos_act))=c_peces;
%                     
%                     if any(lejanos_act)
%                         centrolejanos=[mean(X(segmeros.pixels{c_manchas}(lejanos_act))) mean(Y(segmeros.pixels{c_manchas}(lejanos_act)))];
%                         direccion=centrolejanos-pos(c_peces,:);
%                         normadir(c_peces)=norm(direccion);
%                         if normadir(c_peces)>1
%                             direccion=direccion/normadir(c_peces);
%                         end
%                         pos(c_peces,:)=squeeze(pos(c_peces,:))+direccion;
%                         if min(sqrt(sum((repmat(pos(c_peces,:),[5 1])-squeeze(historia(:,c_peces,:))).^2,3)))<.5
%                             normadir(c_peces)=0;
%                         end
%                         historia(c_historia,c_peces,:)=pos(c_peces,:);
%                     else
%                         normadir(c_peces)=0;
%                     end
%                 end % if no está ya fijado
%             end % c_peces
% 
% %             if frame>475                 
% %                 clf
% %                 imagesc(lienzo)
% %                 hold on
% %                 plot(pos(:,1),pos(:,2),'.')
% %                 title(num2str(frame))
% %                 colorbar
% %                 ginput(1);
% %             end
%         end % while no centrados
%         % Si alguno queda fuera de las manchas, lo mete
%         for c_peces=peces_act
%             pixelcentro=sub2ind(datosegm.tam,round(pos(c_peces,2)),round(pos(c_peces,1)));
%             if ~any(segmeros.pixels{c_manchas}==pixelcentro)
%                 [m,pixelcentro]=min((X(segmeros.pixels{c_manchas})-pos(c_peces,1)).^2+(Y(segmeros.pixels{c_manchas})-pos(c_peces,2)).^2);
%                 pixelcentro=segmeros.pixels{c_manchas}(pixelcentro);
%                 if ~isempty(pixelcentro) % Aquí podría exigirse también que no esté demasiado lejos (que m no sea demasiado grande)
%                     pos(c_peces,:)=[X(pixelcentro) Y(pixelcentro)]';
%                 end
%             end
%         end
%     end % if hay varios centros
end % c_manchas



