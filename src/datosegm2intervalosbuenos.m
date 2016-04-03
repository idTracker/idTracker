% 30-Jul-2013 15:27:10 Bajo umbral_solapa, para que sea más fácil rellenar
% las referencias
% 18-Feb-2013 09:53:48 Quito lo de anular todos los trozos que "toquen" un
% frame con más de n_peces manchas, porque a veces es demasiado
% restrictivo.
% 24-Jul-2012 11:03:20 Cambio el criterio de intervalos buenos, para que
% use los trozos y pueda aprovechar segmentos más largos.
% 01-Dec-2011 12:20:29 Doy la opción de que no coja los del borde
% 14-Nov-2011 10:12:57 Corrijo para que no coja el mapa del primer frame
% del intervalo si la segmentación no es buena.
% 09-Nov-2011 18:02:50 Añado la comprobación de que la segmentación sea
% buena para aceptar el frame para referencias
% 14-Oct-2011 10:33:32 Quito el input n_peces. Lo cogerá de datosegm
% 10-Oct-2011 18:56:27 Cambio 'segm' por datosegm.raizarchivo
% 11-Aug-2011 15:09:33 Revierto el cambio anterior, porque hace que un
% frame con mal solapamiento sea ignorado.
% 09-Aug-2011 17:19:42 Corrijo para que no descarte el último frame del
% intervalo. Para ello, hago que cuando un frame es válido lo sea también
% el siguiente
% 04-Aug-2011 11:47:04 Limpieza general
% 02-Aug-2011 16:59:55 Quito segm_sig. Revierto lo del solapamiento, que
% tampoco era para tanto
% 02-Aug-2011 15:23:15 Cambio el criterio de frames válidos de solapamiento
% a distancia. Mola menos, pero corre más
% APE 2 ago 11 Viene de segm2intervalosbuenos

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function intervalosbuenos=datosegm2intervalosbuenos(datosegm,trozos,solapos,indiv,segmbuena,borde,primerframe,quitaborde)

if nargin<2 || isempty(primerframe)
    primerframe=3000; % Para saltar la parte en la que están separados
end

if nargin<3 || isempty(quitaborde)
    quitaborde=false; % Por defecto, usa todos
end

n_peces=datosegm.n_peces;
umbral_avance=3; % Está en pixels
umbral_dist=10; % En pixels
umbral_solapa=.1; % Solapamiento mínimo permitido para meter el nuevo frame en la referencia

n_frames=size(datosegm.frame2archivo,1);
intervalosbuenos.frames=false(1,n_frames);
archivo_act=0;

% Cálculo de convivencias


% Quito los trozos que aparezcan en la zona previa a primerframe
trozomax=max(max(trozos(1:primerframe-1,:)));
for c_trozos=1:trozomax
    trozos(trozos==c_trozos)=0;
end % c_trozos
n_distintos=sum(trozos>0,2);
% % Por si acaso, si hay algún frame en el que haya más de n_peces trozos,
% % descarto todos los trozos que participan en ese frame
% malos=find(n_distintos>n_peces);
% for c_frames=malos(:)'
%     for c_trozos=1:n_distintos(c_frames)
%         trozos(trozos==trozos(c_frames,c_trozos))=0;
%     end
% end
n_distintos=sum(trozos>0,2);
framestodos=find(n_distintos==n_peces);
grupostrozos=NaN(length(framestodos),n_peces);
c_grupos=0;
for c_frames=framestodos(:)'
     trozos_act=sort(trozos(c_frames,1:n_peces));
     if c_grupos==0 || any(grupostrozos(c_grupos,:)~=trozos_act)
         c_grupos=c_grupos+1;
         grupostrozos(c_grupos,:)=trozos_act;
     end % if es un grupo nuevo
end % c_frames
grupostrozos=grupostrozos(1:c_grupos,:);

trozosbuenos=sort(unique(grupostrozos(:)));
trozo2nfbuenos=NaN(1,max(trozos(:)));
manchasbuenas=false(size(trozos));
% Busca frames válidos y no demasiado solapantes en cada trozo
for c_trozos=trozosbuenos(:)'
    ind=find(trozos==c_trozos);
    [frame,mancha]=ind2sub(size(trozos),ind);
    [s,orden]=sort(frame);
    solapos_act=solapos(ind(orden));
    if quitaborde
        buenos_act=indiv(ind(orden)) & segmbuena(ind(orden)) & ~borde(ind(orden));
    else
        buenos_act=indiv(ind(orden)) & segmbuena(ind(orden));
    end
    pos_act=-Inf;
    siguiente=find(solapos_act>=pos_act+umbral_solapa,1);   
    n_img=length(ind);
%     if c_trozos==926
%         keyboard
%     end
    while ~isempty(siguiente) && siguiente<=n_img
        siguiente_old=siguiente;
        while siguiente<=n_img && ~buenos_act(siguiente)
            siguiente=siguiente+1;
        end
        if siguiente<=n_img
            manchasbuenas(ind(orden(siguiente)))=true;
            pos_act=solapos_act(siguiente);
            siguiente=find(solapos_act>=pos_act+umbral_solapa,1);
        end
%         if ~(siguiente_old<siguiente)
%             keyboard
%         end
    end
    trozo2nfbuenos(c_trozos)=sum(manchasbuenas(ind));
end

