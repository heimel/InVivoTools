function [hp,hr] = plot_psth(N,X,rast,triglength,ratioPSTH,PSTHclear, ...
              theAxes, theTitle, y_label)

%  [H] = PLOT_PSTH(N,X,rast,ratioPSTH,PSTHclear,theAxes)

axes(theAxes);

hp = theAxes;
hr = [];

if ~isempty(rast),

	rect = get(theAxes,'Position');
	delete(theAxes);

        dy = rect(4)*ratioPSTH;
	newRect     = [ rect(1) rect(2) rect(3) dy];
	newRectRast = [ rect(1) rect(2)+dy rect(3) rect(4)-dy ];

        hr = axes('position',newRectRast);

	plot(rast(1,:),rast(2,:),'k.','MarkerSize',20);
	ytick = get(hr,'YTick');
	title(theTitle,'fontsize',16,'fontweight','bold');
	ylabel(y_label,'fontsize',16,'fontweight','bold');
	set(hr,'XLim',[X(1) X(end)],'YLim',[1 triglength],'YDir','reverse', ...
               'XTick',[],'YTick',[0 triglength-1], ...
               'fontsize',16, 'fontweight','bold');

        hp = axes('position',newRect);
end;

bar(X,N);
n = max(N) + PSTHclear;
xlabel('Time (s)','fontsize',16,'fontweight','bold');
ylabel('Avg','fontsize',16,'fontweight','bold');
set(hp,'XLim',[X(1) X(end)],'YLim',[0 n], ...
               'fontsize',16, 'fontweight','bold');

