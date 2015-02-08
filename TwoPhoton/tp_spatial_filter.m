function im = tp_spatial_filter( im, filtername, options, verbose )
%TP_SPATIAL_FILTER applies spatial filter to 2D image
%
%  IM = TP_SPATIAL_FILTER( IM, FILTERNAME, VERBOSE )
%
% 2011-2015, Alexander Heimel
%

if nargin<4
    verbose = [];
end
if isempty(verbose)
    verbose = true;
end

if nargin<2
    filtername = 'medfilt2';
    options = '';
end
if ~isempty(options)
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
    for fr = 1:size(im,3)
        eval(['im(:,:,fr,ch) = ' filtername '(squeeze(im(:,:,fr,ch))' options ');']);
    end
    if verbose
        waiting = waiting + wait_interval;
        waitbar(waiting,hbar);
    end
end
if ndims(im)>3
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

