function position = laserpower2nsc200( frac )
%LASERPOWER2NSC200 converts fraction of laser power to NSC200 setting
%
%  POSITION = LASERPOWER2NSC200( FRAC )
%
%  needed for laser power control with NSC200 in Levelt lab
%
% 2012, Alexander Heimel
%

minx = 5175;
maxx = 7700;

if 0
    x = [5200 47;5700 1420; 6200 4721;6700 8830; 7200 11720; ...
        7700 12900;8300 12940; 5400 50;5500 508;5600 850;6000 3130; ...
        6500 7300;7000 10600;7500 12700];
    x(:,2)=x(:,2)/max(x(:,2));
    [~,ind]=sort(x(:,1));
    x=x(ind,:);
    figure;
    hold on
    plot(x(:,1),x(:,2),'o-');
    fx = (minx-200):(maxx+200);
    plot( fx, (1+sin( (fx -minx)/(maxx-minx)*pi -pi/2))/2 ,'r');
end

position = round(minx + (maxx-minx)*(asin(frac*2 -1)/pi +0.5));
