function output=sd_threshold(recname, recparam, algor_p, output_type,output_p);

  % can assume we're at the data prefix level, not test level

  % output modes supported:  cksmultipleunit, file

output = [];
prefix = pwd;

g = dir;

numtests = 0;
numintervals = 1;
interval = [];

filelength = 0;

got_thresh=~algor_p.automatic;

theThreshes = [];

samps = [];

sd = abs(algor_p.threshold_value);

for i=3:length(g),
        if (exist(g(i).name)), cd(g(i).name); end;
	pwd,
        if exist('acqParams_out')
		disp('exploring...');

		numtests = numtests + 1;
		eval('!mac2unix acqParams_out;');
                r = loadStructArray('acqParams_out');
                j = 1;
                while((j<=length(r))&(strcmp(r(j).name,recname)==0)),j=j+1; end;

		if (j<=length(r))&(r(j).ref==recparam.ref),
			% run this folder 
		   if (~got_thresh)
                      % get threshold
		      present(numtests) = 1;

		      if strcmp(r(j).type,'tetrode'),
			fileend = [ r(j).fname '_c' ...
		        sprintf('%.2i', recparam.channel) ];
		      elseif strcmp(r(j).type,'singleEC'),
		        fileend = r(j).fname,
		      elseif strcmp(r(j).type,'intracellular'),
			fileend = r(j).fname;
		      end;

		      if (filelength == 0),
			fname=[ '/r' sprintf('%.3i',1) '_' fileend];
			data = loadIgor(fname);
			filelength = length(data);
		      end;

		      % determine threshold if necessary
			fname=[ '/r' sprintf('%.3i',1) '_' fileend];
			fna2 =[ '/r' sprintf('%.3i',2) '_' fileend];
			fna3 =[ '/r' sprintf('%.3i',3) '_' fileend];
		        if (r(j).reps>3&algor_p.automatic==1),
  			   data = [loadIgor(fname); loadIgor(fna2); ...
					loadIgor(fna3) ];
		        else, data = loadIgor(fname);
			end;
			if isfield(algor_p,'filter'), 
			     data=filterwaveform(data,algor_p.filter);
			end;
			sd = sd * std(data),
			got_thresh = 1;
		   end;
		   if (algor_p.update==0)|(~exist(output_p.filename)),
                        % we're not updating or haven't visited here yet...
		      	present(numtests) = 1;

		      	if strcmp(r(j).type,'tetrode'),
				fileend = [ r(j).fname '_c' ...
		        	sprintf('%.2i', recparam.channel) ];
		      	elseif strcmp(r(j).type,'singleEC'),
		       		fileend = r(j).fname,
		      	elseif strcmp(r(j).type,'intracellular'),
				fileend = r(j).fname;
		      	end;

		        if (filelength == 0),
				fname=[ '/r' sprintf('%.3i',1) '_' fileend];
				data = loadIgor(fname);
		 		filelength = length(data);
		        end;

			for k=1:r(j).reps, 
				%k,
				fname=[ '/r' sprintf('%.3i',k) '_' fileend];
				fna2=[ '/r' sprintf('%.3i',k+1) '_' fileend];
				data = loadIgor(fname);
				if r(j).reps==1,
				elseif k<r(j).reps,
					data = [data; loadIgor(fna2)];
				else,
					fna2=[ '/r' sprintf('%.3i',k-1) ...
						'_' fileend];
					data = [loadIgor(fna2); data];
				end;
				if isfield(algor_p,'filter'), 
				     data=filterwaveform(data,algor_p.filter);
				end;
				% now do threshold crossing check
				% cheezy but fast
				data = data * algor_p.threshold_sign;
				if algor_p.num_above == 1,
					th=find((data(1:end-1)<sd) & ...
						(data(2:end)>=sd))+1;
				elseif algor_p.num_above == 2,
					th=find((data(1:end-1)<sd) & ...
						(data(2:end)>=sd)  & ...
						(data(3:end)>=sd))+1;
				elseif algor_p.num_above == 3,
					th=find((data(1:end-1)<sd) & ...
						(data(2:end)>=sd)  & ...
						(data(3:end)>=sd)  & ...
						(data(4:end)>=sd))+1;
				elseif algor_p.num_above == 4,
					th=find((data(1:end-1)<sd) & ...
						(data(2:end)>=sd)  & ...
						(data(3:end)>=sd)  & ...
						(data(4:end)>=sd)  & ...
						(data(5:end)>=sd))+1;
				end;
				if r(j).reps==1,
				elseif k<r(j).reps,
					th = th(find(th<=filelength));
				else,
					th = th(find(th>filelength));
					th = th - filelength;
				end;
				th = (k-1)*filelength + th;
				theThreshes = [theThreshes; th];
		        end;
			eval(['save ' output_p.filename ' theThreshes']);
		   else,  % we're updating
			present(numtests) = 1;
			eval(['load ' output_p.filename ' -mat']);
		   end; 
		      disp(['thresh crossings: ' num2str(length(theThreshes))]);
			if strcmp(output_type,'cksmultiunit'),
				ci = output_p.clock_convers;
				samps = [samps ; (theThreshes- ...
				   ci(numtests,2))*r(j).samp_dt+ci(numtests,1)];
				interval(numintervals,[1 2]) =  ...
			 	  [-(ci(numtests,2)-1)*r(j).samp_dt + ...
                                   ci(numtests,1) ...
			 	   r(j).samp_dt*(-ci(numtests,2)-1) + ...
                                   ci(numtests,1) + ...
				   (r(j).reps*filelength+1)*r(j).samp_dt];
				numintervals = numintervals + 1;
			end;
			filelength = 0;
			theThreshes = [];
		else, present(numtests)=0;
		end;
        end;
        cd(prefix);
end;

 % now, finish output

  if strcmp(output_type,'cksmultiunit'),
       algor_p2 = algor_p; algor_p2.update = 1;
       detector_params = struct('prefix',prefix,'recname',recname, ...
             'recparam', recparam, 'algor', algor_p2, 'output_type', ...
		output_type, 'output_p', output_p);
	%interval,  % debugging info
       output = cksmultipleunit(interval,output_p.desc_long, ...
		output_p.desc_brief, samps, detector_params);
	eval([output_p.varname '=output;']);
       eval(['save ' output_p.filename_obj ' ' output_p.varname ';']);
  end;
