function [b,vals] = checksyntaxsize(thefig,taglist,sizelist,errormsg,...
  varnamelist)

%  CHECKSYNTAXSIZE - Checks syntax and size of uitools string arguments
%
%  [B,VALS] = CHECKSYNTAXSIZE(THEFIG,TAGLIST,SIZELIST,[ERRORMSG, VARNAMELIST])
%
%  Examines strings of user interface tools in figure THEFIG.  TAGLIST is
%  a cell list of 'Tag' fields to look at, and SIZELIST is a cell list
%  of the expected sizes for the arguments (leave an element empty to
%  skip the examination for that field).  If a syntax error is found,
%  B is 0 and VALS is an empty cell.  Otherwise, the values resulting from
%  evaluating each string is returned in the cell list VALS.
%
%  Optionally, an error dialog is presented to the user describing the syntax
%  or size error (if ERRORMSG is provided and is 1), and the field is
%  referenced in this message either by its tag or by the corresponding entry
%  in VARNAMELIST if it is provided.
%

errormessage = 0; varlist = taglist;
if nargin>=4, errormessage = errormsg; end;
if nargin>=5, varlist = varnamelist; end;

b=1;vals={};
for i=1:length(taglist),
   try,
      v = eval([get(ft(thefig,taglist{i}),'String');]);
   catch,
      b=0;vals={};
      if errormessage, errordlg(['Syntax error in ' varlist{i}]); end;
      break;
   end;
   if (~isempty(sizelist{i}))&(~eqlen(size(v),sizelist{i})),
      b=0;vals={};
      if errormessage,
           errordlg(['Size error in ' varlist{i} ' ; ' ...
           'expected ' mat2str(sizelist{i}) ' but got ' mat2str(size(v)) '.']);
      end;
      break;
   end;
   vals{i} = v;
end;

function h = ft(h1,st)  %shorthand
h = findobj(h1,'Tag',st);

