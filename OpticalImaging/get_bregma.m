function [x,y,fname]=get_bregma(ref_image,datapath,analysispath)
%GET_BREGMA reads bregma from file or point in image relative to reference 
%
%   [X,Y] = GET_BREGMA(REF_IMAGE,DATAPATH,ANALYSISPATH)
%   [X,Y] = GET_BREGMA(RECORD)
%
%  2005-2014, Alexander Heimel
%
x=[];
y=[];
fname='';

if nargin<3
    analysispath=[];
end
if nargin<2
    datapath=[];
end
if nargin<1
    return;
end

if isstruct(ref_image)
    record = ref_image;
    ref_image = record.ref_image;
    datapath = oidatapath(record);
    analysispath = 'analysis';
end

fname=ref_image;
if exist(fname,'file')
    fname=fullfile(datapath,ref_image);
end
if ~exist(fname,'file')
    fname=fullfile(datapath,analysispath,ref_image);
end
if ~exist(fname,'file')
    fname=fullfile(analysispath,ref_image);
end
if ~exist(fname,'file')
    logmsg(['Cannot find ' fname ]);
    return
end

ind = strfind(upper(fname),'BMP');
if isempty(ind)
    logmsg(['Reference image ' fname ' is not of type BMP.']);
    return
end

fnamebrg=fname;
fnamebrg(ind:ind+2)='BRG';

if ~exist(fnamebrg,'file')
    h=figure;
    img=imread(fname,'bmp');
    imagesc(img);
    axis image
    colormap gray
    set(gca,'units','pixels');
    
    disp('Click on bregma');
    [x,y]=ginput(1);
    x=round(x);
    y=round(y);
    disp(['GET_BREGMA: Clicked on ' num2str(x) ', ' num2str(y)]);
    save(fnamebrg,'x','y','-mat');
    close(h);
else
    load(fnamebrg,'-mat');
end

% disp(['Bregma: x=' num2str(x) ', y=' num2str(y) ' pxls on ' fname]);


