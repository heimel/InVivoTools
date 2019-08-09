function [mousepos,tailbase,snout,stimpos,mouseBoundary] = get_mouse_position(Frame,bg,par,hfig,screenrect )
%GET_MOUSE_POSITION gets mouse centroid, tail, snout, stim in pixels
%
%  [POS,TAILBASE,SNOUT,STIMPOS] = get_mouse_position( FRAME_BG_SUBSTRACTED, PAR, HFIG )
%
% 2017, Laila Blomer
% 2019, adapted by Alexander Heimel

if nargin<4 || isempty(screenrect)
    % taking full frame as screen rectangle
    screenrect = [0 0 size(Frame,2) size(Frame,1)];
end

if nargin<3
    hfig = [];
end

if nargin<2 || isempty(par)
    par.minAreaSize = 200; % pxl, Minimal area for region that is tracked as mouse
    par.minMouseSize = 50^2; % pxl, Minimal area a mouse could be
    par.minStimSize = 10; % pxl, Minimal area for region that might be stimulus
    par.tailWidth = 12; % pxl
    par.tailToMiddle = 70; % pxl
    par.minComponentSize = 10; % pxl, Consider smaller components as noise
    par.dilation = ones(5); % for image dilation
end

bg = double(bg);
frame_bg_subtracted = bg - double(Frame);
frame_bg_subtracted = abs(frame_bg_subtracted);
frame_bg_subtracted = frame_bg_subtracted ./ (bg + 40);


% frame_bg_subtracted = bg16 - int16(Frame);
% frame_bg_subtracted = abs(frame_bg_subtracted);
% frame_bg_subtracted = double(frame_bg_subtracted);
% frame_bg_subtracted = frame_bg_subtracted ./ (double(bg16) + 40);

par.blackThreshold = 0.3;

blackThreshold = par.blackThreshold;

mousepos = [NaN NaN];
stimpos = [NaN NaN];
tailbase = [NaN NaN];
snout = [NaN NaN];

pos = [];

frame_bg_subtracted = max(frame_bg_subtracted,[],3);

if ~isempty(hfig)
    imagesc(frame_bg_subtracted);
    colormap gray
end


while (isempty(pos) || max([pos.Area])<par.minAreaSize || sum([pos.Area])<par.minMouseSize) && blackThreshold>0.01
    
    % threshold
    imbw = frame_bg_subtracted> blackThreshold;
    imbw = imclose(imbw,par.dilation);
    
    % remove small components
%     imbw = bwareaopen(imbw, par.minComponentSize);
    
    % Find mouse position
    pos = regionprops(imbw, 'Centroid', 'Area');
    
    blackThreshold = 0.9*blackThreshold;
end

% threshold
imbw = frame_bg_subtracted> blackThreshold;
imbw = imclose(imbw,par.dilation);


% boundary = bwboundaries(imbw);
% if ~isempty(hfig)
%     hold on
%      for i = 1:length(boundary)
%          plot(boundary{i}(:,2),boundary{i}(:,1),'w')
%     end
% end

% remove small components
mouse = bwareaopen(imbw, par.minComponentSize);

pos = regionprops(mouse, 'Centroid', 'Area');
if isempty(pos)
    logmsg('Could not find any changed components');
    return
end

