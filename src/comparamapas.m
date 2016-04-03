% 30-Apr-2013 11:44:27 Hago que use el try-catch ante cualquier tipo de fallo, pero sólo un número limitado de veces.
% 24-Apr-2013 18:29:10 Hago que transforme a double los mapas, por si estaban ein uint16.
% 11-Dec-2012 12:19:46 Pongo el try-catch para que no se pare todo si pierde conexión con un procesador
% 06-Feb-2012 17:18:02 Quito mejorframeref
% 06-Feb-2012 17:04:17 Añado mejorframeref
% 14-Oct-2011 12:24:26 Hago que el primer output sea menores en vez de errores,
% para ahorrar memoria
% 14-Oct-2011 10:20:42 Añado el parfor
% 07-Jun-2011 14:52:09 Hago que trabaje con más de un mapa en "mapas", y
% cambio el orden del output

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas


% Orden en el output: [mapas mapas_ref resta/suma]


function [menores,errores]=comparamapas(mapas,mapas_ref,indvalidos)

tam=size(mapas);
if nargin<3 || isempty(indvalidos)
    indvalidos{1}=1:prod(tam(1:2));
    indvalidos{2}=prod(tam(1:2))+(1:prod(tam(1:2)));
end


n_refs=length(mapas_ref);

if nargout>=2
    errores=cell(1,n_refs);
end
n_frames=size(mapas,4);
menores=NaN(n_frames,2,n_refs);
mapas=double(mapas);
nfallos_max=5;
for c_refs=1:n_refs    
    n_framesref=size(mapas_ref{c_refs},4);
    errores_act=NaN(n_frames,2,n_framesref);
    ref_act=double(mapas_ref{c_refs}); % Esto lo hago para que no entre la celda entera en el parfor, que exige demasiada memoria
    repetir=true;
    c_fallos=0;
    while repetir
        repetir=false;
        try
            parfor c_frames=1:n_frames
                errores_act(c_frames,:,:)=reshape(comparamapas_mex(mapas(:,:,:,c_frames),ref_act,indvalidos{1}(:),indvalidos{2}(:)),[2 n_framesref]);
            end % c_frames            
        catch me
            c_fallos=c_fallos+1;
            if c_fallos<=nfallos_max
                disp(['Error ' me.identifier ' - ' me.message ' en el parfor de comparamapas. Repitiendo cálculo.'])
                repetir=true;
            else
                keyboard
            end
        end
    end % while repetir
    menores(:,:,c_refs)=min(errores_act,[],3);
    if nargout>=2
        errores_act=permute(errores_act,[1 3 2]);
        errores{c_refs}=errores_act;
    end
end % c_refs

