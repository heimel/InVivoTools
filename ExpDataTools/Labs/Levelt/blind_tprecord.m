function blind_record = blind_tprecord( record )
%BLIND_TPRECORD blinds twophoton data record date and slice info
%
% see also UNBLIND_TPRECORD
%
% 2011, Alexander Heimel
%



blind_record = record;
padded_date = [record.date ':' record.slice ]; 
padded_date = char([padded_date 32*ones(1,16*ceil(length(padded_date)/16)-length(padded_date))]);
blind_record.date = strtrim(base64encode(CryptAES('encode',padded_date,'secret key')));
blind_record.slice = '';
