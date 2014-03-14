function x = linspace_multi(d1,d2,n)

d1=d1(:); 
d2=d2(:);
x=[repmat(d1,1,n-1)+repmat((0:n-2),length(d1),1).*repmat((d2-d1),1,n-1)/(floor(n)-1) d2];

end
