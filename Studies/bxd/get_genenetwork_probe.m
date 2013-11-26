function [val val_sem]=get_genenetwork_probe(strain,db,probesets,probes,zscr)
%GET_GENENETWORK_PROBE gets value of probe or trait from genenetwork for strain
%
%  [VAL VAL_SEM]=GET_GENENETWORK_PROBE(STRAIN,DB,PROBESETS,PROBE,ZSCR)
%
%   STRAIN = BXD-strain, e.g. 'C57Bl/6J' or 'BXD-34'
%   DB = database, e.g. 'HC_M2_0606_P' or 'BXDPublish'
%   PROBESETS e.g. '98332_at' or '10031', or {'98332_at','98332_at'}
%   PROBES, probe in probeset, e.g. '119637' or a celllist corresponding
%   with list of PROBESETS
%        if isempty(PROBES) an average is returned for all probes in probest
%        if PROBES='all', all are returned in val
%   if ZSCR is true, returns the z-score in VAL
%
% e.g. http://robot.genenetwork.org/webqtl/main.py?cmd=get&probeset=98332_at&db=bra08-03MAS5&probe=119637&format=col
%
%  2008-2013, Alexander Heimel
%
if nargin<5
    zscr = [];
end
if isempty(zscr)
    zscr = false;
end
if nargin<4
    probes='';
end

if ~iscell(probesets)
    probesets = {probesets};
end

val = nan(length(probesets),1);
val_sem = nan(size(val));

probe = probes;
for p=1:length(probesets)
    probeset = probesets{p};
    if iscell(probes)
        probe = probes{p};
    end
    if isnumeric(probe)
        probe=num2str(probe);
    end
    if isnumeric(probeset)
        probeset=num2str(probeset);
    end
    
    val(p)=nan;
    
    if ~isunix
        disp('Can only do this computation on a unix computer, due to absence of wget');
        return
    end
    
    tmptraitfile=['~/Temp/bxdtrait' db '_' probeset '_' probe];
    
    if ~exist(tmptraitfile,'file')
        % load page
        traitpage=['http://robot.genenetwork.org/webqtl/main.py?' ...
            'cmd=get&db=' db '&probe=' probe '&format=col&probeset=' probeset];
        cmd=['!wget -q "' traitpage '" -O ' tmptraitfile ];
        disp(cmd);
        eval(cmd);
    end
    
    strain = formatstrain(strain);
    
    f = fopen(tmptraitfile);
    result = textscan(f,'%s%f','Delimiter','\t');
    fclose(f);
    
    if length(result{2})<4
        return
    end
    
    
    if zscr
        result{2}(4:end)=zscore(result{2}(4:end));
    end
    
    ind = strmatch(strain,result{1},'exact');
    if length(ind)==1
            val(p) = result{2}(ind);
    end
end


%cmd=['grep -w ' strain ' ' tmptraitfile ' | cut -f2-' ];
% if strain(end)=='*'
%     strain = strain(1:end-1);
%     cmd=['grep ' strain ' ' tmptraitfile ' | cut -f2-' ];
% else
%     cmd=['grep -w ' strain ' ' tmptraitfile ' | cut -f2-' ];
% end
% [status,result]=system(cmd);
% if ~status
%   % remove </pre> from end
%   p=findstr(result,'</pre>');
%   if ~isempty(p)
%     result=result(1:p-1);
%   end
%   if result(end)==10
%       result = result(1:end-1);
%   end
%   val=split(result,9); % split at tab
%   val=split(result,10); % split at nl
% %   for i=1:length(val)
% %     val{i}=eval(val{i});
% %   end
%   val = cellfun(@str2double,val)';

%  val=[val{:}];



function strain = formatstrain(strain)
strain=upper(strain); % for C57Bl/6J
strain=strain(strain~='-'); % remove hyphens, i.e. BXD-01 -> BXD01
if length(strain)>4 && strcmp(strain(1:min(end,3)),'BXD') &&strain(4)=='0' % remove leading zeros, i.e. BXD01 -> BXD1
    strain=['BXD' strain(5:end)];
end

