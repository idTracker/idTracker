% 21-Jul-2014 22:39:43 / en vez de \
% 16-Apr-2014 17:07:20 Añado la posibilidad de cortar trozos
% 21-Mar-2014 09:13:16 Quito lo de ir al siguiente cruce del individuo
% actual, y ya no hay que pulsar mayúscula.
% 28-Feb-2014 22:59:18 Lo adapto para marcar errores en la interpolación
% 09-Feb-2014 21:38:51 Añado la posibilidad de poner (o corregir)
% centroides
% 04-Feb-2014 23:50:41 Hago que, si puede, coja mancha2centro de man2pez
% 15-Jan-2014 16:57:24 Hago que genere automáticamente las trayectorias,
% que pregunte al empezar si hay varios mancha2pez guardados, y que
% funcione para vídeos con varios platos
% 24-Dec-2013 17:54:16 Hago que tome obj de datosegm
% 12-Dec-2013 17:10:17 Hago que use VideoReader cuando la versión de Matlab
% es reciente
% 01-Dec-2013 18:29:09 Hago que pueda iniciarse sin ningún argumento de
% entrada
% 01-Dec-2013 16:09:41 Mejoras estéticas e intento de mejora de la
% reproducción automática
% 11-Sep-2013 12:12:41 Lo preparo para más de 10 peces
% 11-Sep-2013 11:47:09 Hago que pueda mostrar identidades como números
% 06-Sep-2013 16:22:02 Hago que aparezca la barra de herramientas de la
% figura, para poder hacer zoom. También hago que se pueda meter mancha2pez
% desde fuera, para seguir con una corrección antigua.
% 19-Jun-2013 18:23:37 Cambio el timer por un bucle, con la esperanza de que funcione mejor.
% 13-Jun-2013 10:14:23 Hago que funcione con el nuevo sistema de archivos encriptados
% 20-Feb-2013 18:23:22 Cambio de control+numero a click+numero para corregir
% APE 20 feb 13 Viene de datosegm2muestravideo y datosegm2tracking_manual

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function datosegm2muestravideo_nuevo(datosegm,obj)

datos.corrigeinterpolacion=false;

if ispc
    barra='\';
else
    barra='/';
end

if nargin<1 || isempty(datosegm)
    directorio=ultimodir;
    if ~isempty(directorio) && directorio(end)==barra
        directorio=directorio(1:end-1); % Necesario para que funcione bien el uigetfile cuando el nombre del directorio tiene un espacio al final
    end
   [nombrearchivo,directorio]=uigetfile('*.*','Select video file',directorio); 
   if isempty(dir(directorio))
       directorio=[directorio(1:end-1) ' ' directorio(end)]; % Esto hace falta en los vídeos de Pierre, porque se come el último espacio
   end
   ultimodir(directorio);
   if directorio(end)~=barra
       directorio(end+1)=barra;
   end   
else
    directorio=datosegm.directorio_videos;
end

datos.directorio=directorio;
lista=dir([directorio 'segm*']);

c_platos=0;
for c=1:length(lista)
    if lista(c).isdir && ~isempty(dir([directorio lista(c).name '\mancha2pez*.mat']))
        c_platos=c_platos+1;
        datos.nombresplatos{c_platos}=lista(c).name(5:end);
    end
end


if nargin<2
    obj=[];
end

medidaPantalla=get(0,'ScreenSize');
color_fondo=[.8 .8 .8];
h.figure=figure('Color',color_fondo,'NumberTitle','off');%;('Position', [0 0 medidaPantalla(3) medidaPantalla(4)]);
set(h.figure,'menubar','none','toolbar','figure')



% if isfield(datosegm,'encriptar')
%     segm=load_encrypt([datosegm.directorio datosegm.raizarchivo '_' num2str(1)],datosegm.encriptar);
% else
%     load([datosegm.directorio datosegm.raizarchivo '_' num2str(1)])
% end
% datos.segm=segm;
% datos.archivoabierto=1;
% datosarchivos=directorio2datosarchivos(directorio,raizarchivo);



% datos.colorines=[0 0 0 ; 0 .6 0 ; .5 .2 1; 0 .5 1 ; 1 0 1; .5 1 .5; 1 .5 1; 1 .5 .5 ; 1 .5 0; 0 0 .5; .5 0 0 ];

% colorines=[0 0 0 ; 0 .6 0 ; .5 .2 1; 0 .5 1 ; 1 0 1; .5 1 .5; 1 .5 1; 1 .5 .5 ; 1 .5 0 ];
% colorines=[0 0 0 ; 0 .6 0 ; .5 1 .5; .5 .2 1; 0 .5 1 ; 1 0 1; 1 .5 1; 1 .5 .5 ; 1 .5 0 ]; % PARA EL VÍDEO DE LOS 3+2 PECES CON ESTRES+EXPERIENCIA
% colorines=[0 0 0 ; 0 0 1 ; 1 0 0; .2 .2 1 ; .5 .5 1; .7 .7 1; 1 .2 .2; 1 .5 .5 ; 1 .7 .7 ]; % PARA EL VÍDEO DE GRUPOS 1 Y 2 DE CONFLICTO DE JULIÁN
% colorines=[0 0 0 ; 0 0 1 ; 1 0 0; .2 .2 1 ; 1 .2 .2; 1 .5 .5; .5 .5 1; 1 .7 .7 ; .7 .7 1 ]; % PARA EL VÍDEO DE GRUPOS 3 Y 4 DE CONFLICTO DE JULIÁN

