function d=compareMahalanobis(E, query, candidate)

x=query-candidate;
x=(x.^2)./(E.val');
x=sum(x);

d=sqrt(x);

return;
