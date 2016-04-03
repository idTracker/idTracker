% 22-Dec-2013 02:22:32 Hago que sólo calcule solapos si hay segundo
% argumento de salida
% 17-Dec-2013 18:51:39 Hago que calcule solapos para varios trozos en
% paralelo, de modo que no tenga que cargar cada segm más de una vez.
% 18-Jun-2013 19:26:51 Añado la opción "riskytrozos"
% 09-Apr-2013 10:22:35 Arreglo un bug que hacía que pudiese salir un NaN
% cuando había dos frames idénticos
% 24-Jan-2013 12:08:21 Evito que cargue muchas veces cada segm, creando segm_cell
% 22-Jan-2013 16:50:58 Hago que un avance de solapos de una unidad
% corresponda realmente a no solapar con la mancha original. Esto tarda más
% tiempo, y requiere hacerlo en dos fases.
% 06-Feb-2012 17:43:07 Añado solapos
% APE 07 oct 11

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [trozos,solapos]=solapamiento2trozos(solapamiento,npixels,datosegm,mancha2centro)

if isfield(datosegm,'riskytrozos') && datosegm.riskytrozos
    riskytrozos=true;
else
    riskytrozos=false;
end

umbral_riesgo=3;
n_frames=length(solapamiento);
trozos=zeros(n_frames,1);
solapos=trozos;
trozos(1,1:size(solapamiento{1},1))=1:size(solapamiento{1},1);
% solapos(1,1:size(solapamiento{1},1))=.5;
c_trozos=size(solapamiento{1},1);
% solapos=cell(1,1000);
% cframes_portrozo=zeros(1,1000);
% cframes_portrozo(1:c_trozos)=1;
for c_frames=1:n_frames-1   
    if riskytrozos
        asignadas=false(1,size(solapamiento{c_frames},2));
        asignadas_ant=false(1,size(solapamiento{c_frames},1));
    end
    for c_manchas=1:sum(npixels(c_frames+1,:)>0)
        if ~isempty(solapamiento{c_frames})
            mancha_ant=solapamiento{c_frames}(:,c_manchas)>0;
        else
            mancha_ant=[];
        end
        
        if sum(mancha_ant)==1 && sum(solapamiento{c_frames}(mancha_ant,:)>0)==1
            trozos(c_frames+1,c_manchas)=trozos(c_frames,mancha_ant);
%             distancia=1-solapamiento{c_frames}(mancha_ant,c_manchas)/mean([npixels(c_frames,mancha_ant) npixels(c_frames+1,c_manchas)]);
% %             cframes_portrozo(trozos(c_frames,mancha_ant))=cframes_portrozo(trozos(c_frames,mancha_ant))+1;            
%             solapos(c_frames+1,c_manchas)=solapos(c_frames,mancha_ant)+distancia;      
            asignadas(c_manchas)=true;
            asignadas_ant(mancha_ant)=true;
        elseif ~riskytrozos
            % Inicializa un nuevo trozo
            c_trozos=c_trozos+1;            
%             if c_trozos>length(solapos) % Si hace falta, se alarga solapos otros 1000 trozos.
%                 solapos{end+1000}=[];
%                 cframes_portrozo(end+1000)=0;
%             end
            trozos(c_frames+1,c_manchas)=c_trozos;
%             solapos(c_frames+1,c_manchas)=.5;
%             solapos{c_trozos}=NaN(1,1000);
%             solapos{c_trozos}(1)=.5;
%             cframes_portrozo(c_trozos)=1;
        end % If el solapamiento es una a una
    end % c_manchas
    if riskytrozos && any(~asignadas)
        distancias=sqrt(sum((repmat(permute(mancha2centro(c_frames,1:size(solapamiento{c_frames},1),:),[2 1 3]),[1 size(solapamiento{c_frames},2)])-repmat(mancha2centro(c_frames+1,1:size(solapamiento{c_frames},2),:),[size(solapamiento{c_frames},1) 1])).^2,3));
        distancias(asignadas_ant,:)=Inf;
        distancias(:,asignadas)=Inf;
        while any(~asignadas)
            [m,mancha_act]=min(min(distancias,[],1));
            if isempty(mancha_act) || asignadas(mancha_act)
                mancha_act=find(~asignadas,1);
            end
            [m,mejormatch]=min(distancias(:,mancha_act));   
%             try
            if ~isempty(mejormatch) && (isempty(min(distancias(mejormatch,[1:mancha_act-1 mancha_act+1:end]))) || min(distancias(mejormatch,[1:mancha_act-1 mancha_act+1:end]))/m>umbral_riesgo)
                trozos(c_frames+1,mancha_act)=trozos(c_frames,mejormatch);                
                asignadas_ant(mejormatch)=true;
                distancias(mejormatch,:)=Inf;
%                 caca
            else
                c_trozos=c_trozos+1;
                trozos(c_frames+1,mancha_act)=c_trozos;                
            end
