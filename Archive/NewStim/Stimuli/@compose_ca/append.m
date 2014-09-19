function newcca = append(thecca,varargin)

%  APPEND - add stimuli to a COMPOSE_CA object
%
%    NEWCCA = APPEND(THECCA, THESTIM, [THESTIM2,...])
%
%  Adds stimuli to the list of stimuli to be composed in a COMPOSE_CA stimulus
%  object.  The new COMPOSE_CA object is returned in NEWCCA.  One may add
%  more than one stimulus by providing additional arguments.
%
%  The clut index number for new added stimuli defaults to 1.  Use 
%  SETCLUTINDEX to set the clut index number.  
%
%  See also: COMPOSE_CA, COMPOSE_CA/GET, COMPOSE_CA/SET,
%            COMPOSE_CA/SETCLUTINDEX

for i=1:length(varargin),
	if isa(varargin{i},'stimulus'),
		thecca.stimlist{end+1} = varargin{i};
		thecca.clutindex(end+1) = 1;
	else, error(['Error: stimulus number ' int2str(i) ' to be appended isn''t a stimulus.']);
	end;
end;
newcca = thecca;
