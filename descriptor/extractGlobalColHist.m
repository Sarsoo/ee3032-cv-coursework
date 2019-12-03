function F=extractGlobalColHist(img, divs)

qimg = floor(img .* divs);
bin = qimg(:,:,1) * divs^2 + qimg(:,:,2) * divs^1 + qimg(:,:,3);

vals = reshape(bin, 1, size(bin, 1) * size(bin, 2));

hist_values = histogram(vals, divs^3, 'Normalization', 'probability').Values;

F=hist_values;
return;