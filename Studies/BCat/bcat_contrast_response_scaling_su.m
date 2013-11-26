% beta-catenine contrast response scaling of single unit data
%
% first make figure BCat paper 4B contrast drifting response curve xlog
% both scales with graph_db
%
% put this in extra code
%
% ko_x=[20    40    60    75    90];
% ko_y=[ 0.0744    0.1661    0.3233    0.4600    0.5469];
% wt_x=[20    40    60    75    90];
% wt_y=[   0.1405    0.4651    0.6967    0.8116    0.9631];

% child=get(gca,'children');
% wt_x=get(child(2),'xdata');
% wt_y=get(child(2),'ydata');

wt_x = x{1};
wt_y = y{1};
ko_x = x{2};
ko_y = y{2};

% h_response_scaled=plot(wt_x,wt_y*0.74,':');
% set(h_response_scaled,'color',[0.7 0.7 0.7]);
% h_contrast_scaled=plot(wt_x*1.35,tempy,'r--');
% set(h_contrast_scaled,'color',[0.7 0.7 0.7]);


c=linspace(0,1,100);
[rm,b,n] = naka_rushton(wt_x/100,wt_y);


wt_fit = rm*c.^n./(b^n+c.^n);

% norm=max(wt_fit);
% wt_y=wt_y/norm;
% ko_y=ko_y/norm;
% wt_fit=wt_fit/norm;


%figure;
%hold on
%h.ko=plot(ko_x,ko_y,'go')
%set(h.ko,'color',0.7*[1 1 1 ]);
%plot(wt_x,wt_y,'ro')
h_fit = plot(c*100,wt_fit,'color','k');

% optimal fit contrast scaling
scale=linspace(0.5,2,60);
%scale=1.50
min_error=inf;
for s=scale
	c_scaled=c*100*s;
	ind=findclosest(c_scaled,ko_x);
	error= sum( (ko_y - wt_fit(ind)).^2)
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
disp(['BCAT_CONTRAST_RESPONSE_SCALING_SU: Scaling contrast by ' ...
    num2str(1/proper_scale,2) ' gives minimal error ' num2str(min_error,2)]);
plot(c*100*proper_scale,wt_fit,'k--')

% optimal fit response scaling
scale=linspace(0.1,2,60);
min_error=inf;
for s=scale
	error= sum( (ko_y - wt_y*s).^2);
	if error<min_error
		min_error=error;
		proper_scale=s;
	end
end
disp(['BCAT_CONTRAST_RESPONSE_SCALING_SU: Scaling response by ' ...
    num2str(proper_scale,2) ' gives minimal error ' num2str(min_error,2)]);
plot(c*100,wt_fit*proper_scale,'k:')


set(gca,'XScale','log');
%axis([20 100 0 1.4]);
set(gca,'XTick',[20 30 40 60 80 100]);
%bigger_linewidth(3);
%smaller_font(-12);
h.legend = legend('control','\beta-cat deficient','control fit','scaled contrast','scaled response','location','northwest');
legend boxoff
%set(h.legend,'fontsize',15)
%title('contrast response scaling single-unit');
%save_figure('bcat_contrast_response_scaling_su.png','~/Projects/Mouse/B-Cat/Figures');