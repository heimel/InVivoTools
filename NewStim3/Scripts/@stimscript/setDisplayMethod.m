function A = setDisplayMethod(S, newmethod, methodarg, trigger)

% A = SETDISPLAYMETHOD(S,NEWMETHOD,METHODARG,TRIGGER)
%
%   Sets the display order for this stimscript.  A is the new script
%   returned, and S is the script to be modified.  NEWMETHOD describes the
%   method to use.  0 means display stimuli sequentially, 1 means display
%   the stimuli in random order, and 2 means the user will provide the order
%   explicitly in the vector METHODARG.  If NEWMETHOD is 0 or 1, then METHODARG
%   is the number of times to repeat the stimuli.
%
%   A note about random order of stimulus presentation:  the stimuli are all
%   presented in a random order METHODARG times, and the last stimulus in a
%   sequence will not be the first in the next sequence so it is guarenteed that
%   a given stimulus will not be presented twice in a row.
%
%   TRIGGER can be numeric, 'none' (default), 'all', or 'interleaved' and will set
%   the trigger field in the script accordingly. 'interleaved' will make
%   every stimulus to be shown twice, once with trigger, once without. The
%   order of this will change with every repetition. If TRIGGER is a single
%   numeric value, then this will be set for all stimuli.
%
%   See also:  STIMSCRIPT, GETDISPLAYORDER, NUMSTIMS
%                               Questions to  vanhoosr@brandeis.edu
%
%   200X Stephen VanHooser
%   200X-2015, Alexander Heimel
%

if nargin<4 || isempty(trigger)
    trigger = 'none';
end

methodarg = fix(methodarg);

switch(newmethod)
    case 0
        if methodarg>0
            S.displayOrder = repmat(1:numStims(S),1,methodarg);
        else
            error('METHODARG must be greater than 0.');
        end
    case 1
        if methodarg>0
            N = numStims(S);
            if N>1
                p = 0:1/(N-1):1;
            else
                p=[];
            end
            dO = randperm(N);
            for i=2:round(methodarg)
                if N==1
                    dO = [ dO 1 ]; %#ok<AGROW>
                else
                    r = rand(1,1);
                    n=[ 1:dO(end)-1 dO(end)+1:N];
                    n=n(p(1:end-1)<r&p(2:end)>=r);
                    d=[ 1:n-1 n+1:N ];
                    di = randperm(N-1);
                    dO = [dO n d(di)]; %#ok<AGROW>
                end
            end
            S.displayOrder = dO;
        else
            error('METHODARG must be greater than 0.');
        end
    case 2
        methodarg= fix(methodarg);  % make sure integer
        if (min(methodarg)>=1)&&(max(methodarg)<=numStims(S))
            S.displayOrder = methodarg;
        else
            error(['Error in setDisplayMethod: elements of ' ...
                'METHODARG should run 1..numStims.']);
        end
    otherwise
        error('Error in setDisplayMethod: unknown method.');
end
logmsg(['Display order: ' mat2str(S.displayOrder)]);

S = setTrigger( S, trigger );

A = S;

