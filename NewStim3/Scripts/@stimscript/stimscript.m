function A = stimscript(dummyparams,oldscript)

NewStimScriptListAdd('stimscript');

if nargin==0,
	A = stimscript('default');
	return
end

A = [];
if nargin==2,
	A = oldscript;
else

	%displayMethod should be removed, but don't want to mess stuff up
	data = struct('displayMethod', [], 'displayOrder', [], ...
        'StimTimes', [], 'trigger', [] );
	data.Stims = {};

	A = class(data,'stimscript');

end
