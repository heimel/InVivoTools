function sc_simulate_tuning
%SC_SIMULATE_TUNING
%
% 2014, Alexander Heimel

% sf = 0.01:0.01:0.5;
% r = sfresponse(sf,0.05,0.5);
% plot(sf,r);
% xlabel('Spatial frequency (cpd)');
% ylabel('Response');

theta =-60:0.1:60; % visual angle 
csigma = 2; % center width
ssigma = 5 ; % relative surround width
rf = exp(-(theta/csigma).^2/2)  - 1/ssigma*exp(-(theta/(ssigma*csigma)).^2/2);
sum(rf)

sf = 0.1; % cpd
phase = 0; % degrees
stim = getstim(theta,sf,phase)

figure
plot(theta,rf);
hold on
plot(theta,stim,'k');
box off


sf=0.01:0.01:0.5
phase = 0:1:359;
for i=1:length(sf)
    for j=1:length(phase)
        r(i,j) = getstim(theta,sf(i),phase(j))*rf';
        rc(i,j) = getstim(theta,2*sf(i),phase(j))*rf';
    end
end
figure
hold on
plot(sf,r(:,1));
plot(sf,rc(:,1),'k');

figure
plot(phase,r(sf==0.05,:))

function stim = getstim(theta,sf,phase)
stim = sign(cos(phase/180*pi+360*sf*theta/180*pi));


function r = sfresponse(sf,psf,supp)

r = thresholdlinear( exp( -(sf-psf).^2 ./(2*psf)^2 ) - supp*exp(-sf.^2 ./(2*psf)^2 ));

