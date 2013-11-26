function [data, t] = tpreaddata_singlechannel(records, intervals, pixelinds, mode, channel)
% TPREADDATA_SINGLECHANNEL - Reads twophon data
%
%  [DATA, T] = TPREADDATA(RECORDS, INTERVALS, PIXELINDS, MODE)
%
%  Reads two photon data blocks.  TPREADDATA
%  allows the user to request data in specific time intervals
%  and at specific locations in the image.
%
%  RECORDS contain experiment info. check HELP TP_ORGANIZATION
%  INTERVALS is a matrix specifying time intervals to read,
%     each row specifies a time interval:
%     e.g., INTERVALS = [ 4 5 ; 6 7] indicates to read data
%     between 4 and 5 seconds and also between 6 and 7 seconds
%     time 0 is relative to the beginning of the scans in the
%     first record
%  PIXELINDS is a cell list specifying pixel indices to read
%     from the images.  Each entry should contain the
%     pixel indices for a given region.
%  MODE is the data mode.  It can be the following:
%     0 : Individidual pixel values are returned.
%     1 : Mean data and time for each frame is returned.
%     2 : Values for each pixel index are returned, and if
%            there are no values for that pixel then NaN
%            is returned at those indices.
%     3 : Mean value of each pixel is returned; no
%            individual frame data is recorded.  Any frames
%            w/o data or w/ NaN are excluded.  Time points
%            will be equal to the mean time recorded as well.
%     10: Individidual pixel values are returned, including
%           frames that only have partial data (i.e., when
%           scan is traversing the points to be read at the
%           beginning or end of an interval).
%     11: Mean data and time for each frame is returned,
%           including frames that have partial data.
%           (Note that this could mean that different numbers
%           of pixels are averaged during each frame.)
%     21: Mean data of all responses over all time intervals
%           is returned.
%
%  CHANNEL is the channel number to be read, from 1 to 4.
%
%  DATA is an MxN cell list, where M is the number of time
%  intervals and N is the number of pixel regions specified.
%  T is also an MxN cell list that contains the exact sample
%  times of each point in DATA.
%
%  If there is a file in the directory called 'driftcorrect',
%  then it is loaded and the corrections are applied.
%  (See TPDRIFTCHECK.)
%
%  Tested:  only tested for T-series records, not other types


% tpcorrecttptimes should still be change for levelt and fitzpatrick labs
frametimes = tpcorrecttptimes(records);

if ~iscell(frametimes)
    frametimes = {frametimes};
end

%disp('TEMPORARY: channel manually set to 1');
%channel  = 0

[data, t] = tpreaddata_single_record(records(1), intervals, pixelinds, mode, channel, frametimes{1});
if length(records)>1
    disp('TPREADDATA: not all options are implemented correctly when reading multiple epochs');
    disp('TPREADDATA: returning results of multiple epochs as single interval. If multiple intervals are required,');
    disp('   then these should be explicitly requested in the function call.');
    for i = 2:length(records)
        [single_data, single_t] = tpreaddata_single_record(records(i), intervals, pixelinds, mode, channel, frametimes{i});
        % concatenate to other data
        for m = 1:size(data,1) % loop over intervals
            for n = 1:size(data,2) % loop over cells
                data{m,n} = [data{m,n} ; single_data{m,n}];
                t{m,n} = [t{m,n} ; single_t{m,n}];
            end
        end
    end
end


function [data,t,params] = tpreaddata_single_record(record, intervals, pixelinds, mode, channel, frametimes)

params = tpreadconfig(record);

% now read in which frames correspond to which file names (file names have a cycle number and cycle frame number)
ffile = repmat([0 0],length(frametimes),1);
dr = [];
initind = 1;

