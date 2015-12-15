function [cols,h]=retinotopy_colormap(n,m)
%RETINOTOPY_COLORMAP generates colormap for retinotopy
%
%  COLS=RETINOTOPY_COLORMAP(N,M)
%
%  2005, Alexander Heimel based on drawretinopy
%

if nargin<2
    m=1;
end

numstims = n * m;

cols = hsv(numstims);
purple=[0.7 0.2 0.6];
green=[0 0.7 0];
red=[1 0 0];
blue=[0 0 1];
white=[1 1 1];
gray=[0.7 0.7 0.7];
yellow=[0.95 0.95  0];
orange=[1 0.5 0];
dark_red=[0.7 0.3 0];


if numstims==4,
    cols(1,:)=red;
    cols(2,:)=green;
    cols(3,:)=blue;
    cols(4,:)=yellow;
    cols(5,:)=gray;
elseif numstims==6
    cols(1,:)=red;
    cols(2,:)=yellow;
    cols(3,:)=purple;
    cols(4,:)=green;
    cols(5,:)=orange;
    cols(6,:)=blue;
    cols(7,:)=gray;
elseif numstims==24
    cols( 1,:)=[0.9 0.0 0.0];cols( 2,:)=[1 0 0];cols( 3,:)=[1 0 1];
    cols( 4,:)=[0.8 0.1 0.4];cols( 5,:)=[0.7 0.2 0.6];cols( 6,:)=[0.5 0 0.4];
    cols( 7,:)=[0.2 0 0.7];cols( 8,:)=[0 0 1];cols( 9,:)=[0 0.5 0.8];
    cols(10,:)=[0 0.6 0.8];cols(11,:)=[0 0.8 0.8];cols(12,:)=[0 1 1];
    cols(13,:)=[0.6 0.9 0.4];cols(14,:)=[0.1 0.9 0.1];cols(15,:)=[0 1 0];
    cols(16,:)=[0 0.9 0];cols(17,:)=[0 0.8 0];cols(18,:)=[0 0.7 0.0];
    cols(19,:)=[1 1 0];cols(20,:)=[0.9 0.9 0];cols(21,:)=[1 0.5 0];
    cols(22,:)=[1 0.3 0];cols(23,:)=[0.8 0 0];cols(24,:)=[0.9 0 0];
% Changed by RR 2015-12-12; original commented out
% elseif numstims==24
%     cols( 1,:)=[0.71 0.51 0.8];cols( 2,:)=[0.41 0.33 0.73];cols( 3,:)=[0.31 0.37 0.78];
%     cols( 4,:)=[0.23 0.37 0.76];cols( 5,:)=[0.12 0.48 0.79];cols( 6,:)=[0.06 0.52 0.75];
%     cols( 7,:)=[0.09 0.67 0.79];cols( 8,:)=[0.05 0.71 0.41];cols( 9,:)=[0.09 0.62 0.31];
%     cols( 10,:)=[0.28 0.63 0.31];cols( 11,:)=[0.44 0.61 0.26];cols( 12,:)=[0.57 0.67 0.29];
%     cols( 13,:)=[0.72 0.76 0.32];cols( 14,:)=[0.74 0.68 0.24];cols( 15,:)=[0.8 0.66 0.24];
%     cols( 16,:)=[0.89 0.67 0.23];cols( 17,:)=[0.89 0.6 0.22];cols( 18,:)=[0.88 0.49 0.2];
%     cols( 19,:)=[0.89 0.39 0.21];cols( 20,:)=[0.9 0.23 0.2];cols( 21,:)=[0.91 0.17 0.2];
%     cols( 22,:)=[0.84 0.16 0.32];cols( 23,:)=[0.82 0.17 0.56];cols( 24,:)=[0.74 0.22 0.73];
elseif numstims==9
    cols(1,:)=red;         cols(2,:)=yellow;    cols(3,:)=purple;
    cols(4,:)=green;       cols(5,:)=orange;    cols(6,:)=blue;
    cols(7,:)=dark_red;    cols(8,:)=gray;      cols(9,:)=[0.75 0.5 0.0];
elseif numstims==8,
    cols(4,:) = green; cols(7,:)=purple;
    cols(1,:) = [0.7 0.3 0]; % dark red
    cols(6,:) = [0.2 0.2 0.7];
    cols(3,:) = [0.75 0.5 0.0];
elseif n==3 && m==5,
    
    cols( 1,:)=[0.9 0.0 0.0];cols( 2,:)=[0.8 0.5 0.0];cols( 3,:)=[0.7 0.8 0.0];
    cols( 4,:)=[0.8 0.1 0.4];cols( 5,:)=[0.7 0.6 0.4];cols( 6,:)=[0.6 0.9 0.4];
    cols( 7,:)=[0.5 0.0 0.4];cols( 8,:)=[0.4 0.5 0.4];cols( 9,:)=[0.4 0.8 0.4];
    cols(10,:)=[0.2 0.0 0.7];cols(11,:)=[0.1 0.5 0.6];cols(12,:)=[0.1 0.8 0.6];
    cols(13,:)=[0.0 0.0 0.9];cols(14,:)=[0.0 0.5 0.8];cols(15,:)=[0.0 0.8 0.8];
elseif n==4 && m==6,
    
    cols( 1,:)=[0.9 0.0 0.0];cols( 2,:)=[0.8 0.5 0.0];cols( 3,:)=[0.8 0.1 0.4];
    cols( 4,:)=[0.7 0.8 0];cols( 5,:)=[0.7 0.6 0.4];cols( 6,:)=[0.6 0.9 0.4];
    cols( 7,:)=[0.5 0.0 0.4];cols( 8,:)=[0.4 0.5 0.4];cols( 9,:)=[0.4 0.8 0.4];
    cols(10,:)=[0.2 0.0 0.7];cols(11,:)=[0.1 0.5 0.6];cols(12,:)=[0.1 0.8 0.6];
    cols(13,:)=[0 0.8 0.8];cols(14,:)=[0 0.6 0.8];cols(15,:)=[0.0 0.8 0.8];
    cols(16,:)=[0.0 0.4 0.8];cols(17,:)=[0.0 0.6 0.8];cols(18,:)=[0.0 0.8 0.8];
    cols(19,:)=[0.0 0.0 0.9];cols(20,:)=[0.0 0.5 0.8];cols(21,:)=[0.0 0.8 0.8];
    cols(22,:)=[0.0 0.0 0.9];cols(23,:)=[0.0 0.5 0.8];cols(24,:)=[0.0 0.8 0.8];
elseif numstims==12
    colorz = colormap('jet');
    for tmp=1:12
        cols(tmp,:)=colorz(5*tmp,:);
    end
%cols
else
   % cols = [prism(numstims); 0.7 0.7 0.7];
 %cols = hsv(numstims);
end;
%  colormap(cols)
% cols = [prism(numstims); 0.7 0.7 0.7];
% cols = hsv(numstims);

%cols = prism(numstims);

if nargout==2
    h=figure;
    image(reshape((1:numstims),n,m)');
    axis image
    axis off
    colormap(cols)
end
