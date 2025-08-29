function newud = explore_session_callback( ud)
%explore_session_callback. Helper function to explore session data folder
%
%   NEWUD = explore_session_callback( UD )
%
% 2025, Alexander Heimel

newud = ud;

record = ud.db(ud.current_record);
datatype = record.datatype;

session_path_function = [datatype '_session_path'];

if exist(session_path_function,'file')
    pth = feval(session_path_function,record);
    system(['explorer.exe "' pth '"']);
end

