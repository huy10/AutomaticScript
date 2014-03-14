function F = Laplacian(A, B, M, ang)

[r c] = size(M);  
A = imresize(A, [r c]); 
B = imresize(B, [r c]);  % original face 

% pyramids
numLevels = 4;
LA = getPyramids(A, numLevels, 'laplace');
LB = getPyramids(B, numLevels, 'laplace');
GM = getPyramids(M, numLevels, 'gauss');


% Pout =  rot(LA*GM) + LB*(1-rot(GM))
Pout = cell(1, numLevels);
for i = 1:numLevels
    for j = 1:3
        mask = imresize(GM{i}, [size(LA{i},1) size(LA{i},2)]);
      
        rotmaskedLA = imrotate(LA{i}(:,:,j).*mask, ang, 'nearest', 'crop');
        rotmask = imrotate(mask, ang, 'nearest', 'crop');
        Pout{i}(:,:,j) = rotmaskedLA + LB{i}(:,:,j).*(1-rotmask);
    end
    %figure;imshow(GM{i});
    %figure;imshow(LA{i});
end

% reconstruct
for i = numLevels-1:-1:1
    Pout{i} = Pout{i} + impyramid(Pout{i+1}, 'expand');
end

F = Pout{1};  
F = imresize(F, [r c]);

end
