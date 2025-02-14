function [data,t,discont,ndd] = get_data(dd, interval, warnon)

        if nargin<=2, warn = 0; else, warn = warnon; end;

        [data,dummy,discont] = get_data(dd.measureddata,interval,warn);

        inds=find(dd.time>=interval(1)&dd.time<=interval(2));

        data = dd.data(inds,:); t = dd.time(inds); ndd = dd; 
