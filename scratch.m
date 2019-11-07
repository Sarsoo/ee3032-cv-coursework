

img = double(imread('dataset/Images/10_10_s.bmp'))./255;
imshow(img);


glo = extractGlobalColHist(img)
size(img);