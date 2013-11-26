function [results, fracs, summary] = interneuron_stainings
%INTERNEURON_STAININGS generates a matrix results one for the control and
%one for the MD condition, and each interneuron marker (1 PV, 2 VIP, 3 SOM, 4 CR). 
%On the rows are the different ROIs for all the records and the four columns
%represent (logical):
% 1 colocalized shaft punctum
% 2 non-colocalized shaft punctum 
% 3 colocalized spine punctum fourth a 
% 4 non-colocalized spine punctum 
% 5 % colocalized shafts
% 6 % colocalized spines
%
% Fracs sums this for each record and summary displays the means and SEMS/stdevs.
%
% 2012, Danielle van Versendaal
%

db=load_testdb('tptestdb_olympus_colocalization.mat');
db_imm = db(find_record(db, ...
    'mouse!11.21.12022p37*, stack!*overview*'));

labels = {'PV','VIP','SOM','CR'};

for c = 1:2
    switch c
        case 1 % control
            sutcrit = ['mouse!*SUT*,'];
        case 2 % suture
            sutcrit = ['mouse=*SUT*,'];
    end
    count=1;
    for l = 1:length(labels)
        results{c,l} = [];
        %     db = db_all{c};
        crit = [sutcrit 'mouse!11.21.12022p37*,'...
              'stack=' labels{l} '*' ];
        crit
        db = db_imm( find_record(db_imm, crit));
        length(db)
        for i=1:length(db)
            rois = db(i).ROIs.celllist;
            for j=1:length(rois);
                %results_ctrl_PV(1,1)=i;
                results{c,l}(count,1)=i;
                
                if ismember('shaft',rois(j).type)
                    results{c,l}(count,2)= 1;
                elseif ismember('spine',rois(j).type)
                    results{c,l}(count,2)= 2;
                else
                    results{c,l}(count,2)= 0;
                end
                
                %if ismember('PV',rois(j).labels)
                if ismember(labels{l},rois(j).labels)
                    results{c,l}(count,3)= 1;
                else
                    results{c,l}(count,3)= 0;
                end
                
                
                count=count+1;
                
                %total of gephyrin puncta that are either on a shaft or
                %spine
                total = sum((results{c,l}(:,2))==1 | results{c,l}(:,2)==2 );
                totalsh = sum((results{c,l}(:,2))==1);
                totalsp = sum(results{c,l}(:,2)==2);
                %fraction shafts that colocalize with label during
                %condition
                fracs{c,l}(i,1) = (sum(results{c,l}(:,2)==1 & results{c,l}(:,3)==1))/total;
                %fraction shafts that do not colocalize with label during
                %condition
                fracs{c,l}(i,2) = (sum(results{c,l}(:,2)==1 & results{c,l}(:,3)==0))/total;
                %fraction spines that colocalize with label during
                %condition
                fracs{c,l}(i,3) = (sum(results{c,l}(:,2)==2 & results{c,l}(:,3)==1))/total;
                %fraction spines that do not colocalize with label during
                %condition
                fracs{c,l}(i,4) = (sum(results{c,l}(:,2)==2 & results{c,l}(:,3)==0))/total;
                %fraction of shafts that colocalizes during condition
                fracs{c,l}(i,5) = (sum(results{c,l}(:,2)==1 & results{c,l}(:,3)==1))/totalsh;
                %fraction of shafts that colocalizes during condition 
                fracs{c,l}(i,6) = (sum(results{c,l}(:,2)==2 & results{c,l}(:,3)==1))/totalsp;
               
                for k=1:6
                    summary.means{c,l}(:,k) = nanmean(fracs{c,l}(:,k));
                    summary.stdevs{c,l}(:,k) = nanstd(fracs{c,l}(:,k));
                    summary.sems{c,l}(:,k) = nansem(fracs{c,l}(:,k));
                end
                
            end % j (rois)
        end % i (db)
    end % l (label/staining)
    clear('count')
end % c (condition)

% for l=1:4
% A=[summary_p37.means{1,l}(1,5) ; summary100.means{1,l}(1,5); summary_p37.means{1,l}(1,6); summary100.means{1,l}(1,6)];
% B=[summary_p37.sems{1,l}(1,5) ; summary100.sems{1,l}(1,5); summary_p37.sems{1,l}(1,6); summary100.sems{1,l}(1,6)];
% figure
% errorb(A,B)
% hold on
% bar(A)
% end

A=fracs_p37{1,4}(:,5);
    	B=fracs_p37{1,4}(:,6);
    	D=[A;B];
    	for k=1:length(A);
        	D(k,2)=1;
    	end
    	for l=(length(A)+1):length(D);
        	D(l,2)=2;
    	end
    	pvalues = kruskalwallis(D(:,1),D(:,2))
