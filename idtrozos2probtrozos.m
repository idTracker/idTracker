% 23-Jan-2013 16:22:06 Añado la posibilidad de no poner el mínimo en
% idtrozos
% APE 01 mar 12

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

% This program transforms idtrozos into a probability, assuming that there is a
% fixed probability for each independent frame to make a mistake. This
% probability is fixed as a parameter.

function probtrozos=idtrozos2probtrozos(idtrozos,poneminimo)

if nargin<2 || isempty(poneminimo)
    poneminimo=false; % Parece que funciona mejor así, ver Cuaderno20130123T152936
end

n_peces=size(idtrozos,2);

% I assume (to be conservative) that a frame has a probability to be
% correctly assigned that is twice the probability of being incorrectly
% assigned.
P_bien=2/(n_peces+1);
P_mal=P_bien/2;
logprob_bien=log(P_bien);
logprob_mal=log(P_mal);

% When idtrozos is 0, I still consider there is some probability. To do so,
% I set the minimum at 0.5.
if poneminimo
    minimo=.5;
else
    minimo=0;
end
idtrozos(idtrozos<minimo)=minimo;

n_trozos=size(idtrozos,1);
probtrozos=NaN(n_trozos,n_peces);
for c_trozos=1:n_trozos    
    if any(idtrozos(c_trozos,:)>minimo) % No pasaría nada por no hacer esto, quedarían equiprobables. Pero así mantengo marcados los trozos no identificados, que en su mayoría son peces múltiples. Si en algún momento pongo otro marcador para trozos de peces múltiples, esto sería mejor quitarlo, para que el trozo se identifique por descarte.
        for c_peces=1:n_peces
            probtrozos(c_trozos,c_peces)=idtrozos(c_trozos,c_peces)*logprob_bien + sum(idtrozos(c_trozos,[1:c_peces-1 c_peces+1:end])*logprob_mal); % I do first a log and then an exp, because I think it gives less rounding problems
        end % c_peces
        probtrozos(c_trozos,:)=probtrozos(c_trozos,:)-max(probtrozos(c_trozos,:));
        probtrozos(c_trozos,:)=exp(probtrozos(c_trozos,:));
        probtrozos(c_trozos,:)=probtrozos(c_trozos,:)/sum(probtrozos(c_trozos,:));
    end
end % c_trozos