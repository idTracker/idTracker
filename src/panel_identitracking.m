% 21-May-2016 11:20:11 I add "stop after resegmentation" in the "Advanced"
% menu
% 21-Jul-2014 22:41:32 / en vez de \
% 29-Apr-2014 10:30:41 Elimino la encriptación
% 07-Apr-2014 10:42:29 Añado la búsqueda de nueva versión
% 04-Feb-2014 15:24:01 Antes de "guarda copia", he hecho que funcione con
% el antigou ginput si la versión de matlab es antigua. Además, añado
% "soloreferencias" al menú "Advanced"
% 21-Dec-2013 13:21:56 Hago que guarde obj en datos para no tener que
% reabrir el archivo de vídeo si no es necesario
% 12-Dec-2013 15:40:41 Hago que use VideoReader si la versión es reciente
% 04-Dec-2013 19:10:48 Añado h_ocupado para que los callbacks "pidan la
% vez"
% 25-Nov-2013 17:48:15 Paso de trayectorias a trajectories. Añado lo de
% importar datos de otros vídeos (el 4 de diciembre).
% 25-Nov-2013 10:38:53 Quito la ventanita "Start in frame"
% 22-Nov-2013 18:20:22 Cambio "identitraquinator" por "idTracker", y otros
% lamentables cambios para que quede más serio.
% 20-Nov-2013 08:46:14 Anulo el menú "Advanced" para la versión compilada
% del paper.
% 14-Nov-2013 12:15:06 Añado el menú "Advanced", y preparo para que pueda
% seleccionarse una zona concreta para la normalización de la intensidad
% 08-Sep-2013 17:04:57 Nada.
% 06-Sep-2013 12:42:21 Hago que el ginput para el ROI vaya de punto en
% punto.
% 25-Aug-2013 19:16:15 Hago que el comportamiento del botón ROI cambie
% cuando ya se definido antes algo.
% 04-Jul-2013 20:51:42 Añado n_procesadores
% 31-May-2013 20:53:26 Añado encriptación
% 25-Apr-2013 16:51:09 Añado Trueno
% 19-Apr-2013 17:43:39 Hago que reutilice lo que pueda
% 10-Apr-2013 16:14:23 Evito que falle cuando se pide un frame que se pasa de rango. Además añado el intervalo
% 19-Feb-2013 15:23:22 Hago que pueda reutilizar parte de segm
% 18-Feb-2013 10:30:26 Hago que pueda reutilizar los trozos
% 27-Nov-2012 18:36:18 Cambio el formato de reutiliza
% APE 21 nov 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas.

function [datosegm,h]=panel_identitracking(datosegm)

menuadvanced=~datosegm.encriptar;
if ~isempty(dir(['.' filesep 'advanced.txt']))
    menuadvanced=true;
end
if ~isfield(datosegm,'mascara')
    datosegm.mascara=true(datosegm.tam);
end
if ~isfield(datosegm,'borde')
    datosegm.borde=false(datosegm.tam);
    datosegm.borde(1,:)=true;
    datosegm.borde(:,1)=true;
    datosegm.borde(datosegm.tam(1),:)=true;
    datosegm.borde(:,datosegm.tam(2))=true;
end

color_fondo=[.8 .8 1];
color_botones=[.7 .7 .8];
color_manchas=[0 1 0];
datos.alfa_manchas=.5;
color_mascara=[1 0 0];
datos.alfa_mascara=.5;
tam_letras=11;

margen_horiz=.01;
ancho_textos=.15;
ancho_edits=.1;
ancho_nmanchas=.1;
alto_textos=.03;
alto_ejestams=.015;
margen_vert=.05;
sep_vert=.01;
sep_vert3=.04;
sep_horiz=.01;
sep_horiz2=.04;
ancho_ejes=.6;
alto_ejes=.8;
alto_boton=.1;
sep_colorbar=.01;
ancho_colorbar=.02;

set(0,'Units','centimeters')
tam_pantalla=get(0,'ScreenSize');
set(0,'Units','pixels')

ancho_fig=min([30 tam_pantalla(3)]);
alto_fig=min([15 tam_pantalla(4)-2]); % El -2 es para dar espacio a la barra inferior del windows.
h.fig=figure('Units','centimeters','Position',[(tam_pantalla(3)-ancho_fig)/2 tam_pantalla(4)-alto_fig-3 ancho_fig alto_fig],'Color',color_fondo,'Name',['idTracker - ' datosegm.raizarchivo_videos ' in ' datosegm.directorio_videos],'NumberTitle','off','MenuBar','none','ToolBar','figure');
% Quito los botones que no me interesan
tooltipstrings_botonesquenoquiero={'New Figure','Open File','Edit Plot','Rotate 3D','Brush/Select Data','Link Plot','Insert Colorbar','Insert Legend','Hide Plot Tools','Show Plot Tools and Dock Figure'};
a = findall(h.fig);
for c=1:length(tooltipstrings_botonesquenoquiero)
    b = findall(a,'ToolTipString',tooltipstrings_botonesquenoquiero{c});
    set(b,'Visible','Off')
end % c

ratio_saveandexit=.2;
datosobj_on.Enable='on';
datosobj_off.Enable='off';
h.boton=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton (ancho_textos+sep_horiz+ancho_edits)*(1-ratio_saveandexit) alto_boton],'String','Start','BackgroundColor',color_botones,'FontSize',tam_letras,'HorizontalAlignment','left','Enable','off','UserData',datosobj_on);
h.boton_saveandexit=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz+(ancho_textos+sep_horiz+ancho_edits)*(1-ratio_saveandexit) 1-margen_vert-alto_boton (ancho_textos+sep_horiz+ancho_edits)*ratio_saveandexit alto_boton],'String',sprintf('S&E'),'BackgroundColor',color_botones,'FontSize',tam_letras,'HorizontalAlignment','left','Enable','off','UserData',datosobj_on);

