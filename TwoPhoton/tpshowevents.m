function tpshowevents( data, t, listofcells, listofcellnames, params,process_params, timeint,plot_params,comment)
%TPSHOWEVENTS makes image of cells with color indicating amplitude or onset time
%
%
%
% 2010, Alexander Heimel
%


if nargin<9
    comment = '';
end

% transform to cell structure if data is not
% a little ugly, should be possible to more concisely
if isnumeric( data )
    % put all events in single interval
    new_data = {};
    new_t = {};
    for c=1:size(data,2)
        new_data{1,c} = data(:,c);
        new_t{1,c} = t(:,c);
    end
    t = new_t;
    data = new_data;
end


if ~strcmp(process_params.method,'event_detection')
    warning('TPSHOWEVENTS: need to have detected events before plotting them');
    return
end

if nargin<8
    plot_params.what = 'amplitude'; % {'amplitude','time'}
end

showtime = false;
switch plot_params.what
    case 'time';
        data = t;
        showtime = true;
end



figure('name',capitalize(plot_params.what),'NumberTitle','off');

n_events = 0;
for i=1:size(data,1)
    n_events = n_events + length(data{i,1});
end
n_cols = min(6,n_events);
n_rows = ceil( n_events / n_cols);

colormap default;
cm = colormap;
cm(1,:) = [0 0 0]; % make first color black

cum_event = 1;
for i=1:size(data,1) % intervals
    for event=1:length(data{i,1}) % global events


        im=nan*zeros(params.lines_per_frame, params.pixels_per_line);
        %im=zeros(params.lines_per_frame, params.pixels_per_line);
        for c=1:size(data,2)
            im(listofcells{c}) = data{i,c}(event);
        end

        % first time
        celltimes = zeros(1,size(data,2));
        celldata = zeros(1,size(data,2));
        for c=1:size(data,2)
            celltimes(c) = t{i,c}(event);
            celldata(c) = data{i,c}(event);
        end
        firsttime = min(celltimes);
        
        dcelltimes = diff(sort(celltimes));
        max_time_gap = max(dcelltimes);
        
        comment = [comment ' max.time gap = ' num2str(max_time_gap,'%.2f')];
        
        if showtime
            im = im - firsttime;
            im(isnan(im)) =  -(max(im(:))-min(im(:)))/63; % to get color zero %0.1;
        else
            im(isnan(im)) = 0;
        end

        subplot(n_rows,n_cols,cum_event);
        imagesc( im );
        axis image;axis off
        maxtime = 3.5;
        clim = get(gca,'clim');
        clim(2) = maxtime;
        set(gca,'clim',clim);
        
        colormap(cm);
        title(['Time: ' num2str(fix(firsttime)) ' - ' comment]);
        
        if showtime && n_events==1 % fit wave
            hold on
            % x is horizontal axis in image
            % y is vertical axis in image, consistent with the reverse
            % image y-axis, i.e. top left in image is x=0,y=0, bottom right
            % is x=max_x, y=max_y
            cellpositions = get_cellpositions( listofcells, params );
            [wave_velocity,wave_direction,wave_error,radius,wave_tau] = tp_fit_wave( celltimes, cellpositions, celldata,process_params);
            
            scale = sqrt(params.lines_per_frame^2+params.pixels_per_line^2);
            timerange = (max(im(:))-min(im(:)));
                        
            % draw wave direction arrow
            % WTBARROW does not take reverse diretcion of y-axis into
            % account
            hdl = wtbarrow('create','Translate',[params.pixels_per_line/2 params.lines_per_frame/2],...
                'Rotation',-wave_direction,'Scale',[wave_velocity*timerange/6 scale/25],'Color',[1 1 1]);

            % draw equitime lines
            [ox,oy] = pol2cart(wave_direction-pi/2,scale);
            [dx,dy] = pol2cart(wave_direction,wave_velocity);
            
            n_timesteps = 5;
            for timestep=0:n_timesteps
%                dt=firsttime-wave_tau+timerange*timestep/n_timesteps;
                dt=firsttime-wave_tau+maxtime*timestep/n_timesteps;
                x=dt*dx;  y=dt*dy;
                line([x-ox x+ox],[y-oy y+oy],'Color',cm(round((end-2)/n_timesteps*timestep+2),:));
            end
        end        
        cum_event = cum_event+1;
    end
end

if n_events==1 
    colorbar
end
return




function p = get_cellpositions( listofcells, params )
% returns cell positions struct array with fields x and y (line,pixel)
for c = 1:length(listofcells)
    [y,x]=ind2sub([params.lines_per_frame,params.pixels_per_line],listofcells{c});
    p(c).x = mean(x);
    p(c).y = mean(y);
end