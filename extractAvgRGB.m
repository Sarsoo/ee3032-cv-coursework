function F=extractAvgRGB(img)

red = img(:,:,1);
red = reshape(red, 1, []);
avg_red = mean(red);

green = img(:,:,2);
green = reshape(green, 1, []);
avg_green = mean(green);

blue = img(:,:,3);
blue = reshape(blue, 1, []);
avg_blue = mean(blue);

F=[avg_red avg_green avg_blue];
return;