textos={'Number of individuals','Intensity threshold','Minimum size','Resolution reduction','Remove background','Invert contrast','Interval','# of frames for refs.','roi','Segmentation only','# of processors'};
campos={'n_peces','umbral','umbral_npixels','reduceresol','limpiamierda','cambiacontraste','interval','nframes_refs','roi','trueno','n_procesadores'};
% pordefecto=[8 .85 200 1 1 0];
tipos=[1 1 1 1 2 2 1 1 3 2 1]; % 1 significa 'text', 2 significa 'checkbox', 3 significa que es la línea de botones del ROI
n_campos=length(campos);
for c_campos=1:n_campos
    switch tipos(c_campos)
        case 1 % Edit box
            uicontrol('Style','text','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_textos alto_textos],'String',textos{c_campos},'BackgroundColor',color_fondo,'FontSize',tam_letras,'HorizontalAlignment','left','Enable','off','UserData',datosobj_on);
            h.(campos{c_campos})=uicontrol('Style','edit','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_edits alto_textos],'BackgroundColor','w','FontSize',tam_letras,'HorizontalAlignment','right','Enable','off','UserData',datosobj_on);
            if length(datosegm.(campos{c_campos}))==1
                set(h.(campos{c_campos}),'String',num2str(datosegm.(campos{c_campos})))
            elseif length(datosegm.(campos{c_campos}))==2
                set(h.(campos{c_campos}),'String',[num2str(datosegm.(campos{c_campos})(1)) ' - ' num2str(datosegm.(campos{c_campos})(2))])
            end
        case 2 % Checkbox
            h.(campos{c_campos})=uicontrol('Style','checkbox','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_textos alto_textos],'Value',any(datosegm.(campos{c_campos})),'String',textos{c_campos},'BackgroundColor',color_fondo,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);
        case 3 % Botones del ROI
            ancho_roi=(ancho_textos+ancho_edits+sep_horiz)/3;
            h.push_roi=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_roi alto_textos],'String','Select region','BackgroundColor',color_botones,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);
            h.push_exclude=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz+ancho_roi 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_roi alto_textos],'String','Exclude region','BackgroundColor',color_botones,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);
            h.push_clearmascara=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz+2*ancho_roi 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_roi alto_textos],'String','Clear','BackgroundColor',color_botones,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);            
    end
    if strcmpi(campos{c_campos},'limpiamierda')
        h.push_videomedio=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_edits alto_textos],'String','Comp. Bckgrnd','BackgroundColor',color_botones,'FontSize',tam_letras,'Visible','off','Enable','off','UserData',datosobj_on);
        h.warnings(1)=uicontrol('Style','text','Units','Normalized','Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert .02 alto_textos],'FontSize',tam_letras,'String','!!','BackgroundColor',color_fondo,'ForeGroundcolor',[1 0 0],'FontWeight','bold','Visible','off','Enable','off','UserData',datosobj_on);        
    end
end

pasos=fieldnames(datosegm.reutiliza);
n_pasos=length(pasos);
for c_pasos=1:n_pasos
    c_campos=c_campos+1;
    if c_pasos==1
        h.(pasos{c_pasos})=uicontrol('Style','pushbutton','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_textos+sep_horiz+ancho_edits alto_textos],'Value',datosegm.reutiliza.(pasos{c_pasos}),'String','Load previous data','BackgroundColor',color_fondo,'FontSize',tam_letras,'Enable','off','UserData',datosobj_off,'BackgroundColor',color_botones);    
        if ~isempty(dir([datosegm.directorio 'datosegm.mat']))
            set(h.(pasos{c_pasos}),'UserData',datosobj_on)
        end
    else
        h.(pasos{c_pasos})=uicontrol('Style','checkbox','Units','normalized','Position',[margen_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_textos alto_textos],'Value',datosegm.reutiliza.(pasos{c_pasos}),'String',pasos{c_pasos},'BackgroundColor',color_fondo,'FontSize',tam_letras,'Enable','off','UserData',datosobj_off);    
        h.(['ejeswait' pasos{c_pasos}])=axes('Position',[margen_horiz+ancho_textos+sep_horiz 1-margen_vert-alto_boton-sep_vert-c_campos*alto_textos-(c_campos-1)*sep_vert ancho_edits alto_textos],'XLim',[0 1],'YLim',[0 1],'XTick',[],'YTick',[],'Box','on');
        h.(['wait' pasos{c_pasos}])=patch([0 0 0 0],[0 1 1 0],[.5 .5 .7]);
        h.(['textowait' pasos{c_pasos}])=text(.5,.5,'0 %','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',tam_letras);
    end
end % c_pasos
% Cambio a mano "trozos" por "fragments" y "FillGaps" por "Estimate during crossings"
set(h.Trozos,'String','Fragments')
set(h.FillGaps,'String','Est. during crossings')
% datos.obj=cell(1,size(datosegm.archivo2frame,1));
% Comprueba si hay que crear el objeto vídeo de nuevo
crearobj=true;
if isfield(datosegm,'obj') && ~isempty(datosegm.obj) && ~isempty(datosegm.obj{1})
    try a=get(datosegm.obj{1}); crearobj=false; catch; end
end
if crearobj
    if ~isfield(datosegm,'MatlabVersion') || str2double(datosegm.MatlabVersion(1))<8
        if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos '1.' datosegm.extension]))
            datosegm.obj{1}=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos '1.' datosegm.extension]);
        else
            datosegm.obj{1}=mmreader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
        end
    else
        if ~isempty(dir([datosegm.directorio_videos datosegm.raizarchivo_videos '1.' datosegm.extension]))
            datosegm.obj{1}=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos '1.' datosegm.extension]);
        else
            datosegm.obj{1}=VideoReader([datosegm.directorio_videos datosegm.raizarchivo_videos '.' datosegm.extension]);
        end
    end
