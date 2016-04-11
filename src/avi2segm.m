% 01-Feb-2014 11:18:47 Cambio la definición de centroide, ahora es el
% centro del conjunto de pixels más alejados de los bordes
% 21-Dec-2013 14:35:22 Mejoras de eficiencia, y paralelización
% 20-Dec-2013 20:12:55 Introduzco el número máximo de manchas.
% 13-Aug-2013 12:03:26 Anulo la parte en la que no se usa datosegm.mascara
% 10-Apr-2013 17:26:34 Incorporo la posibilidad de que no se haga la segmentaci�n de todos los frames (o de ninguno), para los casos en los que s�lo se traquea un intervalo
% 27-Feb-2013 20:03:03 Me doy cuenta de que la mediana tarda much�simo m�s que la media, y es lo que m�s est� tardando de la segmentaci�n. As� que pongo otra vez media para la normalizaci�n de intensidades.
% 08-Feb-2013 17:27:31 Hago que pase el video a grayscale
% 23-Nov-2012 16:33:51 Actualizo: Si existe datosegm.mascara, no usa la roi.
% 23-Nov-2012 08:47:06 Meto aqu� cambiacontraste
% 12-Nov-2012 17:45:36 Nada.
% 12-Nov-2012 17:35:27 Cambio media por mediana para la normalizaci�n de los frames
% 17-Oct-2012 20:56:36 Cambio limpiamierda. Ahora cuando la segmentaci�n no
% es buena elimina los pixeles mierda, y si la mancha que queda supera el
% umbral de pez la coge.
% 31-Jul-2012 09:33:38 A�ado la posibilidad de excluir una zona para el
% c�lculo de intensmed
% 26-Jul-2012 20:38:56 A�ado el l�mite m�ximo de pixels
% 23-Jul-2012 20:46:21 A�ado limpiamierda
% 14-Mar-2012 20:55:50 Hago que cuando no hay roi, el borde vaya por el
% borde, valga la redundancia.
% 31-Jan-2012 19:56:40 A�ado la opci�n de roi circular
% 22-Nov-2011 18:19:37 A�ado la resegmentacion
% 18-Nov-2011 10:59:36 A�ado la posibilidad de seleccionar un roi
% 14-Nov-2011 19:02:48 Correcci�n. Cuando ind tiene dos valores, hago que
% coja el m�s grande.
% 11-Nov-2011 18:08:37 Vuelvo a usar la intensidad sola para segmentar, y
% la diferencia s�lo para seleccionar las manchas que est�n bien.
% 10-Nov-2011 17:55:22 Lo cambio, de modo que cuando usaresta=1 s�lo usa la diferencia para
% la segmentaci�n.
% APE 10 nov 11 Viene de avi2miniframes. Cambio la segmentaci�n, usando
% imdilate sobre la diferencia. Espero que esto mejore los casos donde hay
% mucho fondo.

% (C) 2014 Alfonso P�rez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Cient�ficas

% Una forma de filtrar sombras que ser�a m�s r�pida que el uso de
% videomedio ser�a simplemente coger aqu�llas cuyo m�nimo de intensidad
% estuviera por debajo de un umbral muy restrictivo. Funcionar�a casi
% siempre, pero la descarto porque probablemente fallar�a en los frames en
% los que el pez queda muy desenfocado debido al movimiento.

function [segm,frame_out]=avi2segm(video,datosegm,usaresta,roi,traqueaframes)

centrosnuevos=true; % Mantengo la posibilidad de revertir f�cilmente a los centros antiguos

if isfield(datosegm,'max_manchas') && isfield(datosegm.max_manchas,'relativo') && isfield(datosegm.max_manchas,'absoluto')
    max_manchas=max([datosegm.max_manchas.absoluto datosegm.max_manchas.relativo*datosegm.n_peces]);
else
    max_manchas=Inf;
end

if nargin<5 || isempty(traqueaframes)
    traqueaframes=true(size(video,4),1);
end


%Daniel
if size(video,3)==3
    for c_frames=1:size(video,4)
        frame=video(:,:,:,c_frames);               
        frame=colour_filter(frame);
        video(:,:,1,c_frames)=rgb2gray(frame);%Daniel
        %video(:,:,1,c_frames)=rgb2gray(video(:,:,:,c_frames));
    end
    video=video(:,:,1,:);
end

if datosegm.cambiacontraste
    video=255-video;
end

umbralmierda_segmbuena=.1;
umbral_mierdecillas=datosegm.umbral_npixels/5; % Tama�o por debajo del cual se desprecian los restos de las manchas que solapaban con fondo.
% umbralmierda_pez=.7;

% if usaresta
%     fprintf('Atenci�n: La segmentaci�n aqu� se est� haciendo con la diferencia, pero al construir los mapas se har� con la intensidad')
% end

