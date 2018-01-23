% function to try to distort a grid to match an checkerboard imaged with
% the fisheye camera
%
% 2018, Alexander Heimel

im = imread('camera_calib_floor_27.889mm.png');

im = imrotate(im,-1.5);

wy = size(im,1);
wx = size(im,2);

x = linspace(-wx/2,wx/2,17);
y = linspace(-wy/2,wy/2,10);

[mx,my]=meshgrid(x,y);

figure
subplot(2,1,1);
%image(im);
hold on

plot(mx + wx/2,my+wy/2,'.k');
axis square equal image

[mr,mphi] = cart2pol(mx,my);

mr = sqrt(mx.^2 + my.^2);

k1 = 0.0000012;
k2 = 0.00000000000015;

dmx = mx ./ (1+  k1*mr.^2 + k2*mr.^4);
dmy = my ./ (1+ k1*mr.^2 + k2*mr.^4);
subplot(2,1,2);
image(im);
hold on

plot(dmx + wx/2,dmy +wy/2,'.w');
plot([0 wx],[wy/2-0 wy/2-0] ,'g');
plot([wx/2 wx/2],[0 wy] ,'g');

axis square equal image
