% (C) 2013 Alfonso Pérez Escudero, Consejo Superior de Investigaciones Científicas

function [moda,interv95,probk,k]=cuentas2probk_bayes(n,n_totales)

n_nostops=n_totales-n;

% omega=beta(n+1,n_nostops+1); % Esta es la normalización correcta,
% pero no funciona bien para valores muy grandes de n y n_totales
paso=.0001;
k=paso/2:paso:1-paso/2;
logprobk = n*log(k) + n_nostops*log(1-k);
logprobk = logprobk - max(logprobk);
probk = exp(logprobk);
probk=probk/sum(probk)/diff(k(1:2));

[m,ind]=max(probk);
moda=k(ind);
prob_acum=cumsum(probk*diff(k(1:2)));
[m,ind]=min(abs(prob_acum-.975));
interv95(2)=k(ind);
[m,ind]=min(abs(prob_acum-.025));
interv95(1)=k(ind);