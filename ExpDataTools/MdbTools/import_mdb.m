function db=import_mdb( filename, table, crit )
%IMPORT_MDB imports records from MS Access database mdb file with filter
%
%   db=import_mdb( filename, table, crit )
%
%   example:
%      db=import_mdb( '','',...
%    'Transgene=''TLT 817''  and Cre like ''Kazu%'' and not Action=''dead'' ')
%
%    db = import_mdb([],[],'Action like \''alive\''');
%    db = import_mdb([],[],'Action like \''om af te voeren\''');
%    db = import_mdb([],[],'Action like \''alive\'' and \"KO/KI\" like \''R26TOM\''');
%
%   use SHOW_TABLE( DB ) to show table.
%
%  2006-2013, Alexander Heimel
%
%

mdbsql='/home/heimel/Software/mdbtools/mdbtools-0.6pre1/src/util/mdb-sql';
options=' -p -d , ';
defaultfilename = '/mnt/orange/group\ folders/MuizenlijstLeveltLab/Mice.mdb';

if nargin<3
  crit=[];
end
if nargin<2
  table=[];
end
if nargin<1
  filename=[];
end

if isempty(table)
  table='Mouse list';
end
if isempty(filename)
  filename = defaultfilename;
  if ~exist(filename,'file')
    filename='~/Documents/Mice/Mice.mdb';
    disp(['IMPORT_MDB: Using offline database ' filename ]);
  end
end
if isempty(crit)
  crit='Muisnummer\>15000';
end

table=['\"' table '\"'];

sql=['select \* from ' table];

if ~isempty(crit)
  sql=[sql ' where ' crit ];
end

disp(['IMPORT_MDB: Parsing: ' sql ]);

[s,w]=system(['echo ' sql  ]); %#ok<ASGLU>
disp(w);

[s,w]=system(['echo ' sql ' | ' mdbsql options filename] ); %#ok<ASGLU>


%w=w(1:1000);
w=split(w,10); % splits at CR

disp(w{1})
disp(w{2})
disp(w{3})
disp(w{4})
if length(w)<6
  disp('IMPORT_MDB: No records returned.');
  db=[];
  return;
end

fields = split(w{3});
fields = sanitize(fields);

disp(w{end-1});
w=split( {w{4:end-2}} );

while size(w,2)>length(fields)
  fields{end+1}=['field' num2str(length(fields)+1) ]; 
end


db=cell2struct(w,fields,2);

return

function f=sanitize(f)
for i=1:length(f(:))
  s=f{i};
  s( s=='/') = 'd';
  s( s==' ') = '_';
  f{i}=s;
end
