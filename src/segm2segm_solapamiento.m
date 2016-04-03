% 01-May-2013 14:03:23 Nada.
% 28-Apr-2013 16:07:17 Mejoro el rendimiento
% 19-Feb-2013 17:38:49
% 25-Jan-2013 18:04:48 Hago que también entre datosegm para conocer el
% tamaño de los frames
% 18-Oct-2011 10:04:39 Corrijo. El bucle parfor va de 1:n_frames
% APE 01 ago 11

% (C) 2014 Alfonso Pérez Escudero, Gonzalo G. de Polavieja, Consejo Superior de Investigaciones Científicas

function segm=segm2segm_solapamiento(segm,datosegm)

n_frames=length(segm);
segm(1).solapamiento=[];
manchas2.ImageSize=datosegm.tam;
manchas2.Connectivity=8;
manchas2.NumObjects=0;
manchas2.PixelIdxList=cell(1);
for c_frames=1:n_frames
    if ~isempty(segm(c_frames).pixels_sig)
        manchas2.NumObjects=length(segm(c_frames).pixels_sig);
        manchas2.PixelIdxList=segm(c_frames).pixels_sig;
        lienzo2=labelmatrix(manchas2);
        npeces1=length(segm(c_frames).pixels);
        npeces2=length(segm(c_frames).pixels_sig);
        segm(c_frames).solapamiento=zeros(npeces1,npeces2);
        for c1_peces=1:npeces1
            pixels_act=lienzo2(segm(c_frames).pixels{c1_peces});
            for c2_peces=1:npeces2
                segm(c_frames).solapamiento(c1_peces,c2_peces)=sum(pixels_act==c2_peces);
            end % c2_peces
        end % c1_peces
    end
end % c_frames
segm=rmfield(segm,'pixels_sig');
% fprintf('\n')