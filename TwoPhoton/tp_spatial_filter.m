function im = tp_spatial_filter( im, filtername, options )
%TP_SPATIAL_FILTER applies spatial filter to 2D image
%
%  IM = TP_SPATIAL_FILTER( IM, FILTERNAME )
%
% 2011, Alexander Heimel
%

if nargin<2
    filtername = 'medfilt2';
    options = '';
    
    % filtername = 'wiener2';
    % options = '[5 5]';
end
if ~isempty(options)
    options = [',' options];
end

waiting = 0;
wait_interval = 1/3/size(im,4);
hbar = waitbar(waiting,['Applying spatial filter ' filtername ]);


n_channels = size(im,4);

% applying filter
for ch = 1:size(im,4)
    for fr = 1:size(im,3)
        eval(['im(:,:,fr,ch) = ' filtername '(squeeze(im(:,:,fr,ch))' options ');']);
    end
    waiting = waiting + wait_interval;
    waitbar(waiting,hbar);
end
if ndims(im)>3
    for ch = 1:size(im,4)
        for x = 1:size(im,1)
            eval(['im(x,:,:,ch) = ' filtername '(squeeze(im(x,:,:,ch))' options ');']);
        end
        waiting = waiting + wait_interval;
        waitbar(waiting,hbar);
    end
    for ch = 1:size(im,4)
        for y = 1:size(im,2)
            eval(['im(:,y,:,ch) = ' filtername '(squeeze(im(:,y,:,ch))' options ');']);
        end
        waiting = waiting + wait_interval;
        waitbar(waiting,hbar);
    end
end
close(hbar);

