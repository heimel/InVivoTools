function username = user(username)
%USER returns lowercase username from environment variable or license
%
% USERNAME = USER()
%   returns current username
%    
% USERNAME = USER( USERNAME )
%   sets username to USERNAME
%
% USERNAME = USER('')
%   resets username to system user
%
% 2008-2011, Alexander Heimel
%

persistent username_pers

if nargin>0
    username_pers = username;
end

if isempty(username_pers)
    username_pers = lower(getenv('USER'));
    if isempty(username_pers)
        % then try to get it from license
        try
            result = license('inuse');
            username_pers = lower(result.user);
        end
    end
end

username = username_pers;
