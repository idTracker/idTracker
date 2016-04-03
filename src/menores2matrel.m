% 10 dic 12 (Toulouse)

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function matrel=menores2matrel(menores)

n_peces=length(menores);

ind=cell(n_peces,1);
for c_peces=1:n_peces
    [m,ind{c_peces,1}]=min(menores{c_peces,1},[],2);    
end % c_peces
matrel=zeros(n_peces,n_peces+1); % Al inicializarlo como ceros, los que no tengan referencia quedarán con ceros, y luego pasarán a ser equiprobables.
for c1_peces=1:n_peces
    for c2_peces=1:n_peces
        if ~isempty(ind{c1_peces})
            matrel(c1_peces,c2_peces)=sum(ind{c1_peces}(:,1,1)==c2_peces & ind{c1_peces}(:,1,1)==ind{c1_peces}(:,1,2));
        end        
    end
    if ~isempty(ind{c1_peces})
        matrel(c1_peces,n_peces+1)=sum(ind{c1_peces}(:,1,1)~=ind{c1_peces}(:,1,2));
    end    
end