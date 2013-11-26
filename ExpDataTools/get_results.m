function [r,r_sem,mousenames,ages]=get_results(mice,stim_type,measure,eye,...
    verbose,mousedb,testdb,reliable)
%GET_RESULTS from experiment and mouse databases
%
% [r,r_sem,mousenames,ages]=get_results(mice,stim_type,measure,eye,...
%						    verbose,mousedb,testdb,reliable)
%
%      MICE is condition list like, 'strain=C57Bl/6J, type=MD 7d*'
%      STIM_TYPE is e.g. od
%      MEASURE is e.g. c/i
%      EYE is '','both','contra','ipsi'
%      MOUSENAMES is cell-list of mouse names
%      AGES is vector of ages in days
%      VERBOSE is 1 gives a line of informative output per result
%      MOUSEDB is mouse database
%      TESTDB is test database
%      RELIABLE [default=1] 1 to include only reliable measurements,
%                 0 to include all
%
% 2005, Alexander Heimel
%
if nargin<8;reliable=[];end
if nargin<7;testdb=[];end
if nargin<6;mousedb=[];end
if nargin<5;verbose=[];end
if nargin<4;eye='';end

if isempty(reliable)
    reliable=1;
end
if isempty(verbose)
    verbose=1;
end

r=[];
r_sem=[];
mousenames={};
ages=[];

if isempty(mousedb)
    %  disp('loading mousedb');
    mousedb=load_mousedb;
end
if isempty(testdb)
    %  disp('loading testdb');
    testdb=load_testdb;
end

indmice=find_record(mousedb,mice);

if isempty(indmice)
    return
end


%disp([ 'Found ' num2str(length(indmice)) ' mice of ' mice ]);



fid=fopen('results.csv','a');

for i_mouse=indmice
    mouse=mousedb(i_mouse).mouse;
    vals=[];
    val_sems=[];
    age_on_experiment=nan;
    switch stim_type
        case 'none' %means a field from the mouse_db
            switch measure
                case 'weight'
                    vals = get_mouse_weight( mousedb(i_mouse));
                case 'bregma2lambda'
                    vals=mousedb(i_mouse).bregma2lambda;
            end
            
        otherwise % get values from test_db
            cond=[ 'mouse=' mouse ', stim_type=' stim_type ];
            if reliable==1
                cond=[cond ', reliable=1'];
            end
            if ~isempty(eye)
                cond=[cond ', eye=' eye];
            end
            
            indrecords=find_record(testdb,cond);
            if ~isempty(indrecords)
                for i_record=indrecords
                    record=testdb(i_record);
                    [val,val_sem]=get_measure_from_record(record,measure);
                    if isempty(val)
                        [val,val_sem]=get_valrecord(record,measure,mousedb(i_mouse));
                    end
                    
                    if isempty(val)
                        disp(['empty val for ' record.mouse ' in test ' record.test]);
                    elseif isnan(val)
                        disp(['NaN val for ' record.mouse ' in test ' record.test]);
                    else
                        vals(end+1)=val;
                        val_sems(end+1)=val_sem;
                        age_on_experiment=age(mousedb(i_mouse).birthdate,record.date);
                    end
                end
            end
    end
    if ~isempty(vals)
        r(end+1)=nanmean(vals);
        r_sem(end+1)=nanmean(val_sems);
        mousenames{end+1}=mouse;
        ages(end+1)=age_on_experiment;
        sval=num2str(r(end),2);
        ssem=num2str(r_sem(end),2);
        if verbose
            mr=mousedb(i_mouse);
            outputline(fid,mouse,mr.strain,mr.type,mr.sex,mr.tg_number,...
                mr.lsl,mr.typing_lsl,mr.koki,mr.typing_koki,mr.cre,mr.typing_cre,sval,ssem)
        end
    end
end


n=length(find(~isnan(r)));
%if n==0
%  disp('no matching records found.');
%else

strain=getfieldcrit(mice,'strain');
type=getfieldcrit(mice,'type');
sex=getfieldcrit(mice,'sex');
tg_number=[];
lsl=getfieldcrit(mice,'lsl');
typing_lsl=[];
koki=getfieldcrit(mice,'koki');
typing_koki=[];
cre=getfieldcrit(mice,'cre');
typing_cre=[];

if verbose
    outputline(fid,'mean',strain,type,sex,tg_number,lsl,typing_lsl,koki,typing_koki,cre,typing_cre,nanmean(r),[])
    outputline(fid,'std',strain,type,sex,tg_number,lsl,typing_lsl,koki,typing_koki,cre,typing_cre,nanstd(r),[])
    outputline(fid,'count',strain,type,sex,tg_number,lsl,typing_lsl,koki,typing_koki,cre,typing_cre,n,[])
end

fclose(fid);


return

function outputline(fid,name,strain,type,sex,tg_number,lsl,typing_lsl,koki,typing_koki,cre,typing_cre,sval,ssem)
output=sprintf('%-12s,%-12s,',name,strain);
output=[output sprintf('%s,',type)];
output=[output sprintf('%5s,',sex)];
output=[output sprintf('%6d,',tg_number)];
output=[output sprintf('%s,',lsl)];
output=[output sprintf('%d,',typing_lsl)];
output=[output sprintf('%s,',koki)];
output=[output sprintf('%d,',typing_koki)];
output=[output sprintf('%s,',cre)];
output=[output sprintf('%d,',typing_cre)];
if isnumeric(sval)
    if ~isnan(sval)
        sval=num2str(sval,2);
    else
        sval='x';
    end
end
output=[output sprintf('%s,',sval)];
if isnumeric(ssem)
    if ~isnan(ssem)
        ssem=num2str(ssem,2);
    else
        ssem='x'; % to comply with webqtl data entry format
    end
end
output=[output sprintf('%s',ssem)];
output=[output sprintf('\n')];
fprintf(output);
if ~isempty(fid)
    fprintf(fid,output);
end
return


function field=getfieldcrit(mice,fieldname)
field='*';
p=findstr(mice,[fieldname '=']);
if ~isempty(p)
    pc=find(mice(p+1:end)==',');
    if isempty(pc)
        field=mice(p+length(fieldname)+1:end);
    else
        field=mice(p+length(fieldname)+1:p+pc(1));
    end
end
