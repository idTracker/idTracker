% APE 13 ago 2013

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function mascara=zonapoligono(vertices,tam)

n_lineas=size(vertices,1);

% Repito el primer vértice al final para cerrar el polígono
vertices(end+1,:)=vertices(1,:);

% Ecuaciones de las líneas
lineas=NaN(n_lineas,2); % Serán ordenada en el origen y pendiente
for c_lineas=1:n_lineas
    lineas(c_lineas,1)=vertices(c_lineas,2)-(vertices(c_lineas+1,2)-vertices(c_lineas,2))/(vertices(c_lineas+1,1)-vertices(c_lineas,1))*vertices(c_lineas,1);
    lineas(c_lineas,2)=(vertices(c_lineas+1,2)-vertices(c_lineas,2))/(vertices(c_lineas+1,1)-vertices(c_lineas,1));
end

mascara=false(tam);
for x=1:tam(2)
    dentro=(vertices(1:end-1,1)<=x & vertices(2:end,1)>x) | (vertices(1:end-1,1)>x & vertices(2:end,1)<=x);    
%     if x==150
%         keyboard
%     end
    if any(dentro)
        intersecciones=lineas(dentro,1)+lineas(dentro,2)*x;
        n_intersecciones=zeros(tam(1),1);
        for c_intersecciones=1:sum(dentro)
            n_intersecciones=n_intersecciones+((1:tam(1))'>intersecciones(c_intersecciones));
        end % c_intersecciones
        mascara(:,x)=mod(n_intersecciones,2)~=0; % Los que tienen un número impar de intersecciones están dentro
    end
end
