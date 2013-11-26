function colpuncta_analysis

%COLPUNCTA_ANALYSIS
%
%  [RESULTS, = COLPUNCTA_ANALYSIS
%  
% Results is a table with 8 columns:
% 1 stack index
% 2 shaft (1), spine (2), NA (0)
% 3 gephyrin positive
% 4 PV colocalization
% 5 Syt2
% 6 SOM
% 7 CR
% 8 PV
%
% percentages shows % for each stack and antibody, separate for 
% spines and shafts, from which the means can be computed
%
% 2011, Alexander Heimel & Danielle van Versendaal
%
% %experiment = '11.21';
% % db = load_testdb(expdatabases('tp'));
% % db_rajeev = load_testdb('tptestdb_olympus_rajeev');
% % db_rajeev = db_rajeev(find_record(db_rajeev, ...
% %    ['(mouse=11.21.3.01,stack=stack1,date=2011-08-08)|' ...
% %     '(mouse=11.21.3.02,stack=stack1,date=2011-07-29)|' ...
% %     '(mouse=11.21.3.02,stack=stack2,date=2011-07-29)|' ...
% %     '(mouse=11.21.3.02,stack=stack3,date=2011-07-29)|' ...
% %     '(mouse=11.21.3.02,stack=stack6,date=2011-07-29)' ] ));
%

% db_daan = load_testdb('tptestdb_olympus_daan');
% db_daan = db_daan(find_record(db_daan, ...
%    ['(mouse=11.21.3.02,stack=stack1,date=2011-07-29)|' ...
%     '(mouse=11.21.3.02,stack=stack2,date=2011-07-29)|' ...
%     '(mouse=11.21.3.02,stack=stack3,date=2011-07-29)|' ...
%     '(mouse=11.21.3.02,stack=stack6,date=2011-07-29)|' ...
%     '(mouse=11.21.3.04,stack=stack1,date=2011-08-05)|' ...
%     '(mouse=11.21.3.05,stack=stack1,date=2011-08-08)|' ...
%     '(mouse=11.21.3.05,stack=stack2,date=2011-08-04)|' ...
%     '(mouse=11.21.3.05,stack=stack2,date=2011-08-09)' ] ));
% 
% db_nandu = load_testdb('tptestdb_olympus_nandu_imm');
% db_nandu = db_nandu(find_record(db_nandu, ...
%    ['(mouse=11.21.3.01,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack1,date=2011-07-28)|' ...
%     '(mouse=11.21.3.01,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack2,date=2011-07-28)|' ...
%     '(mouse=11.21.3.01,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack3,date=2011-07-28)|' ...
%     '(mouse=11.21.3.01,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer1-2-stack1,date=2011-08-10)|' ...
%     '(mouse=11.21.3.01,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer1-2-stack2,date=2011-08-10)|' ...
%     '(mouse=11.21.3.01,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer1-2-stack3,date=2011-08-10)|' ...
%     '(mouse=11.21.3.01,stack=PVCy5-geph-red-63x2.2-slice2-layer2-stack1,date=2011-08-01)|' ...
%     '(mouse=11.21.3.01,stack=PVCy5-geph-red-63x2.2-slice2-layer2-stack2,date=2011-08-01)|' ...
%     '(mouse=11.21.3.02,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer2-stack1,date=2011-08-10)|' ...
%     '(mouse=11.21.3.02,stack=Sy2Cy5-geph-red-63x2.2-slice2-layer2-stack1,date=2011-08-10)|' ...
%     '(mouse=11.21.3.02,stack=Sy2Cy5-geph-red-63x2.2-slice2-layer2-stack2,date=2011-08-10)|' ...
%     '(mouse=11.21.3.02,stack=CBCy5-geph-red-63x2.2-slice2-layer1-2-stack1,date=2011-08-18)|' ...
%     '(mouse=11.21.3.02,stack=CBCy5-geph-red-63x2.2-slice2-layer1-2-stack2,date=2011-08-18)|' ...
%     '(mouse=11.21.3.02,stack=CBCy5-geph-red-63x2.2-slice3-layer2-stack1,date=2011-08-18)|' ...
%     '(mouse=11.21.3.02,stack=CBCy5-geph-red-63x2.2-slice3-layer1-2-stack2,date=2011-08-18)|' ...
%     '(mouse=11.21.3.02,stack=CBCy5-geph-red-63x2.2-slice4-layer1-2-stack1,date=2011-08-18)|' ...
%     '(mouse=11.21.3.02,stack=stack2_4,date=2011-08-04)|' ...
%     '(mouse=11.21.3.02,stack=stack4_7,date=2011-07-29)|' ...
%     '(mouse=11.21.3.03,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack2,date=2011-07-27)|' ...
%     '(mouse=11.21.3.03,stack=PVCy5-geph-red-63x2.2-slice1-layer2-stack1,date=2011-07-27)|' ...
%     '(mouse=11.21.3.03,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer1-2-stack2,date=2011-07-27)|' ...
%     '(mouse=11.21.3.03,stack=Sy2Cy5-geph-red-63x2.2-slice2-layer1-2-stack1,date=2011-07-27)|' ...
%     '(mouse=11.21.3.03,stack=CBCy5-geph-red-63x2.2-slice2-layer2-stack1,date=2011-08-18)|' ...
%     '(mouse=11.21.3.03,stack=CBCy5-geph-red-63x2.2-slice3-layer1-2-stack2,date=2011-08-19)|' ...
%     '(mouse=11.21.3.03,stack=CBCy5-geph-red-63x2.2-slice4-layer1-2-stack2,date=2011-08-19)|' ...
%     '(mouse=11.21.3.04,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack2,date=2011-07-27)|' ...
%     '(mouse=11.21.3.04,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer2-stack1,date=2011-08-04)|' ...
%     '(mouse=11.21.3.04,stack=Sy2Cy5-geph-red-63x2.2-slice2-layer2-stack1,date=2011-08-04)|' ...
%     '(mouse=11.21.3.05,stack=PVCy5-geph-red-63x2.2-slice1-layer1-2-stack1,date=2011-07-28)|' ...
%     '(mouse=11.21.3.05,stack=PVCy5-geph-red-63x2.2-slice3-layer1-2-stack2,date=2011-08-01)|' ...
%     '(mouse=11.21.3.05,stack=Sy2Cy5-geph-red-63x2.2-slice1-layer2-stack2,date=2011-08-04)|' ...
%     '(mouse=11.21.3.05,stack=Sy2Cy5-geph-red-63x2.2-slice2-layer2-stack3,date=2011-08-04)|' ...
%     '(mouse=11.21.3.05,stack=stack1_2,date=2011-07-29)'] ));

db_analysis = load_testdb('tptestdb_olympus');
db_imm = db_analysis(find_record(db_analysis, ...
   '(mouse=12.81.1.03,stack=1281103_VSOM_100_03)'));


db_raw = db_imm(find_record(db_imm,'comment!*pixel*'));
db_pi = db_raw([]);


for i = 1:length(db_raw)
    ind = find_record(db_imm,['mouse=' db_raw(i).mouse ',stack=' db_raw(i).stack ',comment=*pixel*']);
    if isempty(ind)
        db_pi(i) = db_raw(i);
        db_pi(i).ROIs.celllist = tp_emptyroirec;
    else
        if length(ind)>1
            disp(['COLPUNCTA_ANALYSIS: More than one pixelshift record for mouse=' db_raw(i).mouse ',stack=' db_raw(i).stack '. Only taking first']);
            ind = ind(1);
        end
        db_pi(i) = db_imm(ind);
    end
    
end


[percentages_raw,count_raw] = get_results(db_raw);
[percentages_pi,count_pi] = get_results(db_pi);
percentages_cor = [];
count_cor = [];

flds = fields(percentages_raw);
for i=1:length(percentages_raw)
    
       for f = 1:length(flds)
        field = flds{f};
        p = find(field=='_',1);
        if isempty(p)
            continue
        end
        prot = field(1:p-1);
        pi = percentages_pi(i).([prot '_synapse']);
        percentages_cor(i).(flds{f}) = ...
            (percentages_raw(i).(flds{f}) - pi  ) / ...
            (1 - pi);
        
    end
end

labels = {'syt2','som','cr','pv'}; % can include pv

for i = 1:length(labels)
    lab = labels{i}
    shaft_pos = nansum([count_raw.([lab '_shaft'])]);
    n_shaft = [count_raw.N_shaft];
    n_shaft = n_shaft(~isnan([count_raw.([lab '_shaft'])]));
    n_shaft = nansum(n_shaft)
    
    frac_raw(i,1) = shaft_pos / n_shaft;
    shaft_neg = n_shaft - shaft_pos;

    spine_pos = nansum([count_raw.([lab '_spine'])]);
    n_spine = [count_raw.N_spine];
    n_spine = n_spine(~isnan([count_raw.([lab '_spine'])]));
    n_spine = nansum(n_spine)
    
    frac_raw(i,2) = spine_pos / n_spine;
    spine_neg = n_spine - spine_pos;
       
    chi2.(lab) = chi2class( [shaft_pos shaft_neg; spine_pos spine_neg])

    
    
        shaft_pos = nansum([count_pi.([lab '_shaft'])]);
    n_shaft = [count_pi.N_shaft];
    n_shaft = n_shaft(~isnan([count_pi.([lab '_shaft'])]));
    n_shaft = nansum(n_shaft)
    
    frac_pi(i,1) = shaft_pos / n_shaft;
    shaft_neg = n_shaft - shaft_pos;

    spine_pos = nansum([count_pi.([lab '_spine'])]);
    n_spine = [count_raw.N_spine];
    n_spine = n_spine(~isnan([count_pi.([lab '_spine'])]));
    n_spine = nansum(n_spine)
    
    frac_pi(i,2) = spine_pos / n_spine;
    spine_neg = n_spine - spine_pos;
       

    
end

position = {'shaft','spine'};

fcol = figure;
name = 'juxtaposed';
bar(frac_raw*100)
frac_raw
set(gca,'xticklabel',labels);
ylabel('Juxtaposed to gephyrin puncta (%)')
box off
frac_pi = mean(frac_pi,2);
for i = 1:length(frac_pi)
    line([0.6 1.4]+i-1,100*[frac_pi(i) frac_pi(i)],'color',[0.5 0.5 0.5]);
end
legend('Shaft','Spine','location','NorthWest')
legend boxoff
ylim([0 50])
set(gca,'ytick',(0:10:50));
figpath = ''; %'~/Desktop/Figures';
save_figure([name '.png'],figpath,fcol);
saveas(fcol,fullfile(figpath,[name '.ai']),'ai');


return

% raw
[Means,Stdevs,SEMs] = perc2means( percentages_raw,labels,position,'Raw apposition' );

% pi
[Means,Stdevs,SEMs] = perc2means( percentages_pi,labels,position,'Pixelshift apposition' );

% cor
[Means,Stdevs,SEMs] = perc2means( percentages_cor,labels,position,'Corrected apposition' );



function [Means,Stdevs,SEMs] = perc2means( percentages,labels,position,name )


%Average percentage, std and SEMS for each label separately for shafts and spines across stacks
Means = zeros(length(labels),length(position));
for i=1:length(labels)
    for p=1:length(position)
        index = ( [ percentages.([labels{i} '_' position{p}]) ]>=0);
        Means(i,p)=mean([percentages(:,index).([labels{i} '_' position{p}] )]);
        Stdevs(i,p)=std([percentages(:,index).([labels{i} '_' position{p}] )]);
        SEMs(i,p)= sem([percentages(:,index).([labels{i} '_' position{p}] )]);
    end
end
figure('numbertitle','off','name',name);
title(name);
errorb(Means*100,SEMs*100);
set(gca,'Xticklabel',labels);
ylabel('Adjoining to gephyrin puncta (%)');
box off

filename = ['percentages_' name '.csv'];
saveStructArray(filename, percentages,1,',');
disp(['COLPUNCTA_ANALYSIS: Data saved as ' fullfile(pwd,filename) ]);


function [percentages,count] = get_results(db)
disp('COLPUNCTA_ANALYSE: ISMEMBER SHOULD HAVE ACCOLADES AROUND SECOND ARGUMENT');
count=1;
results = [];
for i=1:length(db)
    rois = db(i).ROIs.celllist;
    for j=1:length(rois);
        results(count,1)=i;
        
        if ismember('shaft',rois(j).type)
            results(count,2)= 1;
        elseif ismember('spine',rois(j).type)
            results(count,2)= 2;
        else
            results(count,2)= 0;
        end
        
        if ismember('Geph',rois(j).labels) 
            results(count,3)= 1;
        else
            results(count,3)= 0;
        end 
        
        if ismember('PV',rois(j).labels)
            results(count,4)= 1;
        else
            results(count,4)= 0;
        end

        if ismember('Syt2',rois(j).labels)
            results(count,5)= 1;
        else
            results(count,5)= 0;
        end

        if ismember('SOM',rois(j).labels) 
            results(count,6)= 1;
        else
            results(count,6)= 0;
        end
                
        if ismember('CR',rois(j).labels) 
            results(count,7)= 1;
        else
            results(count,7)= 0;
        end

        if ismember('PV',rois(j).labels)
            results(count,8)= 1;
        else
            results(count,8)= 0;
        end
        
count=count+1;
    end
end

clear('count');

%stacks = uniq(sort( results(:,1)));

if ~isempty(results)
    last=max(results(:,1));
else
    last = 0;
end


for i=1:last
    ind=find(results(:,1)==i);
    %gephyrin = (results(ind,3)==1);
    shaft = (results(ind,2)==1);
    spine = (results(ind,2)==2);
    N_shaft = sum(results(ind,2)==1);
    N_spine = sum(results(ind,2)==2);
    N_synapse = N_shaft + N_spine;
    
    pv = (results(ind,4)==1);
    syt2 = (results(ind,5)==1);
    som = (results(ind,6)==1);
    cr = (results(ind,7)==1);
    pv = (results(ind,8)==1);

    percentages(i).mouse = db(i).mouse;
    percentages(i).stack = db(i).stack;

    count(i).N_shaft = N_shaft;
    count(i).N_spine = N_spine;
    
    
    if any(results(ind,4))
        percentages(i).pv_shaft = sum(pv & shaft)/N_shaft;
        percentages(i).pv_spine = sum(pv & spine)/N_spine;
        percentages(i).pv_synapse = sum(pv & (shaft|spine))/N_synapse;
        count(i).pv_shaft = sum(pv & shaft);
        count(i).pv_spine = sum(pv & spine);
    else
        percentages(i).pv_shaft = nan;
        percentages(i).pv_spine = nan;
        percentages(i).pv_synapse = nan;
        count(i).pv_shaft = nan;
        count(i).pv_spine = nan;
    end
    
    if any(results(ind,5))
        percentages(i).syt2_shaft = sum(syt2 & shaft)/N_shaft;
        percentages(i).syt2_spine = sum(syt2 & spine)/N_spine;
        percentages(i).syt2_synapse = sum(syt2 & (shaft|spine))/N_synapse;
        count(i).syt2_shaft = sum(syt2 & shaft);
        count(i).syt2_spine = sum(syt2 & spine);
    else
        percentages(i).syt2_shaft = nan;
        percentages(i).syt2_spine = nan;
        percentages(i).syt2_synapse = nan;
        count(i).syt2_shaft = nan;
        count(i).syt2_spine = nan;
    end
        
    if any(results(ind,6))
        percentages(i).som_shaft = sum(som & shaft)/N_shaft;
        percentages(i).som_spine = sum(som & spine)/N_spine;
        percentages(i).som_synapse = sum(som & (shaft|spine))/N_synapse;
        count(i).som_shaft = sum(som & shaft);
        count(i).som_spine = sum(som & spine);
    else
        percentages(i).som_shaft = nan;
        percentages(i).som_spine = nan;
        percentages(i).som_synapse = nan;
        count(i).som_shaft = nan;
        count(i).som_spine = nan;
    end
    
    if any(results(ind,7))
        percentages(i).cr_shaft = sum(cr & shaft)/N_shaft;
        percentages(i).cr_spine = sum(cr & spine)/N_spine;
        percentages(i).cr_synapse = sum(cr & (shaft|spine))/N_synapse;
        count(i).cr_shaft = sum(cr & shaft);
        count(i).cr_spine = sum(cr & spine);
    else
        percentages(i).cr_shaft = nan;
        percentages(i).cr_spine = nan;
        percentages(i).cr_synapse = nan;
        count(i).cr_shaft = nan;
        count(i).cr_spine = nan;
    end
    
    if any(results(ind,8))    
        percentages(i).pv_shaft = sum(pv & shaft)/N_shaft;
        percentages(i).pv_spine = sum(pv & spine)/N_spine;
        percentages(i).pv_synapse = sum(pv & (shaft|spine))/N_synapse;
        count(i).pv_shaft = sum(pv & shaft);
        count(i).pv_spine = sum(pv & spine);
    else
        percentages(i).pv_shaft = nan;
        percentages(i).pv_spine = nan; 
        percentages(i).pv_synapse = nan;
        count(i).pv_shaft = nan;
        count(i).pv_spine = nan;
    end

%    if ~isnan(percentages(i).som_shaft) ||~isnan(percentages(i).syt2_shaft)
%        disp(['mouse=' db(i).mouse ',stack=' db(i).stack ',som_shaft=' num2str(percentages(i).som_shaft)]);
%        disp(['mouse=' db(i).mouse ',stack=' db(i).stack ',syt2_shaft=' num2str(percentages(i).syt2_shaft)]);
%    end
end

%perc_array=reshape(struct2array(percentages),length(fields(percentages)),length(percentages))';

