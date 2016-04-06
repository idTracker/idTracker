% 18-Mar-2014 16:57:14 Hago que meta también las probabilidades
% 01-Dec-2013 10:26:53 Hago que se meta la ruta al archivo, en vez de
% datosegm
% APE, 25 nov 13

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function trajectories2txt(trajectories,probtrajectories,archivo)

if nargin<2 || isempty(archivo)
    archivo='trajectories.txt';
end

%% Build 2D matrix
trajectories2D=NaN([size(trajectories,1) size(trajectories,2)*3]);
for c_peces=1:size(trajectories,2)
    trajectories2D(:,(c_peces-1)*3+1:c_peces*3)=[trajectories(:,c_peces,1) trajectories(:,c_peces,2) probtrajectories(:,c_peces)];
end % c_peces

%% Make headers in the file
fid=fopen(archivo,'w');
for c_peces=1:size(trajectories,2)
    fprintf(fid,['X' num2str(c_peces) '\tY' num2str(c_peces) '\tProbId' num2str(c_peces) '\t']);
end
fprintf(fid,'\n');
fclose(fid);

%% Save matrix
dlmwrite(archivo,trajectories2D,'-append','delimiter','\t')

