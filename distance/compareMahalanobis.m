function d=compareMahalanobis(E, obs, query)

obs_translated = (obs -repmat(query, size(obs,1), 1))';

proj=E.vct*obs_translated;
    
dstsq=proj.*proj;

E.val(E.val==0)=1; % check for eigenvalues of 0

dst=dstsq./repmat((E.val),1,size(obs,2));

d=sum(dst);

d=sqrt(d);

return;
