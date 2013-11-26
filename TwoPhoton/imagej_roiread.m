function roi = imagej_roiread(filename)
% (C) Moo K. Chung, mkchung@wisc.edu
% Program history Nov 12, 2007
% This code has been modified from the both Peter Cloeten's 
% <cloetens@esrf.fr> original Octave code and RoiDecoder.java in ImageJ package.
% 
%
% function roi = roiread(filename)
%
% INPUT
% filename: default filename extension is .roi
%
% OUTPUT
% roi: 2D array of coordinates.  
%
%  The oddity of the NIH .roi file format is that the coordinates are
%  stored with respect to the left most (X) and top most (Y) coordinates of roi.
%
% MATLAB   JAVA
% uint8    byte
% int16   short
% int32    int
% single  float

if ~exist('filename','var')
    filename = [];
end

if isempty(filename)
    help roiread;
    return;
end

if isempty(findstr(filename,'.'))
    % we add .roi for lazy people
    filename = [filename '.roi'];
end

fid = fopen(filename,'r','ieee-be'); %'IEEE floating point with big-endian byte ordering'
hd = fread(fid,8,'uint8');
% check that this is an ImageJ roi

if ~isequal(hd(1:2),[73 111]')
    printf('%s does not contain a valid ImageJ roi\n',filename)
    ret = [];
    return;
else
    switch hd(7)
        case 0
            ret =...
                struct('roitype','polygon','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 1
            ret =...
                struct('roitype','rectangle','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 2
            ret =...
                struct('roitype','ellips','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 3
            ret =...
                struct('roitype','line','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 4
            ret =...
                struct('roitype','freehandline','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 5
            ret =...
                struct('roitype','segmentedline','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 6
            ret =...
                struct('roitype','noroi','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 7
            ret =...
                struct('roitype','freehand','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 8
            ret =...
                struct('roitype','traced','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 9
            ret =...
                struct('roitype','angle','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        case 10
            ret =...
                struct('roitype','point','xycoords_lefttop',[],'xycoords_rightbottom',[]);
        otherwise
            ret =...
                struct('roitype','notyetimplemented','xycoords_lefttop',[],'xycoords_rightbottom',[]);
    end
    
    
    coord = fread(fid,5,'int16'); 
    top = coord(1);
    left = coord(2);
    bottom=coord(3);
    right = coord(4);
    width= right-left;
    height = bottom-top;
    
    %top and left are flipped from MATLAB convention.
    
    n = coord(5); % number of roi
    
    coord= fread(fid,inf,'int16'); 
     
    x=left + coord; % NIH roi format stored coordinates with respect to left and top coordinates
    y=top + coord;
    
    m=length(x);  
    x=x(m-2*n+1:m-n);  %reading backward
    y=y(m-n+1:m); 
    
    roi=[x y];
    
end;

        
        
        
        
        
        
        
        
        
        
        

