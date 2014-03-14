function im = NormalizeIntensities(im,intensities)

mtemp = mean(mean(im));
for color=1:3
    im(:,:,color) = im(:,:,color) + intensities(1,1,color) - mtemp(1,1,color);
end

end