datos.nombrespeces='123456789QWERTYUIOPASDFGHJKL';

% n_archivos=size(datosarchivos.archivo2frame,1);
% for c_archivos=1:n_archivos
%     datos.obj(c_archivos)=mmreader([datosarchivos.directorio datosarchivos.raizarchivo num2str(c_archivos) '.avi']);
% end % c_archivos

%% Guarda datos
guidata(h.figure,datos)

info_act='Select arena';
if length(datos.nombresplatos)>1
    h.popup_plato=uicontrol('Style','popupmenu','Units','normalized','Position',[.9 .8 .09 .05],'String',datos.nombresplatos,'BackgroundColor',color_fondo,'TooltipString',info_act);
end

h.ejes=axes('Position',[.1 .1 .8 .85]);
hold on

info_act='Slide to navigate the video';
h.barrita=uicontrol('Style','slider','Value',1,'Min',1,'Max',100,'Units','Normalized','Position',[0 0 1 .05],'TooltipString',info_act);
info_act=sprintf('Click to start/stop reproduction.\nYou can also:\n- Hit spacebar to start/stop\n- Use the mouse scroll wheel to navigate step-by-step');
h.push_run=uicontrol('Style','pushbutton','Units','normalized','Position',[.9 .4 .09 .05],'String','Run','BackgroundColor',color_fondo,'TooltipString',info_act);
info_act='Number of frames advanced per step. Typing a number at any moment will automatically edit this box';
h.text_nframes=uicontrol('Style','text','Units','normalized','Position',[.9 .3 .09 .05],'String','Speed','BackgroundColor',color_fondo,'TooltipString',info_act);
h.edit_nframes=uicontrol('Style','edit','Units','Normalized','Position',[.9 .25 .09 .05],'String','1','TooltipString',info_act);
info_act='Current frame';
h.text_frameactual=uicontrol('Style','text','Units','normalized','Position',[.9 .15 .09 .05],'String','Frame','BackgroundColor',color_fondo,'TooltipString',info_act);
h.frameactual=uicontrol('Style','edit','Units','Normalized','Position',[.9 .1 .09 .05],'String','1','tooltipstring',info_act);
% h.edit_velocity=uicontrol('Style','edit','Units','Normalized','Position',[.85 .9 .1 .05],'String','0.01');
% h.t=timer('Period',0.01,'TasksToExecute',Inf,'ExecutionMode','FixedSpacing','BusyMode','drop');
h.text_quality=uicontrol('Style','text','Units','normalized','Position',[.9 .55 .09 .2],'String','','BackgroundColor',color_fondo,'TooltipString',info_act);

h.menushow=uimenu('Label','Show');
h.showtray=uimenu('Label','Trajectories','Parent',h.menushow);
h.showtrozos=uimenu('Label','Fragments','Parent',h.menushow);
h.showidnumbers=uimenu('Label','Id''s (numbers)','Parent',h.menushow);
h.showid=uimenu('Label','Id''s (colors)','Parent',h.menushow);
h.menuhelp=uimenu('Label','Help');

%% Carga datos
abreplato(NaN,[],h)
datos=guidata(h.figure);
frametotal=size(datos.datosegm.frame2archivo,1);
set(h.figure,'Name',[datos.datosegm.raizarchivo_videos ' - idPlayer'])
if isempty(obj)
    if isfield(datos.datosegm,'obj') && ~isempty(datos.datosegm.obj)
        datos.obj=datos.datosegm.obj;
    else
        if isfield(datos.datosegm,'archivovideo2frame')
            datos.obj=cell(1,size(datos.datosegm.archivovideo2frame,1));
        else
            datos.obj=cell(1,size(datos.datosegm.archivo2frame,1));
        end
    end
else
    datos.obj=obj;
end


% datos.datosarchivos=datosarchivos;
% datos.frame=1;%el frame en el que estoy referido al video completo.
% obj=mmreader([datosarchivos.directorio datosarchivos.raizarchivo '1.avi']);
% frame=read(datos.obj(1), 1);

% for c_manchas=1:length(segm(1).pixels)
%     frame(segm(1).pixels{c_manchas})=0;
% end

axes(h.ejes)
frame=ones(datos.datosegm.tam);
h.frame=imagesc(frame(:,:,1));
set(h.frame,'HitTest','off')
uistack(h.frame,'bottom')
set(h.ejes,'YDir','reverse')

h.contframe=plot(NaN,NaN);
set(h.contframe,'XData',1);
h.corriendo=plot(0,0);
set(h.corriendo,'Visible','off')
h.control=plot(NaN,NaN);
set(h.control,'XData',0);

axis image
colormap gray
hold on
  


