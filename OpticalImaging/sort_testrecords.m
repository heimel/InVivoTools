function newud=sort_testrecords( ud )
%SORT_TESTRECORD
%
%    NEWUD=SORT_TESTRECORD( UD )
%
% 2006, Alexander Heimel
%

newud=ud;

if isfield(ud.db,'test')
    newud.db=sort_db(ud.db,{'date','mouse','test'});
else 
    newud.db=sort_db(ud.db);
end

