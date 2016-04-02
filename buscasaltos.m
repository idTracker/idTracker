% 18-Feb-2014 12:20:58 Anulo la reasignación poco segura (paso 4). Ahora solo
% reasigna cuando el que estaba antes no es posible.
% 13-Feb-2014 10:14:17 Introduzco el concepto de sospechosos
% APE 11 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [trozo2pez,fijos,cambiados]=buscasaltos(trozos,trozo2pez,probtrozos_relac,mancha2centro,conviven)

% Recorto todo si hay parte sin rellenar (normalmente no debería ser
% necesario)
ultimorelleno=find(any(mancha2centro(:,:,1),2)>0,1,'last');
trozos=trozos(1:ultimorelleno,:);
mancha2centro=mancha2centro(1:ultimorelleno,:,:);
n_trozos=max(trozos(:));
trozo2pez=trozo2pez(1:n_trozos);
probtrozos_relac=probtrozos_relac(1:n_trozos,:);
conviven=conviven(1:n_trozos,1:n_trozos);

conviven(1:n_trozos+1:n_trozos^2)=false; % Anulo la diagonal

% Cálculo de velocidades típicas
x=mancha2centro(:,:,1);
y=mancha2centro(:,:,2);
vel=[];
for c_trozos=1:n_trozos
    ind=find(trozos==c_trozos);
    [frame,mancha]=ind2sub(size(trozos),ind);
    [frame,orden]=sort(frame);
    ind=ind(orden);
    vel=[vel ; sqrt(diff(x(ind)).^2+diff(y(ind)).^2)];
end 
vel=sort(vel);
umbral_vel=2*vel(round(.99*length(vel)));
n_peces=max(trozo2pez(:));

% Primero calcula velocidades de conexión para cada trozo dudoso
[velanterior,velsiguiente,trozoanterior,trozosiguiente,distanterior,distsiguiente]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro);

