function [im] = tpcheckroidrift(record, channel, roirect, roiinds, roix,roiy,roiname)

%  TPCHECKROIDRIFTNAME - Checks twophoton drift correction performance
%
%  IM = TPROIDRIFT(DIRNAME,CHANNEL,ROIRECT,ROIINDS,ROIX,ROIY,RIONAME, PLOTIT)
%
%  Checks drift correction performance.  Takes a rectangle (ROIRECT) as input and
%  then grabs the image of this rectangle from each two-photon frame.  If an
%  object of interest is within this rectangle, the ROIINDS and the X and Y
%  coordinates (relative to the center of ROIRECT) can be specified and the
%  object will be outlined.
%  If the data are to be plotted (PLOTIT==1) then the axes are titled with ROINAME.
%
%  ROIRECT should be [left top right bottom].
%
%  CHANNEL is the channel to be read.

tpdriftplot(record,channel);

pv = tppreview(record,1,1,channel);
im0 = zeros(size(pv));
try
    im0(roirect(2):roirect(4),roirect(1):roirect(3)) = 1;
catch
    logmsg('ROI has (partially) drifted out of field of view.');
end
rectinds = find(im0);
rctx= roirect(3)-roirect(1)+1;
rcty = roirect(4)-roirect(2)+1;

stims = getstimsfile( record );
if isempty( stims )
    havestims = 0;
else
    havestims = 1;
    s.stimscript = stims.saveScript; s.mti = stims.MTI2;
    s.mti=tpcorrectmti(s.mti,record);
end;

%figure;subplot(2,2,1);  image(rescale(pv,[min(min(pv)) max(max(pv))],[0 255])); subplot(2,2,2); image(256*im0); colormap(gray(256));

%interval = [ s.mti{1}.frameTimes(1)-3 s.mti{end}.startStopTimes(3) ]-starttime;
%interval = [ 40 100];
interval = [0 Inf];

[data,t] = tpreaddata(record, interval,{rectinds roiinds},0,channel);

im = reshape(data{1,1},rctx,rcty,length(data{1,1})/(rctx*rcty));
t_ = reshape(t{1,1},rctx,rcty,length(data{1,1})/(rctx*rcty));
t_ = reshape(t_,rctx*rcty,length(data{1,1})/(rctx*rcty));
ims = reshape(data{1,2},length(roiinds),length(data{1,2})/length(roiinds));
t2 = reshape(t{1,2},length(roiinds),length(t{1,2})/length(roiinds));

numframes = size(im,3);
i = 1;

im1 = mean(im(:,:,1:min(5,numframes)));

drt = [0 0 mean(t_(:,1))];

while i<numframes
    framestart = i;
    im_ = zeros(10*size(im,1),10*size(im,2));
    ctr = [ ];
    for j=1:10
        for k=1:10
            if i<numframes
                im_(1+(j-1)*size(im,1):j*size(im,1),1+(k-1)*size(im,2):k*size(im,2))=im(:,:,i);
                ctr(end+1,1:2)=[median(1+(j-1)*size(im,1):j*size(im,1)) median(1+(k-1)*size(im,2):k*size(im,2))];
                if mod(i,3)==0
                    im2 = mean(im(:,:,i:min(i+5,numframes)));
                    drt(end+1,:) = [driftcheck(im1, im2, -10:2:10, -10:2:10 ,1) mean(t_(:,i))];
                end;
                i = i + 1;
            end;
        end;
    end;
    frameend = i;
    imagedisplay(im_); hold on;
    if ~isempty(roix)
        for j=1:size(ctr,1)
            plot(roix+ctr(j,2),roiy+ctr(j,1),'b-');
        end;
    end;
    title(['Extracted frame ' int2str(framestart) ' to ' int2str(frameend) ' of ' roiname '.']);
end

figure;
subplot(4,1,1);
plot(drt(:,3),drt(:,1),'r'); hold on; plot(drt(:,3),drt(:,2),'b');
title(['Drift statistics for ' roiname ' : red is x, blue is y.']);

subplot(4,1,2);
plot(mean(t2,1),mean(ims,1),'k-o');
title('Value at each time point.');
A = axis;

subplot(4,1,3);
plot(mean(t2,1),mean(ims,1)/max(mean(ims,1)),'k-o');
hold on;
if havestims, stimscriptgraph(record,1); end;
axis([A(1:2) 0 3]);

subplot(4,1,4);
plot(mean(t_,1)',1:numframes,'k-o');
title('Relationship between time and frames');
xlabel('Time (s)');
ylabel('Frame (#)');
