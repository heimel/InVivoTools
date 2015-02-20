function available = dec_group_numbers( protocol, show )
%DEC_GROUP_NUMBERS returns the number of mice available on a dec protocol
%
% AVAILABLE = DEC_GROUP_NUMBERS( PROTOCOL, SHOW )
%
%    PROTOCOL is protocol number used in DEC_DB, e.g. 10.38
%    if SHOW is true, a msgbox is displayed with the results
%    AVAILABLE is vector with the number of mice in each group left over
%
% 2012, Alexander Heimel
%

db = []; % to mask matlab db function
protocol = strtrim(protocol);

load(fullfile(expdatabasepath,'decdb'));

decrecord = db(find_record(db,['protocol=' protocol]));
if isempty(decrecord)
    disp(['DEC_GROUP_NUMBERS: Can not find protocol ' protocol ' in dec_db database']);
    n_groups = 9;
    groupnumbers = zeros(1,n_groups);
else
    groupnumbers = decrecord.groupnumbers;
    n_groups = length(groupnumbers);
end


load(fullfile(expdatabasepath,'mousedb'));

for i=1:length(groupnumbers)
    ind = find_record(db,['mouse=' protocol '.' num2str(i,'%2d') '.*']);
    used(i) = length(ind);
end
available = groupnumbers - used;
msgbox(['Mice available: ' mat2str(available')],'Available');