% color_fondo=get(gcf,'Color');
% for c_peces=1:datos.datosegm.n_peces
%     datos.h.labelid(c_peces)=uicontrol('Units','normalized','Style','text','Position',[.95 .9-c_peces/datos.datosegm.n_peces*.8 .05 .1],'String',datos.nombrespeces(c_peces),'ForegroundColor',datos.colorines(c_peces+1,:),'BackgroundColor',color_fondo,'FontSize',12,'TooltipString','Holapis');
% end

datos.nframes_linea=20;



%% Vuelve a guardar datos
guidata(h.figure,datos)


%% Define callbacks, timers y esas cosas
set(h.barrita,'Max',frametotal);
set(h.barrita,'Callback',@(uno,dos) ruedecita(uno,dos,h))
set(h.frameactual,'Callback',@(uno,dos) cambiaframe(uno,dos,h))
set(h.push_run,'Callback',@(uno,dos) correr(uno,dos,h))
% set(h.t,'TimerFcn',@(uno,dos) ruedecita(uno,dos,h))
set(h.figure,'windowscrollwheelfcn',@(uno,dos) ruedecita(uno,dos,h))
set(h.figure,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.push_run,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.frameactual,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.text_frameactual,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.edit_nframes,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.text_nframes,'KeyPressFcn',@(uno,dos) tecla(uno,dos,h))
% set(h.hola,'Callback',@(uno,dos) escribehola(uno,dos,h))
% set(gcf,'windowbuttondownfcn',@(uno,dos) correr(uno,dos,h))
set(h.showtray,'Callback',@(uno,dos) cambiacheck(uno,dos,h))
set(h.showtrozos,'Callback',@(uno,dos) cambiacheck(uno,dos,h))
set(h.showid,'Callback',@(uno,dos) cambiacheck(uno,dos,h))
set(h.showidnumbers,'Callback',@(uno,dos) cambiacheck(uno,dos,h))
set(h.ejes,'ButtonDownFcn',@(uno,dos) seleccionapez(uno,dos,h))
set(h.menuhelp,'Callback',@(uno,dos) ayuda(uno,dos))
if isfield(h,'popup_plato')
    set(h.popup_plato,'Callback',@(uno,dos) abreplato(uno,dos,h))
end






%% ***************
%% ** FUNCIONES **
%% ***************

%% Abre nuevo plato (carga datos)
function abreplato(uno,dos,h)

if ispc
    barra='\';
else
    barra='/';
end

datos=guidata(h.figure);
if isfield(h,'popup_plato') && uno==h.popup_plato
    plato_act=get(uno,'Value');
    for c=1:length(datos.h.lineas)
        delete(datos.h.lineas(c))
    end
    datos.h.lineas=[];
    for c=1:length(datos.h.textos)
        delete(datos.h.textos(c))
    end
    datos.h.textos=[];
else
    plato_act=1;
end

load([datos.directorio 'segm' datos.nombresplatos{plato_act} '\datosegm.mat'])
if isstruct(variable)
    datosegm=variable;
    clear variable
else
    datosegm=load_encrypt([datos.directorio 'segm' datos.nombresplatos{plato_act} '\datosegm.mat'],1);
end
datosegm.directorio=[datos.directorio 'segm' datos.nombresplatos{plato_act} barra];
datosegm.directorio_videos=datos.directorio;
if ~isfield(datosegm,'extension')
    datosegm.extension='avi';
end

if isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension])) && isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos num2str(1) '.' datosegm.extension]))
    datos.usavideo=false;
    datos.archivoabierto=0;
else
    datos.usavideo=true;
    if ~isfield(datosegm,'frame2archivovideo')
        datosegm.frame2archivovideo=datosegm.frame2archivo;
    end
end
datos.videoabierto=0;    
datos.corriendo=false;


datos.datosegm=datosegm;
datos.colorines=[.5 .5 .5 ; jet(datos.datosegm.n_peces)];
datos.esperandocorreccion=false;
axes(h.ejes)

% mancha2pez
archivos=dir([datosegm.directorio 'mancha2pez*.mat']);
if ~isempty(archivos)
    if length(archivos)==1
        coletilla='';
    else
        for c_archivos=1:length(archivos)
            coletilla{c_archivos}=archivos(c_archivos).name(11:end-4);
            nombrescoletilla{c_archivos}=coletilla{c_archivos};
            if isempty(coletilla{c_archivos})
                nombrescoletilla{c_archivos}='Original (not corrected)';
            end            
        end
        respuesta=listdlg('ListString',nombrescoletilla,'SelectionMode','single','PromptString','Please, choose one version','Name','Several versions exist','ListSize',[300 300]);
        if ~isempty(respuesta)
            coletilla=coletilla{respuesta};
        else
            error('You must select one version')
        end        
    end    
    if isfield(datosegm,'encriptar') 
        if datosegm.encriptar
            man2pez=load_encrypt([datosegm.directorio 'mancha2pez' coletilla '.mat'],datosegm.encriptar);        
        else
            load([datosegm.directorio 'mancha2pez' coletilla '.mat'])
            man2pez=variable;
        end
        mancha2pez=man2pez.mancha2pez;
    else
        load([datosegm.directorio 'mancha2pez' coletilla '.mat'])
        man2pez=[];
    end

    datos.mancha2pez=mancha2pez;
    for c_peces=1:size(mancha2pez,2) % Si había trozos, esto sobreescribe a lo anterior. Pero no pasa nada.
        datos.h.textos(c_peces)=text(NaN,NaN,'','Color','r','FontWeight','bold','HorizontalAlignment','center','HitTest','off');
    end % c_peces
    clear mancha2pez
    if isempty(coletilla)
        coletilla=['_' datestr(now,30)];
    end
    datos.coletilla=coletilla;
    set(h.showid,'Check','on')
    set(h.showidnumbers,'Check','on')
