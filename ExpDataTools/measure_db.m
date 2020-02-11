function fig=measure_db
%MEASURE_DB starts measure database (mainly for graphing purposes)
%
%  FIG=MEASURE_DB
%
% 2007, Alexander Heimel
%

[measuredb,filename]=load_measuredb;

[dbpath,dbfilename]=fileparts(filename);
dbfile=fullfile(dbpath,dbfilename);

h_fig=control_db(filename,[1 0 1]); % which will load the file again
set(h_fig,'Name','Measure database');

if nargout==1
    fig=h_fig;
end

left=10;
%buttonwidth=70;
colsep=3;
%buttonheight=30;
top=10;

% extra buttons:
ud=get(h_fig,'UserData');
h=ud.h;

%%

ud.h=h;
set(h_fig,'UserData',ud);

