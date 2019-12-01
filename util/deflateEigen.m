function E=deflateEigen(E, param)

totalenergy=sum(abs(E.val));
currentenergy=0;
rank=0;
for i=1:size(E.vct,2)
    if currentenergy>(totalenergy*param)
        break;
    end
    rank=rank+1;
    currentenergy=currentenergy+E.val(i);
end
            
E.val=E.val(1:rank);
E.vct=E.vct(:,1:rank);