else
    set(h.showid,'Enable','off')
end

% Trozos
if isfield(man2pez,'trozos')
    datos.trozos=man2pez.trozos;
elseif ~isempty(dir([datosegm.directorio 'trozos.mat']))
    if isfield(datosegm,'encriptar')
        if datosegm.encriptar
            variable=load_encrypt([datosegm.directorio 'trozos.mat'],datosegm.encriptar);
        else
            load([datosegm.directorio 'trozos.mat'])
        end
        trozos=variable.trozos;
    else
        load([datosegm.directorio 'trozos.mat'])
    end
    datos.trozos=trozos;
    for c_peces=1:size(trozos,2)
        datos.h.textos(c_peces)=text(NaN,NaN,'','Color','r','FontWeight','bold','FontSize',12,'HitTest','off');
    end % c_peces
    clear trozos    
else
    set(h.showtrozos,'Enable','off')
end

% trayectoria
if isfield(datos,'mancha2pez')
    if isfield(man2pez,'mancha2centro')
        datos.mancha2centro=man2pez.mancha2centro;
    else
        if isfield(datosegm,'encriptar')
            if datosegm.encriptar
                npixelsyotros=load_encrypt([datosegm.directorio 'npixelsyotros.mat'],datosegm.encriptar);
            else
                load([datosegm.directorio 'npixelsyotros.mat'])
                npixelsyotros=variable;
            end
        else
            load([datosegm.directorio 'npixelsyotros.mat'])
        end
        datos.mancha2centro=npixelsyotros.mancha2centro;
    end
    datos.trajectories=mancha2pez2trayectorias(datosegm,datos.mancha2pez,[],[],datos.mancha2centro);
    datos.erroresinterp=false(size(datos.trajectories(:,:,1)));
end

for c_peces=1:datos.datosegm.n_peces
    datos.h.lineas(c_peces)=plot(NaN,NaN,'-','LineWidth',2,'HitTest','off');
end % c_peces
set(h.showtray,'Check','on','Enable','on')

