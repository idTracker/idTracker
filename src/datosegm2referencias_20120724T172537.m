% 28-Jun-2012 09:53:58 Hago que tam_mapas salga de datosegm
% 01-Jun-2012 13:01:33 Evito que haya referencias de más de
% nframes_final frames. Además cambio la forma de recortar las referencias,
% que era al azar, y paso a que estén equiespaciados
% 13-Feb-2012 10:25:27 Corrijo que nframes_final sólo se calculara para las
% dos primeras referencias
% 14-Oct-2011 12:47:51 Quito refs_sinreordenar. Las referencias salen
% directamente sin reordenar
% 10-Oct-2011 19:16:22 Cambia 'segm' por datosegm.raizarchivo
% 06-Oct-2011 16:34:41 Lo preparo para más de dos peces
% 03-Aug-2011 21:25:07 En vez de volver atrás por cada nueva referencia
% incorporada, hace varias pasadas. Así va más rápido.
% 03-Aug-2011 18:55:34 Hago que cuando incorpora una nueva referencia
% vuelva atrás a intentar recuperar las que se dejó por el camino
% 03-Aug-2011 17:51:38 CORRECCIÓN: Hago que ref2_act=referencias2, en vez
% de referencias. Antes el funcionamiento era completamente errático.
% APE 2 ago 11 Viene de segm2referencias

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function [referencias,framesescogidos]=datosegm2referencias(datosegm,intervalosbuenos,nframes_final)

if nargin<3 || isempty(nframes_final)
    nframes_final=500; % Número de frames que queremos en la referencia
end

permutaciones=perms(1:datosegm.n_peces);
n_perms=size(permutaciones,1);
diagonal=1:(datosegm.n_peces+1):datosegm.n_peces^2;

umbral_Ptotal=10^-20;
umbral_Pindiv=10^-10;

% indvalidos=segm2indvalidos(segm);
mat_validos=datosegm.indvalidos;
indvalidos{1}=find(mat_validos(:,:,1));
mat_validos(:,:,1)=false;
indvalidos{2}=find(mat_validos);

n_peces=size(intervalosbuenos.framespararefs,2);
[nvalidos_sort,orden]=sort(min(intervalosbuenos.n_validos,[],2),'descend');
c_intervalos=1;
incorporados=false(1,length(orden));
nframes1=nvalidos_sort(c_intervalos);
mejorintervalo=orden(c_intervalos);
c_refs=zeros(1,n_peces);
archivo_act=-1;
fprintf('[%g %g]',intervalosbuenos.iniciofinal(mejorintervalo,1),intervalosbuenos.iniciofinal(mejorintervalo,2))
archivo_act=datosegm.frame2archivo(intervalosbuenos.iniciofinal(mejorintervalo,1),1);
frame_act=datosegm.frame2archivo(intervalosbuenos.iniciofinal(mejorintervalo,1),2);
load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
tam_mapa=datosegm.tam_mapas;
referencias=cell(1,n_peces);
framesescogidos=cell(1,n_peces);
for c_peces=1:n_peces % Prealoco
    referencias{c_peces}=NaN(tam_mapa(1),tam_mapa(2),tam_mapa(3),max(intervalosbuenos.n_validos(mejorintervalo,:)));
    framesescogidos{c_peces}=NaN(1,max(intervalosbuenos.n_validos(mejorintervalo,:)));
end % c_peces
for c_frames=intervalosbuenos.iniciofinal(mejorintervalo,1):intervalosbuenos.iniciofinal(mejorintervalo,2)
%     fprintf('%g,',c_frames)
    if datosegm.frame2archivo(c_frames,1)~=archivo_act
        archivo_act=datosegm.frame2archivo(c_frames,1);
        load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
    end
    frame_act=datosegm.frame2archivo(c_frames,2);
    for c_peces=1:n_peces
        if intervalosbuenos.framespararefs(c_frames,c_peces)
            c_refs(segm(frame_act).labels(c_peces))=c_refs(segm(frame_act).labels(c_peces))+1;
%             if c_peces==1
%                 segm(frame_act).centros
%                 segm(frame_act).labels
%                 [c_frames segm(frame_act).labels(c_peces)]
%                 pause
%             end
            referencias{segm(frame_act).labels(c_peces)}(:,:,:,c_refs(segm(frame_act).labels(c_peces)))=segm(frame_act).mapas{c_peces};           
            framesescogidos{segm(frame_act).labels(c_peces)}(c_refs(segm(frame_act).labels(c_peces)))=c_frames;
        end % if mapa válido para referencias
    end % c_peces
