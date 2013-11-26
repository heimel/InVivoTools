% overzichtje voor dries

mousedb=load_mousedb;

after='2006-05-18';

ind1=find_record(mousedb,['mouse=05.03.*,supplier=Harlan,actions=*oi*,actions!*sut*,arrival>' after]);
ind2=find_record(mousedb,['mouse=05.03.*,supplier=Harlan,actions=*sut*,arrival>' after]);

groep1=sort({mousedb(ind1).arrival});
groep2=sort({mousedb(ind2).arrival});

disp(['IOI 05.03 Groep 1, sinds ' after]);
disp(['Totaal:' num2str(length(groep1))]);
for i=1:length(groep1)
  disp(groep1{i})
end
disp('');
disp(['IOI 05.03 Groep 2, sinds ' after]);
disp(['Totaal:' num2str(length(groep2))]);
for i=1:length(groep2)
  disp(groep2{i})
end
