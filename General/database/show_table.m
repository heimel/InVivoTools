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
if isempty(db)
    errormsg('Table is empty.');
    return
end

data = transpose(squeeze(struct2cell(db)));
colnames = fieldnames(db);
  
for i=1:numel(data)
    switch class(data{i})
        case 'double'
            data{i} = num2str(data{i});
        case 'struct'
            data{i} = 'struct';
    end
end

t = uitable(h_fig, ...
    'Data', data, ...
    'ColumnName', colnames, ...
    'units','normalized',...
    'position',[ 0 0 1 1],...
    'RearrangeableColumns','on');

