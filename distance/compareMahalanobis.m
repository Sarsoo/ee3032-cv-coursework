function dst=compareMahalanobis(vct, val, mean, F2)

x_minus_mean = (F2 - mean)';
matrices = val' * vct' * x_minus_mean;

x=matrices.^2;
x=sum(x);

dst=sqrt(sqrt(x));

return;
