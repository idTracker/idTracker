% 04-Nov-2012 11:51:03 Cambio el cálculo de P0. En vez de un umbral de 0.5 para la probabilidad, busco la prob. de que sea el mayor de todos.
% Tampoco veo que haga mucha diferencia. Las probabilidades de los muy probables se extremizan un poco, pero las de los poco probables apenas
% cambian (que es donde yo esperaba más diferencia).
% 25-Oct-2012 12:25:15 Sustituyo P2 por P3
% 25-Oct-2012 12:18:36 Ensayo P3
% 24-Oct-2012 19:28:21 Hago que funcione también con matrices MxM
% APE 28 sep 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% matrel debe ser una matriz de dimensión Mx(M+1). Para las reversas,
% simplemente meter la matriz traspuesta.
% También funciona si metemos la matriz MxM, quitando la columna de dudosos.

function [P3,P0,P2,P]=matrel2probs(matrel)

n_peces=size(matrel,1);

% Probabilidad de cada identificación, sin tener en cuenta el resto, usando
% lo de asumir que la probabilidad tiene que ser mayor que 0.5, y usando un
% número efectivo de frames menor que el real (para tener un poco en cuenta
% la redundancia).
factor_redundancia=3;
P0=NaN(n_peces);
% P0_old=P0;
% P0_rev=P0;
for c1=1:n_peces
    probk=NaN(n_peces,10000);    
    for c2=1:n_peces
        [moda,interv95,probk(c2,:),k]=cuentas2probk_bayes(matrel(c1,c2)/factor_redundancia,sum(matrel(c1,1:n_peces))/factor_redundancia);
%         P0_old(c1,c2)=sum(probk(c2,(k>.5)))*diff(k(1:2));
%         [moda,interv95,probk,k]=cuentas2probk_bayes(matrel_rev(c1,c2)/factor_redundancia,sum(matrel_rev(1:end-1,c2))/factor_redundancia);
%         P0_rev(c1,c2)=sum(probk(k>.5))*diff(k(1:2));
    end 
    acumuladas=cumsum(probk,2);
    acumuladas=acumuladas./repmat(acumuladas(:,end),[1 size(acumuladas,2)]);
    for c2=1:n_peces
        P0(c1,c2)=sum(prod(acumuladas([1:c2-1 c2+1:end],:),1).*probk(c2,:)/sum(probk(c2,:)));
    end
end
% Esta normalización no debería ser necesaria, pero lo es por cuestiones de redondeo (creo)
for c=1:n_peces
    P0(c,:)=P0(c,:)/sum(P0(c,:));
%     P0_rev(:,c)=P0_rev(:,c)/sum(P0_rev(:,c));
end

% Cálculo de P3. Cuentas en la página 49 del cuaderno
P3=NaN(n_peces);
for c1_peces=1:n_peces
    for c2_peces=1:n_peces
        P3(c1_peces,c2_peces)=P0(c1_peces,c2_peces)*prod(sum(P0([1:c1_peces-1 c1_peces+1:n_peces],[1:c2_peces-1 c2_peces+1:n_peces]),2),1);
    end
end
P3=P3./repmat(sum(P3,2),[1 n_peces]);

if nargout>2
    disp('Guarning! Puede que esté usando una versión obsoleta de matrel2probs')
    % Evito que los valores demasiado cercanos a 1 me la jodan
    unomenosP0=1-P0;
    % unomenosP0_rev=1-P0_rev;
    for c_peces=1:n_peces
        ind=unomenosP0(c_peces,:)==0;
        if sum(ind)==1
            unomenosP0(c_peces,ind)=sum(P0(c_peces,~ind));
        end
        %     ind=unomenosP0_rev(:,c_peces)==0;
        %     if sum(ind)==1
        %         unomenosP0_rev(ind,c_peces)=sum(P0_rev(~ind,c_peces));
        %     end
    end % c_peces
    % Probabilidad de cada identificación, teniendo en cuenta los de la misma
    % fila
    P=NaN(n_peces);
    % P_rev=P;
    for c1=1:n_peces
        for c2=1:n_peces
            P(c1,c2)=P0(c1,c2)*prod(unomenosP0(c1,[1:c2-1 c2+1:end]));
            %         P_rev(c1,c2)=P0_rev(c1,c2)*prod(unomenosP0_rev([1:c1-1 c1+1:end],c2));
        end
    end
    for c=1:n_peces
        P(c,:)=P(c,:)/sum(P(c,:));
        %     P_rev(:,c)=P_rev(:,c)/sum(P_rev(:,c));
    end
    
    
    % Probabilidad de cada identificación, teniendo en cuenta el resto
    P2=NaN(n_peces);
    % P2_rev=P2;
    for c1=1:n_peces
        for c2=1:n_peces
            P2(c1,c2)=sum(log(sum(P([1:c1-1 c1+1:n_peces],[1:c2-1 c2+1:n_peces]),2)))+log(P(c1,c2));
            %         P2_rev(c1,c2)=sum(log(sum(P_rev([1:c1-1 c1+1:n_peces],[1:c2-1 c2+1:n_peces]),1)))+log(P_rev(c1,c2));
        end
    end
    P2=P2-max(P2(:));
    % P2_rev=P2_rev-max(P2_rev(:));
    P2=exp(P2);
    % P2_rev=exp(P2_rev);
    for c=1:n_peces
        P2(c,:)=P2(c,:)/sum(P2(c,:));
        %    P2_rev(:,c)=P2_rev(:,c)/sum(P2_rev(:,c));
    end
end