function [Yn,Xn,Yerr] = slidingwindowfunc(X, Y, start, stepsize, stop, windowsize,func,zeropad,intervalfunc)

% SLIDINGWINDOWFUNC - Sliding window analysis for 1-dimensional data
%
%       [Yn,Xn,Yint] = SLIDINGWINDOWFUNC(X, Y, START, STEPSIZE, STOP, WINDOWSIZE,...
%             [FUNC='mean'],[ZEROPAD=0],[INTERVALFUNC='nanstderr'])
%
%  Slides a window of STEPSIZE across the data and performs
%  the function FUNC on the set of ordered pairs defined in
%  X and Y.  The window starts at location START and stops at
%  location STOP on X.  WINDOWSIZE determines the window size.
%
%  FUNC should be a string describing the function to be used.  For example:
%  'mean',  or 'median'.
%
%  If a third output argument is given, then the standard error of the mean
%  in each Xn bin is returned in Yint.  The user can optionally specify his
%  own interval function in INTERVALFUNC. The data to be analyzed are put
%  into a variable called 'y', so example INTERVALFUNC values are
%  'stderr(y)' or 'diff(prctile(y,[33 66]))'.
%
%
%  If ZEROPAD is 1, then a 0 is coded if no points are found within a given window.
%  If ZEROPAD is 0, and if no points are found within a given window, no Xn or Yn point
%     is added for that window.
%
%  Xn is the center location of each window and Yn is the result of the
%  function in each window.
%
%  Also see MOVMEAN
%
% 200X, Steve Van Hooser (?), 2016-2023 Alexander Heimel

if nargin<9 || isempty(intervalfunc)
    intervalfunc = 'nanstderr';
end
if nargin<8 || isempty(zeropad)
    zeropad = 0;
end
if nargin<7 || isempty(func)
    func = 'mean';
end
if nargin<6 || isempty(zeropad)
    zeropad = 0;
end
if nargin<3 || isempty(start)
    start = min(X);
end
if nargin<5 || isempty(stop)
    stop = max(X);
end
if nargin<4 || isempty(stepsize)
    stepsize = (stop-start)/100;
end


Xn = [];
Yn = [];
Yerr = [];

f = str2func(func);
intervalf = str2func(intervalfunc);

for i=start:stepsize:stop-windowsize
    INDs = find(X>=i & X<i+windowsize);

    if zeropad || ~isempty(INDs)
        Xn(end+1) = mean([i i+windowsize]);
    end
    if ~isempty(INDs)
        Yn(end+1) = f(Y(INDs));
        y = Y(INDs)';
        if nargout==3 
            Yerr(end+1) = intervalf(Y(INDs)');
        end
    end
    if zeropad && isempty(INDs)
        Yn(end+1) = 0;
        if nargout==3
            Yerr(end+1) = 0;
        end
    end
end

