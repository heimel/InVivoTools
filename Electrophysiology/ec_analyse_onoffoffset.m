function record = ec_analyse_onoffoffset( record, verbose )
%EC_ANALYSE_ONOFFOFFSET computes distance of center of on and off subfield
%
%  RECORD = EC_ANALYSE_ONOFFOFFSET( RECORD )
%
% 2021, Alexander Heimel

if nargin<2 || isempty(verbose)
    verbose = false;
end

measures = record.measures;

for i = 1:length(measures)
    if measures(i).roc_auc<0.7
        continue
    end
    
    
    rf_on = squeeze(measures(i).rf(1,:,:));
    measures(i).on_center = fit2dg(rf_on,verbose);

    rf_off = squeeze(measures(i).rf(2,:,:));
    measures(i).off_center = fit2dg(rf_off,verbose);
    
    d = measures(i).on_center- measures(i).off_center;
    [a,r] = cart2pol(d(1),d(2));
    measures(i).on_off_angle_deg = a/pi*180;
    measures(i).on_off_offset = r;
    
    %     rf_off = squeeze(measures(i).rf(2,:,:));
    %     x = 1:size(rf_off,2);
    %     y = 1:size(rf_off,1);
    %
    %     fit_off = fmgaussfit(x,y,rf_off);
    %     center_off = [fit_off(5) fit_off(6)]
    if verbose
        logmsg(['Cell ' num2str(measures(i).index) ': rf center ' num2str(measures(i).rf_center,'%.1f ')]);
        logmsg(['Cell ' num2str(measures(i).index) ': on center ' num2str(measures(i).on_center,'%.1f ')]);
        logmsg(['Cell ' num2str(measures(i).index) ': off center ' num2str(measures(i).off_center,'%.1f ')]);
        logmsg(['Cell ' num2str(measures(i).index) ': on-off-offset ' num2str(measures(i).on_off_offset,'%.1f ')]);
        logmsg(['Cell ' num2str(measures(i).index) ': on-off-angle_deg ' num2str(measures(i).on_off_angle_deg,'%.1f ')]);
    end
    
end

record.measures = measures;


function center = fit2dg(rf, verbose)
center = [NaN NaN];

on_x_coarse = max(rf,[],1);
on_y_coarse = max(rf,[],2)';
n_x = size(rf,2);
n_y = size(rf,1);

x = 1:n_x;
y = 1:n_y;

gaussEqn = 'a^2*exp(-((x-b)/c)^2)+d';

d = median(rf(:));
a = sqrt(max(on_x_coarse)-d);
[~,b] = max(on_x_coarse);
c = 2;
startPoints = [a b c d];

xf = linspace(1,n_x,100);
rxf = interp1(x',on_x_coarse',xf);
[f1_on,gof] = fit(xf',rxf',gaussEqn,'Start', startPoints);
xcoeff = coeffvalues(f1_on);
        

if gof.rsquare>0.4 && xcoeff(2)<=n_x && xcoeff(2)>=1
    center(1) = xcoeff(2);
end

a = max(on_y_coarse)-d;
[~,b] = max(on_y_coarse);


startPoints = [a b c d];

yf = linspace(1,n_y,100);
ryf = interp1(y',on_y_coarse',yf);
[f1_on,gof] = fit(yf',ryf',gaussEqn,'Start', startPoints);

ycoeff = coeffvalues(f1_on);
if gof.rsquare>0.4 && ycoeff(2)<=n_y && ycoeff(2)>=1
    center(2) = ycoeff(2);
end

if verbose && all(~isnan(center)) 
    figure;
    subplot(1,2,1);
    plot(x,on_x_coarse','o');
    hold on
    plot(xf,xcoeff(1)^2*exp(-((xf-xcoeff(2))/xcoeff(3)).^2)+xcoeff(4));
    hold off
    xlabel('x (pxl)');
    
    subplot(1,2,2);
    plot(y,on_y_coarse,'o');
    hold on
    plot(yf,ycoeff(1)^2*exp(-((yf-ycoeff(2))/ycoeff(3)).^2)+ycoeff(4));
    xlabel('y (pxl)');
    hold off
    
end