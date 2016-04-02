% APE 10 dic 12 (Toulouse)

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% Esta función transforma los datos de entrada en el tipo de entero más pequeño que pueda.

function varargout=transformaint(varargin)

negativos=any(cellfun(@(x) any(x(:)<0),varargin));
if negativos
    tipos={'int8','int16','int32','double'};
else
    tipos={'uint8','uint16','uint32','double'};
end

n_variables=nargin;
tipobueno=1;
for c_variables=1:n_variables
    if negativos
        maximo=max(abs(varargin{c_variables}(:)));
    else
        maximo=max(varargin{c_variables}(:));
    end
    for c_tipos=tipobueno:length(tipos)-1
        if maximo>intmax(tipos{c_tipos})
            tipobueno=c_tipos+1;
        end
    end % c_tipos
end % c_variables

% Ahora transforma las variables
tipobueno=tipos{tipobueno};
varargout=cell(1,n_variables+1);
for c_variables=1:n_variables
    varargout{c_variables}=cast(varargin{c_variables},tipobueno);
end % c_variables
varargout{n_variables+1}=tipobueno;
