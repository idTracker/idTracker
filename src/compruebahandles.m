% APE 29 nov 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function bien=compruebahandles(handles,camposhandles)

bien=true;
for c_campos=1:length(camposhandles)
    if ~isfield(handles,camposhandles{c_campos}) || ~ishandle(handles.(camposhandles{c_campos}))
        bien=false;
    end
end % c_campos