end % c_frames
% Recorto
for c_peces=1:n_peces
    referencias{c_peces}=referencias{c_peces}(:,:,:,1:c_refs(c_peces));
    framesescogidos{c_peces}=framesescogidos{c_peces}(1:c_refs(c_peces));
end % c_peces
% Hay que recalcular nframes1, porque si los peces se cruzaron
% en la vertical, habrá algunos frames que hayan pasado de uno
% al otro lado
nframes1=min(c_refs);
incorporados(mejorintervalo)=true;
% pause
fprintf('%g,',nframes1)

nframes_min=20; % Mínimo de frames que tiene que tener un intervalo para que pueda formar parte de la referencia
algunobueno=true;
while algunobueno
    algunobueno=false;
    c_intervalos=0;
    while c_intervalos<size(intervalosbuenos.iniciofinal,1) && nframes1<nframes_final
        c_intervalos=c_intervalos+1;
        nframes2=nvalidos_sort(c_intervalos);
        mejorintervalo=orden(c_intervalos);        
        if ~incorporados(mejorintervalo) && nframes2>nframes_min
            referencias2=cell(1,n_peces);
            framesescogidos_act=cell(1,n_peces);
            for c_peces=1:n_peces % Prealoco
                referencias2{c_peces}=NaN(tam_mapa(1),tam_mapa(2),tam_mapa(3),max(intervalosbuenos.n_validos(mejorintervalo,:)));
                framesescogidos_act{c_peces}=NaN(1,max(intervalosbuenos.n_validos(mejorintervalo,:)));
            end % c_peces
            c_refs=zeros(1,n_peces);
            fprintf('[%g %g]',intervalosbuenos.iniciofinal(mejorintervalo,1),intervalosbuenos.iniciofinal(mejorintervalo,2))
            for c_frames=intervalosbuenos.iniciofinal(mejorintervalo,1):intervalosbuenos.iniciofinal(mejorintervalo,2)
                %         fprintf('%g,',c_frames)
                if datosegm.frame2archivo(c_frames,1)~=archivo_act
                    archivo_act=datosegm.frame2archivo(c_frames,1);
                    load([datosegm.directorio datosegm.raizarchivo '_' num2str(archivo_act)])
                end
                frame_act=datosegm.frame2archivo(c_frames,2);
                for c_peces=1:n_peces
                    if intervalosbuenos.framespararefs(c_frames,c_peces) && ~isempty(segm(frame_act).mapas{c_peces})
                        c_refs(segm(frame_act).labels(c_peces))=c_refs(segm(frame_act).labels(c_peces))+1;
                        referencias2{segm(frame_act).labels(c_peces)}(:,:,:,c_refs(segm(frame_act).labels(c_peces)))=segm(frame_act).mapas{c_peces};
                        framesescogidos_act{segm(frame_act).labels(c_peces)}(c_refs(segm(frame_act).labels(c_peces)))=c_frames;                        
                    end % if mapa válido para referencias
                end % c_peces
            end % c_frames
            % Recorto
            for c_peces=1:n_peces
                referencias2{c_peces}=referencias2{c_peces}(:,:,:,1:c_refs(c_peces));
                framesescogidos_act{c_peces}=framesescogidos_act{c_peces}(1:c_refs(c_peces));
            end % c_peces
            % Hay que recalcular nframes2, porque si los peces se cruzaron
            % en la vertical, habrá algunos frames que hayan pasado de uno
            % al otro lado
            nframes2=min(c_refs);
            % Se calculan errores para asignar unas referencias a otras
            % Primero recortamos las referencias que más frames tienen, para que la
            % comparación sea con el mismo número de frames
            ref1_act=referencias;
            ref2_act=referencias2;
            for c_peces=1:n_peces
                ref1_act{c_peces}=ref1_act{c_peces}(:,:,:,randperm(size(ref1_act{c_peces},4)));
                ref1_act{c_peces}=ref1_act{c_peces}(:,:,:,1:nframes1);
                ref2_act{c_peces}=ref2_act{c_peces}(:,:,:,randperm(size(ref2_act{c_peces},4)));
                ref2_act{c_peces}=ref2_act{c_peces}(:,:,:,1:nframes2);
            end % c_peces
            errores=cell(n_peces,n_peces);
            for c_peces=1:n_peces
