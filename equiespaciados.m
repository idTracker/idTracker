% 17-Jan-2013 19:09:08 Hago que funcione con n_indices=1
% APE 14 oct 11

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function indices=equiespaciados(n_indices,maximo)

if n_indices>maximo
    error('n_indices debe ser <= maximo')
end

if n_indices>1
    salto=(maximo-1)/(n_indices-1);
    indices=round(1:salto:maximo);
else
    indices=round(maximo/2);
end

% Comprobación
buenos=false(1,maximo);
buenos(indices)=true;
if sum(buenos)<n_indices
    error('Internal error in equiespaciados')
end