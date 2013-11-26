function num=datenumber( isodate)
%DATENUMBER returns datenumber of date of form '2005-03-02'
%
%   NUM=DATENUMBER( ISODATE)
%  
% 2005, Alexander Heimel
%
  
  num=datenum(str2num(isodate(1:4)),str2num(isodate(6:7)),str2num(isodate(9:10)));
