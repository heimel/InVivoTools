function [data,t,discont,nmd] = get_data (measureddata, interval, warnon)

%  [DATA,TIME,DISCONT, NMD] = GET_DATA(MEASUREDDATA,INTERVAL, WARN)
%
%    Retrieves a piece of data from the measureddata object MEASUREDDATA
%    between times specified in the 1x2 matrix INTERVAL.  WARN specifies
%    how the function should handle a request that lies outside the object's
%    own record of when the data was measured (i.e., the 'interval'
%    field of the measureddata object--see 'help measureddata').
%       WARN == 0 or absent => give an error
%       WARN == 1           => give a warning, and return 0's where data
%                                  was not measured
%       WARN == 2           => give neither warning nor error message, and
%                                  return 0's where data was not measured
%
%    If applicable, TIME will be the time of each sample in data, and
%    DISCONT will be 1 if there is a discontinuity in the data returned.
%    NMD is the new associated object.

   % determine whether bounds are exceeded

     if nargin<=2
         warn = 0; 
     else
         warn = warnon; 
     end

     if ~isempty(measureddata.intervals),
       check1 = ones(size(measureddata.intervals));
       check2 = check1;

       check1(interval(1)<measureddata.intervals) = 0;
       check2(interval(2)<=measureddata.intervals) = 0;

       s1 = sum(check1); s2 = sum(check2);
       if (s1~=s2)
           discont = 1;
       else
           discont = 0; 
       end;
     else
         discont = 1;
     end; 

     if discont && (warn==0)
         error(['get_data error: data not sampled ' ...
                                 'over entire requested interval.']); 
     end;
     if discont && (warn==1)
         warning(['get_data: data not sampled ' ...
                                 'over entire requested interval.']); 
     end;

     data = [];
     t = [];
     nmd = measureddata;
