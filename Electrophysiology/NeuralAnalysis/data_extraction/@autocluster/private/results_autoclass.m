function classes=results_autoclass(autoclass,basename)


if(exist([basename '.rlog'],'file'))
   delete([basename '.rlog']);
end


[s,w]=unix([autoclass ' -reports ' ...
        basename '.results-bin '...
	basename '.search ' basename '.r-params']);



fid=fopen([basename '.case-data-1'],'r');

while isempty(findstr(fgetl(fid),'#     Case #  Class'))
end

count=1;
y=ones(1,10)*nan;

while count>0
  line=fgetl(fid);
[x,count]=sscanf(line,'%d %d %f %d %f %d %f %d %f %d %f',11);
  if count>0
    classes(x(1),:)=y;
    classes(x(1),1:count-1)=x(2:count)';
    classes(x(1),1)=classes(x(1),1)+1; %start clusters at 1
  end
end
