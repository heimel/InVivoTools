function db=b6frommdb
%B6FROMMDB loads b6 from mice database
%
%  2009, Alexander Heimel
%

db=import_mdb([],[],'transgene=\''B 6\'' and action=\''alive\''');
