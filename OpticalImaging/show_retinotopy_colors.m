function show_retinotopy_colors( record)
%SHOW_RETINOTOPY_COLORS
%
% 2014, Alexander Heimel
%

cols=retinotopy_colormap(record.stim_parameters(1), ...
    record.stim_parameters(2));
cols=cols(1:record.stim_parameters(1)*record.stim_parameters(2),:);
cols=uint8(round(cols*255));
image(permute(reshape(cols,record.stim_parameters(1),...
    record.stim_parameters(2),3),[2 1 3]));

axis image;
switch record.hemisphere
    case 'left'
        xlabel('nasal <-> temporal');
    case 'right'
        xlabel('temporal <-> nasal');
    otherwise
        xlabel('');
        logmsg(['Unknown hemisphere ' record.hemisphere ] );
end
ylabel('inferior <-> superior');
set(gca,'Xtick',[]);
set(gca,'ytick',[]);