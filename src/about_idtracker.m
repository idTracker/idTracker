% APE 2 dic 13

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

%% Show information about idTracker
function version_idTracker=about_idtracker(uno,dos,datosegm)

if isfield(datosegm,'version_numero')
    version_idTracker=datosegm.version_numero;
else
    version_idTracker='2.1';
end

if nargout==0
    set(0,'Units','centimeters')
    tam_pantalla=get(0,'ScreenSize');
    set(0,'Units','pixels')
    ancho_fig=17;
    alto_fig=10;
    color_fondo=[1 1 1];
    h=figure('Units','centimeters','Position',[(tam_pantalla(3)-ancho_fig)/2 (tam_pantalla(4)-alto_fig)/2 ancho_fig alto_fig],'Color',color_fondo,'Name','About idTracker','NumberTitle','off','MenuBar','none','ToolBar','none');
    
    % Show logo of idTracker
    try
        im=imread('idTracker.png','BackgroundColor',[1 1 1]);
        im=im(:,end:-1:1,:);
        im=permute(im,[2 1 3]);
        im=im(:,40:end-20,:);
        alfa=.3;
        im=uint8(double(im)*alfa+255*(1-alfa));
        
        % im=im(:,end:-1:1,:);
        % figure
        % image(im)
        % ccaca
        ancho_im=alto_fig*size(im,2)/size(im,1);
        axes('Units','centimeters','Position',[0 0 ancho_im alto_fig])
        image(im)
        set(gca,'Visible','off')
        axis image % Esto no debería hacer falta, pero por si acaso
    end
    
    % Text
    texto=sprintf('Version %s\n\nwww.idtracker.es\n\nidTracker has been developed at Cajal Institute (Consejo Superior de Investigaciones Científicas) in Madrid, Spain.\n\nCitation:\nAlfonso Pérez-Escudero, Julián Vicente-Page, Robert Hinz, Sara Arganda, Gonzalo G. de Polavieja (2014) idTracker: Tracking individuals in a group by automatic identification of unmarked animals. Nature Methods 11(7):743-748\n\nNon-commercial use of idTracker is allowed at no cost. The technology behind idTracker is protected by patent PCT/ES2013/070585\n\nidTracker comes with NO WARRANTY. In no event shall the developers or distributors of idTracker be liable for any damages resulting from the use or misuse of the software.',version_idTracker);
    annotation('textbox','Units','centimeters','Position',[ancho_im+.5 1 ancho_fig-ancho_im-2 alto_fig-2],'String',texto,'FontSize',10,'LineStyle','none')
    % h=msgbox(sprintf('Version 1.01\n\nwww.idtracker.es\n\nidTracker is a project born at Cajal Institute (Consejo Superior de Investigaciones Científicas) in Madrid, Spain.\n\nCitation:\nAlfonso Pérez-Escudero, Julián Vicente-Page, Robert Hinz, Sara Arganda, Gonzalo G. de Polavieja. ''idTracker: Tracking individuals in a group by automatic identification of unmarked animals''\n\nNon-commercial use of idTracker is allowed at no cost. The technology behind idTracker is protected by patent PCT/ES2013/070585\n\nidTracker comes with NO WARRANTY. In no event shall the developers or distributors of idTracker be liable for any damages resulting from the use or misuse of the software.'),'About idTracker');
    % set(h,'Color',[.9 .9 .9])
end