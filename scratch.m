
img = double(imread('dataset/Images/5_15_s.bmp'))./255;

img = getGreyscale(img);

[mag_img, angle_img] = getEdgeInfo(img);

imshow(mag_img > 0.01);

export_fig(mag_img > 0.01);