end % if hay que crear el objeto de nuevo
datos.videoabierto=1;
frame=read(datosegm.obj{1},1);
if size(frame,3)==3
    frame=rgb2gray(frame);
end
datos.frame=frame;
datos.ind_frame=1;
% [datos.segm,datos.frame]=avi2segm(frame,datosegm,0,[]);
% datos.cambios.frame=true;
% datos.cambios.segmentacion=true;
h.ejes=axes('Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2 1-margen_vert-alto_ejes ancho_ejes alto_ejes]);
h.frame=imagesc(zeros(datosegm.tam));
hold(h.ejes,'on')
% h.ocupado se usará para que las funciones se den la vez. Cada elemento
% corresponde a una función, con el orden
% [actualiza redibuja clicreutiliza calculavideomedio cogezona borramascara importaparametros empiezatracking]
% Cada función sólo puede empezar cuando h.ocupado es cero para todas las
% demás funciones
% h.ocupado=plot(ones(1,8),NaN(1,8),'Visible','off');
% h.text_frame=uicontrol('Style','text','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2+ancho_nmanchas 1-margen_vert-alto_ejes-sep_vert3-alto_textos ancho_edits alto_textos],'FontSize',tam_letras,'String','Current frame','BackgroundColor',color_fondo,'ForeGroundcolor',[0 0 0]);
h.text_frame=uicontrol('Style','text','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2 1-margen_vert-alto_ejes-sep_vert3-alto_textos ancho_nmanchas alto_textos],'String','Current frame','BackgroundColor',color_fondo,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);
h.edit_frame=uicontrol('Style','edit','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2 1-margen_vert-alto_ejes-sep_vert3-2*alto_textos ancho_edits alto_textos],'String','1','BackgroundColor','w','FontSize',tam_letras,'HorizontalAlignment','right','Enable','off','UserData',datosobj_on);        
% n_manchas=length(datos.segm.pixels);
lienzo=repmat(color_manchas(:),[1 size(frame,1) size(frame,2)]);
lienzo=permute(lienzo,[2 3 1]);
h.lienzo_manchas=image(lienzo,'AlphaData',0);
lienzo=repmat(color_mascara(:),[1 size(frame,1) size(frame,2)]);
lienzo=permute(lienzo,[2 3 1]);
h.lienzo_mascara=image(lienzo,'AlphaData',0);
% datos.cambios.mascara=true;
axis image
colormap gray

caxis([0 1])
h.colorbar_axes=axes('Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2+ancho_ejes+sep_colorbar 1-margen_vert-alto_ejes ancho_colorbar alto_ejes]);
h.colorbar = patch(h.colorbar_axes,[0.9 1 1 0.9],[0 0 1 1],[1,1,1],'linewidth',3);
nColors = 30;
cbarHeight = 1;
cDataList   = linspace(0,1,nColors);
cbarSeg     = cbarHeight/nColors;
cbarY = [0, 0, cbarSeg,cbarSeg] - cbarHeight+1;
for iColor = 0:nColors-1
    patch([0.9 1 1 0.9],cbarY+iColor*cbarSeg,cDataList(iColor+1),'edgecolor','none')
end
h.lineaumbral=line([0.9 1],[1 1]*datosegm.umbral,'Color',color_manchas,'LineWidth',2);
% h_line_cbar = line([cbarLeft,cbarRight],[0,0],'color','k','linewidth',4);
% h.lineaumbral=plot(h.colorbar_axes,[h.colorbar.Position(1) h.colorbar.Position(3)],[1 1]*datosegm.umbral,'Color',color_manchas,'LineWidth',2);

h.text_nmanchas=uicontrol('Style','text','Units','normalized','Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2+ancho_edits 1-margen_vert-alto_ejes-sep_vert3-2*alto_textos ancho_nmanchas 2*alto_textos],'String',sprintf('0 animals\ndetected'),'BackgroundColor',color_fondo,'FontSize',tam_letras,'Enable','off','UserData',datosobj_on);
h.ejes_tams=axes('Position',[margen_horiz+ancho_textos+sep_horiz+ancho_edits+sep_horiz2+ancho_edits+ancho_nmanchas+.01 1-margen_vert-alto_ejes-sep_vert3-alto_ejestams ancho_ejes-ancho_nmanchas-ancho_edits-.01 alto_ejestams],'TickDir','in');%,'FontSize',tam_letras);
xlabel('Sizes of detected animals (pixels)')


if menuadvanced
    h.menu_import=uimenu('Label','Import tracking parameters','Enable','off','UserData',datosobj_on);
    h.menu_advanced=uimenu('Label','Advanced','Enable','off','UserData',datosobj_on);
    h.submenu_regionintensity=uimenu(h.menu_advanced,'Label','Select region for intensity reference');
    h.submenu_solohastareferencias=uimenu(h.menu_advanced,'Label','Finish after learning the references');
    h.submenu_stopafterresegmentation=uimenu(h.menu_advanced,'Label','Finish after resegmentation');
else
    h.menu_import=-1;
    h.menu_advanced=-1;
    h.submenu_regionintensity=-1;
    h.submenu_solohastareferencias=-1;
end
h.menu_about=uimenu('Label','About idTracker','Enable','off','UserData',datosobj_on);
% h.timerboton=timer;

%% Callbacks
set(h.boton,'Callback',@(uno,dos) empiezatracking(uno,dos,h))
set(h.boton_saveandexit,'Callback',@(uno,dos) empiezatracking(uno,dos,h))
for c_campos=1:n_campos
    if isfield(h,campos{c_campos})
        set(h.(campos{c_campos}),'Callback',@(uno,dos) actualiza(uno,dos,h))
    end
end % c_campos
set(h.edit_frame,'Callback',@(uno,dos) actualiza(uno,dos,h))
set(h.push_roi,'Callback',@(uno,dos) cogezona(uno,dos,h))
set(h.push_exclude,'Callback',@(uno,dos) cogezona(uno,dos,h))
if menuadvanced
    set(h.menu_import,'Callback',@(uno,dos) importaparametros(uno,dos,h))
    set(h.submenu_regionintensity,'Callback',@(uno,dos) cogezona(uno,dos,h))
    set(h.submenu_solohastareferencias,'Callback',@(uno,dos) clic_solohastareferencias(uno,dos,h))
    set(h.submenu_stopafterresegmentation,'Callback',@(uno,dos) clic_solohastareferencias(uno,dos,h))
    if isfield(datosegm,'solohastareferencias') && datosegm.solohastareferencias
        set(h.submenu_solohastareferencias,'Checked','on')
    end
end
set(h.push_clearmascara,'Callback',@(uno,dos) borramascara(uno,dos,h))
set(h.push_videomedio,'Callback',@(uno,dos) calculavideomedio(uno,dos,h))
set(h.datosegm,'Callback',@(uno,dos) clicreutiliza(uno,dos,h))
pasos=fieldnames(datosegm.reutiliza);
for c_pasos=2:length(pasos)
    set(h.(pasos{c_pasos}),'Callback',@(uno,dos) actualiza(uno,dos,h))
end % c_pasos
set(h.menu_about,'Callback',@(uno,dos) about_idtracker(uno,dos,datosegm))
set(h.fig,'CloseRequestFcn',@(uno,dos) cerrar(uno,dos,h))
datos.datosegm=datosegm;
datos.campos=campos;


% Comprueba si hay una nueva versión
datos.texto_version='';
try    
    texto=urlread('https://drive.google.com/uc?export=download&id=0B-Ne02D-easKTFZXQjRiSzNibFU');
    version=texto(1:15);
    load versioninfo
    if ~strcmpi(versioninfo.version,version)
        datos.texto_version=texto(16:end);        
        h.menu_newversion=uimenu('Label','New version available!','Enable','off','UserData',datosobj_on);
        set(h.menu_newversion,'Callback',@(uno,dos) actualizaversion(uno,dos,h))
    end
catch me
    try
        save update_error me
    end
end
    

guidata(h.fig,datos);
% ocupado=zeros(1,8);
% ocupado(3)=1; % Da paso a clicreutiliza
% set(h.ocupado,'XData',ocupado); drawnow
clicreutiliza([],[],h) %Antonio: problem here!!!
reactiva(1,h)
% disp('dos')
% actualiza(NaN,[],h)
% disp('tres')
% redibuja([],[],h)
if ~isfield(datosegm,'empezarsinmas') || datosegm.empezarsinmas==0
        uiwait(h.fig)    
else
    datos=guidata(h.fig);
    datos.datosegm.saltatodo=false;
    guidata(h.fig,datos)
end
try
    datos=guidata(h.fig);
catch me
    if ~ishandle(h.fig)
        error('idTracker:WindowClosed','Control panel closed by the user')
    else
        throw(me)
    end
end
datosegm=datos.datosegm;
datosegm.primerframe_intervalosbuenos=datosegm.interval(1);
if menuadvanced
    datosegm.solohastareferencias=strcmpi(get(h.submenu_solohastareferencias,'Checked'),'on');
    datosegm.stopafterresegmentation=strcmpi(get(h.submenu_stopafterresegmentation,'Checked'),'on');
end

%% Update
function actualiza(uno,dos,h)
% ind_funcion=1;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);

% datos.datosegm.progreso

for c_campos=1:length(datos.campos)
    if isfield(h,datos.campos{c_campos})
        if strcmpi(get(h.(datos.campos{c_campos}),'Style'),'edit')
            texto=get(h.(datos.campos{c_campos}),'String');
            texto(texto=='-')=' '; % Cambia el guión por espacio en el intervalo. Luego, str2num interpretará el espacio como separación entre los dos elementos
            datos.datosegm.(datos.campos{c_campos})=str2num(texto);             %#ok<ST2NM>
        elseif strcmpi(get(h.(datos.campos{c_campos}),'Style'),'checkbox')
            datos.datosegm.(datos.campos{c_campos})=get(h.(datos.campos{c_campos}),'Value');
        end
    end
end % c_campos
% Si hace falta, rehace la segmentación
% if any(uno==[h.umbral h.umbral_npixels h.cambiacontraste h.limpiamierda h.edit_frame -1]) % -1 significa que viene de importar datos
%     datos.cambios.segmentacion=true;
% end
if uno==h.interval || uno==-1 % -1 significa que viene de importar datos
    inicioborrar=2; % Si cambia el intervalo, hay que rehacer el background
    datos.datosegm.reutiliza.Background=false;
elseif any(uno==[h.umbral h.umbral_npixels h.reduceresol h.limpiamierda h.cambiacontraste])    
    inicioborrar=3; % El background puede sobrevivir, sólo hay que rehacerlo si cambia el ROI.
elseif any(uno==[h.n_peces])
    inicioborrar=4; % A partir de individualization
elseif any(uno==[h.nframes_refs])
    inicioborrar=5; % A partir de las referencias
else
    inicioborrar=Inf;
end
campos=fieldnames(datos.datosegm.reutiliza);
for c_campos=inicioborrar:length(campos)
    datos.datosegm.reutiliza.(campos{c_campos})=0;
    datos.datosegm.progreso.(campos{c_campos})=0;
end
% if uno==h.cambiacontraste
%     datos.cambios.frame=true;
% end
% Controla el estado de los checkboxes de reutiliza
n_frames=size(datos.datosegm.frame2archivo,1);
set(h.waitBackground,'XData',[0 0 datos.datosegm.progreso.Background datos.datosegm.progreso.Background])
    set(h.textowaitBackground,'String',[num2str(round(datos.datosegm.progreso.Background*100)) ' %'])
if datos.datosegm.progreso.Background>0 && datos.datosegm.limpiamierda
    datosobj.Enable='on';
    set(h.Background,'UserData',datosobj)    
else
    datosobj.Enable='off';
    set(h.Background,'UserData',datosobj,'Value',0)
end
datos.datosegm.reutiliza.Background=get(h.Background,'Value');
pasos=fieldnames(datos.datosegm.reutiliza);
for c_pasos=3:length(pasos) % El primero es datosegm, y el segundo Background
    set(h.(['wait' pasos{c_pasos}]),'XData',[0 0 datos.datosegm.progreso.(pasos{c_pasos}) datos.datosegm.progreso.(pasos{c_pasos})])
    set(h.(['textowait' pasos{c_pasos}]),'String',[num2str(round(datos.datosegm.progreso.(pasos{c_pasos})*100)) ' %'])
%     (pasos{c_pasos})
    if datos.datosegm.progreso.(pasos{c_pasos})>0        
        if get(h.(pasos{c_pasos-1}),'Value')==0 && ~(c_pasos==3 && ~datos.datosegm.limpiamierda) % Si no reutiliza el anterior, no se puede reutilizar este.
            datosobj.Enable='off';
            set(h.(pasos{c_pasos}),'UserData',datosobj,'Value',0)
        else
            datosobj.Enable='on';
            set(h.(pasos{c_pasos}),'UserData',datosobj)
        end
    else
        datosobj.Enable='off';
        set(h.(pasos{c_pasos}),'UserData',datosobj)
    end
    datos.datosegm.reutiliza.(pasos{c_pasos})=get(h.(pasos{c_pasos}),'Value');
end
% Controla visibilidad del botón para calcular el videomedio
if datos.datosegm.limpiamierda
    set(h.push_videomedio,'Visible','on')
    if isfield(datos.datosegm,'videomedio') && ~isempty(datos.datosegm.videomedio) && datos.datosegm.reutiliza.Background
        set(h.warnings(1),'Visible','off')
    else
        set(h.warnings(1),'Visible','on')
    end
else
    set(h.push_videomedio,'Visible','off')
    set(h.warnings(1),'Visible','off')
end
set(h.lineaumbral,'YData',datos.datosegm.umbral*[1 1])
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% ocupado(2)=1; % Reserva la vez para redibuja
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
redibuja([],[],h)
reactiva(1,h)

%% Redibuja
function redibuja(uno,dos,h)
% ind_funcion=2;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);

if datos.ind_frame~=str2double(get(h.edit_frame,'String'))
    datos.ind_frame=str2double(get(h.edit_frame,'String'));
    if datos.ind_frame>size(datos.datosegm.frame2archivo,1)
        datos.ind_frame=size(datos.datosegm.frame2archivo,1);
        set(h.edit_frame,'String',num2str(datos.ind_frame))
    end
    archivo_act=datos.datosegm.frame2archivovideo(datos.ind_frame,1);
    % Comprueba si hay que crear el objeto vídeo
    crearobj=true;
    if isfield(datos.datosegm,'obj') && ~isempty(datos.datosegm.obj{archivo_act})
        try a=get(datos.datosegm.obj{archivo_act}); crearobj=false; catch; end
    end
    if crearobj
        if ~isfield(datos.datosegm,'MatlabVersion') || str2double(datos.datosegm.MatlabVersion(1))<8
            if ~isempty(dir([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(datos.datosegm.frame2archivovideo(datos.ind_frame,1)) '.' datos.datosegm.extension]))
                datos.datosegm.obj{archivo_act}=mmreader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(datos.datosegm.frame2archivovideo(datos.ind_frame,1)) '.' datos.datosegm.extension]);
            else
                datos.datosegm.obj{archivo_act}=mmreader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos '.avi']);
            end
        else
            if ~isempty(dir([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(datos.datosegm.frame2archivovideo(datos.ind_frame,1)) '.' datos.datosegm.extension]))
                datos.datosegm.obj{archivo_act}=VideoReader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos num2str(datos.datosegm.frame2archivovideo(datos.ind_frame,1)) '.' datos.datosegm.extension]);
            else
                datos.datosegm.obj{archivo_act}=VideoReader([datos.datosegm.directorio_videos datos.datosegm.raizarchivo_videos '.avi']);
            end
        end
        datos.videoabierto=archivo_act;
    end
    frame=read(datos.datosegm.obj{archivo_act},datos.datosegm.frame2archivovideo(datos.ind_frame,2));
    if size(frame,3)==3
        frame=rgb2gray(frame);    
    end
    datos.frame=frame;
