function h_fig = show_table( db, h_fig )
%SHOW_TABLE shows struct array as a table
%
% H_FIG = SHOW_TABLE( DB, H_FIG )
% 
% 2013, Alexander Heimel

if nargin<2
    h_fig = [];
end
if isempty(h_fig)
    h_fig = figure('Name','Table','NumberTitle','off','Menubar','none');
else
    figure(h_fig);
end

data = transpose(squeeze(struct2cell(db)));
colnames = fields(db);
  

t = uitable(h_fig, ...
    'Data', data, ...
    'ColumnName', colnames, ...
    'units','normalized',...
    'position',[ 0 0 1 1],...
    'RearrangeableColumns','on');

