% 10-Jul-2013 15:50:56 Nada
% 27-Apr-2013 13:42:37 Elimino la llamada a guardaerrores, que creo que ya
% no hace falta porque al juntarse todos los trozos de golpe al final nunca
% hay que recuperar errores antiguos.
% 12-Dec-2012 14:46:50 Quito n_comparaciones
% 11-Dec-2012 20:32:43 Evito que haga comparaciones dobles, metiendo las signaturas
% 11-Dec-2012 17:54:14 Hago que ind_refs1 pueda contener varios índices
% 11-Dec-2012 10:03:02 Cambio al nuevo formato de comparados y comparables. Ahora todo está basado en el trozo.
% 10-Dec-2012 18:05:44 Cambio al nuevo formato basado en trozos en vez de en grupos
% 08-Dec-2012 20:32:16 Hago que funcione combinando varios grupos para formar una sola referencia
% 08-Dec-2012 20:17:21 Paso de llamar ref a llamar grupo, para llamar ref a las referencias incluyendo cuando ya hay varios grupos juntados
% 08-Dec-2012 15:00:41 Hago que convierta los mapas a double antes de
% comparar, por si están en uint. Además hago que cargue las listas2 de una
% en una para ahorrar algo de memoria.
% APE, 6 dic 12 (Toulouse)

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [matrel,menores,listamapas]=actualizamatrel(ind_refs1,ind_refs2,matrel,menores,listamapas)

ind_refs1=ind_refs1(:)'; % Por si acaso entra como vector columna
ind_refs2=ind_refs2(:)'; % Por si acaso entra como vector columna
n_peces=size(listamapas.ref2trozos{ind_refs1(1)},1);
n_mapas=size(listamapas.lista,4);