end
% if datos.cambios.frame || datos.cambios.segmentacion
    cambialimpiamierda=false;
    if datos.datosegm.limpiamierda && ~isfield(datos.datosegm,'videomedio')
        datos.datosegm.limpiamierda=false;        
        cambialimpiamierda=true;
    end
    if isfield(datos.datosegm,'videomedio') && ~isempty(datos.datosegm.videomedio)
        datos.datosegm=datosegm2datosegm_pixelsmierda(datos.datosegm);        
    end
    datosegm_act=datos.datosegm;
    datosegm_act.max_manchas.absoluto=Inf; % Para que se muestren todas las manchas.
    [datos.segm,frame]=avi2segm(datos.frame,datosegm_act,0,[]);
    if cambialimpiamierda
        datos.datosegm.limpiamierda=true;
    end
% end
% if datos.cambios.frame
    set(h.frame,'CData',frame)
%     datos.cambios.frame=false; 
    % Cambio el orden de los children del colorbar, para que la línea siempre quede por encima.
    drawnow % Para que se actualicen los handles
% hijos=get(h.colorbar,'Children');
% lineaumbral=find(hijos==h.lineaumbral);
% hijos=hijos([lineaumbral 1:lineaumbral-1 lineaumbral+1:end],1); %Antonio:
% problem here -> Hijos is empty. This is not necessary anymore.
% set(h.colorbar,'Children',hijos)
% end

