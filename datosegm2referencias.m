% 26-Feb-2014 13:24:46 
% 05-Feb-2014 10:43:44 Recorto los trozos de intervalosbuenos que tengan
% más de 3000 frames (o el número que sea)
% 10-Sep-2013 11:00:34 Hago que no guarde la lista de mapas, que ocupa un
% huevo y sólo sirve para debugging.
% 03-Sep-2013 19:32:20 Hago que si no existe campo "encriptar" lea los archivos antiguos
% 08-Jul-2013 19:30:04 Hago que pueda coger grupos de trozos que solapan
% con uno ya cogido.
% 13-Jun-2013 09:57:43 Hago que reduzca el umbral_nframes si no hay trozos suficientemente largos
% 24-Apr-2013 18:33:02 Quito la transformación a double de los mapas que hay al final. Así quedarán en uint16 o uint32, lo que corresponda
% 27-Feb-2013 12:31:02 Hago que siempre dibuje las matrices
% 21-Feb-2013 16:56:51 Anulo lo de ir juntando poco a poco. Ahora junta todos de golpe. Dejo la puerta abierta a recuperar el juntado por pasos
% 13-Feb-2013 18:59:33 Hago que salga listamapas
% 12-Dec-2012 15:01:01 Añado la interacción con el panel
% 12-Dec-2012 14:47:23 Quito n_comparaciones
% 12-Dec-2012 11:54:41 Hago que junte todos los grupos de golpe y no dos a dos, a menos que haya algún trozo que rescatar.
% APE 2 ago 11 Viene de segm2referencias_nuevo2

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% En este programa, para ahorrar memoria se podrían eliminar los mapas que sobren de listamapas. Cuando algún pez
% tenga más de nframes_final frames en tams_total, se pueden eliminar mapas de ese pez de los trozos en los que no sean todavía "comparables".

function [referencias,listamapas]=datosegm2referencias(datosegm,intervalosbuenos,trozos,nframes_final,handles)

if ~isfield(datosegm,'refs_solapantes')
    datosegm.refs_solapantes=true; % Por defecto, permite que los grupos de trozos para referencias solapen. Pero sólo funcionará hasta llegar a 500 frames en las referencias
end

juntapocoapoco=false;

if nargin<4 || isempty(nframes_final)
    nframes_final=500; % Número de frames que queremos en la referencia
end
if nargin<5
    handles=[];
end

camposhandles={'ejes','waitReferences','textowaitReferences','References','lienzo_manchas','lienzo_mascara','frame','colorbar'};
if compruebahandles(handles,camposhandles)    
    set(handles.lienzo_manchas,'Visible','off')
    set(handles.lienzo_mascara,'Visible','off')
    set(handles.colorbar,'Visible','off')    
    framepintado=get(handles.frame,'CData');
    drawnow
    title(handles.ejes,'Collecting references...')
    drawnow
end