% Ahora reasigna los que tengan más sentido reasignados
% vel=velanterior+velsiguiente;
asignados=find(trozo2pez>0);
ind=sub2ind(size(probtrozos_relac),asignados,trozo2pez(asignados));
probasignado=probtrozos_relac(ind);
probtrozos_relac(ind)=0;
probsegundo=max(probtrozos_relac(asignados,:),[],2);
ratioprobs=NaN(1,n_trozos);
ratioprobs(asignados)=probasignado./probsegundo;
fijos=false(1,n_trozos);
fijos(ratioprobs>10)=true;
asignados=trozo2pez'>0;
% Primero fija todos los que pueda de los que encajan bien. Una vez todos
% fijos, empieza a reasignar
nuevosfijos=true;
reasignar=false;
c_cambiados=0;
cambiados=[];
pasosactivos=1; 
umbral_anular=3;
% Pasos: 
% 1- Fija los que solo tengan un posible y coincida con su identidad asignada
% 2- Reasigna y fija los que solo tengan un posible y no coincida con su
% identidad asignada. Además anula los que no tengan posibles.
% 3- Fija los que tengan varios posibles, pero su identidad asignada coincida con su mejorpez
% 4- Anula los que puedan mejorar su fit y tengan un ratioprobs
% bajo (por debajo de umbral_anular)
while pasosactivos<5    
    quedan=find(~fijos & trozo2pez'>0);
    disp([num2str(sum(fijos)) ' fijos, quedan ' num2str(length(quedan))])
%     if ~reasignar
%         tipoorden='descend';
%     else
%         tipoorden='ascend'; % Para reasignar, vamos de menos a más probables
%     end
    [s,orden]=sort(ratioprobs(quedan),'descend');
    quedan=quedan(orden);
    nuevosfijos=false;
    fijos_old=fijos;
    for c_trozos=quedan
        posibles=true(1,n_peces);
%         try
        posibles(trozo2pez(conviven(c_trozos,:) & fijos))=false;
%         catch
%             keyboard
%         end
        [m,mascercano1]=min(distanterior(c_trozos,:));
        [m,mascercano2]=min(distsiguiente(c_trozos,:));
        for c_peces=find(posibles)            
            noencaja1 = c_peces~=mascercano1 && ~isnan(trozoanterior(c_trozos,c_peces)) && fijos(trozoanterior(c_trozos,c_peces)) && velanterior(c_trozos,c_peces)>umbral_vel;
            noencaja2 = c_peces~=mascercano2 && ~isnan(trozosiguiente(c_trozos,c_peces)) && fijos(trozosiguiente(c_trozos,c_peces)) && velsiguiente(c_trozos,c_peces)>umbral_vel;
            if noencaja1 || noencaja2
                posibles(c_peces)=false;
            end
        end % c_peces
        % Fija los muy seguros
        if pasosactivos>=1 && sum(posibles)==1 && trozo2pez(c_trozos)>0 && posibles(trozo2pez(c_trozos))
%             if c_trozos==1322
%                 keyboard
%             end
            fijos(c_trozos)=true;
            nuevosfijos=true;
        end
        
        if pasosactivos>=2 && ~any(posibles)    
            trozo2pez(c_trozos)=-1;
            disp(['Trozo ' num2str(c_trozos) ' anulado'])
%             if c_trozos==1322
%                 keyboard
%             end
            listatrozos=find(trozo2pez'>0 & ~fijos);
            if ~isempty(listatrozos)
                [velanterior(listatrozos,:),velsiguiente(listatrozos,:),trozoanterior(listatrozos,:),trozosiguiente(listatrozos,:),distanterior(listatrozos,:),distsiguiente(listatrozos,:)]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro,listatrozos);
            end
%             [velanterior,velsiguiente,trozoanterior,trozosiguiente,distanterior,distsiguiente]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro,find(trozo2pez>0 & ~fijos));
%             fijos(c_trozos)=false;
            nuevosfijos=true;
        end
        
        % Reasigna y fija los que solo tienen un posible y no coincide con
        % su id actual, o bien (en paso 4) los que encajan mejor de otra
        % manera
        if (pasosactivos>=2 && sum(posibles)==1 && (trozo2pez(c_trozos)<0 || ~posibles(trozo2pez(c_trozos))))
            nuevaid=find(posibles);
            conflictivo=find(conviven(c_trozos,:) & trozo2pez'==nuevaid);
            if ~isempty(conflictivo) && all(~fijos(conflictivo))
                % Si hay conflicto, anula la identidad del otro
                trozo2pez(conflictivo)=-1;
            end
            trozo2pez(c_trozos)=nuevaid;
            fijos(c_trozos)=true;
            nuevosfijos=true;
%             listatrozos=find(any(trozoanterior==c_trozos,2) |
%             any(trozosiguiente==c_trozos,2))'; % Los tengo que recalcular
%             todos, porque pueden cambiar los trozos que van delante y
%             detrás al camiar la identidad
            listatrozos=find(trozo2pez'>0 & ~fijos);
            if ~isempty(listatrozos)
                [velanterior(listatrozos,:),velsiguiente(listatrozos,:),trozoanterior(listatrozos,:),trozosiguiente(listatrozos,:),distanterior(listatrozos,:),distsiguiente(listatrozos,:)]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro,listatrozos);
            end
            disp(['Trozo ' num2str(c_trozos) ' reasignado'])
            c_cambiados=c_cambiados+1;
            cambiados(c_cambiados)=c_trozos;
        end
        
        % Fija los que parecen correctos (usa fijos_old para que solo se
        % fije un escalón por iteración). Además anula los que podrían
        % estar mejor y tienen bajo ratioprobs (paso 4)
        if pasosactivos>=3 && trozo2pez(c_trozos)>0 && posibles(trozo2pez(c_trozos))
            mejorpez=[];
            if all(~isnan(trozoanterior(c_trozos,:))) && all(fijos(trozoanterior(c_trozos,:)))
                [m,mejorpez_act]=min(distanterior(c_trozos,:));
                mejorpez=[mejorpez mejorpez_act];
            end
            if all(~isnan(trozosiguiente(c_trozos,:))) && all(fijos(trozosiguiente(c_trozos,:)))
                [m,mejorpez_act]=min(distsiguiente(c_trozos,:));
                mejorpez=[mejorpez mejorpez_act];
            end
            if ~isempty(mejorpez)
                if any(mejorpez==trozo2pez(c_trozos))
                    fijos(c_trozos)=true;
                    nuevosfijos=true;
                elseif pasosactivos>=4 && ratioprobs(c_trozos)<umbral_anular && all(mejorpez==mejorpez(1)) && ~fijos(c_trozos)                    
                    nuevaid=mejorpez(1);
                    conflictivo=find(conviven(c_trozos,:) & trozo2pez'==nuevaid);
                    if ~isempty(conflictivo) && all(ratioprobs(conflictivo)<umbral_anular) && all(~fijos(conflictivo))
                        % Si hay conflicto, anula la identidad del otro
                        trozo2pez(conflictivo)=-1;
                        disp(['Trozo ' num2str(conflictivo) ' anulado'])
%                         if any(conflictivo)==1322
%                             keyboard
%                         end
                    end
                    trozo2pez(c_trozos)=-1;
                    %                     fijos(c_trozos)=true;
                    nuevosfijos=true;
                    listatrozos=find(trozo2pez'>0 & ~fijos);
                    if ~isempty(listatrozos)
                        [velanterior(listatrozos,:),velsiguiente(listatrozos,:),trozoanterior(listatrozos,:),trozosiguiente(listatrozos,:),distanterior(listatrozos,:),distsiguiente(listatrozos,:)]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro,listatrozos);
                    end
                    %                     [velanterior,velsiguiente,trozoanterior,trozosiguiente,distanterior,distsiguiente]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro);
                    disp(['Trozo ' num2str(c_trozos) ' anulado'])
%                     if c_trozos==1322
%                         keyboard
%                     end
                end
            end
        end
    end % c_trozos
    if ~nuevosfijos
        pasosactivos=pasosactivos+1;
    end
end % while hay nuevos fijos


% % Ahora quedan los conflictivos. Estos los recorre de menos a más probable,
% % corrigiendo cuando hay un encaje mejor. Lo hace en dos pasos: En el
% % primer paso, si hay un encaje mejor pero hay otro trozo asignado a su pez
% % preferido, simplemente quita la identidad. Si todo va bien, en el segundo
% % paso el otro pez habrá cambiado también su identidad, y podremos
% % reasignarlo.
% sum(fijos)
% quedan=find(~fijos & asignados);
% [s,orden]=sort(ratioprobs(quedan),'ascend');
% quedan=quedan(orden);
% nuevosfijos=false;
% trozo2pez_orig=trozo2pez;
% for c_trozos=quedan
% %     vels_act=[velanterior(c_trozos,:) ; velsiguiente(c_trozos,:)];
% %     vels_act(~fijos([frameanterior(c_trozos,:) ; framesiguiente(c_trozos,:)]))=NaN;
% %     vels_act=nanmean(vels_act,1);
% %     [m,mejorpez]=nanmin(vels_act);
% %     mejorpez=NaN(1,2);
%     [m,mejorpez(1)]=min(velanterior(c_trozos,:));
%     if ~fijos(trozoanterior(c_trozos,mejorpez(1)))
%         mejorpez(1)=NaN; % Si no está fijo, lo anulamos
%     end
%     [m,mejorpez(2)]=min(velsiguiente(c_trozos,:));
%     if ~fijos(trozosiguiente(c_trozos,mejorpez(2)))
%         mejorpez(2)=NaN;
%     end
%     if all(~isnan(mejorpez))
%         if mejorpez(1)==mejorpez(2)
%             mejorpez=mejorpez(1);
%         else
%             mejorpez=NaN;
% %             disp(['Conflicto en los extremos del trozo ' num2str(c_trozos)])
%         end
%     elseif any(~isnan(mejorpez))
%         mejorpez=mejorpez(~isnan(mejorpez));
%     end
%     if ~isnan(mejorpez(1))
%         if mejorpez==trozo2pez(c_trozos)
%             fijos(c_trozos)=true;
%             nuevosfijos=true;
%         end
%     end
% end


% [s,orden]=sort(probtrozos_relac(ind));
% asignados=asignados(orden);
% c_cambiados=0;
% for c_trozos=asignados(:)'
%     [m,ind_mejor]=min(vel(c_trozos,:));
% %     if c_trozos==66
% %         keyboard
% %     end
%     pezorig=trozo2pez(c_trozos);
%     if pezorig>0 && pezorig~=ind_mejor
%         conviven(c_trozos,c_trozos)=false;
%         otrotrozo=find(conviven(c_trozos,:) & trozo2pez'==ind_mejor);
%         if isempty(otrotrozo)
%             trozo2pez(c_trozos)=ind_mejor;
%             disp(['Trozo ' num2str(c_trozos) ' reasignado sin más'])
%             c_cambiados=c_cambiados+1;
%             cambiados(c_cambiados,1)=c_trozos;
%         elseif probtrozos_relac(otrotrozo)<.9
%             if vel(c_trozos,ind_mejor)+vel(otrotrozo,pezorig)<vel(c_trozos,pezorig)+vel(otrotrozo,ind_mejor)
%                 pez2trozo(c_trozos)=ind_mejor;
%                 pez2trozo(otrotrozo)=pezorig;
%                 disp(['Trozo ' num2str(c_trozos) ' intercambia id con trozo ' num2str(otrotrozo) '.'])
%                 c_cambiados=c_cambiados+1;
%                 cambiados(c_cambiados,1:2)=[c_trozos otrotrozo];
%             else
%                 disp(['Trozo ' num2str(c_trozos) ' no se pudo reasignar por conflicto con trozo ' num2str(otrotrozo) ' (las velocidades no disminuyen)'])
%             end
%         else
%             disp(['Trozo ' num2str(c_trozos) ' no se pudo reasignar por conflicto con trozo ' num2str(otrotrozo) ' que tiene probabilidad alta'])
%         end
%     end
% end
% 
% [s,orden]=sort(cambiados(:,1));
% cambiados=cambiados(orden,:);