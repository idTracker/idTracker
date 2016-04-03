% 15-Jul-2014 17:35:46 Elimino load_encrypt
% APE 1 mar 14

function [segmeros,segm]=segm2segmeros(datosegm,mancha2pez,segm,c_frames)

archivo_act=datosegm.frame2archivo(c_frames,1);
if isempty(segm{archivo_act})
    load([datosegm.directorio 'segm_' num2str(archivo_act) '.mat']);
    segm{archivo_act}=variable;
    segm{archivo_act}=rmfield(segm{archivo_act},'mapas');
    segm{archivo_act}=rmfield(segm{archivo_act},'miniframes');
end
frame_arch=datosegm.frame2archivo(c_frames,2);
lienzo_act=false(datosegm.tam);
pixel2mancha=zeros(datosegm.tam);
for c_manchas=1:length(segm{archivo_act}(frame_arch).pixels)
    if isfield(segm{archivo_act},'resegmentado') && length(segm{archivo_act}(frame_arch).resegmentado)>=c_manchas && segm{archivo_act}(frame_arch).resegmentado(c_manchas)
        pixels_act=segm{archivo_act}(frame_arch).pixels{c_manchas};
    else
        [pixels_act,bwdist_act]=pixels2bwdist(segm{archivo_act}(frame_arch).pixels{c_manchas},datosegm.tam,true);
        max_act=min([min(datosegm.max_bwdist) max(bwdist_act)]);
        umbral_bwdist=max_act/datosegm.ratio_bwdist;
        pixels_act=pixels_act(bwdist_act>=umbral_bwdist);
    end
    lienzo_act(pixels_act)=true;
    pixel2mancha(pixels_act)=c_manchas;
end % c_manchas
manchas=bwconncomp(lienzo_act);
segmeros.pixels=manchas.PixelIdxList;
segmeros.manchasegm=cellfun(@(x) pixel2mancha(x(1)),segmeros.pixels);
segmeros.pez2mancha=false(datosegm.n_peces,length(segmeros.pixels));
for c_manchas=find(mancha2pez(c_frames,:)>0)
    segmeros.pez2mancha(mancha2pez(c_frames,c_manchas),segmeros.manchasegm==c_manchas)=true;
end % c_peces