unidad=pwd;
unidad=unidad(1);
ahora=datestr(now,30);
% directorio_errores=[unidad ':\datosegm2referencias_errores\' ahora];
% listamapas.nombrearchivo_errores=[directorio_errores 'archivoerrores_'];
% if isempty(dir(directorio_errores))
%     mkdir(directorio_errores)
% end

umbral_error=10^-5;
umbral_nframes=15;

mat_validos=datosegm.indvalidos;
indvalidos{1}=find(mat_validos(:,:,1));
mat_validos(:,:,1)=false;
indvalidos{2}=find(mat_validos);

% Recorto los trozos demasiado largos
% plot(intervalosbuenos.trozo2nfbuenos)
% hold on
largos=find(intervalosbuenos.trozo2nfbuenos>datosegm.nframes_refs);
for largo=largos(:)'
    ind=find(trozos==largo & intervalosbuenos.manchasbuenas);
    [frame,mancha]=ind2sub(size(trozos),ind);
    [frame,orden]=sort(frame);
    ind=ind(orden);
    ind_sequedan=ind(equiespaciados(datosegm.nframes_refs,length(ind)));
    intervalosbuenos.manchasbuenas(ind)=false;
    intervalosbuenos.manchasbuenas(ind_sequedan)=true;
    intervalosbuenos.trozo2nfbuenos(largo)=sum(trozos(:)==largo & intervalosbuenos.manchasbuenas(:));
end
% plot(intervalosbuenos.trozo2nfbuenos,'r')
% caca

nvalidos=intervalosbuenos.trozo2nfbuenos(intervalosbuenos.grupostrozos);
if datosegm.n_peces==1
    nvalidos=nvalidos(:);
end
nvalidos_min=min(nvalidos,[],2);
solapanconcogidos=false(size(intervalosbuenos.grupostrozos));

if max(nvalidos_min)<umbral_nframes
    umbral_nframes=10;
    if max(nvalidos_min)<umbral_nframes
        umbral_nframes=5;
        if max(nvalidos_min)<umbral_nframes
            umbral_nframes=max([1 max(nvalidos_min)]);
        end
    end
end


% n_grupos=0;
n_refs=0;
nframes_max=[];
juntables=false(0);
nframes_min=0;
primero=true;
nombres_old=[];
limgrupos=50;
nframesmin_estimado=0;
matrel=NaN(datosegm.n_peces,datosegm.n_peces,0,0);
listamapas.lista=zeros([datosegm.tam_mapas 0]);
n_mapaslista=0;
maximo_todos=0;
n_trozos=0;
h_figura=-1;
cambios=true;
while max(nframes_min)<nframes_final && (max(nvalidos_min)>=umbral_nframes || sum(juntables)>1) && cambios
    cambios=false;
    %% Extrae las nuevas referencias, y actualiza menores
    nuevosgrupos=false;
    if nframesmin_estimado>=500
        datosegm.refs_solapantes=false;
    end
    if nframesmin_estimado<nframes_final && max(nvalidos_min)>=umbral_nframes && length(nframes_min)<limgrupos
        nuevosgrupos=true;
        %         n_grupos=n_grupos+1;
        
        % Primero intenta coger uno que no solape con ninguno ya cogido        
        umbral_trozosolapan=-1;
        ind_grupo=[];
        while (isempty(ind_grupo) || m<umbral_nframes) && umbral_trozosolapan<datosegm.n_peces
            umbral_trozosolapan=umbral_trozosolapan+1;
            nvalidos_act=nvalidos;
            nvalidos_act(solapanconcogidos)=Inf; % Anulo los ya cogidos
            nvalidosmin_act=min(nvalidos_act,[],2);            
            nvalidosmin_act(sum(solapanconcogidos,2)>umbral_trozosolapan)=0;
            [m,ind_grupo]=max(nvalidosmin_act);
        end        
        umbral_trozosolapan
        if umbral_trozosolapan<datosegm.n_peces
            cambios=true;
            n_refs=n_refs+1;
%         % Si no queda ninguno que no solape, coge uno que solape
%         if m<umbral_nframes    
%             disp('Permitiendo solapamiento entre grupos de trozos')
%             [m,ind_grupo]=max(nvalidos_min);
%         end
%         plot(nvalidos_min)
%         pause
% try
        grupo_act=intervalosbuenos.grupostrozos(ind_grupo,:);
% catch
%     keyboard
% end
        
        
%         plot(nvalidos_min)
%         pause
        disp(grupo_act)
        [refs_act,framesescogidos{n_refs}]=grupotrozos2refs(datosegm,trozos,intervalosbuenos,grupo_act);
        tams=cellfun(@(x) size(x,4),refs_act)        
        maximo=max(cellfun(@(x) max(x(:)),refs_act));
        maximo_todos=max([maximo maximo_todos]);
        if maximo_todos<intmax('uint16')
            refs_act=cellfun(@(x) uint16(x),refs_act,'UniformOutput',false);
            listamapas.lista=uint16(listamapas.lista);
        elseif maximo_todos<intmax('uint32')
            refs_act=cellfun(@(x) uint32(x),refs_act,'UniformOutput',false);
            listamapas.lista=uint32(listamapas.lista);
        end
        nframes_min(n_refs)=min(tams)
%         if n_mapaslista~=size(listamapas.lista,4);
%             disp('Esto no debería haber pasado')
%             keyboard
%         end
        n_mapaslista=size(listamapas.lista,4);        
        listamapas.lista(:,:,:,n_mapaslista+1:n_mapaslista+sum(tams))=NaN;
        listamapas.lista2trozo(1:2,n_mapaslista+1:n_mapaslista+sum(tams))=NaN;
        listamapas.ref2trozos{n_refs}=NaN(datosegm.n_peces,1);
        listamapas.solapanconcogidos{n_refs}=solapanconcogidos(ind_grupo,:)';        
        for c_peces=1:datosegm.n_peces
            % ESTO HABRÍA QUE MEJORARLO, PARA QUE NO GUARDE EL MISMO TROZO
            % CON DOS IDENTIDADES DIFERENTES CUANDO PERMITIMOS SOLAPAMIENTO
            % (ES LO QUE HACÍAN LAS LÍNEAS COMENTADAS). PERO ESO NOS
            % EXIGIRÍA CAMBIAR COMPLETAMENTE EL MODO EN EL QUE LOS DATOS SE
            % GUARDAN EN MENORES, Y AHORA MISMO ES UN LÍO TREMENDO.
%             if ~listamapas.solapanconcogidos{n_refs}(c_peces)
                ind_act=n_mapaslista+1:n_mapaslista+tams(c_peces);
                listamapas.lista(:,:,:,ind_act)=refs_act{c_peces};
                n_trozos=n_trozos+1;
                listamapas.trozo2lista{n_trozos}=ind_act;
                listamapas.lista2trozo(1,ind_act)=n_trozos;
                listamapas.lista2trozo(2,ind_act)=1:tams(c_peces);
                listamapas.ref2trozos{n_refs}(c_peces,1)=n_trozos;
                listamapas.trozo2trozo_general(n_trozos)=grupo_act(c_peces);
                listamapas.comparables{n_trozos}=false(1,tams(c_peces));
                n_mapaslista=n_mapaslista+tams(c_peces);
%             else
%                 listamapas.ref2trozos{n_refs}(c_peces,1)=find(listamapas.trozo2trozo_general==grupo_act(c_peces));
%             end % if el trozo no solapa con ninguno ya metido
        end % c_peces
        clear refs_act
        listamapas.comparados{n_trozos,n_trozos}=[];
        
        % Anulo el grupo cogido
        nvalidos_min(ind_grupo)=0;
        
        % Recuerdo o anulo todos los grupos que tengan algún trozo en común
        for c_trozos=1:datosegm.n_peces
            solapanconcogidos(intervalosbuenos.grupostrozos==grupo_act(c_trozos))=true;
%             comunes=intervalosbuenos.grupostrozos==grupo_act(c_trozos);
%             solapanconcogidos(any(comunes,2))=true;            
        end % c_trozos
        
        
        juntables(n_refs)=false;
        menores{n_trozos,n_trozos}=[];
        for c1_trozos=1:n_trozos
            for c2_trozos=1:n_trozos
                if isempty(listamapas.comparados{c1_trozos,c2_trozos})
                    listamapas.comparados{c1_trozos,c2_trozos}=false(1,length(listamapas.trozo2lista{c2_trozos}));
                end
                %                 if isempty(menores{c1_trozos,c2_trozos})
                %                     menores{c1_trozos,c2_trozos}=Inf(
                %                 end
            end
        end
        listamapas.archivoerrores(n_trozos,n_trozos)=0;
        % Extiendo matrel, P0 y P3
        matrel(1:datosegm.n_peces,1:datosegm.n_peces,n_refs,1:n_refs)=NaN;
        matrel(1:datosegm.n_peces,1:datosegm.n_peces,1:n_refs,n_refs)=NaN;
        P0(1:datosegm.n_peces,1:datosegm.n_peces,n_refs,1:n_refs)=NaN;
        P0(1:datosegm.n_peces,1:datosegm.n_peces,1:n_refs,n_refs)=NaN;
        P3(1:datosegm.n_peces,1:datosegm.n_peces,n_refs,1:n_refs)=NaN;
        P3(1:datosegm.n_peces,1:datosegm.n_peces,1:n_refs,n_refs)=NaN;        
        nframes_max(n_refs)=max(tams);
        nframesmin_estimado=nframesmin_estimado+min(tams);
        else
            datosegm.refs_solapantes=false;
        end
    end % if hay que calcular más errores
    if ~datosegm.refs_solapantes
        nvalidos_min(any(solapanconcogidos,2))=0;
    end
    
    % HABRÍA QUE MEJORAR LA ACTUALIZACIÓN DE MATREL PARA QUE NO TENGA QUE RECALCULAR VARIAS
    % VECES LOS ERRORES DEL MISMO TROZO (LAS LÍNEAS COMENTADAS IBAN
    % EN ESTA DIRECCIÓN)
    %
    % ADEMÁS, ES POCO RIGUROSO SEGUIR METIENDO TODOS LOS GRUPOS EN LOS
    % CÁLCULOS DE PROBABILIDADES COMO SI NADA. PORQUE LOS TROZOS QUE
    % APARECEN VARIAS VECES SON TRATADOS COMO INDEPENDIENTES CADA VEZ,
    % LO CUAL ES UN ASCO. PERO TAMPOCO ES QUE SEAN COMPLETAMENTE
    % REDUNDANTES (PORQUE CAMBIAN SUS COMPAÑEROS DE GRUPO), ASÍ QUE NO
    % SÉ BIEN CÓMO TRATARLOS.
    
    % Sólo recalcula nombres si hace falta
    if nuevosgrupos || (any(~juntables) && nframesmin_estimado<nframes_final && juntapocoapoco)
        % Actualiza matrel
%         if size(matrel,3)==16
%             keyboard
%         end
cambios=true;
        if n_refs>1
            faltan=isnan(squeeze(matrel(1,1,:,:)));
            faltan=faltan & faltan';
            [m,ind_actualiza]=max(sum(faltan));
            if m==1 % Puede haber uno, que es la diagonal
                ind_actualiza=[];
            end
            while ~isempty(ind_actualiza)
                menosframes=nframes_min<=nframes_min(ind_actualiza);
                menosframes(ind_actualiza)=false;
                if any(menosframes)
%                     try
                        [matrel,menores,listamapas]=actualizamatrel(find(menosframes),ind_actualiza,matrel,menores,listamapas);
%                     catch
%                         keyboard
%                     end
                end
                masframes=nframes_min>nframes_min(ind_actualiza);
                if any(masframes)
                    [matrel,menores,listamapas]=actualizamatrel(ind_actualiza,find(masframes),matrel,menores,listamapas);
                end
                faltan=isnan(squeeze(matrel(1,1,:,:)));
                faltan=faltan & faltan';
                [m,ind_actualiza]=max(sum(faltan));
                if m==1 % Puede haber uno, que es la diagonal
                    ind_actualiza=[];
                end
            end % while faltan por actualizar
        end % if más de una referencia
%         try
        [nombres,proberror,buenos,P3_mat,P3,principal,P3_orden]=matrel_mat2nombres(matrel,P3);
%         catch
%             keyboard
%         end
        
        % Anulo como juntables los que no sean buenos
        juntables(~buenos)=false;
        
%         if any(isnan(proberror))
%             keyboard
%         end
        
        % Compruebo si algún nombre ha cambiado desde la última iteración
        % Renombro los nombres antiguos, por si ha cambiado el principal
        if ~isempty(nombres_old) && principal<=size(nombres_old,1) % NO HACE LA COMPROBACIÓN SI EL PRINCIPAL ES EL QUE SE HA AÑADIDO NUEVO
            cambionombres=nombres_old(principal,:);
            if ~isempty(nombres_old)
                for c_grupos=1:size(nombres_old,1) % Puede que sean menos que los nuevos
                    if any(cambionombres(nombres(c_grupos,:))~=nombres_old(c_grupos,:))
                        disp(['Los nombres han cambiado en el grupo ' num2str(c_grupos) '. Probabilidad de error antigua ' num2str(proberror_old(c_grupos))])
                        juntables(c_grupos)=false;
                        %                     keyboard
                    end
                end
            end
        end
        
        %% Búsqueda de "juntables"
        if length(juntables)<n_refs
            juntables(n_refs)=false;
        end
        
        %     proberror=1-squeeze(min(max(P3_mat,[],2),[],1))
        juntables(proberror<umbral_error)=true; % Así nunca borro uno que ya era juntable antes
        
        P3_dibujar=NaN(datosegm.n_peces*n_refs,datosegm.n_peces*n_refs);
        for c1_refs=1:n_refs
            for c2_refs=1:n_refs
                P3_dibujar((c1_refs-1)*datosegm.n_peces+1:c1_refs*datosegm.n_peces,(c2_refs-1)*datosegm.n_peces+1:c2_refs*datosegm.n_peces)=P3_orden(:,:,c1_refs,c2_refs);
            end
        end
        if compruebahandles(handles,camposhandles)            
            set(handles.frame,'CData',P3_dibujar)
            axis(handles.ejes,[0.5 datosegm.n_peces*n_refs+.5 0.5 datosegm.n_peces*n_refs+.5])
            %             set(handles.textowaitReferences,'String',[num2str(round(nframesmin_estimado/nframes_final*100)) ' %'])
            drawnow
        else
            if ~ishandle(h_figura)
                h_figura=figure;
            end
            figure(h_figura)
            imagesc(P3_dibujar)
            drawnow
        end
        
        
    end
    
%     try
    [proberror juntables']
%     catch
%         keyboard
%     end
    
%     if ~isempty(dir('f:\parar.txt'))
%         keyboard
%     end
    
    if sum(juntables)>1 && (max(nvalidos_min)<umbral_nframes || length(nframes_min)>=limgrupos || nframesmin_estimado>=nframes_final)
        cambios=true;
        %% Elección de las dos referencias a juntar
        % Cojo dos con proberror intermedio
        ind_juntables=find(juntables);
%         try
        [s,orden]=sort(proberror(juntables));
%         catch
%             keyboard
%         end
        ind_medio=floor(length(orden)/2)+[0 1];
        ind_juntar=ind_juntables(ind_medio)       
        
        %% Junta las referencias
        % Meto la segunda dentro de la primera, y elimino la segunda
        ngrupos1=size(listamapas.ref2trozos{ind_juntar(1)},2);
        ngrupos2=size(listamapas.ref2trozos{ind_juntar(2)},2);        
        listamapas.ref2trozos{ind_juntar(1)}(:,ngrupos1+1:ngrupos1+ngrupos2)=NaN;
        for c_nombres=1:datosegm.n_peces
            pez1=nombres(ind_juntar(1),:)==c_nombres;
            pez2=nombres(ind_juntar(2),:)==c_nombres;
            listamapas.ref2trozos{ind_juntar(1)}(pez1,ngrupos1+1:ngrupos1+ngrupos2)=listamapas.ref2trozos{ind_juntar(2)}(pez2,:);
            listamapas.solapanconcogidos{ind_juntar(1)}(pez1,ngrupos1+1:ngrupos1+ngrupos2)=listamapas.solapanconcogidos{ind_juntar(2)}(pez2,:);
        end % c_nombres
        listamapas.ref2trozos(ind_juntar(2))=[];
        listamapas.solapanconcogidos(ind_juntar(2))=[];
        n_refs=n_refs-1;
        nombres(ind_juntar(2),:)=[];
        proberror(ind_juntar(2))=[];
        juntables(ind_juntar(2))=[];
        matrel(:,:,ind_juntar(2),:)=[];
        matrel(:,:,:,ind_juntar(2))=[];
        P0(:,:,ind_juntar(2),:)=[];
        P0(:,:,:,ind_juntar(2))=[];
        P3(:,:,ind_juntar(2),:)=[];
        P3(:,:,:,ind_juntar(2))=[];
        % Además anulo los elementos de matrel, P0 y P3 que tienen que ver con el trozo resultante de la unión, para que se vuelvan a calcular en la iteración siguiente
        matrel(:,:,ind_juntar(1),:)=NaN;
        matrel(:,:,:,ind_juntar(1))=NaN;
        P0(:,:,ind_juntar(1),:)=NaN;
        P0(:,:,:,ind_juntar(1))=NaN;
        P3(:,:,ind_juntar(1),:)=NaN;
        P3(:,:,:,ind_juntar(1))=NaN;
        
        % Recalcula tamaños de referencias
        nframes_min=NaN(1,n_refs);
        nframes_max=nframes_min;
        tams_refs=NaN(n_refs,datosegm.n_peces);
        for c_refs=1:n_refs
            clear tams_trozos
            tams_trozos(1:size(listamapas.ref2trozos{c_refs},1),1:size(listamapas.ref2trozos{c_refs},2))=...
                cellfun(@(x) length(x),listamapas.trozo2lista(listamapas.ref2trozos{c_refs}));
%             try
            tams_refs(c_refs,:)=sum(tams_trozos.*(~listamapas.solapanconcogidos{c_refs}),2)';
%             catch
%                 keyboard
%             end
        end
        nframes_min=min(tams_refs,[],2);
        nframes_max=max(tams_refs,[],2);
    end % if juntar
    
    % Recalcula tamaños de referencias
        nframes_min=NaN(1,n_refs);
        nframes_max=nframes_min;
        tams_refs=NaN(n_refs,datosegm.n_peces);
        for c_refs=1:n_refs
            clear tams_trozos
            tams_trozos(1:size(listamapas.ref2trozos{c_refs},1),1:size(listamapas.ref2trozos{c_refs},2))=...
                cellfun(@(x) length(x),listamapas.trozo2lista(listamapas.ref2trozos{c_refs}));
            tams_refs(c_refs,:)=sum(tams_trozos.*(~listamapas.solapanconcogidos{c_refs}),2)';
        end
        nframes_min=min(tams_refs,[],2);
        nframes_max=max(tams_refs,[],2);
    
%     % Recalculo el número total de frames estimados    
%     tams_total=zeros(1,datosegm.n_peces);
%     for c_grupos=1:length(listamapas.ref2trozos)
%         for c_peces=1:datosegm.n_peces
%             trozos_act=unique(listamapas.ref2trozos{c_grupos}(nombres(c_grupos,:)==c_peces,:));
%             for c_grupos=1:length(trozos_act)
%                 tams_total(c_peces)=tams_total(c_peces)+length(listamapas.trozo2lista{trozos_act(c_grupos)});
%             end % c_grupos
%         end
%     end
%     tamsfinales=cellfun(@(x) length(x),mapas_act);
%     
    tams_total=zeros(1,datosegm.n_peces);
    for c_refs=1:n_refs
        if juntables(c_refs)
            tams_total(nombres(c_refs,:))=tams_total(nombres(c_refs,:))+tams_refs(c_refs,:);
        end
    end
    nframesmin_estimado=max([max(nframes_min) min(tams_total)])
    
    if compruebahandles(handles,camposhandles)                
        set(handles.waitReferences,'XData',[0 0 nframesmin_estimado/nframes_final nframesmin_estimado/nframes_final])
        set(handles.textowaitReferences,'String',[num2str(round(nframesmin_estimado/nframes_final*100)) ' %'])
        drawnow
    end    
end
[n_frames,ind]=max(nframes_min);
% n_frames=min([n_frames nframes_final]);
% n_grupos=size(listamapas.ref2trozos{ind},2);
referencias=cell(1,datosegm.n_peces);
mapas_act=cell(1,datosegm.n_peces);
for c_peces=1:datosegm.n_peces
    trozos_act=listamapas.ref2trozos{ind}(c_peces,~listamapas.solapanconcogidos{ind}(c_peces,:));
    for c_grupos=1:length(trozos_act)
        mapas_act{c_peces}=[mapas_act{c_peces} listamapas.trozo2lista{trozos_act(c_grupos)}];
    end % c_grupos     
end
tamsfinales=cellfun(@(x) length(x),mapas_act);
n_frames=min([nframes_final min(tamsfinales)]);
for c_peces=1:datosegm.n_peces
    mapas_act{c_peces}=mapas_act{c_peces}(equiespaciados(n_frames,length(mapas_act{c_peces})));
    referencias{c_peces}=listamapas.lista(:,:,:,mapas_act{c_peces});
end
framesescogidos=NaN;

% Borra los archivos de errores
% for c_archivos=1:numel(listamapas.archivoerrores)
%     if listamapas.archivoerrores(c_archivos)>0 && ~isempty(dir([listamapas.nombrearchivo_errores num2str(c_archivos)]))
%         delete([listamapas.nombrearchivo_errores num2str(c_archivos)])
%     end
% end
% rmdir(directorio_errores,'s')

listamapas=rmfield(listamapas,'lista');
listamapas.matrel=matrel;
% for c_peces=1:datosegm.n_peces
%     referencias{c_peces}=double(referencias{c_peces});
% end



if compruebahandles(handles,camposhandles)    
    set(handles.waitReferences,'XData',[0 0 1 1])
    set(handles.textowaitReferences,'String',[num2str(100) ' %'])
    drawnow
    set(handles.frame,'CData',framepintado);    
    set(handles.lienzo_manchas,'Visible','on')
    set(handles.lienzo_mascara,'Visible','on')
    set(handles.colorbar,'Visible','on')    
    drawnow
    axis(handles.ejes,.5+[0 size(framepintado,2) 0 size(framepintado,1)])
    title(handles.ejes,'')
    drawnow
end
