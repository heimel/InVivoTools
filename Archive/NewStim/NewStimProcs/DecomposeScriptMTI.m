function [script1,script2,MTI1,MTI2]=DecomposeScriptMTI(script,MTI,elem1)

% DECOMPOSESCRIPTMTI - Decompose a script and MTI into parts.
%
%  [SCRIPT1,SCRIPT2,MTI1,MTI2]=DECOMPOSESCRIPTMTI(SCRIPT,MTI,ELEMS1)
%
%  Breaks apart a script and an MTI into separate parts.

do = getDisplayOrder(script);

script1 = script; script2 = script;

 % copy script and then remove all elements so type will be same
for i=1:numStims(script),
    script1=remove(script1,1); script2=remove(script2,1);
end;

stims1 = [];
stims2 = [];

for i=1:numStims(script),
   if ~isempty(intersect(elem1,i)),
      script1 = append(script1,get(script,i));
      stims1(end+1) = i;
   else,
      script2 = append(script2,get(script,i));
      stims2(end+1) = i;
   end;
end;

do1 = []; do2 = []; do1_ = []; do2_ = [];

for i=1:length(do),
  f = find(do(i)==stims1);
  if ~isempty(f), do1(end+1) = f; do1_(end+1) = i;
  else,
     f = find(do(i)==stims2);
     if ~isempty(f), do2(end+1) = f; do2_(end+1) = i; end;
  end;
end;

script1=setDisplayMethod(script1,2,do1);
script2=setDisplayMethod(script2,2,do2);

MTI1 = MTI(do1_); MTI2 = MTI(do2_);
