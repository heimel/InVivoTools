function res = correctDisplay(input, bg)
% by Ulf adapted from http://labrigger.com/blog/2012/03/06/mouse-visual-stim/


% Monitor size and position variables
w = 51;  % width of screen, in cm
h = 29;  % height of screen, in cm
cx = w/2;   % eye x location, in cm
cy = 17.4; % eye y location, in cm

% Distance to bottom of screen, along the horizontal eye line
zdistBottom = 11.7;     % in cm
%zdistTop    = 21;     % in cm

% Alternatively, you can specify the angle of the screen
screenAngle = 90;   % in degrees, measured from table surface in front of screen to plane of screen
zdistTop = zdistBottom - (h*sin(deg2rad(90-screenAngle)));

pxXmax = 1280; % number of pixels in an image that fills the whole screen, x
pxYmax = 720; % number of pixels in an image that fills the whole screen, y

%pretend the screen is twice as far away and has double the number of
%pixels, then cut out the morphed image later

% Internal conversions
top = h-cy;
bottom = -cy;
right = cx;
left = cx - w;

% Convert Cartesian to spherical coord
% In image space, x and y are width and height of monitor and z is the
% distance from the eye. I want Theta to correspond to azimuth and Phi to
% correspond to elevation, but these are measured from the x-axis and x-y
% plane, respectively. So I need to exchange the axes this way, prior to
% converting to spherical coordinates:
% orig (image) -> for conversion to spherical coords
% Z -> X
% X -> Y
% Y -> Z

[xi,yi] = meshgrid(1:pxXmax,1:pxYmax);
cart_pointsX = left + (w/pxXmax).*xi;
cart_pointsY = top - (h/pxYmax).*yi;
cart_pointsZ = zdistTop + ((zdistBottom-zdistTop)/pxYmax).*yi;
[sphr_pointsTh sphr_pointsPh sphr_pointsR] ...
            = cart2sph(cart_pointsZ,cart_pointsX,cart_pointsY);

        
%        % view results
% figure
% subplot(3,2,1)
% imagesc(cart_pointsX)
% colorbar
% title('image/cart coords, x')
% subplot(3,2,3)
% imagesc(cart_pointsY)
% colorbar
% title('image/cart coords, y')
% subplot(3,2,5)
% imagesc(cart_pointsZ)
% colorbar
% title('image/cart coords, z')
% 
% subplot(3,2,2)
% imagesc(rad2deg(sphr_pointsTh))
% colorbar
% title('mouse/sph coords, theta')
% subplot(3,2,4)
% imagesc(rad2deg(sphr_pointsPh))
% colorbar
% title('mouse/sph coords, phi')
% subplot(3,2,6)
% imagesc(sphr_pointsR)
% colorbar
% title('mouse/sph coords, radius')

        
%% try a distortion

I = input;

% Rescale the Cartesian maps into dimensions of radians
xmaxRad = max(sphr_pointsTh(:));
ymaxRad = max(sphr_pointsPh(:));

fx = xmaxRad/max(cart_pointsX(:));
fy = ymaxRad/max(cart_pointsY(:));


% Apply the distortion via interpolation
res = interp2(cart_pointsX.*fx,cart_pointsY.*fy,I,sphr_pointsTh,sphr_pointsPh);
res(isnan(res)) = bg;
