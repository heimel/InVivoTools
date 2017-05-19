function [newtimes,frame2dirnum] = tpcorrecttptimes(records)
% TPCORRECTTPTIMES - Corrects time for twophoton files
%
%   [FRAMETIMES,FRAME2DIRNUM] = TPCORRECTTPTIMES(RECORDS)
%
%  Corrects the self-reported frame triggers two-photon 
%  scopes to be consistent with the clock on the acquisition machine.
%
% 200X, Steve Van Hooser
% 200X-2017, Alexander Heimel

tpsetup(records(1));

for i = 1:length(records)
    % use calibrated frametimes 
    params = tpreadconfig(records(i));
    newtimes{i} = params.frame_timestamp; %#ok<AGROW> % +starttime ;
    frame2dirnum{i} = ones(size(newtimes{i})); %#ok<AGROW>
end


return
