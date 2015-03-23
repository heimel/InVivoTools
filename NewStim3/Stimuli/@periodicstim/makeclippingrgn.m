function [img_rgba, destrect, ds_userfields] = makeclippingrgn(PSstim)

% MAKECLIPPINGRGN - Make a clipping region for a periodicstim
%
%  [CLIP_IMAGE, DEST_RECT, DS_USERFIELD] = MAKECLIPPINGRGN(PSSTIM)
%
%  This function returns the elements necessary for the clipping region
%  (that is, mask region) that LOADSTIM can use for its displaystruct
%  object.  See 'help periodicstim' for the meanings of the windowShape
%  parameter.
%
%  See also: PERIODICSTIM/LOADSTIM, DISPLAYSTRUCT

NewStimGlobals; % for pixels_per_cm
PSparams = PSstim.PSparams;

if exist('NewStimViewingDistance','var') && ~isempty(NewStimViewingDistance)
    PSparams.distance = NewStimViewingDistance;
end


rect = PSparams.rect;  % this is the rect requested by the user
width=rect(3)-rect(1); height=rect(4)-rect(2);

if isfield(PSparams,'size') && ~isnan(PSparams.size) % use size to determine rect
    center = [ (rect(1)+rect(3))/2 (rect(2)+rect(4))/2 ];
    width = 2 * PSparams.distance * tan( PSparams.size /2 /360*2*pi) * pixels_per_cm ;
    height = 2 * PSparams.distance * tan( PSparams.size /2 /360*2*pi) * pixels_per_cm ;
    rect(1) = center(1) - width/2;
    rect(3) = center(1) + width/2;
    rect(2) = center(2) - height/2;
    rect(4) = center(2) + height/2;
end


% where are we going to draw on the screen?
[spatialphase, pixelIncrement, wLeng, destrect, width_offscreen, height_offscreen] = spatial_phase(PSstim);

%  width_offscreen = ceil(sqrt(2)*width_offscreen);
%  height_offscreen = ceil(sqrt(2)*height_offscreen);

width_offscreen = ceil(sqrt(width_offscreen^2+height_offscreen^2 )) ;
height_offscreen = width_offscreen;


destrect = CenterRect([0 0 width_offscreen height_offscreen],rect);

frames = temporal_phase(PSstim);

% assume width_offscreen == height_offscreen

%[X,Y] = meshgrid( int16((1:width_offscreen)-width_offscreen/2) , int16([1:height_offscreen]-height_offscreen/2));
% center = [width_offscreen/2 height_offscreen/2];
% [X,Y] = meshgrid( single((1:width_offscreen)-center(1)) ,...
%     single((1:height_offscreen)-center(2))  );

center = [width_offscreen/2 height_offscreen/2];
X = meshgrid( single((1:width_offscreen)-center(1)) ,...
    single((1:height_offscreen)-center(2))  );

colors = pscolors(PSstim);

clear ds_userfields;

% img_rgba = cat(3,repmat(uint8(colors.backdropRGB(1)),width_offscreen,height_offscreen),...
% 	repmat(uint8(colors.backdropRGB(2)),width_offscreen,height_offscreen),...
% 	repmat(uint8(colors.backdropRGB(3)),width_offscreen,height_offscreen));




switch (PSparams.windowShape),
    case {0,2,4,6}, % rectangle
        img_alpha = uint8( 1-(abs(X)<=height/2 & abs(X')<=width/2));
    case {1,3,5,7}, % oval
        %		img_rgba(:,:,4) = uint8( 1-(((X.^2)/((height/2)^2) + (Y.^2)/((width/2)^2) ) <=1 ));
        img_alpha = uint8( 1-(((X.^2)/((height/2)^2) + (X'.^2)/((width/2)^2) ) <=1 ));
        %		img_rgba(:,:,4) = uint8( ~( ((X.^2)*((width/2)^2) + (Y.^2)*((height/2)^2) ) <= ((width/2)^2)*((height/2)^2) ));
    case 8, % gaussian
        sigma_x = 0.33*width/sqrt(8*log(2));
        sigma_y = 0.33*height/sqrt(8*log(2));
        gauss_img = 1-exp(-( (X.^2)/(2*sigma_x.^2) + (X'.^2)/(2*sigma_y.^2) ) );
        img_alpha = uint8(255*gauss_img);
end;


% angles
switch (PSparams.windowShape),
    case {0,1}, % oriented with screen
        ds_userfields.Movie_angles = repmat(90,1,length(frames));
    case {2,3,6,7,8}, % oriented with grating
        %        ds_userfields.Movie_angles = repmat(90-PSparams.angle,1,length(frames));
        % changed 2013-08-12
        ds_userfields.Movie_angles = repmat(90+PSparams.angle,1,length(frames));
%     case {6,7, 8}, % oriented with grating
%         ds_userfields.Movie_angles = repmat(90-PSparams.angle,1,length(frames));
    case {4,5}, % oriented 90 degrees shifted
        ds_userfields.Movie_angles = repmat(180-PSparams.angle,1,length(frames));
end;

switch(PSparams.windowShape),
    case 6, % remove rectangular aperture
        img_alpha = img_alpha + uint8( (abs(X)<=0.5*PSparams.aperture(2) & abs(X')<=0.5*PSparams.aperture(1)));
    case 7, % remove oval aperture
        img_alpha = img_alpha + uint8( (((X.^2)/((0.5*PSparams.aperture(2))^2) + (X'.^2)/((0.5*PSparams.aperture(1))^2))<=1    ) );
        %img_rgba(:,:,4) = img_rgba(:,:,4) + uint8( (((X.^2)*((0.5*PSparams.aperture(1))^2) + (Y.^2)*((0.5*PSparams.aperture(2))^2))<=((0.5*PSparams.aperture(1))^2)*((0.5*PSparams.aperture(2))^2)));
end;

if PSparams.windowShape~=8,  % have to exclude gaussian window because we already multiplied by 255 in that case
    img_alpha = img_alpha*255;
end

clear('X');

img_rgba = zeros(width_offscreen,height_offscreen,4,'uint8');
img_rgba(:,:,1) = repmat(uint8(colors.backdropRGB(1)),width_offscreen,height_offscreen);
img_rgba(:,:,2) = repmat(uint8(colors.backdropRGB(2)),width_offscreen,height_offscreen);
img_rgba(:,:,3) = repmat(uint8(colors.backdropRGB(3)),width_offscreen,height_offscreen);
img_rgba(:,:,4) = img_alpha;