for i=1:1 % used to loop over cycles
    numFrames = params.number_of_frames;
    ffile(initind:initind+numFrames-1,:) = [repmat(i,numFrames,1) (1:numFrames)'];
    initind = initind + numFrames;
end;
driftfilename = tpscratchfilename(record,[],'drift');
if exist(driftfilename,'file'),
    drfile = load(driftfilename,'-mat');
    dr=struct('x',[],'y',[]);
    dr.x = [dr.x; drfile.drift.x];
    dr.y = [dr.y; drfile.drift.y];
    disp(['Drift correction method = ',drfile.method]);
else
    disp(['No driftcorrect file named ' driftfilename]);
end;

% these variables will be used to calculate the time of each pixel within a frame
currScanline_period__us_ = 0;
currLines_per_frame = 0;
currDwell_time__us_ = 0;
currPixels_per_line = 0;

ims = cell(1,length(frametimes));
imsinmem = zeros(1,length(frametimes));

[~,intervalorder] = sort(intervals(:,1));  % do intervals in order to reduce re-reading of frames

data = cell(size(intervals,1),length(pixelinds));
t= cell(size(intervals,1),length(pixelinds));
if mode==21
    accum = cell(1,length(pixelinds));
    taccum = cell(1,length(pixelinds));
    numb = zeros(1,length(pixelinds));
    for i=1:length(pixelinds)
        accum{i} = zeros(size(pixelinds{i}));
        taccum{i}=zeros(size(pixelinds{i}));
        numb(i)=0;
    end;
    data = cell(1,length(pixelinds));
    t= cell(1,length(pixelinds));
end;
for j=1:size(intervals,1) % loop over requested intervals
    if mode==3,
        for i=1:length(pixelinds),
            accum{i}=zeros(size(pixelinds{i}));
            taccum{i}=zeros(size(pixelinds{i}));
            numb(i)=0;
        end;
    end;
    % compute first frame number of current interval j
    if (intervals(intervalorder(j),1)<frametimes(1)) && (intervals(intervalorder(j),2)>frametimes(1)),
        f0 = 1;
    else
        f0=find(frametimes(1:end-1)<=intervals(intervalorder(j),1)& ...
            frametimes(2:end)>intervals(intervalorder(j),1));
    end;
    % compute last frame number of current interval j
    if intervals(intervalorder(j),2)>frametimes(end) && ...
            intervals(intervalorder(j),1)<frametimes(end),
        f1 = length(frametimes);
    else
        f1=find(  frametimes(1:end-1)<=intervals(intervalorder(j),2) & ...
            frametimes(2:end)>intervals(intervalorder(j),2) );
    end
    hwaitbar = waitbar(0,'Reading frames...');
    for f=f0:f1 % loop over frames in interval
        hwaitbar = waitbar(f/(f1-f0));
        %dirid = frame2dirnum(f);  % find the directory where frame number f resides
        if sum(imsinmem)>299,  % limit 300 frames in memory at any one time
            inmem = find(imsinmem);
            ims{inmem(1)} = []; imsinmem(inmem(1)) = 0;
        end;
        if ~imsinmem(f),
            ims{f} = tpreadframe(record,channel,f);
            imsinmem(f) = 1;
        end;
        if (currScanline_period__us_ ~= params.scanline_period__us) || ...
                (currLines_per_frame ~= params.lines_per_frame) ||...
                (currDwell_time__us_ ~= params.dwell_time__us)|| ...
                (currPixels_per_line ~= params.pixels_per_line)
            
            if isfield(params,'bidirectional') && params.bidirectional
                warning('TPREADDATA_SINGLECHANNEL:BIDIRECTIONAL_TIMES',...
                    'TPREADDATA_SINGLECHANNEL: TIMES SHOULD BE RECOMPUTED FOR BIDIRECTIONAL SCANNING');
                warning('off','TPREADDATA_SINGLECHANNEL:BIDIRECTIONAL_TIMES');
            end
            
            %update pixeltimes, time within each frame that each pixel was recorded
            pixeltimes = + repmat( (0 : params.scanline_period : ...
                (params.lines_per_frame-1)*params.scanline_period )', ...
                1,params.pixels_per_line);
            
            pixeltimes = pixeltimes + repmat( 0: (params.dwell_time) : ...
                ((params.pixels_per_line-1)*params.dwell_time), ...
                params.lines_per_frame,1);
            
            %pixeltimes = pixeltimes - params.frame_period;  % if trigger is end-of-frame marker
            
            currScanline_period__us_ = params.scanline_period__us;
            currLines_per_frame = params.lines_per_frame;
            currDwell_time__us_=params.dwell_time__us;
            currPixels_per_line=params.pixels_per_line;
        end;
        t_ = frametimes(f)+pixeltimes;
        for i=1:length(pixelinds)
            if ~isempty(dr) % driftcorrection
                [ii,jj]=ind2sub(size(ims{f}),pixelinds{i});
                switch drfile.method
                    case 'fullframeshift'
                        [thepixelinds, ind_outofbounds] = ...
                            sub2ind_silent_bounds(size(ims{f}),ii-dr.y(f),jj-dr.x(f));
                    case 'greenberg'
                        if length(pixelinds{i})>2000 % too many points
                            disp('greenberg: doing only full frame shifts');
                            [thepixelinds, ind_outofbounds] = ...
                                sub2ind_silent_bounds(size(ims{f}),ii-dr.y(f),jj-dr.x(f));
                        else
                            %disp('greenberg: doing only individual pixel shifts');
                            % using sub2ind and viceversa is slower than they should be
                            
                            thepixelinds=pixelinds{i}; % just for memoryallocation
                            for pind=1:numel(thepixelinds)
                                driftrange.x=(-5:5);
                                driftrange.y=(-5:5);
                                distance_mat=...
                                    (drfile.drift.ypixelpos(f,ii(pind)+driftrange.y,jj(pind)+driftrange.x)-ii(pind)).^2+...
                                    (drfile.drift.xpixelpos(f,ii(pind)+driftrange.y,jj(pind)+driftrange.x)-jj(pind)).^2;
                                [~,ind]=min(distance_mat(:));
                                [shift_ii,shift_jj]=ind2sub([length(driftrange.y) length(driftrange.x)],ind);
                                % check if shift is on border, in which case extend range
                                if shift_ii==length(driftrange.y) || shift_ii==1 || shift_jj==length(driftrange.x) || shift_jj==1
                                    disp('on border of shift range check. should be extended.');
                                end
                                
                                ii(pind)=ii(pind)+shift_ii+min(driftrange.y)-1;
                                jj(pind)=jj(pind)+shift_jj+min(driftrange.x)-1;
                                thepixelinds(pind)=sub2ind(size(ims{f}),ii(pind),jj(pind));
                                ind_outofbounds=[];
                            end
                        end
                end
            else
                thepixelinds = pixelinds{i};
                ind_outofbounds=[];
            end;
            thisdata = double(ims{f}(thepixelinds));
            thisdata(ind_outofbounds)=nan;
            thistime = t_(thepixelinds);
            newtinds = find(thistime>=intervals(intervalorder(j),1)&thistime<=intervals(intervalorder(j),2)); % trim out-of-bounds points
            if mode==1
                if length(newtinds)==length(thepixelinds)
                    thistime = thistime(newtinds);
                    thistime = nanmean(thistime);
                    thisdata = thisdata(newtinds);
                    thisdata = nanmean(thisdata);
                else
                    thistime = []; thisdata = [];
                end
            elseif mode==0
                if length(newtinds)==length(thepixelinds),
                    thistime = thistime(newtinds);
                    thisdata = thisdata(newtinds);
                else
                    thistime = []; thisdata = [];
                end
            elseif mode==3 || mode==21
                if length(newtinds)==length(thepixelinds),
                    thistime = thistime(newtinds);
                    thisdata = thisdata(newtinds);
                else
                    thistime = []; thisdata = [];
                end
                if ~isempty(thistime),
                    accum{i}=nansum(cat(3,accum{i},thisdata),3);
                    taccum{i}=nansum(cat(3,taccum{i},thistime),3);
                    numb(i)=numb(i)+1;
                end
            elseif mode==11
                thistime = thistime(newtinds); thisdata = thisdata(newtinds);
                if ~isempty(newtinds),
                    thistime = nanmean(thistime); thisdata = nanmean(thisdata);
                else
                    thistime = []; thisdata = [];
                end;
            elseif mode==10
                thistime = thistime(newtinds); thisdata = thisdata(newtinds);
            elseif mode==2
                badinds = setdiff(1:length(thepixelinds),newtinds);
                thisdata(badinds) = NaN;
            end
            if (mode~=3)&&(mode~=21)
                data{intervalorder(j),i} = cat(1,data{intervalorder(j),i},reshape(thisdata,numel(thisdata),1));
                t{intervalorder(j),i} = cat(1,t{intervalorder(j),i},reshape(thistime,numel(thisdata),1));
            end
        end
    end
    close(hwaitbar);
    if mode==3
        for i=1:length(pixelinds),
            if numb(i)>0,
                data{intervalorder(j),i} = accum{i}/numb(i);
                t{intervalorder(j),i} = taccum{i}/numb(i);
            else
                data{intervalorder(j),i} = NaN * ones(size(pixelinds{i}));
                t{intervalorder(j),i} = NaN * ones(size(pixelinds{i}));
            end
        end
    end
end
if mode==21
    for i=1:length(pixelinds)
        if numb(i)>0
            data{1,i} = accum{i}/numb(i);
            t{1,i} = taccum{i}/numb(i);
        else
            data{1,i} = NaN * ones(size(pixelinds{i}));
            t{1,i} = NaN * ones(size(pixelinds{i}));
        end
    end
end

for i=1:length(ims), ims{i} = []; end; clear ims; %pack;
