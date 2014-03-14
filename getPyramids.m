function P = getPyramids(I, numLevels, ptype)
% gaussian
P = cell(1, numLevels);
P{1} = I;
for i = 2:numLevels
    P{i} = impyramid(P{i-1}, 'reduce');
end
if strcmp(ptype, 'gauss')
    return;
end

% resize
for i = numLevels-1:-1:1
    s = size(P{i+1})*2-1;
    P{i} = P{i}(1:s(1),1:s(2),:);
end

% laplacian 
for i = 1:numLevels-1
    P{i} = P{i} - impyramid(P{i+1}, 'expand');
end