% Compute quality
if ~isempty(dir([datosegm.directorio 'mancha2id.mat']))
    if datosegm.encriptar
        man2id=load_encrypt([datosegm.directorio 'mancha2id.mat'],datosegm.encriptar);
    else
        load([datosegm.directorio 'mancha2id.mat'])
        man2id=variable;
    end
    if ~isfield(man2id,'identificados')
        man2id.identificados=[];
    end
    [matriz_prop,matriz_nframes]=mancha2pez2quality(datos.mancha2pez,man2id.mancha2id,man2id.identificados);
    set(h.text_quality,'String',sprintf('Quality:\n%0.3g%% wrong\n%0.3g%% no id',100*mean(sum(matriz_prop,2)-matriz_prop(1:size(matriz_prop,1)+1:size(matriz_prop,1)^2)'),100*(size(matriz_prop,1)-sum(matriz_prop(:)))/size(matriz_prop,1)))
end

guidata(h.figure,datos)




%% Activar y desactivar checks en en los menús
function cambiacheck(uno,dos,h)
if strcmpi(get(uno,'Check'),'on')
    set(uno,'Check','off')
else
    set(uno,'Check','on')
    if uno==h.showidnumbers
        set(h.showtrozos,'Check','off')
    elseif uno==h.showtrozos
        set(h.showidnumbers,'Check','off')
    end
end

% Cambia el frame al editar el cuadro de texto
function cambiaframe(uno,dos,h) 
ind_frame=str2double(get(h.frameactual,'String'));
datos=guidata(h.figure);
if ind_frame>=1 && ind_frame<=size(datos.datosegm.frame2archivo,1)
    set(h.contframe,'XData',ind_frame);
    ruedecita(-2,[],h)
else
    set(h.frameactual,'ForegroundColor',[1 0 0])
    pause(.2)
    set(h.frameactual,'ForegroundColor',[0 0 0])
    ind_frame=get(h.contframe,'XData');
    set(h.frameactual,'String',num2str(ind_frame))
end


%Pinta el frame q toca
function ruedecita(uno,dos,h)

ind_frame=get(h.contframe,'XData');%llamamos a ind_frame
multiplicador=str2double(get(h.edit_nframes,'String'));
if uno==0 % Si viene del timer, avanzamos lo que toque
    ind_frame=max([1 ind_frame + multiplicador]);     
    set(h.frameactual,'String',num2str(ind_frame));
elseif uno==h.barrita
    framebarra=get(h.barrita,'Value');
    ind_frame=round(framebarra);
    set(h.frameactual,'String',num2str(ind_frame));
elseif uno==-2 % Si viene del cuadro de texto, no lo cambia
    % Nada
else%if ~isempty(uno)
    ind_frame=ind_frame - dos.VerticalScrollCount*abs(multiplicador);
    set(h.frameactual,'String',num2str(ind_frame));
end
ind_frame=max([1 ind_frame]);
datos=guidata(h.figure);
ind_frame=min([ind_frame size(datos.datosegm.frame2archivo,1)]);
set(h.contframe,'XData',ind_frame)%volvemos a guardar ind_frame
drawnow update
pintaframe(uno,dos,h)
    
%actualizar el valor de la barra al nuevo datos.frame
% guidata(h.figure,datos) % Pongo aquí el guidata para que los datos queden guardados antes de llegar a la parte pesada del programa
function pintaframe(uno,dos,h)%Pinta el frame q toca

datos=guidata(h.figure);
% Anula la espera de corrección
title('')
datos.datosegm.esperacorreccion=false;

% keyboard

estado=get(h.control,'XData');
if estado==1
elseif estado==0
    set(h.control,'XData',1)
    
    
    ind_frame=get(h.contframe,'XData');%llamamos a ind_frame
    
%     disp('Pintaframe')
%     disp(datos.mancha2pez(ind_frame,:))
%     disp(datos.mancha2centro(ind_frame,:,1))
%     disp(datos.trajectories(ind_frame,:,1))
    
    archivo_act=datos.datosegm.frame2archivo(ind_frame,1);
    if ~datos.usavideo
        if archivo_act~=datos.archivoabierto
            %     fprintf('%g,',archivo_act)
            if isfield(datos.datosegm,'encriptar')
                if datos.datosegm.encriptar
                    segm=load_encrypt([datos.datosegm.directorio datos.datosegm.raizarchivo '_' num2str(archivo_act)],datos.datosegm.encriptar);
                else
                    load([datos.datosegm.directorio datos.datosegm.raizarchivo '_' num2str(archivo_act)])
                    segm=variable;
                end
            else
                load([datos.datosegm.directorio datos.datosegm.raizarchivo '_' num2str(archivo_act)])
            end
            datos.segm=segm;
            datos.archivoabierto=archivo_act;
        end
        frame_act=datos.datosegm.frame2archivo(ind_frame,2);
    end
    
    if datos.usavideo
        archivovideo_act=datos.datosegm.frame2archivovideo(ind_frame,1);
        % Comprueba si hay que crear el objeto vídeo de nuevo
        crearobj=true;
        if isfield(datos,'obj') && ~isempty(datos.obj{archivovideo_act})
            try a=get(datos.obj{archivovideo_act}); crearobj=false; catch; end
        end
        if crearobj
            try
            h_waitbar=waitbar(0.5,'Reading video files','Name','Loading video');
            hw=findobj(h_waitbar,'Type','Patch');
            set(hw,'EdgeColor',[.5 .5 .7],'FaceColor',[.5 .5 .7]) % changes the color of the waitbar                        
            catch                
            end
            % Si son demasiados, borra los objetos de datosegm
            if isfield(datos.datosegm,'obj') && sum(cellfun(@(x) ~isempty(x),datos.obj))>100
                datos.obj=cell(1,size(datos.datosegm.archivo2frame,1));
            end
            try
                if archivovideo_act>1 || ~isempty(dir([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(archivovideo_act) '.' datos.datosegm.extension]))
                    datos.obj{archivovideo_act}=mmreader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(archivovideo_act) '.' datos.datosegm.extension]);
                else
                    datos.obj{archivovideo_act}=mmreader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos '.' datos.datosegm.extension]);
                end
            catch
                if archivovideo_act>1 || ~isempty(dir([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(archivovideo_act) '.' datos.datosegm.extension]))
                    datos.obj{archivovideo_act}=VideoReader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(archivovideo_act) '.' datos.datosegm.extension]);
                else
                    datos.obj{archivovideo_act}=VideoReader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos '.' datos.datosegm.extension]);
                end
            end
            datos.videoabierto=archivovideo_act;
            try
            waitbar(1,h_waitbar);
            close(h_waitbar)
            catch
            end
        end        
        framevideo_act=datos.datosegm.frame2archivovideo(ind_frame,2);
        frame=read(datos.obj{archivovideo_act},framevideo_act);        
    else
        frame=ones(datos.datosegm.tam,'uint8');
        for c_manchas=1:length(datos.segm(frame_act).pixels)
            frame(datos.segm(frame_act).pixels{c_manchas})=0;
        end
    end % if usar vídeo original
    set(h.frame,'CData',frame)
    set(h.barrita,'Value',ind_frame)
    set(h.frameactual,'String',num2str(ind_frame));
        
    if strcmpi(get(h.showtray,'Checked'),'on')
        for c_peces=1:datos.datosegm.n_peces
            set(datos.h.lineas(c_peces),'XData',datos.trajectories(max([1 ind_frame-datos.nframes_linea]):ind_frame,c_peces,1),'YData',datos.trajectories(max([1 ind_frame-datos.nframes_linea]):ind_frame,c_peces,2),'Color',datos.colorines(c_peces+1,:),'LineStyle','-','Marker','none')%'.')
        end % c_peces
    elseif isfield(h,'lineas')
        for c_peces=1:datos.datosegm.n_peces
            set(datos.h.lineas(1,c_peces),'XData',NaN,'YData',NaN)
        end % c_peces
    end
    if strcmpi(get(h.showtrozos,'Checked'),'on') || strcmpi(get(h.showid,'Checked'),'on')
        for c_peces=1:size(datos.trozos,2)
            if datos.mancha2centro(ind_frame,c_peces,1)>0
                set(datos.h.textos(c_peces),'Position',[datos.mancha2centro(ind_frame,c_peces,1) datos.mancha2centro(ind_frame,c_peces,2) 0])
            else
                set(datos.h.textos(c_peces),'String','')
            end
        end
    end
    
    if strcmpi(get(h.showtrozos,'Checked'),'on')
        for c_peces=1:size(datos.trozos,2)
            if datos.mancha2centro(ind_frame,c_peces,1)>0
                set(datos.h.textos(c_peces),'String',num2str(datos.trozos(ind_frame,c_peces)))
            else
                set(datos.h.textos(c_peces),'String','')
            end
        end
    elseif strcmpi(get(h.showidnumbers,'Checked'),'on')
        for c_peces=1:size(datos.trozos,2)
            if datos.mancha2centro(ind_frame,c_peces,1)>0
                if datos.mancha2pez(ind_frame,c_peces)>0
                    set(datos.h.textos(c_peces),'String',datos.nombrespeces(datos.mancha2pez(ind_frame,c_peces)))
                else
                    set(datos.h.textos(c_peces),'String','0')
                end
            else
                set(datos.h.textos(c_peces),'String','')
            end
        end
    elseif strcmpi(get(h.showid,'Checked'),'on')
        for c_peces=1:size(datos.trozos,2)
            if datos.mancha2centro(ind_frame,c_peces,1)>0
                set(datos.h.textos(c_peces),'String','o')
            else
                set(datos.h.textos(c_peces),'String','')
            end
        end
    elseif isfield(datos,'trozos')
        for c_peces=1:size(datos.trozos,2)
            set(datos.h.textos(c_peces),'String','')
        end
    end
    if strcmpi(get(h.showid,'Checked'),'on')
        for c_peces=1:length(datos.h.textos)
            if datos.mancha2pez(ind_frame,c_peces)>=0
                ind_color=datos.mancha2pez(ind_frame,c_peces)+1;
            else
                ind_color=1;
            end
            set(datos.h.textos(c_peces),'Color',datos.colorines(ind_color,:))
        end
    end
    
    if isfield(datos,'pezseleccionado')
        for c_peces=1:datos.datosegm.n_peces
            if c_peces==datos.pezseleccionado
                set(datos.h.textos(c_peces),'FontWeight','bold')
            else
                set(datos.h.textos(c_peces),'FontWeight','normal')
            end
        end
    end
    
    guidata(h.figure,datos)
    drawnow expose update
    set(h.control,'XData',0)