% if datos.cambios.segmentacion
    n_manchas=length(datos.segm.pixels);
    alfa_manchas=zeros(datos.datosegm.tam);
    for c_manchas=1:n_manchas
        alfa_manchas(datos.segm.pixels{c_manchas})=datos.alfa_manchas;
    end
    set(h.lienzo_manchas,'AlphaData',alfa_manchas)
    set(h.text_nmanchas,'String',sprintf([num2str(length(datos.segm.pixels)) ' animals\ndetected']))    
    tam_letras=get(h.ejes_tams,'FontSize');
    hold(h.ejes_tams,'off')
    for c_manchas=1:n_manchas
        plot(h.ejes_tams,length(datos.segm.pixels{c_manchas})*[1 1],[0 1],'k','LineWidth',2)
        hold(h.ejes_tams,'on')
    end
    plot(h.ejes_tams,datos.datosegm.umbral_npixels*[1 1],[0 1],'r','LineWidth',2)
    set(h.ejes_tams,'YTick',[],'YLim',[0 1],'TickDir','out','FontSize',tam_letras,'Box','off','YColor','w')
    xlabel(h.ejes_tams,'Sizes of detected animals (pixels)')
%     datos.cambios.segmentacion=false;
% end
% if datos.cambios.mascara
    alfa_act=datos.alfa_mascara*(~datos.datosegm.mascara);
    alfa_act(datos.datosegm.borde)=1;
    set(h.lienzo_mascara,'AlphaData',alfa_act);        