intervalosbuenos.grupostrozos=grupostrozos;
intervalosbuenos.manchasbuenas=manchasbuenas;
intervalosbuenos.trozo2nfbuenos=trozo2nfbuenos;

% for c_frames=primerframe:n_frames-1
%     if mod(c_frames,1000)==0
%         fprintf('%g,',c_frames)
%     end
%     if datosegm.frame2archivo(c_frames,1)~=archivo_act
%         archivo_act=datosegm.frame2archivo(c_frames,1);
%         load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
%     end
%     frame_act=datosegm.frame2archivo(c_frames,2);
%     if all(size(segm(frame_act).solapamiento)==n_peces) && all(sum(segm(frame_act).solapamiento>0)==1) && all(sum(segm(frame_act).solapamiento>0,2)==1)
%         intervalosbuenos.frames(c_frames)=true;
%     end
% end % c_frames
% fprintf('\n')
% 
% diferencias=diff([false intervalosbuenos.frames false]); % Añado los false para que aparezcan bordes de intervalo al principio y al final
% intervalosbuenos.iniciofinal(:,1)=find(diferencias==1);
% intervalosbuenos.iniciofinal(:,2)=find(diferencias==-1)-1;
% 
% n_intervalos=size(intervalosbuenos.iniciofinal,1)
% % intervalosbuenos.logsolap=zeros(n_intervalos,n_peces);
% % intervalosbuenos.distancia=zeros(n_intervalos,n_peces);
% intervalosbuenos.framespararefs=false(n_frames,n_peces);
% intervalosbuenos.n_validos=zeros(n_intervalos,n_peces);
% archivo_act=-1;
% for c_intervalos=1:n_intervalos
%     fprintf('%g,',c_intervalos)
%     if datosegm.frame2archivo(intervalosbuenos.iniciofinal(c_intervalos,1),1)~=archivo_act
%         if archivo_act>0
%             save([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)],'segm')
%         end
%         archivo_act=datosegm.frame2archivo(intervalosbuenos.iniciofinal(c_intervalos,1),1);
%         load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
%     end
%     frame_act=datosegm.frame2archivo(intervalosbuenos.iniciofinal(c_intervalos,1),2);
%     labels_sig=1:n_peces;
% %     segm(frame_act).labels=1:n_peces;    
%     pixels_ultimo=cell(1,length(segm(frame_act).pixels));
%     for c_peces=1:n_peces
%         pixels_ultimo{c_peces}=false(1,prod(datosegm.tam));
%         if segm(frame_act).segmbuena(c_peces) && (~quitaborde || ~segm(frame_act).borde(c_peces))
%             pixels_ultimo{c_peces}(segm(frame_act).pixels{c_peces})=true;
%             intervalosbuenos.framespararefs(intervalosbuenos.iniciofinal(c_intervalos,1),c_peces)=true; 
%         else
%             intervalosbuenos.framespararefs(intervalosbuenos.iniciofinal(c_intervalos,1),c_peces)=false; 
%         end
%     end
%     centros_ultimo=segm(frame_act).centros;
% %     archivo_act=-1;
%     for c_frames=intervalosbuenos.iniciofinal(c_intervalos,1):intervalosbuenos.iniciofinal(c_intervalos,2)-1        
%         if datosegm.frame2archivo(c_frames,1)~=archivo_act
%             if archivo_act>0
%                 save([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)],'segm')
%             end
%             archivo_act=datosegm.frame2archivo(c_frames,1);
%             load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])            
%         end
%         frame_act=datosegm.frame2archivo(c_frames,2);
%         segm(frame_act).labels=labels_sig;
%         for c_peces=1:n_peces
%             bicho_sig=find(segm(frame_act).solapamiento(c_peces,:));
%             labels_sig(bicho_sig)=segm(frame_act).labels(c_peces);
%             pixels_act=false(1,prod(datosegm.tam));
%             pixels_act(segm(frame_act).pixels{c_peces})=true;
%             solap_act=sum(pixels_act & pixels_ultimo{segm(frame_act).labels(c_peces)})/sum(pixels_ultimo{segm(frame_act).labels(c_peces)});
%             if solap_act<umbral_solapa && segm(frame_act).segmbuena(c_peces) && (~quitaborde || ~segm(frame_act).borde(c_peces))
%                 intervalosbuenos.framespararefs(c_frames,c_peces)=true;
%                 pixels_ultimo{segm(frame_act).labels(c_peces)}=pixels_act;
%                 intervalosbuenos.n_validos(c_intervalos,segm(frame_act).labels(c_peces))=intervalosbuenos.n_validos(c_intervalos,segm(frame_act).labels(c_peces))+1;
%             end % if válido
% %             dist_act=sqrt(sum((segm(frame_act).centros(c_peces,:)-centros_ultimo(segm(frame_act).labels(c_peces),:)).^2));
% %             if dist_act>umbral_dist
% %                 intervalosbuenos.framespararefs(frame_act,c_peces)=true;
% %                 centros_ultimo(segm(frame_act).labels(c_peces),:)=segm(frame_act).centros(c_peces,:);
% %                 intervalosbuenos.n_validos(c_intervalos,segm(frame_act).labels(c_peces))=intervalosbuenos.n_validos(c_intervalos,segm(frame_act).labels(c_peces))+1;
% %             end
%         end % c_bichos
%     end % c_frames
% end % c_intervalos
% save([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)],'segm')
% fprintf('\n')
