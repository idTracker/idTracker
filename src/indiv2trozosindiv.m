% APE 15 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function trozo2indiv=indiv2trozosindiv(indiv,trozos)

n_trozos=max(trozos(:));
trozo2indiv=false(1,n_trozos);
for c_trozos=1:n_trozos
    if sum(indiv(trozos==c_trozos))>sum(~indiv(trozos==c_trozos))
        trozo2indiv(c_trozos)=true;
    end
end % c_trozos