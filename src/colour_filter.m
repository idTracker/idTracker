function frame=colour_filter(frame) %Filter or exchange colors, default is
                                    %to set range of colours to zero
                                    %(black)

        a=(frame(:,:,1)<=67 | frame(:,:,1)>=114);
        frame(:,:,1)=frame(:,:,1).*uint8(a);        
        a=(frame(:,:,2)<=30 | frame(:,:,2)>=65);
        frame(:,:,2)=frame(:,:,2).*uint8(a);       
        a=(frame(:,:,3)<=25 | frame(:,:,3)>=56);
        frame(:,:,3)=frame(:,:,3).*uint8(a);                 
        
        
        