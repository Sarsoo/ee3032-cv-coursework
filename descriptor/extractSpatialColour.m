function F=extractSpatialColour(img, grid_rows, grid_columns)

img_size = size(img);
img_rows = img_size(1);
img_cols = img_size(2);

row_divs = [];
for i = 1:grid_rows
    row_divs(i) = i/grid_rows;
end
col_divs = [];
for i = 1:grid_columns
    col_divs(i) = i/grid_columns;
end

descriptor = [];
%% divide image into sectors as defined grid parameters
for i = 1:grid_rows
    for j = 1:grid_columns
        
        % cell row pixel range
        row_start = round( (i-1)*img_rows/grid_rows );
        if row_start == 0
            row_start = 1;
        end
        row_end = round( i*img_rows/grid_rows );
        
        % cell column pixel range
        col_start = round( (j-1)*img_cols/grid_columns );
        if col_start == 0
            col_start = 1;
        end
        col_end = round( j*img_cols/grid_columns );
        
        % grab cell from parameters as above
        img_cell = img(row_start:row_end, col_start:col_end, :);
        
        %take average values
        avg_vals = extractAvgRGB(img_cell);
        
        %concatenate average values into vector
        descriptor = [descriptor avg_vals(1) avg_vals(2) avg_vals(3)];
        
    end
end

F=descriptor;
return;