end
% disp([datestr(inicio,'HH:MM:SS:FFF') '   ' datestr(now,'HH:MM:SS:FFF')])

%% Seleccionar pez
function seleccionapez(uno,dos,h)
datos=guidata(h.figure);
pos=get(uno,'CurrentPoint');
% x=round(pos(1,1));
% y=round(pos(1,2));
if pos(1,1)>=0 && pos(1,1)<=datos.datosegm.tam(2) && pos(1,2)>=0 && pos(1,2)<=datos.datosegm.tam(1)
%     pixel=sub2ind(datos.datosegm.tam,y,x);
    % plot(x,y,'.')
    ind_frame=get(h.contframe,'XData');
    distancias=sqrt((datos.mancha2centro(ind_frame,:,1)-pos(1,1)).^2+(datos.mancha2centro(ind_frame,:,2)-pos(1,2)).^2);
    [m,manchabuena]=min(distancias);
%     if datos.datosegm.frame2archivo(ind_frame,1)~=datos.archivoabierto
%         archivo_act=datos.datosegm.frame2archivo(ind_frame,1);
%         %     fprintf('%g,',archivo_act)
%         if isfield(datosegm,'encriptar')
%             segm=load_encrypt([datos.datosegm.directorio datos.datosegm.raizarchivo '_' num2str(archivo_act)],datosegm.encriptar);
%         else
%             load([datos.datosegm.directorio datos.datosegm.raizarchivo '_' num2str(archivo_act)])
%         end
%         datos.segm=segm;
%         datos.archivoabierto=archivo_act;
%     end
%     frame_act=datos.datosegm.frame2archivo(ind_frame,2);
%     manchabuena=[];
%     for c_manchas=1:length(datos.segm(frame_act).pixels)
%         if any(datos.segm(frame_act).pixels{c_manchas}==pixel)
%             manchabuena=c_manchas;
%         end
%     end
    if ~isempty(manchabuena)
        if isfield(datos,'trozos')
            datos.trozoseleccionado=datos.trozos(ind_frame,manchabuena);
        end
        if isfield(datos,'mancha2pez')
            datos.pezseleccionado=datos.mancha2pez(ind_frame,manchabuena);
        end
        datos.esperandocorreccion=true;
        title(h.ejes,'Type new identity to correct, or SPACE to divide the fragment')
        drawnow expose update
    end
    guidata(h.figure,datos)
