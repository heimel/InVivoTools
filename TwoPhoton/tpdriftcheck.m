function [dr] = tpdriftcheck(record, channel, refrecord,  method, writeit, doplotit)
%  TPDRIFTCHECK - Checks two-photon data for drift
%
%    [DR] = TPDRIFTCHECK(RECORD, CHANNEL, REFRECORD, METHOD, WRITEIT, PLOTIT)
%
%  Reports drift across a twophoton time-series record.  Drift is
%  calculated by computing the correlation for pixel shifts within
%  the search space specified.
%
%  RECORD is a record describing the data, see HELP TP_ORGANIZATION
%  relative to data at the beginning of REFRECORD
%  CHANNEL is the channel to be read.
%
%  If WRITEIT is 1, then a 'driftcorrect.mat' file is written to the
%  directory, detailing shifted frames.
%
%  DR is a two-dimensional vector that contains the X and Y shifts for
%  each frame.
%
%  If PLOTIT is 1, the results are plotted in a new figure.
%
% wrapper around drift or motion correction algorithms

switch method
    case '?'
        % return possible methods
        dr = {'fullframeshift','greenberg'};
        return
    case '' 
        % set default method
        method = 'fullframeshift';
end
disp(['Drift correction method: ' method]);
driftfilename = tpscratchfilename( record, [], 'drift');

howoften=10;
avgframes=5; % only implemented for tpdriftcheck_steve

params = tpreadconfig(record);
total_n_frames = params.number_of_frames;
analysed_n_frames = fix( (total_n_frames-1)/howoften+1);

switch method
  case 'fullframeshift'
    searchx = -6:2:6;
    searchy = -6:2:6;
    refsearchx = -100:10:100;
    refsearchy = -100:10:100;
    dr = tpdriftcheck_fullframeshift(record, channel, searchx, searchy, ...
      refrecord, refsearchx, refsearchy, howoften, avgframes);
  case 'greenberg'
    %   base_image = tppreview(refdirname,avgframes,1,channel);  % the first image
    data=zeros(params.lines_per_frame,params.pixels_per_line,analysed_n_frames,'uint8');
    cfr=1;
    for fr=1:howoften:total_n_frames
      data(:,:,cfr)=tpreadframe(record,channel,fr);
      cfr=cfr+1;
    end
    base_image=mean(data,3);

    [p, iter_used, corr, failed, settings, xpixelposition, ypixelposition] ...
      = tpdriftcheck_greenberg(data,base_image);
  
    data=[];clear('data');
end
disp('Computed drift correction');

if writeit,

  % first interpolate values
  newframeind = 1:total_n_frames;
  frameind = 1:howoften:total_n_frames-avgframes;
  switch method
    case 'fullframeshift'
      drift.x=round(interp1(frameind,dr(:,1),newframeind,'linear','extrap')');
      drift.y=round(interp1(frameind,dr(:,2),newframeind,'linear','extrap')');
    case 'greenberg'
      drift.xpixelpos=interp1(frameind,shiftdim(xpixelposition(:,:,:),2),newframeind,'linear','extrap');
      drift.ypixelpos=interp1(frameind,shiftdim(ypixelposition(:,:,:),2),newframeind,'linear','extrap');
      % image mean drifts:
      drift.x=round(mean(mean(drift.xpixelpos,3),2)-(params.pixels_per_line+1)/2);
      drift.y=round(mean(mean(drift.ypixelpos,3),2)-(params.lines_per_frame+1)/2);
  end
  %drift((end-30:end),:)=repmat([-20 -20],31,1); % for debugging
  save(driftfilename,'method','drift','-mat');
end;
clear('dr');
dr(:,1)=drift.x;
dr(:,2)=drift.y;

%first_image = tppreview(refdirname,avgframes,1,channel);

intervals = [ params.frame_timestamp(1) params.frame_timestamp(2)];
first_image = tpreaddata(record,intervals, {(1:params.lines_per_frame * params.pixels_per_line)}, 3, channel);
first_image = reshape( first_image{1}, params.lines_per_frame, params.pixels_per_line);

intervals = [ params.frame_timestamp(end-1) inf];% params.frame_timestamp(end)];
last_image = tpreaddata( record,intervals, {(1:numel(first_image))}, 3, channel);
if isempty(last_image{1})
  disp('Lost last image');
end
last_image=reshape(last_image{1},size(first_image,1),size(first_image,2));



if doplotit,
  load(driftfilename,'-mat');
  figure;
  subplot(2,2,1);
  im0=first_image;
  im1=last_image;
  image(rescale(im0,[min(min(im0)) max(max(im0))],[0 255])); colormap(gray(256));
  title('First image');

  subplot(2,2,2);
  im2 = (im0 / max(max(im0)));
  im2(:,:,2) = im1/max(max(im0)); % green
  im2(:,:,3) = im2(:,:,1);        % blue
  im2(:,:,1) = zeros(size(im0));  % red
  im2(im2>1) = 1;
  image(im2);
  title('blue=first image, green = last image');
  switch method
    case 'fullframeshift'
      subplot(2,2,3);
      plot(dr(:,1));
      title('X drift'); ylabel('Pixels'); xlabel('Frame #');
      subplot(2,2,4);
      plot(dr(:,2));
      title('Y drift'); ylabel('Pixels'); xlabel('Frame #');
    case 'greenberg'
      subplot(2,2,3);
      plot(dr(:,1));
      title('mean X drift'); ylabel('Pixels'); xlabel('Frame #');
      subplot(2,2,4);
      plot(dr(:,2));
      title('mean Y drift'); ylabel('Pixels'); xlabel('Frame #');
  end
end;

