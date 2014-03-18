function fgm_add_fig_captions(n_types)
%FGM_ADD_FIG_CAPTIONS add figure label icons for figure-ground modulation figure
%
% FGM_ADD_FIG_CAPTIONS( N_TYPES )
%
% 2010, Alexander Heimel
%

persistent im

set(gca,'Xtick',[]);

xlim([0.25 0.5+n_types]);
switch n_types
    case {3,6,8}
        filename = ['label_fgm_figures_' num2str(n_types) 'types.png'];
    otherwise
        disp(['No label figure for n-types = ' num2str(n_types)]);
        return
end
fullname = fullfile(fileparts(which('fgm_add_fig_captions')),filename);
im = imread(fullname);
set(gca,'Xtick',[]);
smaller_font(-12);

p = get(gca,'position');

p(2) = max([p(2) 0.1]);
subplot('position',[p(1) 0 p(3) p(2)*0.9]);
image(im);
box off;
axis off
smaller_font(12);
