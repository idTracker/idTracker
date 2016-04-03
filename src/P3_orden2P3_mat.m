% APE 26 nov 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function P3_mat=P3_orden2P3_mat(P3_orden,buenos)

if nargin<2 || isempty(buenos)
    buenos=true(1,size(P3_orden,4));
end

P3_mat=sum(log(P3_orden(:,:,:,buenos)),4);
P3_mat=P3_mat-max(P3_mat(:));
P3_mat=exp(P3_mat);
P3_mat=P3_mat./repmat(sum(P3_mat,2),[1 size(P3_mat,2) 1]);