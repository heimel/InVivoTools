function [s,avg_img]=dofindcellsCR(s,iter,total_iters,varargin)
% docellfindCR: find cells and save params, for super-wrapper program
% From docellfindlistAKCR--  given mat files for avg_frm, find cells
% modelled after dofixcells.m
% varargin here could set: nbinning,save_flag,read_mat_file

global dataroot
global procroot
global matroot
global rootroot

  [procoutfname, matoutfname]= getoutfilenameNewCR(s); % standard calling with one matfile and one procfile  
  load([matoutfname,'_avg']);  %avg data
 % normalize for findcells:
 avtmp1=uint8(255*avg_img/(max(avg_img(:))));
 % find cells
 nf = 1 ; % index of structure s,  for backwards compatibility
 [labelimg,binarymask] = find_cellsAK(avtmp1,s,nf);
 shadeimg = shadecellsCR(avg_img, binarymask);
 figure;
 imshow(shadeimg);

 % get geometric info about cells
 [strr,centroid,diam,eccentricity,extent,majoraxis,minoraxis] = get_region_statsCR(labelimg);
 cellfname=[procoutfname,'_cells.mat'];
 save(cellfname,'labelimg','binarymask','strr','centroid','diam','eccentricity','extent','majoraxis','minoraxis' );  
 close all
