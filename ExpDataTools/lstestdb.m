function h_fig = lstestdb
%LSTESTDB opens database with Friederieke's linescan info
%
%  H_FIG = LSTESTDB
%  
%
% 2010, Alexander Heimel
%

h_fig = experiment_db('ls');

ud=get(h_fig,'UserData');
disp('TPLINESCANDB: resetting process parameters');
for i=1:length(ud.db)
    ud.db(i).process_params = tpprocessparams(ud.db(i));
end
set(h_fig,'Userdata',ud);


