function filename=save_figure(filename,path,h)
%SAVE_FIGURE saves figures in png format (cropped)
%
%  SAVE_FIGURE(FILENAME,PATH,H)
%
% 200X-2020, Alexander Heimel

if nargin<2
    path='';
end
if nargin<3
    h=[];
end
if isempty(h)
    h=gcf;
end

filename=lower(subst_filechars(filename));

if strcmp(filename(max(1,end-3):end),'.png')==1 
    filename=filename(1:end-4); % remove png extension
end

path=compose_figurepath(path);

savewd=pwd;
if ~exist(path,'dir')
    logmsg([ path ' does not exist. Saving to desktop']);
    path = getdesktopfolder;
end
cd(path);
if  isunix && ~ismac
    savefig_gs([filename '.png'],h,'png'); % to avoid missing fonts
    % alternative
    % frame = getframe(h);
    % imwrite(frame.cdata,[filename '.png']);
else % windows or max (assume absence of ghostscript)
    saveas(h,[filename '.png'],'png');
    saveas(h,[filename '.pdf'],'pdf');
end
filename = fullfile(path,filename);
cd(savewd);

filename=[filename '.png'];
logmsg(['Figure saved as ' filename ' (bitmap) and as pdf/eps (vector graphics)']);