%             catch
%                 keyboard
%             end
            asignadas(mancha_act)=true;
            distancias(:,mancha_act)=Inf;
        end
    end
%     fprintf('%g,',c_frames)
end % c_frames
% solapos=solapos(1:c_trozos);

if nargout>=2
    clear c_trozos
    n_trozos=max(trozos(:));
    solapos=NaN(size(trozos));
    lienzo=cell(1,n_trozos);
    distancias=cell(1,n_trozos);
    c_dist=NaN(1,n_trozos);
    ultimoframe=NaN(1,n_trozos);
    % activos=false(1,n_trozos);
    archivoabierto=0;
    % lienzo=false(datosegm.tam);
    % distancias=NaN(1,10^4); % Prealoco con espacio de sobra
    % maximo_segm=4;
    % segm_cell=cell(1,size(datosegm.archivo2frame,1));
    n_frames=size(datosegm.frame2archivo,1);
    for c_frames=1:n_frames
        archivo_act=datosegm.frame2archivo(c_frames,1);
        if archivoabierto~=archivo_act
            fprintf('%g,',archivo_act)
            load([datosegm.directorio 'segm_' num2str(archivo_act) '.mat'])
            segm=variable;
            archivoabierto=archivo_act;
        end
        frame_arch=datosegm.frame2archivo(c_frames,2);
        %     activos(:)=false;
        for c_manchas=1:sum(trozos(c_frames,:)>0)
            trozo_act=trozos(c_frames,c_manchas);
             %         activos(trozo_act)=true;
            if isnan(ultimoframe(trozo_act)) % Esto quiere decir que es la primera vez que aparece. Inicializa todo
                lienzo{trozo_act}=false(datosegm.tam);
                lienzo{trozo_act}(segm(frame_arch).pixels{c_manchas})=true;
                distancias{trozo_act}=NaN(1,sum(trozos(:)==trozo_act)); % Prealoco con espacio de sobra
                solapos(c_frames,c_manchas)=.5;
                c_dist(trozo_act)=0;
                ultimoframe(trozo_act)=c_frames;
            else
                c_dist(trozo_act)=c_dist(trozo_act)+1;
                mancha_ant=trozos(c_frames-1,:)==trozo_act;
                distancias{trozo_act}(c_dist(trozo_act))=1-solapamiento{c_frames-1}(mancha_ant,c_manchas)/mean([npixels(c_frames-1,mancha_ant) npixels(c_frames,c_manchas)]);
            end
            % Si no solapa o ha terminado el trozo, reescalo y meto las distancias
            %         try
            %             ~any(lienzo{trozo_act}(segm(frame_arch).pixels{c_manchas})) || c_frames==n_frames || ~any(trozos(c_frames+1,:)==c_trozos)
            %         catch
            %             keyboard
            %         end
            if ~any(lienzo{trozo_act}(segm(frame_arch).pixels{c_manchas})) || c_frames==n_frames || ~any(trozos(c_frames+1,:)==trozo_act) % Si no solapa, ha llegado a 1. Reescalo y meto las distancias
                %             keyboard
                if c_dist(trozo_act)>0
                    total=1-sum(lienzo{trozo_act}(segm(frame_arch).pixels{c_manchas}))/mean([sum(lienzo{trozo_act}(:)) npixels(c_frames,c_manchas)]);
                    distancias{trozo_act}(1:c_dist(trozo_act))=cumsum(distancias{trozo_act}(1:c_dist(trozo_act)));
                    if all(distancias{trozo_act}(1:c_dist(trozo_act))==0) && total==0 % Para evitar NaN cuando el bicho no se ha movido en absoluto
                        distancias{trozo_act}(1:c_dist(trozo_act))=1;
                    end
                    distancias{trozo_act}(1:c_dist(trozo_act))=distancias{trozo_act}(1:c_dist(trozo_act))/distancias{trozo_act}(c_dist(trozo_act))*total;
                    c=0;
                    solapos_inicial=solapos(ultimoframe(trozo_act),trozos(ultimoframe(trozo_act),:)==trozo_act);
                    for c2_frames=ultimoframe(trozo_act)+1:c_frames
                        c=c+1;
                        mancha_act=trozos(c2_frames,:)==trozo_act;
                        solapos(c2_frames,mancha_act)=solapos_inicial+distancias{trozo_act}(c);
                        if isnan(solapos(c2_frames,mancha_act))
                            keyboard
                        end
                    end % c2_frames
                end
                lienzo{trozo_act}(:)=false;
                lienzo{trozo_act}(segm(frame_arch).pixels{c_manchas})=true;
                ultimoframe(trozo_act)=c_frames;
                c_dist(trozo_act)=0;
            end
            % Si ha terminado, borro lienzo
            if c_frames==n_frames || ~any(trozos(c_frames+1,:)==trozo_act)
                lienzo{trozo_act}=[];
                distancias{trozo_act}=[];
            end
        end % c_manchas
    end % c_frames
    fprintf('\n')
end % if hay segundo output
