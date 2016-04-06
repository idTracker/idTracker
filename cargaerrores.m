% 11-Dec-2012 12:30:24 Cambio de los errores clasificados por refs a los errores clasificados por trozos
% APE 6 dic 12 Viene de refs2errores

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% Esta función carga los errores de la comparación de dos referencias. Los errores guardados pueden no incluir todos los mapas de las
% referencias (si no entraron todos en las comparaciones previas), así que rellena con NaN lo que falte.

function errores=cargaerrores(trozo1,trozo2,listamapas)

n_mapas1=length(listamapas.trozo2lista{trozo1});
n_mapas2=length(listamapas.trozo2lista{trozo2});
errores=NaN(n_mapas1,n_mapas2,2);
archivo_act=listamapas.archivoerrores(max([trozo1 trozo2]),min([trozo1 trozo2]));
if archivo_act>0
    load([listamapas.nombrearchivo_errores num2str(archivo_act)])
    if trozo1<trozo2
        errores_arch=permute(errores_arch,[2 1 3]); %#ok<NODEF>
    end
    comparados1=listamapas.comparados{trozo2,trozo1};
    if any(listamapas.comparados{trozo1,trozo2}) % Si hay comparados en la ref. 2, eso quiere decir que se compararon todos los de la ref. 1
        comparados1(:)=true;
    end
    
    comparados2=listamapas.comparados{trozo1,trozo2};
    if any(listamapas.comparados{trozo2,trozo1}) % Si hay comparados en la ref. 1, eso quiere decir que se compararon todos los de la ref. 2
        comparados2(:)=true;
    end
    try
    errores(comparados1,comparados2,:)=errores_arch;
    catch
        keyboard
    end
end



