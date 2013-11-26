function [conditions,response,response_sem]=make_popcurve(strain,type,stim_type,normalized,save_option,show)
%
% 2006, Alexander Heimel
%
if nargin<6
  show=[];
end
if nargin<5
  save_option=[];
end
if nargin<4
  normalized=[];
end
if nargin<2
  type='*';
end
if nargin<1
  strain='*';
end

if isempty(show)
  show=1;
end

if isempty(normalized)
  normalized=0;
end

if isempty(save_option)
  save_option=1;
end

if isempty(find(strain=='='))
  strain=['strain=' strain];
end

if isempty(find(type=='='))
  type=['type=' type];
end

mice=[strain ', ' type];


mousedb=load_mousedb;
testdb=load_testdb;
indmice=find_record(mousedb,mice);

disp([ 'Found ' num2str(length(indmice)) ' mice of ' mice ]);

indtests=[];
for m=1:length(indmice)
  mouse=['mouse=' mousedb(indmice(m)).mouse];
  indtests=[indtests ...
	    find_record(testdb,...
			[mouse ', reliable=1, stim_type=' stim_type ])];
end

disp([ 'Found ' num2str(length(indtests)) ' tests of type ' stim_type ]);

ud.db=testdb;
ud.ind=indtests;
[ud,conditions,response,response_sem]=average_tests(ud,normalized,show);



bigger_linewidth(3);
smaller_font(-11);

if save_option
  filename=['curve_' strain '_' type '_' stim_type];
  save_figure(filename);
end

return

%%%%%%%%%%%%%%%%%%%%%%%%
