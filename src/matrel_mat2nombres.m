% 22-Jul-2013 14:37:07 Arreglo un bug que aparecía cuando había un solo
% pez cambiando un squeeze por un permute
% 12-Jun-2013 20:05:52 Hago que se generen los nombres aunque haya NaN's en P_act
% APE 3 dic 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% P3 es opcional, es para no recalcular si no hace falta.

function [nombres,proberror,buenos,P3_mat,P3,principal,P3_orden]=matrel_mat2nombres(matrel,P3)

if nargin<2 || isempty(P3)
    P3=NaN(size(matrel));
end

n_peces=size(matrel,1);
n_refs=size(matrel,3);

% Cálculo de P3
for c1_refs=1:n_refs
    for c2_refs=1:n_refs
        if isnan(P3(1,1,c1_refs,c2_refs)) && ~isnan(matrel(1,1,c1_refs,c2_refs))
            [P3(:,:,c1_refs,c2_refs),P0(:,:,c1_refs,c2_refs)]=matrel2probs(matrel(:,:,c1_refs,c2_refs));
            % Esta renormalización me sale de dar la vuelta a las probabilidades usando Bayes:
            P3(:,:,c2_refs,c1_refs)=(P3(:,:,c1_refs,c2_refs)./repmat(sum(P3(:,:,c1_refs,c2_refs),1),[n_peces 1]))';
        end
    end % c2_refs
    P3(:,:,c1_refs,c1_refs)=eye(n_peces);
end % c1_refs

%% Acumulación de probabilidades y extracción de los nombres más probables
% Cálculo de la probabilidad acumulada de asignaciones por pares
Pgrande=NaN(n_peces,n_peces,n_refs,n_refs,n_refs);
for cinicial=1:n_refs
    for cintermedia=1:n_refs
        for cfinal=1:n_refs
            Pgrande(:,:,cinicial,cintermedia,cfinal)=P3(:,:,cinicial,cintermedia)*P3(:,:,cintermedia,cfinal); % Todas las filas de todas las matrices de Pgrande suman 1.
        end
    end
end
Pacum=permute(prod(Pgrande,4)./(prod(Pgrande,4)+prod(1-Pgrande,4)),[1 2 3 5 4]); % Creo que Bayes diría que esta hay que normalizarla por filas. El permute quiere hacer lo mismo que haría un squeeze, pero lo uso para no cargarme las primeras dimensiones cuando hay un solo individuo.


% Busco el que mejor se lleva con todo el mundo
notas=squeeze(min(max(P3,[],2),[],1));
sumas=sum(notas,2);
[m,principal]=max(sumas);
%     figure
%     imagesc(notas)

% Asigno nombres respecto al que mejor se lleva con todo el mundo
% nombres_P2=NaN(n_refs,n_peces);
if any(isnan(Pacum(:)))
    disp('Guarning, guarning!! NaN''s en Pacum')
end
nombres=NaN(n_refs,n_peces);
for c_refs=1:n_refs
    P_act=Pacum(:,:,c_refs,principal);    
    P_act(isnan(P_act))=0; % ESTO ES MUY CUTRE!! NO DEBERÍA HABER NANS, PERO LOS PASO A CEROS
    for c_peces=1:n_peces
        [m,ind]=max(P_act(:));
        [pez,pez_ref]=ind2sub(size(P_act),ind);
        nombres(c_refs,pez)=pez_ref;
        P_act(pez,:)=-1;
        P_act(:,pez_ref)=-1;
    end % c_peces
end
% principal
nombres(principal,:)=1:n_peces;


%% Cálculo de proberror e intento de reordenación de los que estén mal ordenados
P3_orden=NaN(size(P3));
for c1_refs=1:n_refs
    for c2_refs=1:n_refs
        if c1_refs==c2_refs
            P3_orden(:,:,c1_refs,c2_refs)=1/n_peces;
        else
            try
            P3_orden(nombres(c1_refs,:),nombres(c2_refs,:),c1_refs,c2_refs)=P3(:,:,c1_refs,c2_refs);
            catch
                keyboard
            end
        end
    end % c2_refs
end % c1_refs

% Calculo las probabilidades
P3_mat=P3_orden2P3_mat(P3_orden);
proberror=NaN(n_refs,1);
for c_refs=1:n_refs
    proberror(c_refs)=1-min(diag(P3_mat(:,:,c_refs)));
end

buenos=true(n_refs,1);
while any(proberror(buenos)>=.5)
    buenos=buenos & proberror<.5;
    %     buenos(find(proberror>=.5 & buenos,1,'last'))=false;
    P3_mat=P3_orden2P3_mat(P3_orden,buenos);
    proberror=NaN(n_refs,1);
    for c_refs=1:n_refs
        proberror(c_refs)=1-min(diag(P3_mat(:,:,c_refs)));
    end
end

cambios=true;
while cambios
    cambios=false;
    malos=find(~buenos);
    for c_malos=malos(:)'
        P_act=P3_orden2P3_mat(P3_orden,buenos);
        P_act=P_act(:,:,c_malos);
        nombres_nuevo=NaN(1,n_peces);
        for c_peces=1:n_peces
            [m,ind]=max(P_act(:));
            [pez,pez_ref]=ind2sub(size(P_act),ind);
            nombres_nuevo(nombres(c_malos,:)==pez)=pez_ref;
            P_act(pez,:)=0;
            P_act(:,pez_ref)=0;
        end % c_peces
        proberror_nueva=1-m;
        % Si es posible una reordenación, la meto
        if proberror_nueva<.5
            nombres(c_malos,:)=nombres_nuevo;
            cambios=true;
            % Rehago P3_orden
            P3_orden=NaN(size(P3));
            for c1_refs=1:n_refs
                for c2_refs=1:n_refs
                    if c1_refs==c2_refs
                        P3_orden(:,:,c1_refs,c2_refs)=1/n_peces;
                    else
                        P3_orden(nombres(c1_refs,:),nombres(c2_refs,:),c1_refs,c2_refs)=P3(:,:,c1_refs,c2_refs);
                    end
                end % c2_refs
            end % c1_refs
            buenos(c_malos)=true;
            %             else
            %                 figure
            %                 imagesc(P_act)
            %                 drawnow
        end
    end
end % while cambios

P3_mat=P3_orden2P3_mat(P3_orden,buenos);
proberror=NaN(n_refs,1);
for c_refs=1:n_refs
    proberror(c_refs)=1-min(diag(P3_mat(:,:,c_refs)));
end
% Hago una última comprobación, por si uno de los nuevos me ha fastidiado uno de los viejos
if any(proberror(buenos)>.5)
    buenos=proberror<.5;
    P3_mat=P3_orden2P3_mat(P3_orden,buenos);
    proberror=NaN(n_refs,1);
    for c_refs=1:n_refs
        proberror(c_refs)=1-min(diag(P3_mat(:,:,c_refs)));
    end
end