% APE 6 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [areamayor,ratio,vector_corte,signos]=mancha2manchacortada(pixels,centro,vectores_corte,X,Y)

if nargin<3 || isempty(vectores_corte)
    n_cortes=9;
    angulos=(0:pi/n_cortes:pi)';
    angulos=angulos(1:end-1);
    vectores_corte=[cos(angulos) sin(angulos)];
end
if nargin<4 || isempty(X)
    X=repmat(1:datosegm.tam(2),[datosegm.tam(1) 1]);
end
if nargin<5 || isempty(Y)
    Y=repmat((1:datosegm.tam(1))',[1 datosegm.tam(2)]);
end


x_rel=X(pixels)-centro(1);
y_rel=Y(pixels)-centro(2);
n_angulos=size(vectores_corte,1);
areamayor=NaN(1,n_angulos);
signosvector=[1 -1];
ratio=NaN(1,n_angulos);
for c_cortes=1:n_angulos
    signos=x_rel*vectores_corte(c_cortes,1)+y_rel*vectores_corte(c_cortes,2);
    sumas=[sum(signos>0) sum(signos<0)];
    [areamayor(c_cortes),ind]=max(sumas);
    ratio(c_cortes)=sumas(ind)/sumas(3-ind);
    vectores_corte(c_cortes,:)=vectores_corte(c_cortes,:)*signosvector(ind); % Para que apunte en la dirección del lado mayor
end % c_cortes
[areamayor,ind]=max(areamayor);
vector_corte=vectores_corte(ind,:);
ratio=ratio(ind);

if nargout>=3
    signos=x_rel*vector_corte(1)+y_rel*vector_corte(2);
end