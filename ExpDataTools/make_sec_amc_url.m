function coded_url = make_sec_amc_url( url )
%MAKE_SEC_AMC_URL takes url and return secure amc adress
%
%     CODED_URL = MAKE_SEC_AMC_URL( URL )
%
% 2010, Alexander Heimel
%

chars = '0123456789.abcdefghijklmnopqrstuvwxyz';
shifts = [ -6   -11    -8     1     5     3    -3     4     3     0    -3     2    -2    -3     1    -3     0   -10 ]

url = strtrim(url);
p = find(url=='/',1);
if isempty(p)
    site = url;
    doc = '';
else
    site = url(1:p-1);
    doc = url(p:end);
end


% ugly but straightforward
for i = 1:length(site)
    site(i)
    shifts(i)
    
  ind = find(chars == site(i));    
  ind = mod(ind+shifts(i)-1,length(chars))+1;
  coded_url(i) = chars(ind);
end
coded_url(coded_url=='.')='-';
coded_url = ['https://c2-' coded_url '.sec.amc.nl' doc]