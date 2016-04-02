% 02-Feb-2014 18:15:43 Hago que matriznoson pueda ser probabilística.
% Ahora, para los elementos distintos de 0 el número indica la probabilidad
% de que no sean del mismo individuo.
% 15-Mar-2012 16:16:56 Cambio la condición de máximo claro, para evitar
% problemas con el redondeo. Además, introduzco umbral_probaceptable
% APE 01 mar 12 viene de idtrozos2identidades

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% matriznoson puede ser conviven

function [mancha2pez,trozo2pez,probtrozos_relac]=probtrozos2identidades(trozos,probtrozos,matriznoson,umbral_probaceptable)

if nargin<4 || isempty(umbral_probaceptable)
    umbral_probaceptable=0; % Por defecto, no hay umbral.
end

n_trozos=max(trozos(:));
tam_trozos=size(trozos);
n_peces=size(probtrozos,2);
otrospeces=NaN(n_peces,n_peces-1);
for c_peces=1:n_peces
    otrospeces(c_peces,:)=[1:c_peces-1 c_peces+1:n_peces];
end % c_peces
probtrozos_relac=NaN(n_trozos,n_peces);
for c_trozos=1:n_trozos
    if ~isnan(probtrozos(c_trozos,1))
        %     ind=find(trozos==c_trozos);
        %     [frames,manchas]=ind2sub(tam_trozos,ind);
        otrostrozos=find(matriznoson(c_trozos,:)>0);
        %     otrostrozos=unique(trozos(frames,:));
        %     otrostrozos=otrostrozos(otrostrozos>0);
        %     otrostrozos=otrostrozos(~isnan(idtrozos(otrostrozos,1)));
        otrostrozos(otrostrozos==c_trozos)=[];
        otrostrozos=otrostrozos(~isnan(probtrozos(otrostrozos,1)));
        %     if c_trozos==497
        %         keyboard
        %     end
        for c_peces=1:n_peces
            % Primero lo calculo en logaritmo, para evitar redondeos a 0.
            probtrozos_relac(c_trozos,c_peces)=log(probtrozos(c_trozos,c_peces));
            %         if ~isempty(otrostrozos)
            for c_otros=otrostrozos(:)'
                %             log(sum(exp(logprob_idtrozos(c_otros,otrospeces(c_peces,:)))))
                probnoson=matriznoson(c_trozos,c_otros);
                probtrozos_relac(c_trozos,c_peces)=probtrozos_relac(c_trozos,c_peces)+log(probnoson*(1-probtrozos(c_otros,c_peces))+(1-probnoson));
                %             id_relac(c_trozos,c_peces)=id_relac(c_trozos,c_peces)+sum(idtrozos(c_otros,otrospeces(c_peces,:)))-idtrozos(c_otros,c_peces);
            end % c_otros
        end % c_peces
        % Ahora quito el logaritmo, y normalizo
        probtrozos_relac(c_trozos,:)=probtrozos_relac(c_trozos,:)-max(probtrozos_relac(c_trozos,:));
        probtrozos_relac(c_trozos,:)=exp(probtrozos_relac(c_trozos,:));
        probtrozos_relac(c_trozos,:)=probtrozos_relac(c_trozos,:)/sum(probtrozos_relac(c_trozos,:));
    end % if no es nan
end % c_trozos

clear c_trozos

% ATENCIÓN, PSEUDOBUG: UTILIZA PROBTROZOS_RELAC2 PARA VER LA PROBABILIDAD
% DEL TROZO A LA HORA DE ASIGNARLO, PERO NO PARA EL ORDEN DE ASIGNACIÓN
% (DADO QUE MAYORES NO SE ACTUALIZA).

