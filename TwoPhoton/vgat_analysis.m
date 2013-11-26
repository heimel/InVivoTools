function [results, percentages, Y]= vgat_analysis

%VGAT_ANALYSIS
%
%  [RESULTS, PERCENTAGES] = VGAT_ANALYSIS
%  
% Results is a table with 8 columns:
% 1 stack index
% 2 VGAT colocalization yes (1), no (0)
% 3 normal data (1), pixelshift (2)
% 
% percentages shows % for for the normal data and the pixelshifted data
%
% 2011, Alexander Heimel & Danielle van Versendaal


db_analysis = load_tptestdb_for_analysis; 
db_vgat = db_analysis(find_record(db_analysis, ...
   ['(mouse>11.21.3.05,mouse<11.21.3.09)']));

db = [db_vgat];

% Select the records
% db_vgat = load_testdb('tptestdb_olympus_VGAT');
% db_vgat = db_vgat(find_record(db_vgat, ...
%    ['(mouse>11.21.3.05,mouse<11.21.3.09)']));
% 
% % better to make additional step?
% db = [db_vgat];

% fill the results nx3-matrix
count=1;
for i=1:length(db)
    if ~isfield(db(i).ROIs,'celllist')
        continue;
    end
    rois = db(i).ROIs.celllist;
    comment = db(i).comment;
    for j=1:length(rois);
        results(count,1)=i;
        if ismember('VGAT',rois(j).labels)
            results(count,2)= 1;
        else
            results(count,2)= 0;
        end
        if ~isempty(strfind(lower(comment),'pixelshift'))
            results(count,3)=2;
        else
            results(count,3)=1;
        end
        results(count,4) = median(rois(j).zi);
        count=count+1;
    end
end
 
% Calculate the percentages and store in percentages
for i=1:max(results(:,1))
    ind_slice_normal = find(results(:,1)==i & results(:,3)==1 );
    ind_slice_normal_top = find(results(:,1)==i & results(:,3)==1 & results(:,4)<6);
    ind_slice_normal_bottom = find(results(:,1)==i & results(:,3)==1 & results(:,4)>=6);
    ind_slice_shifted = find(results(:,1)==i & results(:,3)==2 );
    ind_slice_shifted_top = find(results(:,1)==i & results(:,3)==2 & results(:,4)<6);
    ind_slice_shifted_bottom = find(results(:,1)==i & results(:,3)==2 & results(:,4)>=6);
    percentages(i).normal_all = sum(results(ind_slice_normal,2))/length(ind_slice_normal)*100;
    percentages(i).normal_top = sum(results(ind_slice_normal_top,2))/length(ind_slice_normal_top)*100;
    percentages(i).normal_bottom = sum(results(ind_slice_normal_bottom,2))/length(ind_slice_normal_bottom)*100;
    percentages(i).shifted_all = sum(results(ind_slice_shifted,2))/length(ind_slice_shifted)*100;
    percentages(i).shifted_top = sum(results(ind_slice_shifted_top,2))/length(ind_slice_shifted_top)*100;
    percentages(i).shifted_bottom = sum(results(ind_slice_shifted_bottom,2))/length(ind_slice_shifted_bottom)*100;
end

%Average percentage, std and SEMS for each label separately for shafts and spines across stacks
labels = {'normal','shifted'};
position = {'all','top','bottom'};
Means = zeros(length(labels),length(position));
for i=1:length(labels)
    for p=1:length(position)
        index = ( [ percentages.([labels{i} '_' position{p}] ) ]>=0);
        Means(i,p)=mean([percentages(:,index).([labels{i} '_' position{p}] )]);
        Stdevs(i,p)=std([percentages(:,index).([labels{i} '_' position{p}] )]);
        SEMs(i,p)= sem([percentages(:,index).([labels{i} '_' position{p}] )]);
    end
end

figure
Y=Means;
E=SEMs;
%uses the errorb function of Jonathan Lansey (BSD license)
%http://www.mathworks.com/matlabcentral/fileexchange/27387-create-healthy-looking-error-bars
errorb(Y,E)


