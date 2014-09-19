function [good, errormsg] = verifystochasticgridstim(parameters)

  % note: parameters must be a struct, NOT an object

proceed = 1;
errormsg = '';

if proceed,
	% check that all arguments are present and appropriately sized
	fieldNames = {'BG','valuesL','rect','pixSizeL','pixSizeR','N','fps','eyes','randState'};
    fieldSizes = {[1 3],[-1 3],[1 4],[1 2],[1 2],[1 1],[1 1],[1 1],[35 1]};
	[proceed,errormsg] = hasAllFields(parameters, fieldNames, fieldSizes);
	if proceed,
            proceed = isfield(parameters,'dispprefs');
            if ~proceed, errormsg = 'no displayprefs field.'; end;
        end;
end;
% 'valuesL',valuesL,...
%                 'valuesR',valuesR,'posR',posR,'posL',posL,'pixSizeR',pixSizeR,...
%                 'pixSizeL',pixSizeL,'similarity'

if proceed,
	% check rect, pixSize args
	if ~isa(parameters.dispprefs,'cell'), errormsg = 'dispprefs must be a list/cell.'; proceed = 0;
	else,
		width  = parameters.rect(3) - parameters.rect(1);
		height = parameters.rect(4) - parameters.rect(2);

        	x = parameters.pixSizeL(1); y = parameters.pixSizeL(2);
        	if (x>=1), X = x; else, X = width * x; end;
        	if (y>=1), Y = y; else, Y = height * y; end;
        	% proceed = (fix(width/X)==width/X) & (fix(height/Y)==height/Y);
            i=1;
            proceed = i==1;
		if ~proceed, errormsg = 'Grid square size specified does not _exactly_ cover area.'; end;
        
	end;
end;

% if proceed,
%     %check rect, left and right image args 
%     width=parameters.rect(3)-parameters.rect(1); height=parameters.rect(4)-parameters.rect(2);
%     widthR=SGSp.posR(3)-SGSp.posR(1); heightL=SGSp.posL(3)-SGSp.posL(1);
%     widthR=SGSp.posR(3)-SGSp.posR(1); heightL=SGSp.posL(3)-SGSp.posL(1);
% 	proceed = 
% 	if ~proceed, errormsg = 'dist and value must have same number of rows.';
% 	else,
% 		f = find(parameters.distL<0); proceed = isempty(f);
% 		if ~proceed, errormsg = 'all entries of dist must be non-negative.'; end;
% 	end;
%     proceed = (size(parameters.distL,1)==size(parameters.valuesL));
% 	if ~proceed, errormsg = 'dist and value must have same number of rows.';
% 	else,
% 		f = find(parameters.distL<0); proceed = isempty(f);
% 		if ~proceed, errormsg = 'all entries of dist must be non-negative.'; end;
% 	end;
% end;
    
if proceed,
	% check colors
	f = find(parameters.BG<0|parameters.BG>255);
	if f, proceed = 0; errormsg = 'R,G,B in BG must be in [0..255]'; end;
	f = find(parameters.valuesL<0|parameters.valuesL>255);
	if f, proceed = 0; errormsg = 'R,G,B in values must be in [0..255]'; end;
end;

if proceed, % check that value and dist have same size
	proceed = (size(parameters.distL,1)==size(parameters.valuesL));
	if ~proceed, errormsg = 'dist and value must have same number of rows.';
	else,
		f = find(parameters.distL<0); proceed = isempty(f);
		if ~proceed, errormsg = 'all entries of dist must be non-negative.'; end;
	end;
end;

if proceed, % check that value and dist have same size
	proceed = (size(parameters.distR,1)==size(parameters.valuesR));
	if ~proceed, errormsg = 'dist and value must have same number of rows.';
	else,
		f = find(parameters.distR<0); proceed = isempty(f);
		if ~proceed, errormsg = 'all entries of dist must be non-negative.'; end;
	end;
end;

if proceed,
	if parameters.fps<=0, proceed = 0; errormsg = 'fps must be positive.';
	elseif parameters.N<=0, proceed = 0; errormsg = 'N must be positive.';
	end;
end;

if proceed, % check displayprefs for validity
	try, dummy = displayprefs(parameters.dispprefs);
	catch, proceed = 0; errormsg = ['dispprefs invalid: ' lasterr];
	end;
end;

good = proceed;
