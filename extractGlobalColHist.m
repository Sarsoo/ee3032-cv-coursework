function F=extractGlobalColHist(img)

divs = 15;

qimg = floor(img .* divs);
bin = qimg(:,:,1) * divs^2 + qimg(:,:,2) * divs^1 + qimg(:,:,3);

vals = reshape(bin, 1, size(bin, 1) * size(bin, 2));

% dimensions = size(img);
% 
% width = dimensions(2);
% height = dimensions(1);
% 
% pixel_count = width * height;
% 
% bin_values = zeros([1, pixel_count]);
% count = 1;
% for i = 1:length(img(:, 1, 1))
%     for j = 1:length(img(1, :, 1))
%         red = img(i, j, 1);
%         green = img(i, j, 2);
%         blue = img(i, j, 3);
%         
%         red_bin = floor(red*divs);
%         green_bin = floor(green*divs);
%         blue_bin = floor(blue*divs);
%         
%         bin_value = red_bin * (divs^2) + green_bin * (divs^1) + blue_bin;
%         
%         bin_values(count) = bin_value;
%         
%         count = count + 1;
%     end
% end

% hist_values = histogram(bin_values, (divs^3 - 1)).Values ./ pixel_count;
% hist_values = histogram(bin_values, divs^3, 'Normalization', 'probability').Values;

hist_values = histogram(vals, divs^3, 'Normalization', 'probability').Values;

F=hist_values;
return;