end

%% Pulsación de una tecla (cualquiera)
function tecla(uno,dos,h)
% disp('Tecla')
if ~isempty(dos.Character) % Para que no se ejecute al pulsar solo shift
datos=guidata(h.figure);
simbolos_shiftnums={'!','"','·','$','%','&','/','(',')','='};
if ~datos.esperandocorreccion
    switch dos.Character
        case' '
            correr([],[],h)
        case {'c','C','x','X'} % Siguiente cruce o anterior cruce
            disp('caca')
            buenos=false(size(datos.trozos));
            ind_frame=get(h.contframe,'XData');
            %             if strcmpi(dos.Modifier,'shift') % Siguiente cruce, sea de quien sea
            for c_manchas=1:size(datos.trozos,2)
                if datos.trozos(ind_frame,c_manchas)>0
                    buenos(datos.trozos==datos.trozos(ind_frame,c_manchas))=true;
                end
            end
%             sumas=sum(buenos,2);
%             buenos=sumas==sumas(ind_frame);
            buenos=~any(datos.trozos>0 & ~buenos,2);
            %             elseif isfield(datos,'pezseleccionado') && datos.pezseleccionado>0 % Siguiente cruce del que está seleccionado
            %                 mancha_act=datos.mancha2pez(ind_frame,:)==datos.pezseleccionado;
%                 trozo_act=datos.trozos(ind_frame,mancha_act);
%                 if length(trozo_act)==1
%                     buenos=datos.trozos==trozo_act;
%                 end
%             elseif isfield(datos,'trozoseleccionado') && datos.trozoseleccionado>0 && any(datos.trozos(ind_frame,:)==datos.trozoseleccionado) % Si no hay pez seleccionado, sólo actúa si seguimos en el trozo seleccionado
%                 buenos=datos.trozos==datos.trozoseleccionado;
%             end
            if dos.Character=='x' || dos.Character=='X' % Cruce anterior
                buenos(ind_frame:end)=true;
                framecruce=find(~buenos,1,'last');
                if ~isempty(framecruce)
                    set(h.contframe,'XData',framecruce)
                end
            else % Cruce siguiente
                buenos(1:ind_frame)=true;
                framecruce=find(~buenos,1,'first');
                if ~isempty(framecruce)
                    set(h.contframe,'XData',framecruce)
                end
            end
        case {'1','2','3','4','5','6','7','8','9'} % Cambio de velocidad
            if ~isfield(datos,'corrigeinterpolacion') || ~datos.corrigeinterpolacion
                set(h.edit_nframes,'String',dos.Character)
            else
                ind_frame=get(h.contframe,'XData');
                erroresinterp=datos.erroresinterp;
                erroresinterp(ind_frame,str2double(dos.Character))=~erroresinterp(ind_frame,str2double(dos.Character));
                title(['Bicho ' dos.Character ' marcado como ' num2str(erroresinterp(ind_frame,str2double(dos.Character))) ' en frame ' num2str(ind_frame)])
                disp(['Bicho ' dos.Character ' marcado como ' num2str(erroresinterp(ind_frame,str2double(dos.Character))) ' en frame ' num2str(ind_frame)])
                drawnow
                save([datos.datosegm.directorio 'erroresinterp.mat'],'erroresinterp')
                datos.erroresinterp=erroresinterp;
                guidata(h.figure,datos)
            end
        case simbolos_shiftnums % Nuevo centroide
            pez=find(cellfun(@(x) x==dos.Character,simbolos_shiftnums));
            title(['Click on centroid for fish ' num2str(pez)])
            [x,y]=ginput(1);
            if ~isempty(x)
                corrige(h,[pez x y])
            end
            title('')
    end
