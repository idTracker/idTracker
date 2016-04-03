% APE 5 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [pixels,distancias,pixels_sinrellenar,distancias_sinrellenar]=pixels2bwdist(pixels,tam,rellenahuecos)

if nargin<3 || isempty(rellenahuecos)
    rellenahuecos=false;
end

lienzo=false(tam);
lienzo(pixels)=true;
[i,j]=ind2sub(tam,pixels);
i=[min(i) max(i)];
j=[min(j) max(j)];
minilienzo=false(diff(i)+3,diff(j)+3);
minilienzo(2:end-1,2:end-1)=lienzo(i(1):i(2),j(1):j(2));
distancias_sinrellenar=bwdist(~minilienzo);
distancias_sinrellenar=distancias_sinrellenar(minilienzo);
pixels_sinrellenar=pixels;
if rellenahuecos
    minilienzo=imfill(minilienzo,'holes');
    lienzo(i(1):i(2),j(1):j(2))=minilienzo(2:end-1,2:end-1);
    pixels=find(lienzo);
    distancias=bwdist(~minilienzo);
    distancias=distancias(minilienzo);
else
    distancias=distancias_sinrellenar;
    pixels=pixels_sinrellenar;
end

