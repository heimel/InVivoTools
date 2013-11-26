function [ind_obs1,ind_obs2,pvals,avgdiff] = image_line_analysis(avg,stddev,mask,filenames,cond1,cond2,cond0,frames,mnnn,mxxx,pt1,pt2)

% IMAGE_LINE_ANALYSIS - Analyze mean activity and discriminability along a line
%
%  [IND_OBS1,IND_OBS2,PVALS]=IMAGE_LINE_ANALYSIS(AVG,STDDEV,MASK,FILENAMES,
%     COND1,COND2,COND0,FRAMES,[PT1 PT2])
%
%  Analyzes activity along a user-specified line for two stimuli (COND1 and
%  COND2) in an optical imaging experiment with average data AVG and standard
%  deviation STDDEV.  If PT1 and PT2 are specified, the line is taken to be
%  the line between these points.  If not, the user is asked to click two
%  points to specify the line.  Pixels between these points are then selected
%  for analysis, omitting any points that fall within MASK, which should be a
%  matrix of 0's and 1's the same size as AVG(:,:,[COND1]);
%
%  The individual trial data are then read for these points from the filenames
%  listed, using the normalization method of subtraction from condition COND0
%  and the output method of frame averaging over FRAMES.
%  
%  See also: AVERAGE_IMAGES

if nargin<11, xx=[]; yy=[]; else, xx=[pt1(1) pt2(1)]; yy=[pt1(2) pt2(2)]; end;

linewidths = 4;
h = figure;
subplot(3,3,1); plotimagemap(avg(:,:,cond1)',0,256,mnnn,mxxx);
	colormap(gray); axis equal;

subplot(3,3,2); plotimagemap(avg(:,:,cond2)',0,256,mnnn,mxxx);
	colormap(gray); axis equal;

subplot(3,3,1);

happy=~isempty(xx);
if happy, subplot(3,3,1); hold on; l1=plot(xx,yy,'b','linewidth',linewidths);
	      subplot(3,3,2); hold on; l2=plot(xx,yy,'r','linewidth',linewidths);
end;
l1 = []; l2 = [];

while ~happy,
	if ishandle(l1), delete(l1); end; if ishandle(l2), delete(l2); end;
	bname=questdlg(...
		'Please select two points to form a line in the first image',...
		'Please select','Ok','Ok');

	[xx,yy]=ginput(2);

	subplot(3,3,1); hold on; l1=plot(xx,yy,'b','linewidth',linewidths);
	title(['Avg image, condition ' int2str(cond1)]);
	ylabel('Pixels');xlabel('Pixels');
	subplot(3,3,2); hold on; l2=plot(xx,yy,'r','linewidth',linewidths);
	title(['Avg image, condition ' int2str(cond2)]);
	ylabel('Pixels');xlabel('Pixels');
	drawnow;
	buttonname=questdlg('Are you satisfied with the line?','Line good',...
			'Yes','No','No');
	happy=strcmp(buttonname,'Yes');
end;

[linepoints,lineinds]=lineselectpixels([yy(1) xx(1)],...
    [yy(2) xx(2)],0.5:size(avg,2)-0.5,0.5:size(avg,1)-0.5);
  % remove points from mask
maskinds = find(mask);

[goodinds,linds]=setdiff(lineinds,maskinds);
lineinds = lineinds(linds); linepoints=linepoints(linds);

[linepoints,newlineinds]=sort(linepoints);lineinds=lineinds(newlineinds);

mx=max(max(max(avg(:,:,[cond1 cond2]))));
mn=min(min(min(avg(:,:,[cond1 cond2]))));
maskimg=repmat(mn,size(avg,1),size(avg,2));
maskimg(lineinds)=mx;

subplot(3,3,3);colormap(gray(256)); imagesc(maskimg');axis equal;
title('Points included in line');
ylabel('Pixels');xlabel('Pixels');

avg1=double(avg(:,:,cond1));stddev1=double(stddev(:,:,cond1));
avg2=double(avg(:,:,cond2));stddev2=double(stddev(:,:,cond2));

subplot(3,3,4);hold off;
plot(linepoints,avg1(lineinds)-double(stddev1(lineinds)),'b'); hold on;
plot(linepoints,avg1(lineinds)+double(stddev1(lineinds)),'b');
plot(linepoints,avg2(lineinds)-double(stddev2(lineinds)),'r');
plot(linepoints,avg2(lineinds)+double(stddev2(lineinds)),'r');
plot(linepoints,avg1(lineinds),'b','linewidth',3);
plot(linepoints,avg2(lineinds),'r','linewidth',3);
a=axis;
axis([min(linepoints) max(linepoints) a(3) a(4)]);
title('Mean values w/ standard deviation');
ylabel('Intensity');xlabel('Position (pixels)');

subplot(3,3,5);
 avgdiff=(avg1-avg2);
 imagesc(avgdiff'); colormap(gray); axis equal;
 hold on; plot(xx,yy,'g','linewidth',linewidths);
title(['Condition ' int2str(cond1) ' - Condition ' int2str(cond2)]);
ylabel('Pixels');xlabel('Pixels');
 
subplot(3,3,6);
 plot(linepoints,avg1(lineinds)-avg2(lineinds),'g');
a=axis;
axis([min(linepoints) max(linepoints) a(3) a(4)]);
title('Mean difference values');
ylabel('Intensity difference');xlabel('Position (pixels)');

[ind_,avg_,stddev_]=average_image_pixels(filenames,[cond0 cond1 cond2],...
		frames,lineinds,'avgframes','subtract',1);

ind_obs1 = reshape(mean(ind_(:,:,2,:),2),[length(lineinds) length(filenames)]);
ind_obs2 = reshape(mean(ind_(:,:,3,:),2),[length(lineinds) length(filenames)]);

subplot(3,3,7);
plot(linepoints,ind_obs1); hold on;
plot(linepoints,avg1(lineinds),'b','linewidth',4);
a1 = axis;
subplot(3,3,8);
plot(linepoints,ind_obs2); hold on;
plot(linepoints,avg2(lineinds),'r','linewidth',4);
a2=axis;
subplot(3,3,7);
axis([min(linepoints) max(linepoints) min([a2(3) a1(3)]) max([a2(4) a1(4)])]);
title(['Individual observations and mean, condition ' int2str(cond1)]);
xlabel('Position (pixels)'); ylabel('Intensity');
subplot(3,3,8);
axis([min(linepoints) max(linepoints) min([a2(3) a1(3)]) max([a2(4) a1(4)])]);
title(['Individual observations and mean, condition ' int2str(cond2)]);
xlabel('Position (pixels)'); ylabel('Intensity');

pvals=lineanalysis_bootstrap2(ind_obs1,ind_obs2,10000);
subplot(3,3,9);
plot(linepoints,1-((pvals)/2+0.5),'r'); hold on;
plot(linepoints,(pvals)/2+0.5);
a=axis;
axis([min(linepoints) max(linepoints) a(3) a(4)]);
plot([a(1) a(2)],[0.8 0.8],'g');
plot([a(1) a(2)],[0.7 0.7],'g');
plot([a(1) a(2)],[0.66 0.66],'g');
