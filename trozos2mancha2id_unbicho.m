% APE 31 dic 13

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function mancha2id=trozos2mancha2id_unbicho(trozos,mancha2centro,conviven)

n_trozos=max(trozos(:));
% Calcula la distancia recorrida durante cada trozo, mientras el trozo es
% el único que hay en la imagen
trozos_act=trozos;
varios=sum(trozos_act>0,2)>1;
trozos_act(varios,:)=NaN;
x=mancha2centro(:,:,1);
y=mancha2centro(:,:,2);
distancias=NaN(1,n_trozos);
mancha2id=zeros(size(trozos));
for c_trozos=1:n_trozos
    ind=find(trozos==c_trozos);
    ind=ind(:);
    centros_act=[x(ind) y(ind)];
    centros_act(isnan(trozos_act(ind)))=NaN; % Anulo los frames en los que hay algún otro trozo
    dist_act=sqrt(sum((centros_act(2:end,:)-centros_act(1:end-1,:)).^2,2));
    distancias(c_trozos)=sum(dist_act(~isnan(dist_act)));
end % c_trozos
while any(~isnan(distancias))
    [m,ind]=max(distancias);
    mancha2id(trozos==ind)=1;
    distancias(ind)=NaN;
    distancias(conviven(ind,:))=NaN;
end