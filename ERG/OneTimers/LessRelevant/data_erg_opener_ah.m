global ergConfig;

%data_erg(mouse,run).stims
%data_erg(mouse,run).params = [baseline; awave; atime; bwave; btime]
%data_erg.expgroup
%1 = B6, 2 = BalbC, 3 = DBA2, 4 = C3H


% ERG data fits
if ~exist('fitted','var')
  try
    load ([ergConfig.datadir filesep 'data_erg.mat']);
  catch
    load ('data_erg.mat');
  end
  colors='bgrcmyk';
  c='k';
  n_mouse=size(data_erg,1);
  n_run=size(data_erg,2);
  for mouse = 1:n_mouse;
    for run = 1:2; %1:n_run;
      d = data_erg(mouse,run);
      if ~isempty(d.stims)
        c=colors(mod(find(colors==c),7)+1);
        
        d.stims = d.stims / 140000*25;
%        if (d.expgroup==4)
%          continue
%        end

        y=d.params(4,:) - d.params(2,:); %a to b wave
        x=d.stims;
        x=x/max(x);

        b=median(x);
        n=1;
        m=2;
        rm=max(y(:))*(b^m+max(x)^m)/max(x)^n;

        [rm,b,n,m,exitflag] = naka_rushton(x,y,[rm b n n]);
%??     attempts=attempts+1;

        if exitflag~=1
          disp('no convergence');
          if 1 % don't include
            rm=nan;
            b=nan;
            n=nan;
            m=nan;
          end
        end

        figure
        semilogx(x,y,[c 'x']); hold on;
        xfit=logspace(log10(min(x)),log10(max(x)),100);
        yfit=rm * xfit.^n./(b^m + xfit.^m);
        semilogx(xfit,yfit,c );

        xlabel('intensity');
        ylabel('response');
        switch d.expgroup
          %1 = B6, 2 = BalbC, 3 = DBA2, 4 = C3H, 5 = GABA
          case 1,tit='B6';
          case 2,tit='BALB';
          case 3,tit='DBA';
          case 4,tit='C3H';
          case 5,tit='GABA';
        end

        data_erg(mouse,run).mouse = mouse;
        data_erg(mouse,run).run = run;
        data_erg(mouse,run).rm=rm;
        data_erg(mouse,run).b=b;
        data_erg(mouse,run).n=n;
        data_erg(mouse,run).m=m;
        data_erg(mouse,run).mminn=m-n;
        [maxyfit,ind]=max(yfit);
        data_erg(mouse,run).max_response=maxyfit; % maximum response
        data_erg(mouse,run).optimal_intensity=xfit(ind); % intensity with maximum response
        data_erg(mouse,run).response_at_max_intensity=yfit(end); % response to maximum intensity
        i50=xfit(find(yfit>maxyfit/2,1));
        data_erg(mouse,run).i50=i50;
        data_erg(mouse,run).log_i50=log10(i50);
        rel_dip=1-data_erg(mouse,run).response_at_max_intensity/data_erg(mouse,run).max_response;
        data_erg(mouse,run).rel_dip=rel_dip;

        c50=0; %JC:??
        tit=[tit sprintf('rm=%.2f b=%f n=%.2f m=%.2f c50=%f dipsize=%.2f',rm,b,n,m,c50,rel_dip)];
        title(tit);
        disp(tit);
      end
    end
  end
  fitted=1; % remove fitted in workspace to run this code again
end

% graphs of all measures against all measures
groupnumbers=unique(sort([data_erg(:,:).expgroup]));
indgrp={};
for g=groupnumbers
  indgrp{g}=[];
  for i=1:length(data_erg(:))
    if data_erg(i).expgroup==g
      indgrp{g}=[indgrp{g} i];
    end
  end
end

%fs={'b','n','m','mminn','max_response','optimal_intensity','response_at_max_intensity','log_i50','rel_dip'};
fs={'max_response','log_i50'};
if exist('subst_ctlchars')==2
  for f=1:length(fs)
    % substitute characters like _, / which would be interpreted as text
    % control characters by plot
    lab{f}=subst_ctlchars(fs{f});
  end
else
  for f=1:length(fs)
    a = fs{f};  
    a(a=='_')=' '
    lab{f}=a;
  end
end

for f1=1:length(fs)
  for f2=f1+1:length(fs)
    figure;
    hold on;
    for g=1:length(indgrp)
      h=plot([data_erg(indgrp{g}).(fs{f1})],[data_erg(indgrp{g}).(fs{f2})]    ,['x' colors(mod(g-1,7)+1)]);
      set(h,'MarkerSize',15);
      set(h,'LineWidth',4);
    end
    xlabel(lab{f1});
    ylabel(lab{f2});
    if exist('smaller_font')==2
      smaller_font(-12);
      bigger_linewidth(4);
    end
    legend('B6','BALB/c','DBA','C3H','GABA','Location','BestOutside');
  end
end

%xlswrite('c:\jochem.xls',[data_erg.mouse]','Sheet1','A')
%xlswrite('c:\jochem.xls',[data_erg.expgroup]','Sheet1','B')
%xlswrite('c:\jochem.xls',[data_erg.(fs{1})]','Sheet1','C')
%xlswrite('c:\jochem.xls',[data_erg.(fs{2})]','Sheet1','D')
