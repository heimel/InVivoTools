function r2s_pxl = project2monitor(r_rw_cm, screen_topleft_r2n_cm,pixels_per_cm) 
%PROJECT2MONITOR takes the real world coordinates of a stimulus and returns coordinates as projected on the screen
%
%  r2s_pxl = project2monitor(r_rw_cm, screen_topleft_r2n_cm) 
%
%
% 10-11-2014 Azadeh
%

% rw is real world coordinates relative to nose
% r2n is screen coordinates relative to nose
% r2s is screen coordinates relative to topleft of the screen


x_rw = r_rw_cm(1);
y_rw = r_rw_cm(2);
z_rw = r_rw_cm(3);


x_r2n_cm = (x_rw*screen_topleft_r2n_cm(3))/z_rw;
y_r2n_cm = (y_rw*screen_topleft_r2n_cm(3))/z_rw;

% x (right is positive) 
% y (up is positive)
% z (in front of the mouse is positive)

x_r2s_cm = x_r2n_cm - screen_topleft_r2n_cm(1); % right is positive
y_r2s_cm = y_r2n_cm - screen_topleft_r2n_cm(2); % up is positive


r2s_pxl(1) = x_r2s_cm * pixels_per_cm; % right is positive
r2s_pxl(2) = -y_r2s_cm * pixels_per_cm; % down is positive









