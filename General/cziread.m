function [img,info] = cziread(filename,scenenr,scalenr,channel)
%CZIREAD loads czi image
%
%  [IMG,INFO] = CZIREAD(FILENAME,SCENENR,SCALENR,CHANNEL,VERBOSE)
%
%      SCENENR starts at 0
%      SCALENR starts at 1, largest scale first
%      CHANNEL starts at 1
%
%  For INFO struct, see CZIINFO
%
% 2021, Alexander Heimel

if nargin<1 || isempty(filename)
    filename = '\\vs01\CSF_DATA\Shared\InVivo\Experiments\TAC1_Cfos_images\Jump_TMT\58172\Jacqueline_2021_03_26_0037_4-3.czi';
end
if nargin<2 || isempty(scenenr)
    scenenr = 0;
end
if nargin<3 || isempty(scalenr)
    scalenr = 1;
end
if nargin<4 || isempty(channel)
    channel = 1;
end

info = cziinfo(filename);

img = [];

inum = find( [info(:).scene] == scenenr & [info(:).scale] == scalenr);
if isempty(inum)
    disp('Could not find matching scene or scale number');
    return
end
if length(inum)>1
    disp('Found more than one matching scene and scale');
    return
end

%  load image
reader = bfGetReader(filename);
setSeries(reader,inum-1);
img =  bfGetPlane(reader, channel);
info = info(inum);

