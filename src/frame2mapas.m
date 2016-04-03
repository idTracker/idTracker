% 23-Dec-2013 21:47:35 Añado la entrada dist_max
% 10-Aug-2011 16:45:49 Cambio el umbral por defecto a .85 para ser
% consistente con avi2miniframes
% 10 ago 11 Corrijo para que no falle la segmentación al bajar la
% resolución
% 09-Jun-2011 17:06:08 Vuelvo a activar la reducción de resolución
% 31-May-2011 15:16:26 Elimino la versión vieja (ahora todo lo hace
% sumaelementosplus3)
% 17-May-2011 23:17:57 Añado el mex-file
% 13-May-2011 18:01:10 Eficiencia
% APE 8 may 2011 Viene de frame2mapacontraste

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function mapas=frame2mapas(frame,intensmed,umbral,reduceresol,dist_max)

if nargin<3 || isempty(umbral)
%     umbral=.9; % Plato pequeño
    umbral=.85; % Plato grande
end
if nargin<4 || isempty(reduceresol)
    reduceresol=1; % Esto significa que no reduce la resolución
end
if nargin<5 || isempty(dist_max)
    dist_max=100;
end

intens_max=umbral;

tam=size(frame);
frame=double(frame);
if nargin<2 || isempty(intensmed)
    intensmed=mean(frame(:));
end
frame=frame/intensmed;
buenos=frame<umbral;
manchas=bwconncomp(buenos);
npixels=cellfun(@(x) size(x,1),manchas.PixelIdxList);
[n_pixels,buena]=max(npixels);
buenos(:)=false;
buenos(manchas.PixelIdxList{buena})=true;

% Reduce la resolución (para que vaya más rápido)
frame1=frame;
if reduceresol>1
    while mod(tam(1),reduceresol)~=0
        buenos=buenos(1:end-1,:);
        frame=frame(1:end-1,:);
        tam=size(frame);
    end
    while mod(tam(2),reduceresol)~=0
        buenos=buenos(:,1:end-1);
        frame=frame(:,1:end-1);
        tam=size(frame);
    end
    frame_old=frame;
    buenos_old=buenos;
    frame=zeros([tam(1)/reduceresol tam(2)]);
    buenos=zeros([tam(1)/reduceresol tam(2)]);
    for c=1:reduceresol
        frame=frame+frame_old(c:reduceresol:end,:);
        buenos=buenos+buenos_old(c:reduceresol:end,:);
    end
    frame_old=frame;
    buenos_old=buenos;
    frame=zeros(tam/reduceresol);
    buenos=zeros(tam/reduceresol);
    for c=1:reduceresol
        frame=frame+frame_old(:,c:reduceresol:end);
        buenos=buenos+buenos_old(:,c:reduceresol:end);
    end
    frame=frame/reduceresol^2;
    tam=size(frame);
end
buenos=buenos>=reduceresol^2/2;



manchas=bwconncomp(buenos);
npixels=cellfun(@(x) size(x,1),manchas.PixelIdxList);
[n_pixels,buena]=max(npixels);
[y,x]=ind2sub(tam,manchas.PixelIdxList{buena}); % A estas alturas se supone que sólo queda una mancha
rectangulo=[min(x) max(x) min(y) max(y)];
lienzo=false(tam);
lienzo(manchas.PixelIdxList{buena})=true;
lienzo=lienzo(rectangulo(3):rectangulo(4),rectangulo(1):rectangulo(2));
ind=find(lienzo);
[ind_fil,ind_col]=ind2sub(size(lienzo),ind);
intens=frame(manchas.PixelIdxList{buena});
% intens=intens/mean(intens);

% tam_lienzo=size(lienzo);
% X=repmat(-tam_lienzo(2):tam_lienzo(2),[2*tam_lienzo(1)+1 1]);
% Y=repmat(-tam_lienzo(1):tam_lienzo(1),[2*tam_lienzo(2)+1 1])';
% distbin=floor(sqrt(X.^2+Y.^2))+1;


