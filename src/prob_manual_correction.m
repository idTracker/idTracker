function prob_corrected=prob_manual_correction(datosegm,trozos,solapos,probtrozos)
fprintf('Manual references probabilities.\n')
load([datosegm.directorio 'mancha2pez_manual.mat'])
man2pez_manual=variable;
mancha2id_manual=man2pez_manual.mancha2pez;
idtrozos_manual=mancha2id2idtrozos(datosegm,trozos,solapos,mancha2id_manual);
prob_corrected=probtrozos;
%probtrozos_manual=idtrozos2probtrozos(idtrozos_manual);
for c_trozos=1:size(idtrozos_manual,1)
    %idtrozos(c_trozos,:)
    %probtrozos(c_trozos,:)
    %sum(probtrozos(c_trozos,:))
    if( sum(idtrozos_manual(c_trozos,:)>0)==1)
        temp=idtrozos_manual(c_trozos,:);
        temp(temp==0)=0;
        temp(temp>0)=1.00000;
        prob_corrected(c_trozos,:)=temp;
    end
end