% Ahora empieza por el más seguro, y va asignando identidades
mayores=max(probtrozos_relac,[],2);
trozo2pez=NaN(n_trozos,1);
probtrozos_relac2=probtrozos_relac;
% valor=probtrozos_relac(503,4);
while any(~isnan(mayores))
    [m,trozo_act]=max(mayores); % Este es el que está asignado con mayor probabilidad
    ind=find(trozos==trozo_act);
    [frames,manchas]=ind2sub(tam_trozos,ind);
    if ~isnan(probtrozos(trozo_act,1))
        [m,pez]=max(probtrozos_relac2(trozo_act,:));
        if m>umbral_probaceptable
        [m2,pezorig]=max(probtrozos_relac(trozo_act,:));
        if pezorig~=pez
            fprintf('El trozo %g (frames %g-%g) no se asignó a su mejor opción. Probabilidad de original de la asignación = %g. Probabilidad original de la mejor opción = %g.\n',trozo_act,min(frames),max(frames),probtrozos_relac(trozo_act,pez),probtrozos_relac(trozo_act,pezorig))
        end        
        if sum(abs(probtrozos_relac2(trozo_act,:)-m)<10^-10)==1
            trozo2pez(trozo_act)=pez;
            probtrozos(trozo_act,:)=0;
            probtrozos(trozo_act,pez)=1;
            % Ahora recalcula probtrozos_relac2 para todos los trozos
            % con los que hay interacción
            otrostrozos_act=find(matriznoson(trozo_act,:)>0);
            otrostrozos_act(otrostrozos_act==trozo_act)=[];
            otrostrozos_act=otrostrozos_act(~isnan(probtrozos(otrostrozos_act,1)));
            for c_otrostrozos=otrostrozos_act(:)'
                otrostrozos=find(matriznoson(c_otrostrozos,:));
                otrostrozos(otrostrozos==c_otrostrozos)=[];
                otrostrozos=otrostrozos(~isnan(probtrozos(otrostrozos,1)));
                original=probtrozos_relac2;
                for c_peces=1:n_peces
                    % Primero lo calculo en logaritmo, para evitar redondeos a 0.                    
                    probtrozos_relac2(c_otrostrozos,c_peces)=log(probtrozos(c_otrostrozos,c_peces));
                    for c_otros=otrostrozos(:)'
                        probnoson=matriznoson(c_otrostrozos,c_otros);
                        probtrozos_relac2(c_otrostrozos,c_peces)=probtrozos_relac2(c_otrostrozos,c_peces)+log(probnoson*(1-probtrozos(c_otros,c_peces))+(1-probnoson));
                    end % c_otros
                end % c_peces
                % Ahora quito el logaritmo, y normalizo
                probtrozos_relac2(c_otrostrozos,:)=probtrozos_relac2(c_otrostrozos,:)-max(probtrozos_relac2(c_otrostrozos,:));
                probtrozos_relac2(c_otrostrozos,:)=exp(probtrozos_relac2(c_otrostrozos,:));
                probtrozos_relac2(c_otrostrozos,:)=probtrozos_relac2(c_otrostrozos,:)/sum(probtrozos_relac2(c_otrostrozos,:));
                
            end % c_otrostrozos
%             if probtrozos_relac2(503,4)~=valor
%                 keyboard
%                 valor=probtrozos_relac2(503,4);
%             end
        else            
            fprintf('El trozo %g (frames %g-%g) no se asignó por no tener máximo claro.\n',trozo_act,min(frames),max(frames))            
        end % if hay un único máximo    
        else
            fprintf('El trozo %g (frames %g-%g) no se asignó por ser demasiado incierto. Probabilidad de la identificación: %g (sin contar con otros), %g (contando con otros)\n',trozo_act,min(frames),max(frames),probtrozos(trozo_act,pez),probtrozos_relac2(trozo_act,pez))            
        end % if supera el umbral de probabilidad
    end % if no es nan
    mayores(trozo_act)=NaN;
end % while quedan por asignar

mancha2pez=NaN(size(trozos));
mancha2pez(trozos>0)=trozo2pez(trozos(trozos>0));


% idrelac_sort=sort(probtrozos_relac,2,'descend');
% segundos=idrelac_sort(:,2);
% trozo2pez=NaN(n_trozos,1);
% 
% while any(~isnan(segundos))
%     [m,trozo_act]=min(segundos); % Este es el que más margen tiene respecto a la segunda opción
%     
% %     if trozo_act==23
% %         keyboard
% %     end
%     if any(idtrozos(trozo_act,:)>0)
%         ind=find(trozos==trozo_act);
%         [frames,manchas]=ind2sub(tam_trozos,ind);
%         otrostrozos=unique(trozos(frames,:));
%         otrostrozos=otrostrozos(otrostrozos>0);
%         otrostrozos=otrostrozos(~isnan(trozo2pez(otrostrozos)));
%         otrostrozos(otrostrozos==trozo_act)=[]; % ESTO DEBERÍA SOBRAR, YA QUE EL TROZO ACTUAL TENDRÁ NAN.
%         pecesqueno=trozo2pez(otrostrozos);
%         pecesqueno=pecesqueno(~isnan(pecesqueno));
%         pecesqueno=unique(pecesqueno);
%         logprob_act=id_relac(trozo_act,:);
%         logprob_act(pecesqueno)=-Inf;
%         [m,pez]=max(logprob_act);
%         trozo2pez(trozo_act)=pez;
%         framesafavor(trozo_act)=idtrozos(trozo_act,pez)-segundos(trozo_act);
%         if logprob_act(pez)<0
% %             keyboard
%             fprintf('El trozo %g (frames %g-%g no se asignó a su mejor opción. Frames a favor %g.\n',trozo_act,min(frames),max(frames),framesafavor(trozo_act))
%         end
%     end
%     segundos(trozo_act)=NaN;
% end % while quedan trozos sin asignar

