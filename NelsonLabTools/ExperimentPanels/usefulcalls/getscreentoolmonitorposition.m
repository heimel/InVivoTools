function mps = getscreentoolmonitorposition(fig)

% GETSCREENTOOLMONITORPOSITION - Return current monitor position in screentool
%
% MPS = GETSCREENTOOLMONITORPOSITION
%
%  Returns a structure with the monitor position taken from the screentool
%  window.  The stucture has the fields 'MonPosX','MonPosY','MonPosZ',
%  corresponding to the horizontal displacement (X), forward distance
%  displacement aka depth (Y), and vertical displacement (Z).

mps = [];
if nargin==1, z=fig; else, z=geteditor('screentool'); end;
if ~isempty(z),
	mpxstr = (get(findobj(z,'Tag','MonPosXEdit'),'string'));
	mpystr = (get(findobj(z,'Tag','MonPosYEdit'),'string'));
	mpzstr = (get(findobj(z,'Tag','MonPosZEdit'),'string'));
	if isempty(mpxstr)|isempty(mpystr)|isempty(mpzstr),
		mps=[];return;
	end;
	try,
		X = str2num(mpxstr);
		Y = str2num(mpystr);
		Z = str2num(mpzstr);
	catch,
		errordlg(['Syntax error in monitor positions.']);
		error(['Syntax error in monitor positions.']);
	end;
    if Y<0,
		errordlg(['Depth(Y) cannot be negative.']);
		error(['Depth(Y) cannot be negative.']);
	end;
	mps = struct('MonPosX',X,'MonPosY',Y,'MonPosZ',Z);
end;