%     datos.cambios.mascara=false;
% end

% Controla el aspecto del botón de ROI
if any(~datos.datosegm.mascara(:))
    set(h.push_roi,'String','Include region')
else
    set(h.push_roi,'String','Select region')
end

guidata(h.fig,datos)
reactiva(1,h)
% ocupado(ind_funcion)=0;
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez

%% Carga datosegm para reutilizar
function clicreutiliza(uno,dos,h)
% ind_funcion=3;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);
if uno==h.datosegm % Si no viene del botón, estamos simplemente comprobando si hay algo reutilizable con el datosegm que ya tenemos.
    load([datos.datosegm.directorio 'datosegm'])
    datosegm=variable;
    datos.datosegm=datosegm;
end
datos.datosegm=datosegm2progreso(datos.datosegm);
% Hago que reutilice todo lo que haya terminado
campos=fieldnames(datos.datosegm.progreso);
for campo=campos(:)'
    if datos.datosegm.progreso.(campo{1})==1
        datos.datosegm.reutiliza.(campo{1})=1;
        set(h.(campo{1}),'Value',1)
    end
end

for c_campos=1:length(datos.campos)
    if isfield(h,datos.campos{c_campos})
        if strcmpi(get(h.(datos.campos{c_campos}),'Style'),'edit')
            set(h.(datos.campos{c_campos}),'String',num2str(datos.datosegm.(datos.campos{c_campos})))
        elseif strcmpi(get(h.(datos.campos{c_campos}),'Style'),'checkbox')
            set(h.(datos.campos{c_campos}),'Value',datos.datosegm.(datos.campos{c_campos}))
        end
    end
end % c_campos
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% ocupado(1)=1; % Reserva la vez para actualiza
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
actualiza(NaN,[],h)
reactiva(1,h)




%     set(h.Background,'Enable','on')
%     set(h.waitBackground,'XData',[0 0 1 1])
%     set(h.textowaitBackground,'String','100 %')
% else
%     set(h.Background,'Enable','off')
%     set(h.waitBackground,'XData',[0 0 0 0])
%     set(h.textowaitBackground,'String','0 %')
% end


%% Compute videomedio
function calculavideomedio(uno,dos,h)
% ind_funcion=4;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);
datos.datosegm=datosegm2videomedio(datos.datosegm,100,h);
datos.datosegm.progreso.Background=size(datos.datosegm.frame2archivo,1);
% datos.cambios.frame=1;
% datos.cambios.segmentacion=1;
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% ocupado(1)=1; % Reserva la vez para actualiza
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
actualiza(NaN,[],h)
% redibuja([],[],h)
reactiva(1,h)

%% Select region (for ROI, for exclusion, or for intensmed)
function cogezona(uno,dos,h)
% ind_funcion=5;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);

campos=fieldnames(datos.datosegm.reutiliza);
for c_campos=2:length(campos)
    datos.datosegm.reutiliza.(campos{c_campos})=0;
    datos.datosegm.progreso.(campos{c_campos})=0;
end
datos.datosegm.videomedio=[];

