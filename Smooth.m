function im  =  Smooth(im, positions, indexes, ymins, xmins)

BLURSIZE = 5;
border = BLURSIZE;
for i = 1:2
    index = indexes(i);
    xmin = xmins(i);
    xmax = xmin+positions(index,3);
    ymin = ymins(i);
    ymax = ymin+positions(index,4);
    
    blur = ones(BLURSIZE,1)/BLURSIZE;
    for color = 1:3
        if ymin-border-(BLURSIZE-1)/2 > 0
            im(ymin-border:ymin+border,xmin:xmax,color) = conv2(im(ymin-border-(BLURSIZE-1)/2:ymin+border+(BLURSIZE-1)/2,xmin:xmax,color),blur,'valid');
        end
        if ymax+border+(BLURSIZE-1)/2 < size(im,1)
            im(ymax-border:ymax+border,xmin:xmax,color) = conv2(im(ymax-border-(BLURSIZE-1)/2:ymax+border+(BLURSIZE-1)/2,xmin:xmax,color),blur,'valid');
        end
    end
    blur = ones(1,BLURSIZE)/BLURSIZE;
    for color = 1:3
        if xmin-border-(BLURSIZE-1)/2 > 0
            im(ymin:ymax,xmin-border:xmin+border,color) = conv2(im(ymin:ymax,xmin-border-(BLURSIZE-1)/2:xmin+border+(BLURSIZE-1)/2,color),blur,'valid');
        end
        if xmax+border+(BLURSIZE-1)/2 < size(im,2)
            im(ymin:ymax,xmax-border:xmax+border,color) = conv2(im(ymin:ymax,xmax-border-(BLURSIZE-1)/2:xmax+border+(BLURSIZE-1)/2,color),blur,'valid');
        end
    end
end
