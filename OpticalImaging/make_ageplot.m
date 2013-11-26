function [ar,p]=make_ageplot(strains,types,stim_type,measure,eye, ...
			     labels,ylab,prefax)
%MAKE_AGEPLOT plots parameter versus age
%
%    [r,p]=make_ageplot(strains,types,stim_type,measure,eye, ...
%			     labels,ylab,prefax)
%
% 2006, Alexander Heimel
         
ar={};
p={};

if nargin<8
  prefax=[];
end

if nargin<7
  ylab=[];
end

if nargin<6
  labels=[];
end

if ~iscell(strains)
  strains={strains};
end

for s=1:length(strains)
  if isempty(find(strains{s}=='='))
    strains{s}=['strain=' strains{s}];
  end
end


r={};
r_sem={};
mice={};
ages={};

for s=1:length(strains)
  for i=1:length(types)
    [r{s,i},r_sem{s,i},mice{s,i},ages{s,i}]=...
	get_results([strains{s} ', type=' types{i}], ...
		    stim_type,measure,eye);
  end
end

figure;
hold on;
m='o+x*sdv>ph';
l={'-',':','-.','--'};
leg={};
c={'k','r','b','g'};
for s=1:length(strains)
  for i=1:length(types)
    [age,ind]=sort(ages{s,i});
    ar{s,i}=[age; r{s,i}(ind)];
    h=plot(age,r{s,i}(ind),[m(1) c{mod(s-1,4)+1} ]);
    m(end+1)=m(1);
    m=m(2:end);
    strain=strains{s};
    if strcmp(strain(1:7),'strain=');
      strain=strain(8:end);
    end
    if strcmp(strain(1:4),'lsl=');
      strain=strain(5:end);
    end
    pos=findstr(strain,'typing_lsl=1');
    if ~isempty(pos)
      strain=strain( [(1:pos-1) (pos+13:end)]);
    end
    if isempty(find(strain==','))
      strain=[strain ', '];
    end
    if ~isempty(r{s,i})
      leg{end+1}=[strain  types{i}];
    end
  end
end
 

for s=1:length(strains)
  for i=1:length(types)
    xm=mean(ages{s,i});
    x=ages{s,i}-xm;
    ym=mean(r{s,i});
    y=r{s,i}-ym;
    a=(y*x')/(x*x');
    b=ym-xm*a;
    plot( x+xm,a*(x+xm)+b, [ l{mod(i-1,4)+1} c{mod(s-1,4)+1} ]);
    [rc,pval]=corrcoef(ages{s,i},r{s,i}');
    p{end+1}=pval(1,2);
    disp(['Correlation of strain ' strains{s} ...
      ' type ' types{i} ' and age: ' num2str( rc(1,2) ) ])
    disp(['p-value of non-zero correlation:' num2str(pval(1,2))]);
  end
end
    
    
if ~isempty(prefax)
  axis(prefax);
end
if ~isempty(ylab)
  ylabel(ylab);
end
if ~isempty(labels)
  leg=labels;
end

xlabel('Age (days)');

handles=get(gcf,'Children');
for h=handles
  childs=get(h,'Children');
  for child=childs
    try
      set(child,'MarkerSize',10)
    end
  end
end

bigger_linewidth(3);
smaller_font(-11);
legend(leg,3 )