% get mouse center
indmouse = find([pos.Area]>par.minAreaSize);
posCentroids = [pos(indmouse).Centroid];
mousepos = [ posCentroids(1:2:end)*[pos(indmouse).Area]'/sum([pos(indmouse).Area]), ...
    posCentroids(2:2:end)*[pos(indmouse).Area]'/sum([pos(indmouse).Area])];

% get stim center
indstim = find([pos.Area]<par.minAreaSize & [pos.Area]>par.minStimSize);
if ~isempty(indstim)
    if length(indstim)>1 % more than one fits the size criteria
        % then find the one closest to the horizontal midline of the screen
        posCentroids = [pos(indstim).Centroid];
        posCentroids = reshape(posCentroids,2,length(indstim))';
        [~,indind] = min(abs(posCentroids(:,2)- (screenrect(2)+screenrect(4)/2)));
        indstim = indstim(indind);
    end
    stimpos = pos(indstim).Centroid ;
    if ~isempty(hfig)
        plot(stimpos(1),stimpos(2),'ro');
    end
end



% Mouse boundaries
% Get mouse boundaries
% design new binary image with 1 shape, the mouse. Also make new
% mouseBoundaries
boundary = bwboundaries(mouse);
[M, N] = size(mouse);
mouseBinary = false(size(mouse));
for i = indmouse
    mouseBinary = mouseBinary | poly2mask(boundary{i}(:,2), boundary{i}(:,1), M, N);
end
mouseBoundary = bwboundaries(mouseBinary);

if ~isempty(hfig)
    hold on
    for i = 1:length(mouseBoundary)
        plot(mouseBoundary{i}(:,2),mouseBoundary{i}(:,1),'y')
    end
    hold off
end

br = 5;
while length(mouseBoundary)>1 && br<30 % grow until single component
    se = strel('disk',br);
    mouseBinary = imclose(mouseBinary,se);
    mouseBoundary = bwboundaries(mouseBinary);
    br = br + 5;
end
A = cellfun('size', mouseBoundary, 1);
[~, ind] = max(A);
mouseBoundary = mouseBoundary{ind};
row = size(mouseBoundary,1);

%mouseBinary = bwmorph(mouseBinary, 'bridge', Inf);
%mouseBinary = bwmorph(mouseBinary, 'thicken');


if ~isempty(hfig)
    hold on
    plot(mouseBoundary(:,2),mouseBoundary(:,1),'c')
    hold off
end

% Find tail
% find farthest geodesic point from mouse position and check if it is far
% enough from mouse centre.
D = bwdistgeodesic(mouseBinary, floor(mousepos(1)), floor(mousepos(2)), 'quasi-euclidean');
posTails = D(:);

[num,indD] = max(posTails);
if isnan(num) || (num == 0)
    tailNotFound = true;
else
    [ytailtip,xtailtip] = ind2sub(size(D),indD);
    if pdist([mousepos; [xtailtip, ytailtip]]) < par.tailToMiddle
        % tailtip too close to centroid
        tailNotFound = true;
    else
        tailNotFound = false;
    end
end

if tailNotFound
    %logmsg('Did not find tail');
    return
end

if ~isempty(hfig)
    hold on
    plot(xtailtip,ytailtip,'r*');
    hold off
end


% take snout at the point furthers away from the tail tip
D = bwdistgeodesic(mouseBinary, xtailtip, ytailtip, 'quasi-euclidean');
posSnout = D(:);
[~,indD] = max(posSnout);
[snout(2),snout(1)] = ind2sub(size(D),indD);

if ~isempty(hfig)
    hold on
    plot(snout(1),snout(2),'gx');
    hold off
end


% Compute distance between found tail and every point of mouseBoundary
% to get the coordinate with the minimum distance, which should be the tip
np = length(mouseBoundary(:,1));
Pp = [ytailtip xtailtip];

% matrix of distances between all points and all vertices
dpv(:,:) = hypot((repmat(mouseBoundary(:,1)', [np 1])-repmat(Pp(:,1), [1 1])),...
    (repmat(mouseBoundary(:,2)', [np 1])-repmat(Pp(:,2), [1 1])));

% Find the vector of minimum distances to vertices.
[~, index] = min(abs(dpv),[],2);
ind = index(1);
firstInd = ind;
left = ind;
right = ind;
halfway = round(mod(ind + (row / 2), row));

% Beginning of tail
% Look for beginning of tail by following the mouse boundary untill
% distance between the two sides become larger than tailWidth.
beginFound = false;
while ~beginFound && ~tailNotFound
    left = mod((left + row - 2), row) + 1;
    right = mod(right, row) + 1;
    dist = pdist([mouseBoundary(left,:); mouseBoundary(right,:)]);
    if dist > par.tailWidth
        beginFound = true;
        ind = right;
    elseif (left == halfway) || (right == halfway)
        tailNotFound = true;
    end
end

if tailNotFound % did not find tail base
    return
end

% Separate tail and body
% Check if the end of the mouseBoundary is passed or not. Based on this,
% devide the mouse in the binary image in the body and the tail

passEnd = 0;
if ind > firstInd
    dif = ind - firstInd;
    tailB = mod(firstInd - dif, row);
    tailE = ind;
    if tailB == 0
        tailB = 1;
    end
else
    dif = firstInd - ind;
    tailB = ind;
    tailE = mod(firstInd + dif, row);
    if tailE == 0
        tailE = row;
    end
end

if tailB > tailE
    passEnd = true;
end

% separate tail and body
if passEnd
    fulltail = vertcat(mouseBoundary(tailB:end, :),mouseBoundary(1:tailE, :));
    rest = mouseBoundary(tailE:tailB, :);
else
    fulltail = mouseBoundary(tailB:tailE, :);
    rest = vertcat(mouseBoundary(tailE:end, :), mouseBoundary(1:tailB, :));
end

% Find new tail and mouse positions

% new tail position
tailbase(1) = mean([fulltail(1,2)  fulltail(end,2)]);
tailbase(2) = mean([fulltail(1,1)  fulltail(end,1)]);

if ~isempty(hfig)
    hold on
    plot(tailbase(1),tailbase(2),'rx');
    hold off
end

% new mouse binary mask
tailBinary = poly2mask(fulltail(:,2), fulltail(:,1), M, N);
mouseNew = poly2mask(rest(:,2), rest(:,1), M, N);

% if there are multiple shapes in the binary image, make a new image
% with only the largest shape
temp = bwconncomp(mouseNew);
if temp.NumObjects > 1
    numPixels = cellfun(@numel,temp.PixelIdxList);
    [~ ,idx] = max(numPixels);
    temp2 = zeros(size(mouse));
    temp2(temp.PixelIdxList{idx}) = 1;
    mouseNew = logical(temp2);
end

% only if the body is bigger than the tail, take the new mouse position
% from the centre of the body.
if (sum(tailBinary(:)) < sum(mouseNew(:)))
    posNew = regionprops(mouseNew, 'Centroid');
    mousepos = posNew.Centroid;
end

if ~isempty(hfig)
    hold on
    plot(mousepos(1),mousepos(2),'bo');
    hold off
end
