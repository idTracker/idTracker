% 23-Feb-2014 09:33:55 Eficiencia
% APE 12 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [velanterior,velsiguiente,trozoanterior,trozosiguiente,distanterior,distsiguiente]=trozos2velsentretrozos(trozos,trozo2pez,mancha2centro,listatrozos)

n_trozos=max(trozos(:));
n_peces=max(trozo2pez);

mancha2pez=NaN(size(trozos));
for c_trozos=find(trozo2pez(:)'>0)
    mancha2pez(trozos==c_trozos)=trozo2pez(c_trozos);
end

if nargin<4 || isempty(listatrozos)
    listatrozos=1:n_trozos;
end


velanterior=NaN(n_trozos,n_peces);
velsiguiente=velanterior;
distanterior=velanterior;
distsiguiente=velanterior;
trozoanterior=NaN(n_trozos,n_peces);
trozosiguiente=trozoanterior;
for c_trozos=listatrozos(:)'
    %     if trozo2pez(c_trozos)>0
    frameinicio=find(any(trozos==c_trozos,2),1,'first');
    framefinal=find(any(trozos==c_trozos,2),1,'last');
    manchainicio=trozos(frameinicio,:)==c_trozos;
    manchafinal=trozos(framefinal,:)==c_trozos;
    centroinicio=mancha2centro(frameinicio,manchainicio,:);
    centrofinal=mancha2centro(framefinal,manchafinal,:);
    for c_peces=1:n_peces
        % Uso este while en vez de find, porque es mucho más rápido
        frameanterior=frameinicio-1;
        while frameanterior>=1 && ~any(mancha2pez(frameanterior,:)==c_peces)
            frameanterior=frameanterior-1;
        end
%         frameanterior=find(any(mancha2pez(1:frameinicio-1,:)==c_peces,2),1,'last');
        if frameanterior>=1
            manchanterior=mancha2pez(frameanterior,:)==c_peces;
            trozoanterior(c_trozos,c_peces)=trozos(frameanterior,manchanterior);
            distanterior(c_trozos,c_peces)=sqrt(sum((centroinicio-mancha2centro(frameanterior,manchanterior,:)).^2));
            velanterior(c_trozos,c_peces)=distanterior(c_trozos,c_peces)/(frameinicio-frameanterior);
        end
        % Uso este while en vez de find, porque es mucho más rápido
        framesiguiente=framefinal+1;
        while framesiguiente<=size(mancha2pez,1) && ~any(mancha2pez(framesiguiente,:)==c_peces)
            framesiguiente=framesiguiente+1;
        end
%         framesiguiente=framefinal+find(any(mancha2pez(framefinal+1:end,:)==c_peces,2),1,'first');
        if framesiguiente<=size(mancha2pez,1)
            manchasiguiente=mancha2pez(framesiguiente,:)==c_peces;
            try
            trozosiguiente(c_trozos,c_peces)=trozos(framesiguiente,manchasiguiente);
            catch
                keyboard
            end
            distsiguiente(c_trozos,c_peces)=sqrt(sum((centrofinal-mancha2centro(framesiguiente,manchasiguiente,:)).^2));
            velsiguiente(c_trozos,c_peces)=distsiguiente(c_trozos,c_peces)/(framesiguiente-framefinal);
        end
    end % c_peces
    %     end
end % c_trozos
velanterior=velanterior(listatrozos,:);
velsiguiente=velsiguiente(listatrozos,:);
trozoanterior=trozoanterior(listatrozos,:);
trozosiguiente=trozosiguiente(listatrozos,:);
distanterior=distanterior(listatrozos,:);
distsiguiente=distsiguiente(listatrozos,:);