respuesta = questdlg('Select shape of region','Geometry','Rectangular','Circular','Polygon','Rectangular');
switch respuesta
    case 'Rectangular'
        title(h.ejes,'Please, select two opposite corners of the rectangle');   
        h_puntos=plot(h.ejes,NaN,NaN,'r.','MarkerSize',10);
        for c_puntos=1:2
            try
                [x(c_puntos,1),y(c_puntos,1)]=ginput_nocross(1);
            catch
                [x(c_puntos,1),y(c_puntos,1)]=ginput(1);
            end
            x(x<1)=1;
            x(x>datos.datosegm.tam(2))=datos.datosegm.tam(2);
            y(y<1)=1;
            y(y>datos.datosegm.tam(1))=datos.datosegm.tam(1);
            set(h_puntos,'XData',x,'YData',y)
        end % c_puntos        
        delete(h_puntos)
        roi=round([x y]);
        datos.datosegm.roi=[x y];
        mascara=true(datos.datosegm.tam);
        mascara(:,1:min(roi(:,1))-1)=false;
        mascara(:,max(roi(:,1))+1:end)=false;
        mascara(1:min(roi(:,2))-1,:)=false;
        mascara(max(roi(:,2))+1:end,:)=false;
%         borde=false(datos.datosegm.tam);
%         borde(min(roi(:,2)):max(roi(:,2)),min(roi(:,1)))=true;
%         borde(min(roi(:,2)):max(roi(:,2)),max(roi(:,1)))=true;
%         borde(min(roi(:,2)),min(roi(:,1)):max(roi(:,1)))=true;
%         borde(max(roi(:,2)),min(roi(:,1)):max(roi(:,1)))=true;
    case 'Circular'
        title(h.ejes,'Please, select four points along the circle');
        h_puntos=plot(h.ejes,NaN,NaN,'r.','MarkerSize',10);
        for c_puntos=1:4
            try
                [x(c_puntos,1),y(c_puntos,1)]=ginput_nocross(1);
            catch
                [x(c_puntos,1),y(c_puntos,1)]=ginput(1);
            end
            x(x<1)=1;
            x(x>datos.datosegm.tam(2))=datos.datosegm.tam(2);
            y(y<1)=1;
            y(y>datos.datosegm.tam(1))=datos.datosegm.tam(1);
            set(h_puntos,'XData',x,'YData',y)
        end % c_puntos        
        delete(h_puntos)
        A=[x y ones(4,1)];
        b=-x.^2-y.^2;
        coefs=A\b;        
        roi(1)=-coefs(1)/2;
        roi(2)=-coefs(2)/2;
        roi(3)=sqrt(roi(1)^2+roi(2)^2-coefs(3));
        X=repmat(1:datos.datosegm.tam(2),[datos.datosegm.tam(1) 1]);
        Y=repmat((1:datos.datosegm.tam(1))',[1 datos.datosegm.tam(2)]);
        mascara=(X-roi(1)).^2 + (Y-roi(2)).^2<roi(3)^2;
%         borde=abs(sqrt((X-roi(1)).^2 + (Y-roi(2)).^2)-(roi(3)-1))<=sqrt(2);
        datos.datosegm.roi=roi;
    case 'Polygon'
        title(h.ejes,'Please, select at least three points and press ENTER');
        c_puntos=0;
        seguir=true;
        h_puntos=plot(h.ejes,NaN,NaN,'r.-','MarkerSize',10);
        while seguir
            c_puntos=c_puntos+1;
            try
                [x_act,y_act]=ginput_nocross(1);
            catch
                [x_act,y_act]=ginput(1);
            end
            if ~isempty(x_act)
                x(c_puntos,1)=x_act;
                y(c_puntos,1)=y_act;
                x(x<1)=1;
                x(x>datos.datosegm.tam(2))=datos.datosegm.tam(2);
                y(y<1)=1;
                y(y>datos.datosegm.tam(1))=datos.datosegm.tam(1);
                set(h_puntos,'XData',x,'YData',y)
            else
                seguir=false;
            end
        end % while seguir cogiendo puntos
        delete(h_puntos)
        if length(x)<3
             errordlg('You must specify at least 3 corners of the polygon','Error');
        end
        x(x<1)=1;
        x(x>datos.datosegm.tam(2))=datos.datosegm.tam(2);
        y(y<1)=1;
        y(y>datos.datosegm.tam(1))=datos.datosegm.tam(1);
        datos.datosegm.roi=round([x y]);
        mascara=zonapoligono(datos.datosegm.roi,datos.datosegm.tam);        
end
if uno==h.push_roi
    if any(~datos.datosegm.mascara(:))
        datos.datosegm.mascara=datos.datosegm.mascara | mascara;
    else
        datos.datosegm.mascara=mascara;
    end
    mascara=datos.datosegm.mascara;
    borde=false(size(mascara));
    borde(1:end,1:end-1)=borde(1:end,1:end-1) | ~mascara(1:end,1:end-1) & mascara(1:end,2:end);
    borde(1:end,2:end)=borde(1:end,2:end) | ~mascara(1:end,2:end) & mascara(1:end,1:end-1);
    borde(1:end-1,1:end)=borde(1:end-1,1:end) | ~mascara(1:end-1,1:end) & mascara(2:end,1:end);
    borde(2:end,1:end)=borde(2:end,1:end) | ~mascara(2:end,1:end) & mascara(1:end-1,1:end);
    datos.datosegm.borde=borde;
elseif uno==h.push_exclude
    datos.datosegm.mascara(mascara)=false;
    mascara=datos.datosegm.mascara;
    borde=false(size(mascara));
    borde(1:end,1:end-1)=borde(1:end,1:end-1) | ~mascara(1:end,1:end-1) & mascara(1:end,2:end);
    borde(1:end,2:end)=borde(1:end,2:end) | ~mascara(1:end,2:end) & mascara(1:end,1:end-1);
    borde(1:end-1,1:end)=borde(1:end-1,1:end) | ~mascara(1:end-1,1:end) & mascara(2:end,1:end);
    borde(2:end,1:end)=borde(2:end,1:end) | ~mascara(2:end,1:end) & mascara(1:end-1,1:end);
    datos.datosegm.borde=borde;
elseif uno==h.submenu_regionintensity
    datos.datosegm.mascara_intensmed=mascara;
end

title(h.ejes,'')
% datos.cambios.mascara=true;
% datos.cambios.segmentacion=true;
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% ocupado(1)=1; % Reserva la vez para actualiza
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
actualiza(NaN,[],h)
reactiva(1,h)

%% Clear ROI (mascara)
function borramascara(uno,dos,h)
% ind_funcion=6;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);

