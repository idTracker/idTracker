% APE 6 feb 14

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function segm=segm2segm_centros(datosegm,segm)

n_frames=length(segm);
X=repmat(1:datosegm.tam(2),[datosegm.tam(1) 1]);
Y=repmat((1:datosegm.tam(1))',[1 datosegm.tam(2)]);
n_cortes=9;
angulos=(0:pi/n_cortes:pi)';
angulos=angulos(1:end-1);
vectores_corte=[cos(angulos) sin(angulos)];
for frame_arch=1:n_frames
    n_manchas=length(segm(frame_arch).pixels);
    segm(frame_arch).max_bwdist=NaN(1,n_manchas);
    segm(frame_arch).bwdist_centro=NaN(1,n_manchas);
    segm(frame_arch).areamayor=NaN(1,n_manchas);
    segm(frame_arch).areacore=NaN(1,n_manchas);
    segm(frame_arch).max_distacentro=NaN(1,n_manchas);
    for c_manchas=1:n_manchas
        if ~isfield(segm(frame_arch),'resegmentado') || length(segm(frame_arch).resegmentado)<c_manchas || ~segm(frame_arch).resegmentado(c_manchas)
            [pixels,distancias]=pixels2bwdist(segm(frame_arch).pixels{c_manchas},datosegm.tam,false);
            segm(frame_arch).max_bwdist(c_manchas)=max(distancias);
            umbral=segm(frame_arch).max_bwdist(c_manchas)/datosegm.ratio_bwdist;
            buenos=distancias>=umbral;
        else
            pixels=segm(frame_arch).pixels{c_manchas};
            buenos=true(size(pixels));
            distancias=NaN(size(pixels));
        end
        segm(frame_arch).centros(c_manchas,:)=[mean(X(pixels(buenos))) mean(Y(pixels(buenos)))];
        [m,ind_pixelcercano]=min((X(pixels)-segm(frame_arch).centros(c_manchas,1)).^2+(Y(pixels)-segm(frame_arch).centros(c_manchas,2)).^2);
        segm(frame_arch).bwdist_centro=distancias(ind_pixelcercano);
        segm(frame_arch).areacore(c_manchas)=sum(buenos);
        segm(frame_arch).areamayor(c_manchas)=mancha2manchacortada(pixels(buenos),segm(frame_arch).centros(c_manchas,:),vectores_corte,X,Y);      
        segm(frame_arch).max_distacentro(c_manchas)=max(sqrt((X(pixels(buenos))-segm(frame_arch).centros(c_manchas,1)).^2+(Y(pixels(buenos))-segm(frame_arch).centros(c_manchas,2)).^2));
    end % c_manchas
end % c_frames