else % Correcciones
    title('')
    datos.esperandocorreccion=false;
    guidata(h.figure,datos)
    if dos.Character=='º' || dos.Character=='0'
        pezbueno=NaN;
    elseif dos.Character==' '
        pezbueno=' ';
    else
        pezbueno=regexpi(datos.nombrespeces,dos.Character);
    end
    %     switch dos.Character
    %         case {'1','2','3','4','5','6','7','8','9'}
    %             pezbueno=str2num(dos.Character);
    %         case '0'
    %             pezbueno=10;
    %         case ''''
    %             pezbueno=11;
    %         case '¡'
    %             pezbueno=12;
    %         case 'º' % Sin identificar/múltiple
    %             pezbueno=NaN;
    %         otherwise
    %             pezbueno=[];
    %     end
    if ~isempty(pezbueno)
        corrige(h,pezbueno)
    end
end
pintaframe(uno,dos,h)
end

%% Corrección de identidad
function corrige(h,pezbueno)
datos=guidata(h.figure);
% pos_fig=get(h.figure,'Position');
% % pos_ejes=get(h.ejes,'Position');
% pos_ejes=plotboxpos(h.ejes); % Esta función es de matlabcentral
% % get(h.ejes,'Position')
% % get(h.ejes,'TightInset')

% pos2=get(0,'PointerLocation');
% pos2=(pos2-pos_fig(1:2))./pos_fig(3:4); % Pasa a referido a la figura, y en unidades relativas
% pos2=(pos2-pos_ejes(1:2))./pos_ejes(3:4); % Pasa a referido a los ejes, y en unidades relativas
% pos2(2)=1-pos2(2); % Porque el eje y está invertido en imágenes.
% tam_foto=size(get(h.frame,'CData'));
% pos2=pos2.*tam_foto([2 1]); % Pasa a pixels
% x=pos2(1);
% y=pos2(2);

% [x,y]=ginput(1);
% Localiza la mancha
if length(pezbueno)==1 % Cambio de identidad de una mancha o corte de fragmento
    elementos=find(datos.trozos==datos.trozoseleccionado);
    if pezbueno==' ' % Corte del fragmento
        [frame,mancha]=ind2sub(size(datos.trozos),elementos);
        ind_frame=get(h.contframe,'XData');
        datos.trozos(elementos(frame>ind_frame))=max(datos.trozos(:))+1;
    elseif isnan(pezbueno) || pezbueno<=datos.datosegm.n_peces        
        datos.mancha2pez(elementos)=pezbueno;
        datos.pezseleccionado=pezbueno;
        % datos.mancha2pez(ind_frame,:)        
    end
elseif length(pezbueno)==3 % Nuevo centroide
    ind_frame=get(h.contframe,'XData');%llamamos a ind_frame
    mancha=find(datos.mancha2pez(ind_frame,:)==pezbueno(1),1);
    if isempty(mancha)
        mancha=sum(datos.mancha2centro(ind_frame,:,1)>0)+1;
    end
    datos.mancha2pez(ind_frame,mancha)=pezbueno(1);
    datos.mancha2centro(ind_frame,mancha,:)=pezbueno(2:3);    
end
% set(h.figure,'windowscrollwheelfcn',@(uno,dos) ruedecita(uno,dos,h))
datos.trajectories=mancha2pez2trayectorias(datos.datosegm,datos.mancha2pez,[],[],datos.mancha2centro);

variable.mancha2pez=datos.mancha2pez;
variable.mancha2centro=datos.mancha2centro;
variable.trozos=datos.trozos;
if datos.datosegm.encriptar
    save_encrypt([datos.datosegm.directorio 'mancha2pez' datos.coletilla],variable,datos.datosegm.encriptar)
else
    save([datos.datosegm.directorio 'mancha2pez' datos.coletilla],'variable')
end
trajectories=datos.trajectories;
save([datos.datosegm.directorio 'trajectories' datos.coletilla],'trajectories')
clear mancha2pez

% disp('Correccion')
% datos.mancha2pez(ind_frame,:)
% datos.mancha2centro(ind_frame,:,1)
% datos.trajectories(ind_frame,:,1)

guidata(h.figure,datos)
pintaframe([],[],h)

function correr(uno,dos,h)
corriendo=~get(h.corriendo,'XData'); % Este controla si está corriendo
% corriendo
set(h.corriendo,'XData',corriendo)
set(h.figure, 'CurrentObject',h.figure)
% datos=guidata(h.figure);
% datos.corriendo=~datos.corriendo;
% guidata(h.figure,datos);
if corriendo && ~get(h.corriendo,'YData') % Para evitar que pueda entrar más de una vez al anidarse
    set(h.corriendo,'YData',1)
    set(h.push_run,'String','Stop')
    while corriendo       
        corriendo=get(h.corriendo,'XData');
        ruedecita(0,dos,h)
        drawnow
    end
    set(h.corriendo,'YData',0)
    set(h.push_run,'String','Run')
end
% disp('correr')
pause(.1)
% if strcmpi(get(h.t,'Running'),'off')
%     start(h.t)
% else
%     stop(h.t)
% end


% function corrige(uno,dos,h,archivo,titulo)
% datos=guidata(h.figure);
% [x,y]=ginput(1);
% set(h.figure,'windowscrollwheelfcn',@(uno,dos) ruedecita(uno,dos,h,archivo,titulo)) % Por algún motivo raro esta función se pierde al hacer ginput.
% datos.trayectoria(datos.frame,1)=x;
% datos.trayectoria(datos.frame,2)=y;
% guidata(h.figure,datos)
% ruedecita([],[],h,archivo,titulo)

% function retraquea(uno,dos,h,archivo,titulo,umbrales,roi,videomedio)
% datos=guidata(h.figure);
% title('Traqueando...')
% if isempty(roi)
%     figure
% end
% datos.trayectoria=tracking_choices(archivo,umbrales,roi,videomedio,datos.frame+1,datos.trayectoria);
% guidata(h.figure,datos)
% ruedecita([],[],h,archivo,titulo)

function ayuda(uno,dos)
msgbox(sprintf('To start/stop reproduction of the video, click "Run" or hit spacebar.\n\nYou may also advance step-by-step in the video using the mouse scroll wheel.\n\nUse the slide bar on the bottom to go to any point of the video, or edit the ''Current frame'' box to go to an specific frame.\n\nThe box''Speed'' controls how many frames the video will advance per step of the mouse scroll wheel (or per iteration when running). A negative number will make the video to play backwards.'),'Help')

function finaliza(uno,dos,h)
uiresume(h.figure)