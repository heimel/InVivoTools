function [squm, coneact]=rgb2squirrel( mat )
%RGB2SQUIRREL takes mx3 matrix of RGB vals as computes rgb through squirrel cones
%
%    SQUM=RGB2SQUIRREL( MAT )
%        MAT = M x 3 matrix of rgb values
%
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
  
  
format='double';
try 
  x=mat(1,:)*1;
catch
  format='uint8';
  mat=double(mat);
end

sz=size(mat);
mat=reshape( mat, prod(sz(1:end-1)),3);

% from  nelson/color/squirrelcolor.m
             %  R      G      B
  PHOTOMON = [ 0.0008 0.0057 0.0299; ...  % S
	      0.0135 0.0742 0.0191; ...  % M
	      0.0030 0.0520 0.0351 ]; % rod
  
  CONEMON = PHOTOMON(1:2,:);

  
                %   R   G  B 
  PSEUDOCOLORS = [ 0  0  1;...
		   1   1  0 ];
  PSEUDOCOLORS(1,:)=PSEUDOCOLORS(1,:)/sum(CONEMON(1,:));
  PSEUDOCOLORS(2,:)=PSEUDOCOLORS(2,:)/sum(CONEMON(2,:));

  try
	  coneact= mat * CONEMON';
  catch
	  mat=double(mat);
	  coneact= mat * CONEMON';
  end
 
mat=coneact *PSEUDOCOLORS;
squm=reshape(mat,sz);
coneact=reshape(coneact,[ sz(1:end-1) 2]);

if strcmp(format,'uint8')==1
  squm=uint8(fix(squm));
end

