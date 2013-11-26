function [objs,objnames] = load2celllist(filename,varargin)

% LOAD2CELLLIST - Loads saved objects to a cell list
%
%  [OBJS,OBJNAMES] = LOAD2CELLLIST(FILENAME, ...)
%
%  Loads objects from a Matlab file FILENAME into a cell list.
%  Additional arguments are passed on to the Matlab LOAD command.
%
%  OBJS is a cell list of all variables matching the loading
%  criteria
%
%  Example:
%      [myobjs,mynames]=LOAD2CELLLIST('myfile','cell*','-mat');
%  
%      If the file 'myfile' contains two variables named 'cell1'
%      and 'cell2', then
%       mynames = {'cell1' 'cell2'} and
%       myobjs = { (data of 'cell1')  (data of 'cell2') }
%
%  See also:  LOAD
%  

g = load(filename,varargin{:});

objnames = fieldnames(g); objs = {};

for i=1:length(objnames), objs{i}=getfield(g,objnames{i}); end;