campos=fieldnames(datos.datosegm.reutiliza);
for c_campos=2:length(campos)
    datos.datosegm.reutiliza.(campos{c_campos})=0;
    datos.datosegm.progreso.(campos{c_campos})=0;
end
datos.datosegm.videomedio=[];

datos.datosegm.mascara=true(datos.datosegm.tam);
datos.datosegm.borde=false(datos.datosegm.tam);
datos.datosegm.borde(1,:)=true;
datos.datosegm.borde(:,1)=true;
datos.datosegm.borde(datos.datosegm.tam(1),:)=true;
datos.datosegm.borde(:,datos.datosegm.tam(2))=true;

% datos.cambios.mascara=true;
% datos.cambios.segmentacion=true;
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% ocupado(1)=1; % Reserva la vez para actualiza
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
actualiza(NaN,[],h)
reactiva(1,h)

function importaparametros(uno,dos,h)
% ind_funcion=7;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);
directorio=ultimodir;
[nombrearchivo,directorio]=uigetfile('*.avi','Select video file from which tracking parameters are to be borrowed',directorio);

if directorio(end)~=filesep
    directorio(end+1)=filesep;
end
ultimodir(directorio);
if ~isempty(dir([directorio 'segm' filesep 'datosegm.mat']))
   load([directorio 'segm' filesep 'datosegm.mat'])
   if isstruct(variable)
       datosegm=variable;
       clear variable
   else
       datosegm=load_encrypt([directorio 'segm' filesep 'datosegm.mat'],1);
   end
   % Primero los campos que se ven en el panel
   for c_campos=1:length(datos.campos)       
       if isfield(h,datos.campos{c_campos})
           if strcmpi(get(h.(datos.campos{c_campos}),'Style'),'edit')
               set(h.(datos.campos{c_campos}),'String',num2str(datosegm.(datos.campos{c_campos})))
           elseif strcmpi(get(h.(datos.campos{c_campos}),'Style'),'checkbox')
               set(h.(datos.campos{c_campos}),'Value',datosegm.(datos.campos{c_campos}))
           end
       end
   end % c_campos
   % Resto de los campos
   if all(datos.datosegm.tam==datosegm.tam)
       datos.datosegm.roi=datosegm.roi;
       datos.datosegm.mascara_intensmed=datosegm.mascara_intensmed;
       datos.datosegm.mascara=datosegm.mascara;
       datos.datosegm.borde=datosegm.borde;
   else
        msgbox('Resolution is different in the two videos. Region of Interest and Region for Intensity Normalization could not be imported. All the other parameters have been successfully imported.','Parameters partially imported')
   end
   guidata(h.fig,datos)
%    ocupado(ind_funcion)=0;
%    ocupado(1)=1; % Reserva la vez para actualiza
%    set(h.ocupado,'XData',ocupado); drawnow % Da la vez
   actualiza(-1,[],h)
   reactiva(1,h)
else
    msgbox(sprintf('Tracking parameters not found\n\nThe file %ssegm\\datosegm.mat that contains the parameters does not exist',directorio),'Parameters not found')
end


%% Start tracking
function empiezatracking(uno,dos,h)
% ind_funcion=8;
% ocupado=get(h.ocupado,'XData');
% ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% while any(ocupado)==1 % Si está ocupado, espera a que se desocupe
%     pause(.1)
%     ocupado=get(h.ocupado,'XData');
%     ocupado(ind_funcion)=0; % Ignora el valor que corresponde a ella misma
% end
% ocupado(ind_funcion)=1;
% set(h.ocupado,'XData',ocupado); drawnow % Coge la vez
reactiva(0,h)
datos=guidata(h.fig);    
if uno==h.boton_saveandexit
    datos.datosegm.saltatodo=true;    
else
    datos.datosegm.saltatodo=false;
    set(h.boton,'String','Running')
end
guidata(h.fig,datos)
% ocupado(ind_funcion)=0;
% set(h.ocupado,'XData',ocupado); drawnow % Da la vez
uiresume(h.fig)

%% Change state of buttons
function reactiva(estado,h)
hijos=get(h.fig,'Children');
for c=1:length(hijos)
    if ~strcmpi(get(hijos(c),'Type'),'axes')
        if estado % Enable todo lo que corresponda
            datosobj=get(hijos(c),'UserData');
            set(hijos(c),'Enable',datosobj.Enable)
        else % Disable todo
            set(hijos(c),'Enable','off')
        end
    end
end
drawnow

%% Click in solohastareferencias in the "Advanced" menu
function clic_solohastareferencias(uno,dos,h)
if strcmpi(get(uno,'Checked'),'on')
    set(uno,'Checked','off')
else
    set(uno,'Checked','on')
end

%% Open the update dialog
function actualizaversion(uno,dos,h)
datos=guidata(h.fig);
% instrucciones=sprintf('\n\nInstallation instructions:\n\n- Download new version from www.idtracker.es/download/executables (click below to open the page in your browser)\n- Click ''Download'' to download the compressed files\n- Make a back-up of your current idTracker files (optional)\n- Unzip the new files');
respuesta=questdlg([sprintf('New version available\n') datos.texto_version],'idTracker - New version available','Download new version','Cancel','Download & install (manually)');
if strcmpi(respuesta,'Download new version')
    web('http://www.idtracker.es/download','-browser')
end

%% Close the window
function cerrar(uno,dos,h)
% uiresume(h.fig)
closereq