%% Busca los comparables de cada trozo, teniendo en cuenta los que forman parte del mismo pez
trozos1=[];
for c_refs1=ind_refs1
    trozos1=[trozos1 listamapas.ref2trozos{c_refs1}(:)'];
end % c_refs1
trozos2=[];
for c_refs2=ind_refs2
    trozos2=[trozos2 listamapas.ref2trozos{c_refs2}(:)'];
    clear tams_trozos
    tams_trozos(1:size(listamapas.ref2trozos{c_refs2},1),1:size(listamapas.ref2trozos{c_refs2},2))=...
        cellfun(@(x) length(x),listamapas.trozo2lista(listamapas.ref2trozos{c_refs2}));
    tams=sum(tams_trozos,2);
    mintam=min(tams);
    for c_peces2=1:n_peces
        comparables_act=false(1,tams(c_peces2));
        c_mapas=0;
        for c_grupos=1:size(listamapas.ref2trozos{c_refs2},2)
            comparables_act(c_mapas+1:c_mapas+tams_trozos(c_peces2,c_grupos))=listamapas.comparables{listamapas.ref2trozos{c_refs2}(c_peces2,c_grupos)};            
            c_mapas=c_mapas+tams_trozos(c_peces2,c_grupos);
        end % c_grupos
        extra=mintam-sum(comparables_act);
        if extra>0
            nocomparados=find(~comparables_act);
            nuevos=nocomparados(equiespaciados(extra,length(nocomparados)));
            comparables_act(nuevos)=true;
            % Vuelve a guardar los comparables
            c_mapas=0;
            for c_grupos=1:size(listamapas.ref2trozos{c_refs2},2)
                listamapas.comparables{listamapas.ref2trozos{c_refs2}(c_peces2,c_grupos)}=comparables_act(c_mapas+1:c_mapas+tams_trozos(c_peces2,c_grupos));
                c_mapas=c_mapas+tams_trozos(c_peces2,c_grupos);
            end % c_grupos
        elseif extra<0
            disp('Esto no debería haber pasado')
            keyboard
        end
    end % c_peces2
end % c_refs2


%% Busca los mapas que hay que comparar
% Uso las signaturas para distinguir entre trozos de las refs1 que tengan que compararse con distintos mapas de las refs2
buenos1{1}=false(1,n_mapas);
buenos2{1}=false(1,n_mapas);
signaturas{1}=[];
comparados_nuevo=listamapas.comparados;
pardetrozos2signatura=NaN(length(listamapas.trozo2lista),length(listamapas.trozo2lista));
for c_trozos1=trozos1
    n_mapas1=length(listamapas.trozo2lista{c_trozos1});
    buenos1_act=false(1,n_mapas);
    buenos2_act=false(1,n_mapas);
    for c_trozos2=trozos2        
        n_mapas2=length(listamapas.trozo2lista{c_trozos2});
        comparables_mat=false(n_mapas1,n_mapas2);
        comparados_mat=comparables_mat;
        comparables_mat(:,listamapas.comparables{c_trozos2})=true;
        comparados_mat(:,listamapas.comparados{c_trozos1,c_trozos2})=true;
        comparados_mat(listamapas.comparados{c_trozos2,c_trozos1},:)=true;
        buenos1_act(listamapas.trozo2lista{c_trozos1}(any(comparables_mat & ~comparados_mat,2)))=true;
        buenos2_act(listamapas.trozo2lista{c_trozos2}(any(comparables_mat & ~comparados_mat,1)))=true;
        comparados_nuevo{c_trozos1,c_trozos2}=listamapas.comparables{c_trozos2};
    end % c_trozos2
    if any(buenos1_act) && any(buenos2_act)
        if isempty(signaturas{1}) % La primera vez, rellena la primera signatura
            signaturas{1}=buenos2_act;
        end
        ind_signatura=0;
        for c_signaturas=1:length(signaturas)
            if all(signaturas{c_signaturas}==buenos2_act)
                ind_signatura=c_signaturas;
            end
        end
        if ind_signatura==0 % Si no coincide con ninguna signatura, crea una nueva
            ind_signatura=length(signaturas)+1;
            signaturas{ind_signatura}=buenos2_act;
            buenos1{ind_signatura}=buenos1_act;
            buenos2{ind_signatura}=buenos2_act;            
        else % Si coincide con alguna signatura, lo mete ahí.
            buenos1{ind_signatura}(buenos1_act)=true;
            buenos2{ind_signatura}(buenos2_act)=true;
        end        
        pardetrozos2signatura(c_trozos1,trozos2)=ind_signatura;
    end
end % c_trozos1


%% Realiza comparaciones, guarda los nuevos errores y actualiza menores
for c_signaturas=1:length(signaturas)
    % Realiza las comparaciones
    if (sum(buenos1{c_signaturas})>0 && sum(buenos2{c_signaturas})>0)
        % Primero troceo la lista de mapas de las refs2, para que no sature memoria al paralelizar
        ind_buenos2=find(buenos2{c_signaturas});
        n_listas=ceil(length(ind_buenos2)/3000);
        lista1=double(listamapas.lista(:,:,:,buenos1{c_signaturas}));
        lista2=cell(1);
        c_mapas=0;
        errores_juntos=zeros(sum(buenos1{c_signaturas}),sum(buenos2{c_signaturas}),2,'uint16');
        for c_listas=1:n_listas
            lista2{1}=double(listamapas.lista(:,:,:,ind_buenos2((c_listas-1)*3000+1:min([length(ind_buenos2) c_listas*3000]))));
            [menores_act,errores_act]=comparamapas(lista1,lista2,[]); % AQUÍ FALTA METER ind_validos PARA QUE VAYA MÁS RÁPIDO
            lista2{1}=[];
            [errores_juntos,errores_act]=transformaint(errores_juntos,errores_act{1}); % Transformo para que ocupe menos
            % Junto los errores
            nmapas_act=size(errores_act,2);
            errores_juntos(:,c_mapas+1:c_mapas+nmapas_act,:)=errores_act;
            c_mapas=c_mapas+nmapas_act;
            clear errores_act
            %         errores_act{c_listas}=[];
        end % c_listas
        clear lista1 lista2
    end % if hay que hacer comparaciones
        
    % Actualiza menores, y guarda los nuevos errores que se han calculado
    lista2trozo1=listamapas.lista2trozo(:,buenos1{c_signaturas});
    lista2trozo2=listamapas.lista2trozo(:,buenos2{c_signaturas});
    for c_trozos1=trozos1
        mapas1=lista2trozo1(1,:)==c_trozos1;
        for c_trozos2=trozos2
            if pardetrozos2signatura(c_trozos1,c_trozos2)==c_signaturas && any(comparados_nuevo{c_trozos1,c_trozos2}~=listamapas.comparados{c_trozos1,c_trozos2})
                errores_arch=cargaerrores(c_trozos1,c_trozos2,listamapas);
                % Busca errores nuevos y los mete
                mapas2=lista2trozo2(1,:)==c_trozos2;
                errores_arch(lista2trozo1(2,mapas1),lista2trozo2(2,mapas2),:)=errores_juntos(mapas1,mapas2,:); %#ok<NASGU>
                listamapas.comparados{c_trozos1,c_trozos2}=comparados_nuevo{c_trozos1,c_trozos2};
%                 listamapas=guardaerrores(c_trozos1,c_trozos2,listamapas,errores_arch);
                menores{c_trozos1,c_trozos2}=min(errores_arch(:,listamapas.comparados{c_trozos1,c_trozos2},:),[],2);
            end % if hay cambios
        end % c_trozos2
    end % c_trozos1
end % c_signaturas

%% Actualiza matrel
for c_refs1=ind_refs1
    clear tams_trozos1
    tams_trozos1(1:size(listamapas.ref2trozos{c_refs1},1),1:size(listamapas.ref2trozos{c_refs1},2))=...
        cellfun(@(x) length(x),listamapas.trozo2lista(listamapas.ref2trozos{c_refs1}));
    tams1=sum(tams_trozos1,2);
    for c_refs2=ind_refs2
        if isnan(matrel(1,1,c_refs1,c_refs2)) % Sólo lo rehace si es necesario
            % Genera los menores correspondientes a la comparación de la ref. 1 con la ref. 2 actual
            menores_act=cell(n_peces,1);
            for c_peces1=1:n_peces
                menores_act{c_peces1}=Inf(tams1(c_peces1),n_peces,2);
                c_mapas1=0;
                for c_grupos1=1:size(listamapas.ref2trozos{c_refs1},2)
                    ind1_act=c_mapas1+1:c_mapas1+tams_trozos1(c_peces1,c_grupos1);
                    c_mapas1=c_mapas1+tams_trozos1(c_peces1,c_grupos1);
                    for c_peces2=1:n_peces
                        for c_grupos2=1:size(listamapas.ref2trozos{c_refs2},2)
                            menores_act{c_peces1}(ind1_act,c_peces2,:)=min([menores_act{c_peces1}(ind1_act,c_peces2,:) ...
                                menores{listamapas.ref2trozos{c_refs1}(c_peces1,c_grupos1),listamapas.ref2trozos{c_refs2}(c_peces2,c_grupos2)}],[],2);
                        end % c_grupos2
                    end % c_grupos1
                end % c_peces2
            end % c_peces1
            % Y ahora actualiza matrel usando esos menores
            matrel_act=menores2matrel(menores_act);
            matrel(:,:,c_refs1,c_refs2)=matrel_act(:,1:n_peces);
        end
    end % c_refs2
end % c_refs1
