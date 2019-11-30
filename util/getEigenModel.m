function E=getEigenModel(obs)

E.N  = size(obs,1);
E.D  = size(obs,2);
E.org= mean(obs);

obs_translated=obs-repmat(E.org,E.N,1);

C=(1/E.N) * (obs_translated' * obs_translated);

[U V]=eig(C);

% sort eigenvectors and eigenvalues by eigenvalue size (desc)
linV=V*ones(size(V,2),1);
S=[linV U'];
S=flipud(sortrows(S,1));
U=S(:,2:end)';
V=S(:,1);

E.vct=U;
E.val=V;

return;