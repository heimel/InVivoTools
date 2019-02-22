function stack = imregisterstack(stack)
%IMREGISTERSTACK aligns the images from a stack using imregcorr (translation only)
%
% STACK = IMREGISTERSTACK( STACK )
%
% matlab register functions can only register two images at a time
% imregister has no transformation output so cannot be used properly
% imregcorr has a transformation matrix as output so the only suitable way to do it currently
%
% input and output are 3D arrays
% each layer is registered to the layer above and the resulting translations
% are saved. then for each layer, all transformation of above layers are added
% to its own translation to get the resulting output
%
% 2018, Tobias van der Bijl

start = tic;

tform = affine2d;

out = stack;

% start registration from the center to optimize the amount of data that is kept
middleOfStackIndex = round(size(stack,3)/2);

% second half
for i = (middleOfStackIndex+1):size(stack,3)
    tform(i) = imregcorr(stack(:,:,i),stack(:,:,i-1),'translation');    
    tform(i).T(3,1:2) = tform(i).T(3,1:2) + tform(i-1).T(3,1:2);
    out(:,:,i) = imwarp(stack(:,:,i), tform(i), 'OutputView', imref2d(size(stack(:,:,1))));     
end

% first half
for i = (middleOfStackIndex-1):-1:1
    tform(i) = imregcorr(stack(:,:,i),stack(:,:,i+1),'translation');    
    tform(i).T(3,1:2) = tform(i).T(3,1:2) + tform(i+1).T(3,1:2);
    out(:,:,i) = imwarp(stack(:,:,i), tform(i), 'OutputView', imref2d(size(stack(:,:,1))));     
end

logmsg(['Returned in ', num2str(round(toc(start))), ' seconds'])

stack = out;


% old version with problems

% imregister for a volume using each previous image to register to
% align image 2 to 1, 3 to 2, etc.
% problems, doing it one by one starting from the first creates an increasing
% registration distance which causes misalignment with large stacks / large artefacts
% function stack = imregisterStack(stack, option)
% start = tic;
% 
% % handle input
% if ~exist('option', 'var') || isempty(option)
%    option = 'rigid'; 
% end
% 
% % settings
% [optimizer, metric] = imregconfig('monomodal');
% % optimizer.MaximumIterations = 100;
% 
% w = progressBar(size(stack,3));
% for i = 2:size(stack,3)
%     stack(:,:,i) = imregister(stack(:,:,i), stack(:,:,i-1), option, optimizer, metric);
%     w.iterator = i;
% end
% 
% disp([mfilename, ' returned in ', num2str(round(toc(start))), ' seconds'])
% 
