function db = xls2db( fname, sheet, label_row) 
%XLS2DB import excel file to array of structs
%
% DB = XLS2DB( FNAME )
%
% uses XLS2VAR to do the work
%
% 2010, Alexander Heimel

var = xls2var( fname, sheet, label_row );

flds = fieldnames( var );
n_rows = length(var.(flds{1}));

for i = 1:n_rows
  for j = 1:length(flds)
      field = flds{j};
      try
          content = var.(field)(i);
      catch
          content = [];
      end
          while length(content)==1 && iscell(content)
          content = content{1};
      end
      db(i).(field) = content;
  end

end

end

