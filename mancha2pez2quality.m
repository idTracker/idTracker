% APE 20 ene 2014

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [matriz_prop,matriz_nframes]=mancha2pez2quality(mancha2pez,mancha2id,identificados)

if nargin<3 || isempty(identificados)
    identificados=mancha2id>0;
end

mancha2pez=mancha2pez(:,1:size(mancha2id,2)); % Esto es necesario cuando mancha2pez viene de interpolación

n_peces=max(mancha2pez(:));
matriz_nframes=NaN(n_peces);
matriz_prop=matriz_nframes;
for c1_peces=1:n_peces
    for c2_peces=1:n_peces
        matriz_nframes(c1_peces,c2_peces)=sum(mancha2pez(:)==c1_peces & mancha2id(:)==c2_peces);
    end % c2_peces
    matriz_prop(c1_peces,:)=matriz_nframes(c1_peces,:)/sum(mancha2pez(:)==c1_peces & identificados(:));
end % c1_peces
