function r2s_pxl = project2monitor(r_rw_cm, screen_center_r2n_cm,screen_pxl,screen_cm) 
%PROJECT2MONITOR takes the real world coordinates of a stimulus and returns coordinates as projected on the screen
%
%  r2s_pxl = project2monitor(r_rw_cm, screen_center_r2n_cm) 
%
%
% 10-11-2014 Azadeh
%

% rw is real world coordinates relative to nose
% r2n is screen coordinates relative to nose
% r2s is screen coordinates relative to topleft of the screen

screen_topleft_r2n_cm(1) = screen_center_r2n_cm(1) - screen_cm(1)/2;
screen_topleft_r2n_cm(2) = screen_center_r2n_cm(2) + screen_cm(2)/2;
screen_topleft_r2n_cm(3) = screen_center_r2n_cm(3);

x_rw = r_rw_cm(1);
y_rw = r_rw_cm(2);
z_rw = r_rw_cm(3);

if abs(z_rw) > 0.1 % i.e. not within a mm
    x_r2n_cm = (x_rw*screen_topleft_r2n_cm(3))/z_rw;
    y_r2n_cm = (y_rw*screen_topleft_r2n_cm(3))/z_rw;
else
    x_r2n_cm = sign(x_rw)*1e4;
    y_r2n_cm = sign(y_rw)*1e4;
end
    
% x (right is positive) 
% y (up is positive)
% z (in front of the mouse is positive)

x_r2s_cm = x_r2n_cm - screen_topleft_r2n_cm(1); % right is positive
y_r2s_cm = y_r2n_cm - screen_topleft_r2n_cm(2); % up is positive


r2s_pxl(1) = x_r2s_cm * screen_pxl(1)/screen_cm(1); % right is positive
r2s_pxl(2) = -y_r2s_cm * screen_pxl(2)/screen_cm(2); % down is positive









