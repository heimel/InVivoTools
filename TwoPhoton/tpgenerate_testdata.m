function tpgenerate_testdata
%CREATETPTESTDATA generates artificial data to test data analysis
%
% 2010, Alexander Heimel
%

width = 100;
height = 70;
n_frames = 150;
cell_radius_min = 4;
cell_radius_mean = 10;
n_cells = 4;

% generate drift
switch 2
    case 1
        drift.x = ( (1:n_frames)> n_frames/2)*5; % at halftime shift of 5 pixels in x-direction
        drift.y = ( (1:n_frames)> n_frames/3)*8; % at 1/3time shift of 8 pixels in y-direction
    case 2
        drift.x = 0.1*(1:n_frames);
        drift.y = 0*(1:n_frames);
end

% generate data

% put shift in here to make it easier

data = zeros(height,width,n_frames);
[x,y] = meshgrid( 1:width, 1:height);
for c=1:n_cells
    within_image = 0;
    while ~within_image
        celldata(c).x = ceil( width * rand(1));
        celldata(c).y = ceil( height * rand(1));
        celldata(c).radius = cell_radius_min + round( (cell_radius_mean-cell_radius_min)*2 * rand(1));
        if (celldata(c).x - celldata(c).radius) > 0 && (celldata(c).x + celldata(c).radius) < width && ...
                (celldata(c).y - celldata(c).radius) > 0 && (celldata(c).y + celldata(c).radius) < height
            within_image = 1;
        end
    end
    celldata(c).signal =2^9*thresholdlinear( 1 +rand(1) + rand(1)*sin( (1:n_frames) / n_frames * 2*pi /rand(1)) );

    for f = 1:n_frames
        cellimageseq(:,:,f) =  celldata(c).signal(f) *double(((x- celldata(c).x -drift.x(f) ).^2 + (y- celldata(c).y -drift.y(f) ).^2) < celldata(c).radius^2 );
    end
    data = data + cellimageseq;
end

write_multitiffs(data,2);

return


function write_multitiffs(data,n_epochs)

data = uint16(data);

record.experiment = 'test';
record.stack = '01';
record.mouse = 'a';
record.ref_epoch = '01';
record.date = datestr(now,29);
record.datatype = 'tp';
record.experimenter = 'FS';
record.slice = '';
record.epoch ='01';
fpath = experimentpath( record );
if ~exist(fpath,'dir')
    success = mkdir( fpath );
    if ~success
        warning('CREATETPTESTDATA:could not create test directory.');
    end
end


n_frames = size(data,3);
n_frames_per_epoch = floor( n_frames /n_epochs);
for epoch = 1:n_epochs
    record.epoch = num2str(epoch,'%02d');
    fname = tpfilename( record, 1, 1 );

    sfname=tpscratchfilename( record, 1, '*' );
    delete(sfname);
    sfname=tpscratchfilename( record, [], '*' );
    delete(sfname);


    if exist(fname,'file')
        delete(fname);
    end
    for f = 1 + (epoch-1)*n_frames_per_epoch: epoch*n_frames_per_epoch
        imwrite(data(:,:,f), fname,'tif','Compression','none','WriteMode','append');
    end
    disp(['Wrote testdata at ' fname ]);
end
return