%                 c_peces
                [menores_act,errores(c_peces,1:n_peces)]=comparamapas(ref1_act{c_peces},ref2_act,indvalidos);
            end
            
            menores=NaN(nframes1,n_peces,2);
            for c1_peces=1:n_peces
                for c2_peces=1:n_peces
                    menores(:,c2_peces,1:2)=min(errores{c1_peces,c2_peces},[],2);
                    %         menores2(:,c1_peces)=min(errores{c1_peces,c2_peces},[],2);
                end % c2_peces
                [m,ind]=min(menores,[],2);
                for c2_peces=1:n_peces
                    resultados1(c1_peces,c2_peces)=sum(ind(:,1,1)==c2_peces & ind(:,1,2)==c2_peces);
                end % c3_peces
                % Indecisos:
                resultados1(c1_peces,n_peces+1)=sum(ind(:,1,1)~=ind(:,1,2));
            end % c1_peces
            
            menores=NaN(n_peces,nframes2,2);
            for c2_peces=1:n_peces
                for c1_peces=1:n_peces
                    menores(c1_peces,:,1:2)=min(errores{c1_peces,c2_peces},[],1);
                    %         menores2(:,c1_peces)=min(errores{c1_peces,c2_peces},[],2);
                end % c2_peces
                [m,ind]=min(menores,[],1);
                for c1_peces=1:n_peces
                    resultados2(c1_peces,c2_peces)=sum(ind(1,:,1)==c1_peces & ind(1,:,2)==c1_peces);
                end % c3_peces
                % Indecisos:
                resultados2(n_peces+1,c2_peces)=sum(ind(1,:,1)~=ind(1,:,2));
            end % c1_peces
            
%             resultados1
%             resultados2
            
            
            % Calcula (fuleramente) la probabilidad de error
            P1=NaN(n_peces);
            P2=NaN(n_peces);
            for c1_peces=1:n_peces
                for c2_peces=1:n_peces
                    [moda,interv95,probk,k]=cuentas2probk_bayes(resultados1(c1_peces,c2_peces),sum(resultados1(c1_peces,1:end-1)));
                    P1(c1_peces,c2_peces)=sum(probk(k>.5))*diff(k(1:2));
                    [moda,interv95,probk1,k1]=cuentas2probk_bayes(resultados2(c1_peces,c2_peces),sum(resultados2(1:end-1,c2_peces)));
                    P2(c1_peces,c2_peces)=sum(probk(k>.5))*diff(k(1:2));
                end % c2_peces                
            end % c_peces
%             P1
%             P2
%             n_perms
            P1_perm=NaN(1,n_perms);
            P2_perm=P1_perm;
            for c_perms=1:n_perms
                mat=P1(:,permutaciones(c_perms,:));
                P1_perm(c_perms)=prod(mat(diagonal));
                mat=P2(:,permutaciones(c_perms,:));
                P2_perm(c_perms)=prod(mat(diagonal));
%                 if mod(c_perms,1000)==0
%                     c_perms
%                 end
            end % c_perms
            P1_perm=P1_perm/sum(P1_perm);
            P2_perm=P2_perm/sum(P2_perm);            
            P_total=P1_perm.*P2_perm;
            P_total=P_total/sum(P_total);
            [m,ind]=max(P_total);
%             log(P1_perm)
%             log(P2_perm)
%             log(P_total)
            perm_buena=permutaciones(ind,:);