X=repmat(0:dist_max,[dist_max+1 1]);
dist=sqrt(X.^2+X'.^2);
cerca2=double(dist<dist_max);
distbin2=floor(dist)+1; 

binsc_dist=0:dist_max;
nbins_intens=40;
intens_restas=intens*nbins_intens/intens_max; % De este modo, floor(intens)+1 nos da el bin en el que cae cada intensidad.
intens_sumas=intens*nbins_intens/intens_max/2; % De este modo, floor(intens)+1 nos da el bin en el que cae cada intensidad.

tam_hist=[nbins_intens length(binsc_dist)];
mapas=sumaelementosplus3(tam_hist,ind_fil,ind_col,intens_restas,intens_sumas,distbin2,cerca2);
mapas=reshape(mapas,[tam_hist 2]);

% [s,orden_dist]=sort(distbin(:));
% nfilas_dist=size(distbin,1);
% centro=[tam_lienzo(1)+1 tam_lienzo(2)+1];
% 
% ind_buenos=sub2ind(size(distbin),ind_fil-ind_fil(1)+centro(1),ind_col-ind_col(1)+centro(2));
% indfil_old=ind_fil(1);
% indcol_old=ind_col(1);


% binsc_intens=0:.025:intens_max;

% [h,pixel2bin]=histc(intens,binsc_intens);
% pixel2bin=pixel2bin';


% n_elems=prod(tam_hist);
% mapas=zeros(prod([tam_hist 2]),1);
% mapas2=zeros(prod([tam_hist 2]),1);


% quedan=true(1,n_pixels);

% semilla_segundoind=tam_hist(1)*(pixel2bin-1);
% ind_restas=NaN(1,n_pixels);
% ind_sumas=NaN(1,n_pixels);
% for c_pixels=1:1:n_pixels  
%     cambiofilas=ind_fil(c_pixels)-indfil_old;
%     cambiocolumnas=ind_col(c_pixels)-indcol_old;
%     indfil_old=ind_fil(c_pixels);
%     indcol_old=ind_col(c_pixels);
%     if cambiofilas~=0
%         ind_buenos = ind_buenos - cambiofilas;
%     end
%     if cambiocolumnas~=0
%         ind_buenos = ind_buenos - nfilas_dist*cambiocolumnas;
%     end
%     distbin_act(c_pixels:n_pixels)=distbin(ind_buenos(c_pixels:n_pixels));
% %     cerquismo(c_pixels:n_pixels)=cerquismo(ind_buenos(c_pixels:n_pixels));
%     cerca=distbin_act<=dist_max; 
%     buenos = cerca & quedan;    
% %     ind_restas(buenos)=floor(abs(intens_restas(buenos)-intens_restas(c_pixels)))+1;
% %     ind_sumas(buenos)=floor(abs(intens_sumas(buenos)+intens_sumas(c_pixels)))+1;
% %     
% % %     ind_restas(buenos)=floor(abs(intens_restas(buenos)-intens_restas(c_pixels)))+1;
% % %     ind_sumas(buenos)=floor(abs(intens_sumas(buenos)+intens_sumas(c_pixels)))+1;
% % %     ind1 = ind_restas(buenos) + tam_hist(1)*(distbin_act(buenos)-1);     
% % %     ind2 = ind_sumas(buenos) + tam_hist(1)*(distbin_act(buenos)-1); 
% %     
% %     ind=NaN(2*sum(buenos),1);     
% %     ind(1:sum(buenos),1) = ind_restas(buenos) + tam_hist(1)*(distbin_act(buenos)-1);   
% %     ind(sum(buenos)+1:2*sum(buenos),1) = n_elems+ ind_sumas(buenos) + tam_hist(1)*(distbin_act(buenos)-1); 
% %     mapas=sumaelementos(mapas,ind);
%     distbinact_act=distbin_act(buenos);
%     mapas=sumaelementosplus2(mapas,intens_restas(buenos),intens_restas(c_pixels),intens_sumas(buenos),intens_sumas(c_pixels),distbinact_act,tam_hist(1),n_elems);
% 
% %     ind2_restas=floor(abs(intens_restas(buenos)-intens_restas(c_pixels)))+1;
% %     ind2_sumas=floor(abs(intens_sumas(buenos)+intens_sumas(c_pixels)))+1;    
% %     mapas2=sumaelementosplus(mapas2,ind2_restas,ind2_sumas,distbinact_act,tam_hist(1),n_elems);
%     
% %     if sum(abs(mapas-mapas2))>0
% %         keyboard
% %     end
%     
% %     for c=1:length(ind)
% %         mapas(ind(c))=mapas(ind(c))+1;
% %     end
% %     ind1=sort(ind1);
% %     difs=diff(ind1);
% %     cambios=find(difs>0);
% %     numeros=diff([0 cambios length(ind1)]);
% %     indices=cumsum([ind1(1) difs(cambios)]); % ESTO ES UNA IDIOTEZ.
% %     mapas(indices)=mapas(indices)+numeros;
% %     ind2=sort(ind2);
% %     difs=diff(ind2);
% %     cambios=find(difs>0);
% %     numeros=diff([0 cambios length(ind2)]);
% %     indices=n_elems + cumsum([ind2(1) difs(cambios)]); % ESTO ES UNA IDIOTEZ.
% %     mapas(indices)=mapas(indices)+numeros;
%     quedan(c_pixels)=false;
% end % c_pixels
% mapas=reshape(mapas,[tam_hist 2]);

% histogramaco(:,:,end-1)=histogramaco(:,:,end-1)+histogramaco(:,:,end);
% histogramaco=histogramaco(:,:,1:end-1);
% for c1_bins=1:size(histogramaco,1)
%     for c2_bins=c1_bins+1:size(histogramaco,2)
%         histogramaco(c1_bins,c2_bins,:)= histogramaco(c1_bins,c2_bins,:)+ histogramaco(c2_bins,c1_bins,:);
%          histogramaco(c2_bins,c1_bins,:)=0;
%     end
% end




% 
% 
% 
% tam=size(frame);
% frame=double(frame);
% if nargin<2 || isempty(intensmed)
%     intensmed=mean(frame(:));
% end
% frame=frame/intensmed;
% % figure
% % imagesc(frame)
% 
% for c=1:2
%     if mod(tam(1),2)~=0
%         frame=frame(1:end-1,:);
%     end
%     if mod(tam(2),2)~=0
%         frame=frame(:,1:end-1);
%     end    
%     frame=(frame(1:2:end,:)+frame(2:2:end,:))/2;
%     frame=(frame(:,1:2:end)+frame(:,2:2:end))/2;
%     tam=size(frame);
% end
% % figure
% % imagesc(frame)
% % caca
% 
% buenos=frame<.9;
% 
% manchas=bwconncomp(buenos);
% npixels=cellfun(@(x) size(x,1),manchas.PixelIdxList);
% [n_pixels,buena]=max(npixels);
% [y,x]=ind2sub(tam,manchas.PixelIdxList{buena});
% intens=frame(manchas.PixelIdxList{buena});
% % intens=intens/mean(intens);
% 
% binsc_intens=0:.025:intens_max;
% pendiente=(length(binsc_intens)-1)/intens_max;
% binsc_dist=0:dist_max;
% [h,pixel2bin]=histc(intens,binsc_intens);
% pixel2bin=pixel2bin';
% 
% tam_hist=[length(binsc_dist) length(binsc_intens)];
% mapa=zeros(tam_hist);
% % tic
% quedan=true(1,n_pixels);
% dist_act=NaN(1,n_pixels);
% % semilla_segundoind=tam_hist(1)*(pixel2bin-1);
% for c_pixels=1:1:n_pixels
%     dist_act=sqrt((x-x(c_pixels)).^2+(y-y(c_pixels)).^2);
%     dist_act(c_pixels:end)=sqrt((x(c_pixels:end)-x(c_pixels)).^2+(y(c_pixels:end)-y(c_pixels)).^2);
%     cerca=dist_act'<=dist_max;
%     buenos = cerca & quedan;
%     contraste=abs(intens(c_pixels)-intens(buenos));
%     histog_act=hist3([dist_act(buenos) contraste],'Edges',{binsc_dist' binsc_intens'});
%     mapa=mapa+histog_act;
% %     dist2bin(c_pixels:n_pixels)=floor(dist_act(c_pixels:n_pixels))+1; % Esto es equivalente a hacer el histograma para binsc [0 1 2 3...]     
% % %     dist2bin(c_pixels:n_pixels)=floor(dist_act)+1; % Esto es equivalente a hacer el histograma para binsc [0 1 2 3...]   
% 
% %     contraste=abs(intens(c_pixels)-intens(buenos));
% %     ind_contraste=floor(contraste*pendiente)+1;
% %     ind = ind_contraste + tam_hist(1)*(dist2bin(buenos)-1);    
% % %     ind=sub2ind(tam_hist,repmat(pixel2bin(c_pixels),[1 sum(buenos)]),pixel2bin(buenos),dist2bin(buenos));
% %     ind=sort(ind);
% %     difs=diff(ind);
% %     cambios=find(difs>0);
% %     numeros=diff([0 cambios length(ind)]);
% %     indices=cumsum([ind(1) difs(cambios)]); % ESTO ES UNA IDIOTEZ.
% % %     histogramaco_act=hist(ind,1:n_elems);
% %     mapa(indices)=mapa(indices)+numeros;
% %     quedan(c_pixels)=false;
% %     for c2_pixels=c_pixels:n_pixels
% % %         try
% %         if dist2bin(c2_pixels)>0
% %             histogramaco(pixel2bin(c_pixels),pixel2bin(c2_pixels),dist2bin(c2_pixels))=histogramaco(pixel2bin(c_pixels),pixel2bin(c2_pixels),dist2bin(c2_pixels))+1;
% %         end
% % %         catch
% % %             keyboard
% % %         end
% %     end % c2_pixels    
% end % c_pixels
% % toc
% % histogramaco_nue=reshape(histogramaco,tam_hist);
% % caca
% % histogramaco=zeros(length(binsc_intens),length(binsc_intens),length(binsc_dist));
% % tic
% % for c_pixels=1:1:n_pixels
% %     dist_act=sqrt((x-x(c_pixels)).^2+(y-y(c_pixels)).^2);
% %     [h,dist2bin(c_pixels:n_pixels)]=histc(dist_act(c_pixels:n_pixels),binsc_dist);    
% %     for c2_pixels=c_pixels:n_pixels
% % %         try
% %         if dist2bin(c2_pixels)>0
% %             histogramaco(pixel2bin(c_pixels),pixel2bin(c2_pixels),dist2bin(c2_pixels))=histogramaco(pixel2bin(c_pixels),pixel2bin(c2_pixels),dist2bin(c2_pixels))+1;
% %         end
% % %         catch
% % %             keyboard
% % %         end
% %     end % c2_pixels    
% % end % c_pixels
% % toc
% 
% % histogramaco(:,:,end-1)=histogramaco(:,:,end-1)+histogramaco(:,:,end);
% % histogramaco=histogramaco(:,:,1:end-1);
% % for c1_bins=1:size(histogramaco,1)
% %     for c2_bins=c1_bins+1:size(histogramaco,2)
% %         histogramaco(c1_bins,c2_bins,:)= histogramaco(c1_bins,c2_bins,:)+ histogramaco(c2_bins,c1_bins,:);
% %          histogramaco(c2_bins,c1_bins,:)=0;
% %     end
% % end