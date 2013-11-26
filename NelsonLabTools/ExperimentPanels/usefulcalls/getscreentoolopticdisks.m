function ods = getscreentoolopticdisks (fig)

% GETSCREENTOOLOPTICDISKS - Return current optic disk locations in screentool
%
% ODS = GETSCREENTOOLOPTICDISKS
%
%  Returns a structure with the optic disks taken from the screentool window:
%  The stucture has the fields 'RightVert','LeftVert','RightHort','LeftHort'.

ods = [];

if nargin==1, z = fig; else, z = geteditor('screentool'); end;
if ~isempty(z),
	lfVtstr = (get(findobj(z,'Tag','leftVertEdit'),'string'));
	rtVtstr = (get(findobj(z,'Tag','rightVertEdit'),'string'));
	lfHtstr = (get(findobj(z,'Tag','leftHortEdit'),'string'));
	rtHtstr = (get(findobj(z,'Tag','rightHortEdit'),'string'));
	if isempty(lfVtstr)|isempty(rtVtstr)|isempty(lfHtstr)|isempty(rtHtstr),
		ods=[];return;
	end;
	try,
		lfVt = str2num(lfVtstr);
		rtVt = str2num(rtVtstr);
		lfHt = str2num(lfHtstr);
		rtHt = str2num(rtHtstr);
	catch,
		errordlg(['Syntax error in optic disk locations.']);
		error(['Syntax error in optic disk locations.']);
	end;
    if lfHt>0,
		errordlg(['Left horizontal should be negative.']);
		error(['Left horizontal should be negative.']);
	end;
    if rtHt<0,
		errordlg(['Right horizontal should be positive.']);
		error(['Right horizontal should be positive.']);
	end;
	if rtVt>0|lfVt>0,
		warndlg(['It is very unusual for right or left vert ' ...
				'optic disk to be above zero.']);
	end;
	ods = struct('RightVert',rtVt,'LeftVert',lfVt,...
				'RightHort',rtHt,'LeftHort',lfHt);
end;