%             pause
            
            
%             [moda,interv95,probk1,k1]=cuentas2probk_bayes(resultados1(1,1),sum(resultados1(1,1:2)));
%             [moda,interv95,probk2,k2]=cuentas2probk_bayes(resultados1(2,1),sum(resultados1(2,1:2)));
%             P1=sum(probk1(k1<.5))*diff(k1(1:2))*sum(probk2(k2>.5))*diff(k2(1:2));
%             P2=sum(probk1(k1>.5))*diff(k1(1:2))*sum(probk2(k2<.5))*diff(k2(1:2));
%             cambio=P1>P2; % Si P1>P2, indica que las nuevas referencias están intercambiadas respecto a las primeras
%             % Siempre hay que poner la peque en el numerador, para que no se quede
%             % sin precisión y redondee a 1
%             if ~cambio
%                 P_res1=P1/(P1+P2);
%             else
%                 P_res1=P2/(P1+P2);
%             end
%             
%             [moda,interv95,probk1,k1]=cuentas2probk_bayes(resultados2(1,1),sum(resultados2(1:2,1)));
%             [moda,interv95,probk2,k2]=cuentas2probk_bayes(resultados2(1,2),sum(resultados2(1:2,2)));
%             P1=sum(probk1(k1<.5))*diff(k1(1:2))*sum(probk2(k2>.5))*diff(k2(1:2));
%             P2=sum(probk1(k1>.5))*diff(k1(1:2))*sum(probk2(k2<.5))*diff(k2(1:2));
%             if ~cambio
%                 P_res2=P1/(P1+P2);
%             else
%                 P_res2=P2/(P1+P2);
%             end
%             
%             P_total=P_res1*P_res2/(P_res1*P_res2+(1-P_res1)*(1-P_res2));
            
%             format short e
%             Probabilidades = [P_res1 P_res2 P_total]
%             format
            
            if (1-P_total(ind))<umbral_Ptotal && (1-P1_perm(ind))<umbral_Pindiv && (1-P2_perm(ind))<umbral_Pindiv
                fprintf('OK:')
                for c_peces=1:n_peces
                    referencias{c_peces}(:,:,:,end+1:end+size(referencias2{perm_buena(c_peces)},4))=referencias2{perm_buena(c_peces)};
                    framesescogidos{c_peces}=[framesescogidos{c_peces}  framesescogidos_act{perm_buena(c_peces)}];
                    % Si hace falta, recorta la referencia
                    if size(referencias{c_peces},4)>nframes_final
                        buenos=equiespaciados(nframes_final,size(referencias{c_peces},4));
                        referencias{c_peces}=referencias{c_peces}(:,:,:,buenos);
                        framesescogidos{c_peces}=framesescogidos{c_peces}(buenos);
                    end
                end % c_peces
%                 if ~cambio
%                     referencias{1}(:,:,:,end+1:end+size(referencias2{1},4))=referencias2{1};
%                     referencias{2}(:,:,:,end+1:end+size(referencias2{2},4))=referencias2{2};
%                     framesescogidos{1}=[framesescogidos{1}  framesescogidos_act{1}];
%                     framesescogidos{2}=[framesescogidos{2}  framesescogidos_act{2}];
%                 else
%                     referencias{2}(:,:,:,end+1:end+size(referencias2{1},4))=referencias2{1};
%                     referencias{1}(:,:,:,end+1:end+size(referencias2{2},4))=referencias2{2};
%                     framesescogidos{1}=[framesescogidos{1}  framesescogidos_act{2}];
%                     framesescogidos{2}=[framesescogidos{2}  framesescogidos_act{1}];
%                 end
                % Si lo incorpora, vuelve al principio para intentar repescar
                % los que se ha dejado por el camino
                incorporados(mejorintervalo)=true;
                algunobueno=true;
            else
                fprintf('Rechazada:')
            end % if referencias aceptadas
%             [size(referencias{1},4) size(referencias{2},4)]
%             pause
            nframes1=min(cellfun(@(x) size(x,4),referencias));%[size(referencias{1},4) size(referencias{2},4)]);
            fprintf('%g,',nframes1)
        end % if intervalo no incorporado
    end % c_intervalos
end % while quedan intervalos aprovechables
fprintf('\n')

% refs_sinreordenar=referencias;
% Recorto las referencias al tamaño deseado

nframes_final=min(cellfun(@(x) size(x,4),referencias)); % Por si no se han podido incluir todos los frames que se querían
for c_peces=1:n_peces
%     permutacion=randperm(size(referencias{c_peces},4));
%     buenos=sort(permutacion(1:nframes_final));
    buenos=equiespaciados(nframes_final,size(referencias{c_peces},4));
    referencias{c_peces}=referencias{c_peces}(:,:,:,buenos);
    framesescogidos{c_peces}=framesescogidos{c_peces}(buenos);
%     referencias{c_peces}=referencias{c_peces}(:,:,:,1:nframes_final);
%     referencias{c_peces}=referencias{c_peces}(:,:,:,randperm(size(referencias{c_peces},4)));
%     referencias{c_peces}=referencias{c_peces}(:,:,:,1:nframes_final);
end % c_peces