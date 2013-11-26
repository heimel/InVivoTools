function TestRemoteComm

% TESTREMOTECOMM - Tests NewStim's RemoteCommunications tools
%
%   Runs a series of tests to check RemoteCommunications in NewStim
%
%

fprintf('$$$Checking to see if we can open remotecommunications port\n');

b = remotecommopen;

if b==1, fprintf(['remotecommopen reported no error.\n']);
else, fprintf(['remotecommeopn reported an error.\n']); end; % should have given details

 % now test sending a script to be run

str = {'a=5;' 'a=5;' 'a=5;' 'save gotit -mat;' };

fprintf(['$$$$Calling sendremotecommand with a simple script.\n']);

b = sendremotecommand(str);

if b==1, fprintf('sendremotecommand w/ simple script was successful\n');
else, fprintf('sendremotecommand w/ simple script was unsuccessful\n'); end;

 % now test an erroneous script

str = {'a=5;' 'a=5;' 'a=testnum;' 'save gotit a -mat;'};

fprintf(['$$$Calling sendremotecommand with a script with an error.\n']);

b = sendremotecommand(str);
if b==0, fprintf('sendremotecommand w/ error script was unsuccessful as it should have been\n');
end;


fprintf(['$$$Calling sendremotecommandvar with a script that does variable input/output.\n']);

str = {'a=5;' 'a=5;' 'a=testvar;' 'save fromremote a -mat;' 'save gotit a -mat'};

[b,var] = sendremotecommandvar(str,{'testvar'},{10});

if b==1,
	fprintf('sendremotecommand w/ var script was successful and var is as follows:\n');
	var,
else,
	fprintf('sendremotecommand w/ var script was unsuccessful\n');
end;

fprintf(['$$$Calling sendremotecommand w/ script that takes a long time...please cancel it.\n']);

str = {'pause(30); a=5; save gotit a -mat;'}

b = sendremotecommand(str);

if b==0,
	str = {'pause(1); a=5; save gotit a -mat;'}
	fprintf(['$$$Now trying another script while previous script is running...should fail.\n']);
	b = sendremotecommand(str);
	if b==0,
		fprintf(['Script failed as expected.\n']);
	else, fprintf(['Script succeeded but it shouldn''t have.\n']);
	end;
elseif b==1,
	fprintf(['Script succeeded but shouldn''t have -- either user didn''t cancel or there is an error.\n']);
end;

fprintf(['Please wait...\n']);

pause(30);

fprintf(['$$$Now trying another simple script that should succeed.\n']);

str = {'pause(1); a=5; save gotit a -mat;'};
b = sendremotecommand(str);
if b==0, fprintf(['Script failed unexpectedly.\n']);
else, fprintf(['Script suceeded as expected.\n']);
end;

