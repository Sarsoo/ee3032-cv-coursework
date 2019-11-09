function [mag_img, angle_img]=getEdgeInfo(img)

blur = [1 1 1 ; 1 1 1 ; 1 1 1] ./ 9;
blurredimg = conv2(img, blur, 'same');

Kx = [1 2 1 ; 0 0 0 ; -1 -2 -1] ./ 4;
Ky = Kx';

dx = conv2(blurredimg, Kx, 'same');
dy = conv2(blurredimg, Ky, 'same');

mag_img = sqrt(dx.^2 + dy.^2);
angle_img = atan2(dy,dx);

% normalise between 0 and 2pi
angle_img = angle_img - min(reshape(angle_img, 1, []));

return;