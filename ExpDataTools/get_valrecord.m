function [val,val_sem]=get_valrecord(record,measure)
%GET_VALRECORD gets measure from record
%
%   [VAL,VAL_SEM]=GET_VALRECORD(RECORD,MEASURE)
%               set record.reliable=2 to reduce stringency
%
%
% 2005-2015, Alexander Heimel
%

val = [];
val_sem = [];

switch measure
	case 'depth'
		val = record.depth;
		return
end

if ~isfield(record,'response')
	return
end

y = record.response;
dy = record.response_sem;

if isempty(y)
	return
end

conditions=[];
if ~isempty(record)
	conditions = get_conditions_from_record(record);
end

switch measure
	case 'adaptation_low'
		% adaption_low computes the slope of the response versus
		% trialnumber of the stimulus with the lowest stimulus parameter
		t=(1:size(record.response_all,1)); %number of trials
		t=t-mean(t);
		y=record.response_all;
		y=y-repmat(mean(y),size(y,1),1);
		conditions(conditions==0) = nan; % to avoid picking blank
		conditions(conditions==-2) = nan; % to avoid picking
		% shutters closed
		[m,ind] = min(conditions); %#ok<*ASGLU>
		y = y(:,ind);
		val = (t*y) / (t*t') ;
		val_sem = 0;
		return
	case 'adaptation_high'
		t=(1:size(record.response_all,1)); %number of trials
		t=t-mean(t);
		y=record.response_all;
		y=y-repmat(mean(y),size(y,1),1);
		conditions(conditions==0) = nan; % to avoid picking blank
		conditions(conditions==-2) = nan; % to avoid picking
		% shutters closed
		[m,ind]=max(conditions);
		y=y(:,ind);
		val=(t*y) / (t*t') ;
		val_sem=0;
		return
end

switch record.stim_type
	case 'retinotopy'
		if isempty(record.response)
			logmsg(['Warning response is empty for ' record.date ...
				'test ' record.test]);
		end
		switch measure
			case 'screen_center_ml'
				val=record.response(1)/1000; % convert to mm
				val_sem=nan;
			case 'screen_center_ap'
				val=record.response(2)/1000;% convert to mm
				val_sem=nan;
		end
	case 'rt_response'
		switch measure
			case 'max'
				[val,ind]=max(record.response);
				val_sem=record.response_sem(ind);
			case 'topleft'
				if mod(prod(record.stim_parameters),2)==1
					% blank stim
					val=record.response(2);
					val_sem=record.response_sem(2);
				else
					% no blank stim
					val=record.response(1);
					val_sem=record.response_sem(1);
				end
		end
	case {'od','od_bin','od_mon'}
		ind_contra=find(conditions==1);
		ind_ipsi=find(conditions==-1);
		ind_none=find(conditions==-2);
		y=thresholdlinear(y);
		
		if y(ind_none)>2*dy(ind_none)
			val=nan;
			val_sem=nan;
			logmsg('none too high')
		else
			
			switch measure
				case 'contra'
					if ~isempty(strfind(record.rorfile,'empty'))
						logmsg('ROR is empty. Cannot be used for absolute responses');
						val=nan;
						val_sem=nan;
					else
						val=y(ind_contra);
						val_sem=dy(ind_contra);
					end
				case 'ipsi'
					if ~isempty(strfind(record.rorfile,'empty'))
						logmsg('ROR is empty. Cannot be used for absolute responses');
						val=nan;
						val_sem=nan;
					else
						val=y(ind_ipsi);
						val_sem=dy(ind_ipsi);
					end
				case {'response','c+i'}
					if ~isempty(strfind(record.rorfile,'empty'))
						logmsg('ROR is empty. Cannot be used for absolute responses');
						val=nan;
						val_sem=nan;
					else
						val=y(ind_contra)+y(ind_ipsi);
						val_sem=sqrt(dy(ind_contra)^2+dy(ind_ipsi)^2);
					end
				case 'c/i'
					val=abs(y(ind_contra)/y(ind_ipsi));
					val_sem=val*...
						sqrt( (dy(ind_contra)/y(ind_contra))^2+...
						(dy(ind_ipsi)/y(ind_ipsi))^2);
				case {'c/ci','icbi','cbi'}
					val=y(ind_contra)/(y(ind_contra)+y(ind_ipsi));
					val_sem=0;
				case {'iodi','odi'}
					val=(y(ind_contra)-y(ind_ipsi))/(y(ind_contra)+y(ind_ipsi));
					val_sem=2*y(ind_ipsi)/(y(ind_contra)+y(ind_ipsi))^2* ...
						sqrt( dy(ind_contra)^2 +dy(ind_ipsi)^2);
				case 'abs_contra'
					tc=record.timecourse_roi;
					val=tc(1,ind_contra)-min(tc(:,ind_contra));
					val_sem=0;
				case 'abs_ipsi'
					tc=record.timecourse_roi;
					val=tc(1,ind_ipsi)-min(tc(:,ind_ipsi));
					val_sem=0;
				case 'abs_icbi'
					tc=record.timecourse_roi;
					valc=tc(1,ind_contra)-tc(5,ind_contra);
					vali=tc(1,ind_ipsi)-tc(5,ind_ipsi);
					valc=thresholdlinear(valc);
					vali=thresholdlinear(vali);
					val=valc/(valc+vali);
					val_sem=0;
			end
		end
	case {'sf_contrast','contrast_sf'}
		sf=record.stim_sf;
		contrast=record.stim_contrast;
		% dim y = n_contrasts x n_sf
		y=reshape(y,length(sf),length(contrast))';
		dy=reshape(dy,length(sf),length(contrast))';
		
		measure=split(measure,'_');
		switch measure{1}
			case 'sf'
				val=sf;
				val_sem=0*val;
			case 'contrast'
				val=contrast;
				val_sem=0*val;
			case {'c50','threshold','sensitivity'}
				if length(measure)>1 && ~isempty(strfind(measure{2},'cpd'))
					selected_sf=measure{2}(1:end-3);
					if strcmp(selected_sf,'all')
						indsf=(1:length(sf));
					else
						selected_sf=eval(selected_sf);
						[selsf,indsf]=find( sf> selected_sf-0.05 & sf<selected_sf+0.05 );
					end
				else	% take lowest sf
					selected_sf=min(sf);
					[selsf,indsf]=find( sf> selected_sf-0.05 & sf<selected_sf+0.05 );
				end
				val=[];val_sem=[];
				for i=indsf
					indcontrast=(1:length(contrast));
					resp=y(indcontrast,i);
					[nk_rm,nk_b,nk_n]=naka_rushton(contrast(:)',resp(:)');
					
					cn=(0:0.005:1);
					r=nk_rm* (cn.^nk_n)./ ...
						(nk_b^nk_n+cn.^nk_n) ; % without spont
					switch measure{1}
						case 'c50'
							ind=findclosest(r,0.5*max(r));
							if max(r)>1e-5
								val = [val cn(ind)]; %#ok<AGROW>
							else
								val = [val 1]; %#ok<AGROW>
							end
						case 'threshold' % 2 * mean sem is taken as threshold
							ind=findclosest(r,2*mean(dy(:)));
							if max(r)>1e-5
								val = [val cn(ind)]; %#ok<AGROW>
							else
								val = [val nan]; %#ok<AGROW> %1
							end
						case 'sensitivity' % 2 * mean sem is taken as threshold
							ind=findclosest(r,2*mean(dy(:)));
							if max(r)>1e-5
								val = [val 1/cn(ind)]; %#ok<AGROW>
							else
								val = [val 0]; %#ok<AGROW>
							end
					end
					val_sem = [val_sem nan]; %#ok<AGROW>
				end
			case 'max'
				[val,ind] = max(y(:));
				val_sem = dy(ind);
			case 'response'
				switch measure{2}
					case 'all'
						indcontrast=(1:length(contrast));
						indsf=(1:length(sf));
					case 'allcpd'
						indsf=(1:length(sf));
					otherwise
						if ~isempty(strfind(measure{2},'cpd'))
							selected_sf=eval(measure{2}(1:end-3));
							[selsf,indsf]=find( sf> selected_sf-0.05 & sf<selected_sf+0.05 );
						elseif ~isempty(strfind(measure{2},'%'))
							selected_contrast=eval(measure{2}(1:end-3));
							[selcon,indcontrast]=...
								find( contrast>(selected_contrast/100-5) & ...
								contrast< (selected_contrast/100+5));
						else
							errormsg(['Unknown response measure ' measure{2}]);
						end
				end
				switch measure{3}
					case 'all%'
						indcontrast=(1:length(contrast));
					case 'lowcontrast'
						[tmp,indcontrast]=min(contrast);
					case 'highcontrast'
						[tmp,indcontrast]=max(contrast);
					case 'lowsf'
						[tmp,indsf]=min(sf);
					case 'highsf'
						[tmp,indsf]=max(sf);
					otherwise
						if ~isempty(strfind(measure{3},'%'))
							selected_contrast=eval(measure{3}(1:end-1));
							[selcon,indcontrast]=...
								find( contrast>(selected_contrast/100-0.05) & ...
								contrast< (selected_contrast/100+0.05));
						else
							errormsg(['Unknown response measure ' measure{3} ]);
						end
				end
				
				if ~isempty(indsf)
					val=y(indcontrast,indsf);
					val_sem=dy(indcontrast,indsf);
				else
					val=nan*zeros(length(indcontrast),1);
					val_sem=val;
				end
				
				if length(measure)==4
					switch measure{4}
						case 'normalized'
							[chigh,indchigh]=max(contrast);
							[sflow,indsflow]=min(sf);
							val=val/max(y(indchigh,indsflow));
							val_sem=dy/max(y(indchigh,indsflow));
						otherwise
							logmsg(['Error unknown response measure ' measure{4} ]);
					end
				end
				
				if size(val,2)==1
					val = val';
					val_sem = val_sem';
				end
				
			case 'cutoff' % is always sf_cutoff
				switch measure{2}
					case 'lowcontrast'
						[c,ind] = min(contrast);
					case 'highcontrast'
						[c,ind] = max(contrast);
				end
				[val,rc] = cutoff_thresholdlinear(sf ,y(ind,:));
		end
		
	case {'sf','sf_temporal','sf_low_contrast','sf_low_tf'}
		x = record.stim_sf;
		blank = find(x==0);
		condind = setdiff( (1:length(x)),blank);
		baseline_fluc = std(mean(record.timecourse_ratio(1:2,:),1));
		rel_baseline_fluc = std(mean(record.timecourse_ratio(1:2,:),1)) /...
			max(abs(record.timecourse_ratio(:)));
		switch measure
			case 'sf_cutoff'
				if rel_baseline_fluc>0.25 & record.reliable~=2 %#ok<AND2>
					%disp('baseline fluctuations are too large');
					val = nan;
					val_sem = nan;
				else
					if isempty(dy)
						dy = ones(size(y))*baseline_fluc;
					end
					
					[val,rc] = cutoff_thresholdlinear(x(condind) ,y(condind));
					if rc>0
						val = NaN;
						val_sem = NaN;
					else
						% calculate error in fit
						error_fit = abs(y(condind)-thresholdlinear((x(condind)-val)*rc));
						too_large = sum(double(error_fit>1.5*dy(condind)));
						if too_large>1 & record.reliable~=2 %#ok<AND2>
							%disp('fit in error is larger than std.dev.');
							val = NaN;
						end
						
						% calculate error in acuity
						val_1 = cutoff_thresholdlinear(x(condind) ,y(condind)+dy(condind) );
						val_2 = cutoff_thresholdlinear(x(condind) ,y(condind)-dy(condind));
						if isnan(val_2)
							val_2 = 0;
						end
						val_sem = abs(val_1-val_2)/2;
						if val_sem>0.15 & record.reliable~=2 %#ok<AND2> %cpd error too large
							val = NaN;
							val_sem = NaN;
						end
					end
				end
			case 'max_response'
				[val,mi] = max(y(condind));
				val_sem = dy(condind(mi));
			case 'response'
				val = y(condind);
				val_sem = dy(condind);
			case 'sf'
				val = x(condind);
				val_sem = 0*x;
			case 'response_0.1cpd'
				[sf,ind] = find( x(condind)> 0.05 & x(condind)<0.15 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
			case 'response_0.2cpd'
				[sf,ind] = find( x(condind)> 0.15 & x(condind)<0.25 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
			case 'response_0.3cpd'
				[sf,ind] = find( x(condind)> 0.25 & x(condind)<0.35 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
			case 'response_0.4cpd'
				[sf,ind] = find( x(condind)> 0.35 & x(condind)<0.45 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
			case 'response_0.5cpd'
				[sf,ind] = find( x(condind)> 0.45 & x(condind)<0.55 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
			case 'response_0.6cpd'
				[sf,ind] = find( x(condind)> 0.55 & x(condind)<0.65 );
				val = y(condind(ind));
				val_sem = dy(condind(ind));
		end
	case 'tf'
		x = conditions;
		blank = find(x==0);
		condind = setdiff( (1:length(x)),blank);
		switch measure
			case 'tf_cutoff'
				val = cutoff_thresholdlinear([ x(condind)  30],[y(condind) 0]);
				val_sem = nan;
			case 'high_response'
				[hightf,indm] = max(conditions);
				val = hightf;
				val_sem = y(indm);
			case 'max_response'
				[val,mi] = max(y(condind));
				val_sem = dy(condind(mi));
			case 'ratio15_5'
				i5 = find(x==5);
				i15 = find(x==15);
				if ~isempty(i15) && ~isempty(i5)
					val = y(i15)/y(i5);
					val_sem = 0;
				else
					val = nan;
					val_sem = nan;
				end
			case 'tf_slope'
				[cutoff,val,offset]=...
					cutoff_thresholdlinear([ x(condind)  40],[y(condind) 0]);
				val_sem=nan;
			case 'response@15'
				i15=find(x==15);
				if ~isempty(i15)
					if y(i15)-2*dy(i15)>0
						val=1;
						val_sem=0;
					else
						val=0;
						val_sem=0;
					end
				else
					val=nan;
					val_sem=nan;
				end
				
		end
		
	case 'contrast'
		x=conditions;
		blank=find(x==0);
		condind=setdiff( (1:length(x)),blank);
		switch measure
			case 'c50'
				val=halfwaypoint(x(condind),y(condind))*100;
				val_sem=nan;
			case 'contrast_cutoff'
				val=100*cutoff_thresholdlinear([-0.1 -0.05  0 x(condind)],...
					[0 0 0 y(condind)]);
				val_sem=nan;
			case 'contrast'
				val=x(condind);
				val_sem=0*x;
			case 'response'
				val=y(condind);
				val_sem=dy(condind);
			case 'response_normalized'
				[m,indc]=max(x(condind));
				val=y(condind)/y(condind(indc));
				val_sem=dy(condind)/y(condind(indc));
			case 'response_roi'
				onsetframe=floor(record.stim_onset/0.6);
				offsetframe=min(size(record.timecourse_roi,1),ceil(record.stim_offset/0.6));
				% hard coded frame duration
				logmsg('hard coded frameduration of 0.6s');
				r=record.timecourse_roi;
				r=(r-repmat(mean(r(1:onsetframe,:),1),13,1))./repmat(mean(r(1:onsetframe,:),1),13,1);
				val=-mean(r(onsetframe+1:offsetframe,condind),1);
			case 'response_roi_normalized'
				onsetframe=floor(record.stim_onset/0.6);
				offsetframe=min(size(record.timecourse_roi,1),ceil(record.stim_offset/0.6));
				% hard coded frame duration
				logmsg('hard coded frameduration of 0.6s');
				r=record.timecourse_roi;
				r=(r-repmat(mean(r(1:onsetframe,:),1),13,1))./repmat(mean(r(1:onsetframe,:),1),13,1);
				val=-mean(r(onsetframe+1:offsetframe,condind),1);
				val=val/max(val);
		end
	otherwise
		errormsg(['Stim type ' record.stim_type ' is not implemented.'])
end

