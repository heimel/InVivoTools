function record = unblind_tprecord( blind_record )
%UNBLIND_TPRECORD unblinds twophoton data record date and slice info
%
% see also BLIND_TPRECORD
%
% DEPRECATED 
%
% 2011, Alexander Heimel
%


%record = blind_record;
%s = strtrim(char(CryptAES('decode',base64decode(blind_record.date),'secret key')'));
%record.date = s(1:find(s==':')-1);
%record.slice = s(find(s==':')+1:end);
