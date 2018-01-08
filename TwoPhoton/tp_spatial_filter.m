function im = tp_spatial_filter( im, filtername, options, verbose )
%TP_SPATIAL_FILTER applies spatial filter to 2D or 3D image
%
%  IM = TP_SPATIAL_FILTER( IM, FILTERNAME, OPTIONS, VERBOSE )
%
% 2011-2017, Alexander Heimel
%

if nargin<4 || isempty(verbose)
    verbose = true;
end
if nargin<2 || isempty(filtername)
    filtername = 'medfilt2';
    options = '';
end
if nargin<3 
    options = '';
end

if ~isempty(options) && options(1)~=','
    options = [',' options];
end

if verbose
    waiting = 0;
    wait_interval = 1/3/size(im,4);
    hbar = waitbar(waiting,['Applying spatial filter ' filtername ]);
end

n_channels = size(im,4);

% applying filter
for ch = 1:n_channels
    switch filtername(end)
        case '3' % 3D filtering
            eval(['im(:,:,:,ch) = ' filtername '(squeeze(im(:,:,:,ch))' options ');']);
        otherwise % default 2d filtering
            for fr = 1:size(im,3)
                eval(['im(:,:,fr,ch) = ' filtername '(squeeze(im(:,:,fr,ch))' options ');']);
            end
    end
    if verbose
        waiting = waiting + wait_interval;
        waitbar(waiting,hbar);
    end
end

if ndims(im)>3 && filtername(end)~='3' 
    % apply 2d filter also along x and y dimensions
    for ch = 1:n_channels
        for x = 1:size(im,1)
            eval(['im(x,:,:,ch) = ' filtername '(squeeze(im(x,:,:,ch))' options ');']);
        end
        if verbose
            waiting = waiting + wait_interval;
            waitbar(waiting,hbar);
        end
    end
    for ch = 1:n_channels
        for y = 1:size(im,2)
            eval(['im(:,y,:,ch) = ' filtername '(squeeze(im(:,y,:,ch))' options ');']);
        end
        if verbose
            waiting = waiting + wait_interval;
            waitbar(waiting,hbar);
        end
    end
end
if verbose
    close(hbar);
end

