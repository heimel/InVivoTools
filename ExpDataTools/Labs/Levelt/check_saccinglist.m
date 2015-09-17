function [db,alivedb,sacdb] = check_saccinglist
%CHECK_SACCINGLIST checks the Levelt afvoerlijst / saccinglist for mice 
%
%  [DB,ALIVEDB,SACDB] = CHECK_SACCINGLIJST
%
% 2013-2015, Alexander Heimel
%

% crit = ['\(not Action like \''dead\''\) ' ...
%     ' and \(not Action like \''kwijt\''\) ' ...
%     ' and \(not Action like \''used\''\) ' ...
%     ' and \(not Action like \''sonja\''\) ' ...
%     ' and \(not Action like \''verhaagen\''\) ' ...
%     ' and \(not Action like \''wijnholds\''\) ' ...
%     ' and \(not Action like \''caroline\''\) ' ...
%     ' and \(not Action like \''od\''\) ' ...
%     ' and \(not Action like \''USA\''\) ' ...
%     ' and \(not Action like \''Nestler\''\) ' ...
%     ];

aftevoeren_str = 'om af te voeren';

crit = ['\(\(Action like \''alive\''\) or \(Action like \''' aftevoeren_str '\''\) or \(Action like \''inzetten%\''\)\)'];
%strains = ['\(Transgene like \''T5\''\)'];
%strains = [strains ' or \(Transgene like \''DBA\''\)'];
%strains = [strains ' or \(Transgene like \''DBA\''\)'];
%strains = [strains ' or \(Cre like \''Kazu\''\)'];

%crit = [crit ' and \(' strains '\)'];

db = import_mdb([],[],crit);
strains = '(Transgene=T5)|(Transgene=DBA)|(Transgene=*gcam*)|(KOdKI=GCamp3)|(KOdKI=R26TOM)|(Cre=GAD*)|(Cre=SST*)|(Cre=CR-Cre*)|(Cre=Kazu,Typing_KOdKI!hom*,Typing_KOdKI!het*)';
db = db(find_record( db,strains));

if isempty(db)
    logmsg('No records found. ');
    return
end

db = reorder_fields(db,[3 4 5 1]);
db = sort_db(db);

sacdb = db(find_record(db,['Action=' aftevoeren_str]));
hsac = show_table(sacdb);
set(hsac,'Name','Saccing');

alivedb = db(find_record(db,'Action=alive|Action=inzetten*'));
halive = show_table(alivedb);
set(halive,'Name','Alive');

