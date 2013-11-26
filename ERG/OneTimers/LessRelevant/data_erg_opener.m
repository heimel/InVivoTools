global ergConfig;
load ([ergConfig.datadir filesep 'data_erg.mat']);

clear mouse data_jc stims results groups;
%data_erg(mouse,run).stims
%data_erg(mouse,run).params = [1=baseline; 2=awave; 3=atime; 4=bwave; 5=btime]
%data_erg.expgroup

%1 = B6, 2 = BalbC, 3 = DBA2, 4 = C3H, 5 = GABA

excludegroup = [5];

i = 0;
for mouse = 1:size(data_erg,1)
  data_jc(mouse).res = [0 0 0 0 0 0 0 0 0 0]';  
  data_jc(mouse).grp = 0;
  for run = 1:2 if sum(excludegroup==data_erg(mouse,run).expgroup)==0 && length(data_erg(mouse,run).stims) > 0 %size(data_erg,2)
    i = i + 1;   
    stims(i,:) = data_erg(mouse,run).stims(end-9:end);
    results(i,:,:) = [data_erg(mouse,run).params(:,end-9:end)' zeros(1,10,1)'];
    results(i,:,2) = results(i,:,2) - results(i,:,1);
    results(i,:,4) = results(i,:,4) - results(i,:,1);
    results(i,:,6) = results(i,:,4) - results(i,:,2);
    groups(i) = data_erg(mouse,run).expgroup;
    data_erg(mouse,run).atob = results(i,:,4) - results(i,:,1);
    data_erg(mouse,run).mouse = mouse;

    data_jc(mouse).res(:) =  + (results(i,:,4) - results(i,:,1));
    data_jc(mouse).grp = data_erg(mouse,run).expgroup;
  end; end 
  data_jc(mouse).res(:) = data_jc(mouse).res(:) / 2;
end

colors='bgrcmyk';
lines ={':','--','-','-.'};
for resnr = 4%1:size(results,3)
  figure; hold off;
  for grp = unique(groups)
    dummy = [1:length(groups)]; teller = 0;
    for mnr = dummy(groups==grp)
      teller = teller + 1;  
%      x = stims(groups==grp,:)';
%      y = results(groups==grp,:,resnr)';
      x = stims(mnr,:)';
      y = results(mnr,:,resnr)';
      c = ['x' colors(mod(grp-1,7)+1) lines{round(teller/2)}];
      h=semilogx(x/140000*25,y*100,c,'LineWidth',3); hold on;
      H(grp) = h(1);
    end
  end
  legend(H,'B6','BALB/c','DBA','C3H','GABA','Location','BestOutside');
  xlim([2.5/1000,25])
end

%[data_jc([data_jc.grp] > 0).grp]
%[data_jc([data_jc.grp] > 0).res]
%xlswrite(',[data_erg.mouse]','Sheet1','A')
%xlswrite('c:\jochem2.xls',[data_erg.expgroup]','Sheet1','B')
%xlswrite('c:\jochem2.xls',[data_erg.atob]','Sheet1','M')
