

img = double(imread('dataset/Images/10_10_s.bmp'))./255;
% imshow(img);

img = getGreyscale(img);

[mag, angle] = getEdgeInfo(img);

F = getEdgeAngleHist(mag, angle)
