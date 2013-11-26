function [wave_velocity,wave_direction,wave_error,radius,wave_tau] = tp_fit_wave( t, cellpositions, data, process_params)
%TP_FIT_WAVE fits plane wave to two-photon data
%
% cartesian coordinates
%    x is horizontal axis in image
%    y is vertical axis in image, consistent with the reverse
%       image y-axis, i.e. top left in image is x=0,y=0, bottom right
%       is x=max_x, y=max_y
% polar coordinates
%    0 rad is from left to right
%    pi/2 rad is from top to bottom, consistent with the reverse
%       images y-axis
%
% 2010, Alexander Heimel
%


%t = remove_mean(t);




px = repmat([cellpositions.x], size(t,1),1);
py = repmat([cellpositions.y], size(t,1),1);

% remove cell positions which are not participating, from mean
non_events = find(isnan(t));
px(non_events) = NaN;
py(non_events) = NaN;



xstd = nanstd(px')';
ystd = nanstd(py')';
radius = sqrt(xstd.^2+ystd.^2);

[th,r] = cart2pol(px, py);
%th = th-pi/2; % to match image orientation


wave_velocity=zeros(size(t,1),1);
wave_direction=zeros(size(t,1),1);
wave_error=zeros(size(t,1),1);
wave_tau=zeros(size(t,1),1);


for i = 1:size(th,1) % events
    if max(t(i,:))==min(t(i,:)) % i.e. only one cell active, or all simultaneous
        wave_velocity(i) = nan;
        wave_direction(i) = NaN;
        wave_error(i) = NaN;
        continue;
    end
    
    
    % solve direction by minimizing positional error
    %[wave_direction(i),wave_error(i)] = fminsearch(@(phi) wave_fitting_error_pos(phi,th(i,:),r(i,:),t(i,:)),0);
    %wave_velocity(i) = nanmean( r(i,:).*cos(th(i,:)-wave_direction(i)).*t(i,:)) / ...
    %    nanmean( t(i,:).^2);
    
    
    % solve velocity and direction by minimizing time error
    % taking random starting conditions to avoid biasing to a particular
    % direction
    
    % start_cond = [pi*2*rand(1) rand(1)*100]; % phi, v [0 0]
    %start_cond = [0 150]; % phi, v [0 0]
    %disp('should rerandomize');
    
    events=~isnan(t(i,:)); % events is a misnomer for participating cells here
    the = th(i,events);
    re = r(i,events);
    te = t(i,events);
    %    [wave_speed,wave_error(i)] = fminsearch(@(x) wave_fitting_error_time(x,the,re,te),start_cond);
    %    wave_direction(i) = wave_speed(1);
    %    wave_velocity(i) = wave_speed(2);
    %    wave_speed
    mte=mean(te);
    xce = re.*cos(the);
    xse = re.*sin(the);
    mxce=mean(xce);
    mxse=mean(xse);
    mxct=mean(xce.*te);
    mxst=mean(xse.*te);
    %  [wave_phi,wave_error(i)] = fminsearch(@(phi) wave_fitting_error_time_only(phi,the,re,te,mte,mxce,mxse,mxct,mxst),start_cond(1));
    bias_removal = rand(1)*pi;
    [wave_phi,wave_error(i)] = fminbnd(@(phi) wave_fitting_error_time_only(phi,the,re,te,mte,mxce,mxse,mxct,mxst),-pi+bias_removal,pi+bias_removal);
%   [wave_phi,wave_error(i)] = fminbnd(@(phi) wave_fitting_error_time_only(phi,the,re,te,mte,mxce,mxse,mxct,mxst),0,2*pi);
    
    wave_error(i) = wave_error(i) / (sum(events)-1); % to make errors comparable
    wave_speed = (mean( (re.*cos(the-wave_phi)).^2) - (mean(re.*cos(the-wave_phi)))^2) / ...
                 (mean( (te.*re.*cos(the-wave_phi))) - mean(te)*mean(re.*cos(the-wave_phi)));
    
    wave_direction(i) = wave_phi;
    wave_velocity(i) = wave_speed;
    
    % make velocity positive
    wave_direction(i) = wave_direction(i) + pi*(1-sign(wave_velocity(i)))/2;
    wave_direction(i) = mod(wave_direction(i) + pi,2*pi) - pi;
    wave_velocity(i) = abs( wave_velocity(i));
    
    if isinf( wave_velocity(i) ) || wave_velocity(i)>10^6
        wave_velocity(i) = NaN;
        wave_direction(i) = NaN;
    end
    
    %wave_tau(i) = mean( te - re.*cos(the-wave_direction(i)) / wave_velocity(i));
    wave_tau(i) = mean( te )  - mean( re.*cos(the-wave_direction(i))) / wave_velocity(i);
    
end

return


function err = wave_fitting_error_time_only(phi,th,r,t,mean_t,mean_xc,mean_xs,mean_xct,mean_xst)
% this function could be accelarated by writing cos(th-phi) =
% cos(th)cos(phi) + sin(th)sin(phi) and then precomputing some terms
%
%disp('SPeed up this function!');
x = r.*cos(th-phi);
% xc = r.*cos(th)*cos(phi)
% xs = r.*sin(th)*sin(phi)
% x = cos(phi)*xc + sin(phi)*xs
% mx = cos(phi)*mean_xc + sin(phi)*mean_xs
mx = mean_xc*cos(phi) + mean_xs*sin(phi);
v = (mean( x.^2) - mx^2) / ...
    (mean_xct*cos(phi)+mean_xst*sin(phi) - mean_t*mx);
dt = t - r.*cos(th- phi )/ v;
err = dt*dt'  -  sum(dt)^2/size(dt,2);
%err = dt*dt'  ;%-  sum(dt)^2/size(dt,2);





function err = wave_fitting_error_time(x,th,r,t)
% this function could be accelarated by writing cos(th-phi) =
% cos(th)cos(phi) + sin(th)sin(phi) and then precomputing some terms
%
%phi = x(1);
%v = x(2);
%err = var( t - r.*cos(th-phi)/v);
dt = t - r.*cos(th- x(1) )/ x(2);
err = dt*dt' -  sum(dt)^2/size(dt,2);




function err = wave_fitting_error_pos2(x,th,r,t)
phi = x(1);
v = x(2);
tau = nanmean( t - r.*cos(th-phi) / v);
err = nanmean(  (v*(t-tau)-r.*cos(th-phi)  ).^2);



function err = wave_fitting_error_pos(phi,th,r,t)
v = nanmean( r.*cos(th-phi).*t) / ...
    nanmean( t.^2);
err = nanmean(  (r.*cos(th-phi) - v*t).^2);

