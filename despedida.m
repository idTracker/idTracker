% 18-Mar-2014 15:37:07 Añado probtrayectorias y quito h
% APE 01 dic 13

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function despedida(datosegm,trayectorias,probtrayectorias)

h_desp=figure('Color','w','Name','idTracker - Job done','NumberTitle','off','MenuBar','none','ToolBar','figure');
axes('Position',[.2 .05 .3 .9])
mapa=jet(size(trayectorias,2));
hold on
for c_bichos=1:size(trayectorias,2)
    plot3(trayectorias(:,c_bichos,1),trayectorias(:,c_bichos,2),(1:size(trayectorias,1))','LineWidth',2,'Color',mapa(c_bichos,:))
end
axis tight
ejes=axis;
plot3([ejes(1) ejes(1) ejes(2) ejes(2) ejes(1)],[ejes(3) ejes(4) ejes(4) ejes(3) ejes(3)],zeros(1,5),'k','LineWidth',2) % Esto sería más lógico pintarlo antes que las trayectorias (para que quede por detrás), pero compruebo que queda por delante de todas maneras.    
view([20 -10])
set(gca,'XTick',[],'YTick',[])
zlabel('Time (frames)')
% ar=get(gca,'DataAspectRatio');
% ar(1:2)=mean(ar(1:2))
% set(gca,'DataAspectRatio',ar)

annotation('textbox','Position',[.55 .8 .4 .2],'String',sprintf('Tracking finished! :-)'),'LineStyle','none','FontSize',11,'FontWeight','bold','VerticalAlignment','bottom');

annotation('textbox','Position',[.55 .7 .4 .1],'String',sprintf('Reliability of identities:'),'LineStyle','none','FontSize',11,'FontWeight','normal','VerticalAlignment','bottom');

probmedia=mean(probtrayectorias(probtrayectorias>=0));
if isnan(probmedia)
    palabra='N/A';
    colorpalabra=[.5 .5 .5];
elseif probmedia>.8
    palabra=['High (' num2str(round(probmedia*100)) ' %)'];
    colorpalabra=[.2 .8 .2];
elseif probmedia>.7
    palabra=['Intermediate (' num2str(round(probmedia*100)) ' %)'];
    colorpalabra=[.8 .5 .2];
else
    palabra=['Low (' num2str(round(probmedia*100)) ' %)'];
    colorpalabra=[1 0 0];
    annotation('textbox','Position',[.55 .58 .4 .05],'String',sprintf('Warning!!\nIdentities may be unreliable'),'Color',colorpalabra,'LineStyle','none','FontSize',12,'FontWeight','bold','VerticalAlignment','bottom','HorizontalAlignment','left');
end

annotation('textbox','Position',[.55 .64 .4 .05],'String',palabra,'Color',colorpalabra,'LineStyle','none','FontSize',12,'FontWeight','bold','VerticalAlignment','bottom','HorizontalAlignment','center');


annotation('textbox','Position',[.55 .35 .4 .15],'String',sprintf('The results are in the files named ''trajectories'' in the same folder as the video.'),'LineStyle','none');

uicontrol('Style','pushbutton','String','About the output files','Units','normalized','Position',[.55 .25 .4 .08],'Callback',@(uno,dos) ExplainOutputFiles)
uicontrol('Style','pushbutton','String','See results','Units','normalized','Position',[.55 .15 .4 .08],'Callback',@(uno,dos) datosegm2muestravideo_nuevo(datosegm))
uicontrol('Style','pushbutton','String','Exit','Units','normalized','Position',[.55 .05 .4 .08],'Callback',@(uno,dos) cerrar(uno,dos,h_desp))

% Links a la ayuda
% labelStr = '<html><center><a href="">Undocumented<br>Matlab.com';
% cbStr = 'web(''http://Undocumentedmatlab.com'');';
% hButton = uicontrol('string',labelStr,'pos',[20,20,100,35],'callback',cbStr);
% jButton = findjobj(hButton); % get FindJObj from the File Exchange
% jButton.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
% jButton.setContentAreaFilled(0); % or: jButton.setBorder([]);

function ExplainOutputFiles
msgbox(sprintf('You will find four output files in the same folder as the video: Two of them are .mat files, to be loaded into Matlab. The other two are .txt files to import the data into any other software. Both .mat and .txt files contain identical information, which is the following:\n\n- X AND Y COORDINATES OF EACH INDIVIDUAL IN EACH FRAME\n\nFor .mat files: This information is contained in the variable ''trajectories'', which is a three-dimensional matrix. The first dimension runs along frames of the video, the second dimension runs along the different individuals, and the third dimension corresponds to the x and y coordinates. So for example, the element trajectories(1742,3,1) is the x coordinate of individual 3 in frame 1742.\n\nIn the .txt files: Each row corresponds to one frame of the video. Columns 1 and 2 are the x and y coordinates of individual 1, respectively. Columns 4 and 5 are the x and y coordinates of individual 2, and so on. NOTE that columns 3, 6, 9 etc. are not coordinates (see below).\n\n-PROBABILITY OF CORRECT ASSIGNMENT\n\nThis is an estimation of the probability of correct assignment for each frame. It is usually conservative, see Supplementary Figure 3 of the paper [1].\n\nIn the .mat files: The probability is contained in the variable probtrajectories, which is a two-dimensional matrix. The first dimension runs along frames, and the second dimension runs along individuals.\n\nIn the .txt files: The probabilities for individual 1 are in column 3, for individual 2 in column 6, and so on.\n\nDIFFERENCE BETWEEN trajectories AND trajectories_nogaps\n\nThe files called ''trajectories'' contain only the position of each individual when it is not occluded. \n\nThe files called ''trajectories_nogaps'' contain the position of each individual also when occluded. The probability of correct identity contains a negative number when the position comes from an estimation. -1 means that the animal was occluded, but a centroid was found after resegmentation of the image. -2 means that the image could not be resegmented, so the position of the centroid is not very accurate. See the paper [1] for more information. There may be small differences between ''trajectories'' and ''trajectories_nogaps'' even in the non-occluded frames, due to a correction algorithm during the estimation of occluded centroids.\n\n[1] Pérez-Escudero, Vicente-Page, Hinz, Arganda, de Polavieja. idTracker: Tracking individuals in a group by automatic identification of unmarked animals. Nature Methods 11(7):743-748 (2014)'),'idTracker - About the output files');

function cerrar(uno,dos,h_desp)
close(h_desp)