% if nargin<2 || isempty(datosegm)
%     umbral=.85;
% else
%     umbral=datosegm.umbral;
% end
if nargin<3 || isempty(usaresta)
    usaresta=false; % Por defecto, NO usa la resta par filtrar manchas (por compatibilidad con versiones anteriores)
end
if nargin<4
    roi=[];
end

% if ~isfield(datosegm,'mascara')
%     error('Esto est� obsoleto')
%     mascara=true(datosegm.tam);
%     borde=false(datosegm.tam);
%     if ~isempty(roi)
%         if numel(roi)==4 % roi cuadrada
%             roi=round(roi);
%             x=1:datosegm.tam(2);
%             y=1:datosegm.tam(1);
%             mascara(:,x<min(roi(:,1)))=false;
%             mascara(:,x>max(roi(:,1)))=false;
%             mascara(y<min(roi(:,2)),:)=false;
%             mascara(y>max(roi(:,2)),:)=false;
%             borde(:,min(roi(:,1)))=true;
%             borde(:,max(roi(:,1)))=true;
%             borde(min(roi(:,2)),:)=true;
%             borde(max(roi(:,2)),:)=true;
%         elseif numel(roi)==3 % roi circular
%             X=repmat(1:datosegm.tam(2),[datosegm.tam(1) 1]);
%             Y=repmat((1:datosegm.tam(1))',[1 datosegm.tam(2)]);
%             mascara=(X-roi(1)).^2 + (Y-roi(2)).^2<=roi(3)^2;
%             borde=(X-roi(1)).^2 + (Y-roi(2)).^2>=(roi(3)-1)^2;
%         end % if roi cuadrada
%     else
%         borde(:,1)=true;
%         borde(:,end)=true;
%         borde(1,:)=true;
%         borde(end,:)=true;
%     end
% else
    mascara=datosegm.mascara;
    borde=datosegm.borde;
% end
% imagesc(double(mascara)+3*double(borde))
% caca
if ~isfield(datosegm,'mascara_intensmed') || isempty(datosegm.mascara_intensmed)
    mascara_intensmed=mascara;
else
    mascara_intensmed=datosegm.mascara_intensmed;
end

tam=size(video(:,:,1,1));
X=repmat(1:tam(2),[tam(1) 1]);
Y=repmat((1:tam(1))',[1 tam(2)]);
n_frames=size(video,4);
% radio_filtro=7;
% x=-radio_filtro:radio_filtro;
% x=repmat(x,[length(x) 1]);
% pelota=sqrt(x.^2+x'.^2)<=radio_filtro
umbral_orig=datosegm.umbral; % Saco las cosas de datosegm, para no tener que mandar datosegm entero a cada procesador
umbral_npixels=datosegm.umbral_npixels;
limpiamierda=datosegm.limpiamierda;
if isfield(datosegm,'pixelsmierda')
    pixelsmierda=datosegm.pixelsmierda;
else
    pixelsmierda=[];
end
tam=datosegm.tam;
if isfield(datosegm,'umbral_npixelsmax')
    umbral_npixelsmax=datosegm.umbral_npixelsmax;
else
    umbral_npixelsmax=[];
end
segm(n_frames).intensmed=[];
segm(n_frames).centros=[];
segm(n_frames).pixels={};
segm(n_frames).miniframes={};
segm(n_frames).segmbuena=[];
segm(n_frames).borde=[];
distancias=zeros(datosegm.tam,'single');
for c_frames=1:n_frames
    if traqueaframes(c_frames)
        frame_orig=video(:,:,1,c_frames);
        frame=double(frame_orig);
        segm(c_frames).intensmed=mean(frame(mascara_intensmed));
        umbral=umbral_orig*segm(c_frames).intensmed;
        %     frame=frame/segm(c_frames).intensmed; % ESTO ES M�S EFICIENTE SI LO QUE RE-ESCALO ES EL UMBRAL. PERO SI LO CAMBIO TENGO QUE TENER CUIDADO CON EL SEGUNDO OUTPUT
        %     if usaresta
        %         binario_todos=(frame<umbral(1)) & mascara;
        %         diferencia=frame-videomedio;
        %         binario_dif=(diferencia<datosegm.umbral_dif) & mascara;
        %         manchas=bwconncomp(binario_todos);
        %         L=labelmatrix(manchas);
        %         manchas_dif=bwconncomp(binario_dif);
        %         n_manchas=length(manchas_dif.PixelIdxList);
        %         binario=false(datosegm.tam);
        %         c_manchasbuenas=0;
        %         listapixels=cell(1,n_manchas);
        %         segmbuena=false(1,n_manchas);
        %         for c_manchas=1:n_manchas
        %             ind=L(manchas_dif.PixelIdxList{c_manchas});
        %             ind=ind(ind>0);
        % %             1
        %             if length(ind)>0
        % %                 2
        %                 [ind,numUnique] = count_unique(ind); %% ATENCI�N: ESTA FUNCI�N NO ES M�A, LA HE COGIDO DE MATLABCENTRAL
        %                 [m,ind_mayor]=max(numUnique);
        %                 ind=ind(ind_mayor); % Si hay m�s de un valor, coge el que m�s pixels tenga
        %                 mancha_act=L==ind;
        %                 if sum(mancha_act(:))>length(manchas_dif.PixelIdxList{c_manchas})*1.5 % Si se agranda demasiado, la rechaza y usa la que viene de la diferencia
        % %                     3
        %                     segmbuena_act=false;
        %                     pixels_act=manchas_dif.PixelIdxList{c_manchas};
        %                 else % Si todo est� bien, usamos la segmentaci�n por intensidades
        % %                     4
        %                     segmbuena_act=true;
        %                     pixels_act=find(mancha_act);
        %                 end
        %                 if length(pixels_act)>datosegm.umbral_npixels
        % %                     4
        %                     c_manchasbuenas=c_manchasbuenas+1;
        %                     segmbuena(c_manchasbuenas)=segmbuena_act;
        %                     listapixels{c_manchasbuenas}=pixels_act;
        %                 end
        %             end
        % %             hold off
        % %             imagesc(frame)
        % %             hold on
        % %             [y,x]=ind2sub(datosegm.tam,manchas_dif.PixelIdxList{c_manchas});
        % %             plot(x,y,'r.')
        % %             pause
        %         end % c_manchas
        %         listapixels=listapixels(1:c_manchasbuenas);
        %         segmbuena=segmbuena(1:c_manchasbuenas);
        %         %         imagesc(figura)
        %         %         colorbar
        %         %         ginput(1);
        %     else
        binario=(frame<umbral(1)) & mascara;
        manchas=bwconncomp(binario);
        tams=cellfun(@(x) length(x),manchas.PixelIdxList);
        buenos=tams>umbral_npixels;
        listapixels=manchas.PixelIdxList(buenos);
        tams=tams(buenos);
        segmbuena=true(1,sum(buenos));
        ratiosmierda=NaN(1,sum(buenos));
        if limpiamierda
            if ~isempty(pixelsmierda)
                for c_manchas=1:length(listapixels)
                    ratiosmierda(c_manchas)=sum(pixelsmierda(listapixels{c_manchas}))/tams(c_manchas);
                end
            else
                ratiosmierda=zeros(1,length(listapixels));
            end
            %             ratiosmierda
            malos=find(ratiosmierda>umbralmierda_segmbuena);
            segmbuena(malos)=false;
            for c_malos=malos
                listapixels{c_malos}=listapixels{c_malos}(~pixelsmierda(listapixels{c_malos}));
                tams(c_malos)=length(listapixels{c_malos});
                if tams(c_malos)>umbral_npixels
                    % Quito manchas aisladas muy peque�as
                    lienzo=false(tam);
                    lienzo(listapixels{c_malos})=true;
                    manchas_act=bwconncomp(lienzo);
                    tams_act=cellfun(@(x) length(x),manchas_act.PixelIdxList);
                    malos_act=find(tams_act<=umbral_mierdecillas);
                    if ~isempty(malos_act)
                        for c_malosact=malos_act
                            lienzo(manchas_act.PixelIdxList{c_malosact})=false;
                        end
                        listapixels{c_malos}=find(lienzo);
                    end
                end
                tams(c_malos)=length(listapixels{c_malos});
            end
            buenos=tams>umbral_npixels;
            %             buenos=ratiosmierda<umbralmierda_pez;
            listapixels=listapixels(buenos);
            segmbuena=segmbuena(buenos);
            tams=tams(buenos);
        end
        if ~isempty(umbral_npixelsmax)
            segmbuena(tams>umbral_npixelsmax)=false;
        end
        %     end % if usaresta
        
        % Resegmentaci�n
        if length(umbral)==2
            binario_resegm=(frame<umbral(2)) & mascara;
            umbralnpixels_act=umbral_npixels*sum(binario_resegm(:))/sum(binario(:));
            manchas_resegm=bwconncomp(binario_resegm);
            tams_resegm=cellfun(@(x) length(x),manchas_resegm.PixelIdxList);
            buenos=tams_resegm>umbralnpixels_act;
            manchas_resegm.NumObjects=sum(buenos);
            manchas_resegm.PixelIdxList=manchas_resegm.PixelIdxList(buenos);
            L=labelmatrix(manchas_resegm);
            for c_manchas=length(listapixels):-1:1
                ind=L(listapixels{c_manchas});
                ind=ind(ind>0);
                ind=unique(ind);
                if length(ind)>1
                    listapixels=[listapixels(1:c_manchas-1) manchas_resegm.PixelIdxList(ind) listapixels(c_manchas+1:end)];
                    segmbuena=[segmbuena(1:c_manchas-1) false(1,length(ind)) segmbuena(c_manchas+1:end)];
                end
            end % c_manchas
        end
        n_buenos=length(listapixels);
    else
        n_buenos=0;
        listapixels={};
        segmbuena=zeros(1,0);
        segm(c_frames).intensmed=NaN;
    end
    % Si hay demasiadas manchas, no las coge (para evitar que la memoria se
    % vaya de madre m�s adelante)
    if n_buenos>max_manchas
        n_buenos=0;
        listapixels=[];
        segmbuena=[];
    end
    segm(c_frames).centros=NaN(n_buenos,2);
    segm(c_frames).max_bwdist=NaN(1,n_buenos);
    segm(c_frames).bwdist_centro=NaN(1,n_buenos);
    segm(c_frames).pixels=cell(1,n_buenos);
    segm(c_frames).pixels_core=cell(1,n_buenos);
    segm(c_frames).miniframes=cell(1,n_buenos);
    segm(c_frames).segmbuena=segmbuena;
    segm(c_frames).borde=false(size(segmbuena));
    
    %     % Quito el fondo, para que no salgan cosas raras en los miniframes
    %     frame_uint8=video(:,:,1,c_frames);
    %     frame_uint8(~binario)=255;
    for c_buenos=1:length(listapixels)
        %         if tams(buenos(c_buenos))>1.5*sum(binario_dif(manchas.PixelIdxList{buenos(c_buenos)}))
        %             % Si la mancha ha crecido demasiado, cogemos s�lo la parte que
        %             % coincide con la segmentaci�n sin videomedio
        %             manchas.PixelIdxList{buenos(c_buenos)}=manchas.PixelIdxList{buenos(c_buenos)}(binario_dif(manchas.PixelIdxList{buenos(c_buenos)}));
        %             segm(c_frames).segmbuena(c_buenos)=false;
        %         else
        %             segm(c_frames).segmbuena(c_buenos)=true;
        %         end % if la mancha crece demasiado
        if centrosnuevos
            lienzo=false(datosegm.tam);
            lienzo(listapixels{c_buenos})=true;
            ind=find(lienzo); % En este caso es m�s r�pido hacerlo con find que sin find            
            x=X(ind);
            y=Y(ind);            
            limites=[min(x) max(x) min(y) max(y)];
            % Nota: distancias no se resetea, as� que quedan elementos de
            % pasadas anteriores. No importa, porque s�lo voy a utilizar
            % los �ndices que est�n en ind. Pero hay que tener cuidado con
            % esto          
            minilienzo=true(diff(limites(3:4))+3,diff(limites(1:2))+3); % Dejo un pixel de margen para que el exterior del pez cuente como que no hay pez
            minilienzo(2:end-1,2:end-1)=~lienzo(limites(3):limites(4),limites(1):limites(2));
            distancias_mini=bwdist(minilienzo);
            distancias(limites(3):limites(4),limites(1):limites(2))=distancias_mini(2:end-1,2:end-1);
            segm(c_frames).max_bwdist(c_buenos)=max(distancias(ind));
            pixels_act=distancias(ind)>=segm(c_frames).max_bwdist(c_buenos)-3;
            segm(c_frames).pixels_core{c_buenos}=ind(pixels_act);
            segm(c_frames).centros(c_buenos,1:2)=[mean(x(pixels_act)) mean(y(pixels_act))];
            segm(c_frames).bwdist_centro(c_buenos)=distancias(round(segm(c_frames).centros(c_buenos,2)),round(segm(c_frames).centros(c_buenos,1)));
        else
            segm(c_frames).centros(c_buenos,1:2)=[mean(X(listapixels{c_buenos})) mean(Y(listapixels{c_buenos}))];
        end
        segm(c_frames).pixels{c_buenos}=listapixels{c_buenos};
        segm(c_frames).miniframes{c_buenos}=frame_orig(min(Y(listapixels{c_buenos})):max(Y(listapixels{c_buenos})),min(X(listapixels{c_buenos})):max(X(listapixels{c_buenos})));
        segm(c_frames).borde(c_buenos)=any(borde(listapixels{c_buenos}));
    end
    
    % HAGO QUE SEGMBUENA INCORPORE TAMBI�N EL BORDE, PARA QUE EL RESTO DEL
    % TRACKING EXCLUYA LOS QUE TOCAN BORDE.
    segm(c_frames).segmbuena=segm(c_frames).segmbuena & ~segm(c_frames).borde;
    
    %     if c_frames==3
    %             keyboard
    %         end
end % c_frames
if nargout>=2
    frame_out=double(video(:,:,1,1));    
    frame_out=frame_out/segm(1).intensmed;
end
