% APE 22 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function trozo2pez=mancha2pez2trozo2pez(mancha2pez,trozos)

if size(mancha2pez,2)>size(trozos,2)
    trozos(1,size(mancha2pez,2))=false; % Por si mancha2pez ha crecido en la interpolación
end

n_trozos=max(trozos(:));
trozo2pez=NaN(1,n_trozos);
for c_trozos=1:n_trozos
    pez=mancha2pez(trozos==c_trozos);
    pez=pez(~isnan(pez));
    pez=unique(pez);
    if length(pez)>1
        disp(['Trozo ' num2str(c_trozos) ' tiene identidad múltiple!'])
    elseif length(pez)==1
        trozo2pez(c_trozos)=pez;
    end
end % c_trozos