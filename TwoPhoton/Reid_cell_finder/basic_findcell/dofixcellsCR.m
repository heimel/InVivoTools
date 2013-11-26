    function dofixcellsCR(s,iter,total_iters,varargin)
% do a generic calculation given input s, structure from listfile, with new
% directories
global dataroot
global procroot
global matroot
global rootroot
  % this is a hardcoded name of a new directory that is created in rootroot...
  % perhaps it can be passed as a varargin argument later....
  procroot1=[  rootroot,'\dataproc1'];
  mkcommand=['!mkdir ',procroot1];
  eval(mkcommand);
  [procoutfname, matoutfname,procoutfname1]= getoutfilenameNewCR(s,procroot1); % standard calling with one matfile and one procfile  
  load([procoutfname,'_cells.mat']);  %get cell definitions and info
  load([matoutfname,'_avg']);  %avg data

avg_img = double(avg_img);
avg_img = uint8(255*avg_img/(max(avg_img(:))));

answer = {};
repeat = false;
while (size(answer) == [0 0])
if repeat    
    [labelimg, binarymask, adapt] = fix_cellsAK (avg_img, binarymask, s, 1, adapt);
else
    [labelimg, binarymask, adapt] = fix_cellsAK (avg_img, binarymask, s);
end
% Open original image in ImageJ for inspection
% set the Java user directory to the ImageJ root so that ImageJ can load standard plugins and macros
disp('Initializing ImageJ for inspection of original image'); 
wd = java.lang.System.getProperty('user.dir');
java.lang.System.setProperty('user.dir', 'C:\Program Files\ImageJ');
% create an instance of ImageJ 
IJ = ij.ImageJ;
% convert the original image array to ImagePlus object and display it  
avg_imgij = array2ijAK(avg_img);
avg_imgij.show;

% show current cell mask
HM = figure;
imshow(binarymask);
title('Fixed Mask'); 

shadeimg = shadecellsCR(adapt, binarymask);
% show shaded image
HS = figure;
imshow(shadeimg);
title('Shaded'); 

% ask if cell mask is satisfactory
answer = inputdlg('If you are ''at the end of happiness'' press OK. Otherwise press Cancel to continue mask modification.','Satisfactory?',1,{'{Ignore this textbox}'},'on');
close(HM);
close(HS);

% Close ImageJ
avg_imgij.hide;
ij.WindowManager.closeAllWindows;
IJ.quit;
% reset java user directory to original value
java.lang.System.setProperty('user.dir', wd);
repeat = true;
end

 % save new cell info into procroot1 (a whole new tree of data/result directories).
 [strr,centroid,diam,eccentricity,extent,majoraxis,minoraxis] = get_region_statsCR(labelimg);
 save([procoutfname1,'_cells.mat'],'labelimg','binarymask','strr','centroid','diam','eccentricity','extent','majoraxis','minoraxis' );  
 
 
disp('Paused. Press any key to continue...');
pause