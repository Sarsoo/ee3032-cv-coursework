function F=getEdgeAngleHist(mag_img, angle_img)

bins = 8;
threshold = 0.1;

dimensions = size(angle_img);
rows = dimensions(1);
columns = dimensions(2);

vals = [];
for i = 1:rows
    for j = 1:columns
        if mag_img(i, j) > threshold
            
            bin_value = angle_img(i, j) / (2 * pi);
            bin_value = bin_value * bins;
            
            vals = [vals bin_value];
            
        end
    end
end

F= histogram(vals, bins, 'Normalization', 'probability').Values;
return;