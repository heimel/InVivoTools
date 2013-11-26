function condnames=get_condnames( stim_type, conditions)
%GET_CONDNAMES generates labels for the conditions
%
%   CONDNAMES=GET_CONDNAMES( STIM_TYPE, CONDITIONS)
%
% 2005, Alexander Heimel
%
  
  condnames=[];
  
  switch stim_type
   case 'od',
    allnames=[' none ';' ipsi ';' blank';'contra';' both '];
    condnames=allnames(conditions+3,:);
   case {'sf','tf','contrast'},
    num_condnames=num2str( conditions','%6g');
    condnames=char(32*ones( length(conditions),6));
    condnames(:,1:size(num_condnames,2))=num_condnames;
    blank=find(conditions==0);
    if ~isempty(blank)
      condnames(find(conditions==0),:)='blank ';
    end

  end
