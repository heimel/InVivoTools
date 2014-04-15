% This function displays some preliminary results in a multiplot figure
% From left to right will be:
% * a-wave troughs (red) and b-wave peaks (blue)
% * a-wave times (red) and b-wave times (blue)
% * Calibration curves
% * Amount of samples thrown away for each condition (averaging set)
%
% For multichannel recording it will use the second half of the subplots
% In between erg_analysis_block_hysteresis will display its results.
%
% The function gathers the data via the cached getdata functions, this
% speeds up subsequent reads, also for offline analysis later on.

function erg_analysis_block_pulsetrain(filename, calibfilename)
global ergConfig;

[block duration stimuli] = erg_getdata_div(filename);
accepted_types = {'pulsetrain'};
if isempty(block)
    return
end

if (~ismember(block.type,accepted_types)) 
    errormsg('Can not analyze this blocktype with this type of analysis, I am so sorry!'); 
    return
end;
load(calibfilename, 'calib_saved');
[channel_avg stims prepulse_period] = erg_getdata_avg(filename); % get average waveforms
[channel_bsc prepulse_samples stims] = erg_getdata_bsc(filename);  % get a- and b-wave amplitudes

%try
    %	figure(ergConfig.subplotfig);
    ergConfig.subplotfig = figure;
	subplot1(block.numchannels,4,'Gap',[0.1 0.1]); % used to be 16, Alexander 2012-05-03
%catch
%	ergConfig.subplotfig =  figure(1);
	%subplot1(4,4,'Gap',[0.02 0.02]); hold off;
%	subplot1(block.numchannels,4,'Gap',[0.1 0.1]); hold off; % used to be 4x4, Alexander 2012-05-03
%end

sweeps_start = 1;
sweeps_end = size(channel_avg{1}.resultset,1);
sweeps_effective = sweeps_end - sweeps_start + 1;
totsamples = size(channel_avg{1}.resultset,2);

for chan = 1:block.numchannels

	% plotting measures
	figname = ['ERG Analysis'];
    	figure(ergConfig.subplotfig);
	set(ergConfig.subplotfig,'Name',figname,'NumberTitle','off');
	avg = channel_avg{chan};
	bsc = channel_bsc{chan};

	disp('ERG_BLOCK_PULSETRAIN: Assuming blue intensity to cd conversion. Incorrect for other light sources!');
	subplot1(1+(chan-1)*4); hold off;

	intensities  = log10(stims(sweeps_start:sweeps_end)*ergConfig.convert2cd.blue); % log cd s / m^2
	awave_amplitudes = bsc.awave; %-(bsc.awave-bsc.baseline);%/ergConfig.voltage_amplification*1000000; % uV
	bwave_amplitudes = bsc.bwave; %(bsc.bwave-bsc.awave);%/ergConfig.voltage_amplification*1000000; % uV

	plot(intensities,awave_amplitudes,'b',...
		intensities,bwave_amplitudes,'r');
	xlabel('Log intensity (cd s/m^2)');
	ylabel('Amplitude (\muV)');
	ylim([-50 500]);
	subplot1(2+(chan-1)*4); hold off;
	plot(log10(stims(sweeps_start:sweeps_end)*ergConfig.convert2cd.blue),bsc.atime/10,'b',...
		log10(stims(sweeps_start:sweeps_end)*ergConfig.convert2cd.blue),bsc.btime/10+30,'r');
	xlabel('Log intensity (cd s/m^2)');
	ylabel('Time (ms)');
	subplot1(3+(chan-1)*4); hold off;
	cA = calib_saved.(['greenLow']);  cB = calib_saved.(['greenHigh']);   cC = calib_saved.(['blueLow']);   cD = calib_saved.(['blueHigh']);   cE = calib_saved.(['UVLow']);    cF = calib_saved.(['UVHigh']);
	plot(cA.in,cA.out,'g:'); hold on; plot(cB.in, cB.out/100,'g-'); hold on;
	plot(cC.in,cC.out,'b:'); hold on; plot(cD.in, cD.out/100,'b-'); hold on;
	plot(cE.in,cE.out,'m:'); hold on; plot(cF.in, cF.out/100,'m-');
	ylabel('Calibration');
	subplot1(4+(chan-1)*4); hold off;  plot((sweeps_start:sweeps_end),avg.nRemoved,'r.');
	xlabel('Sweep number');
	ylabel('Number removed');


	[export_path,export_basename]=fileparts(filename);
    if block.numchannels>1
        export_basename = [export_basename '_chan' num2str(chan)]; %#ok<AGROW>
    end
    
	export_filename = [export_basename '.xls'];

    
    if isunix
        logmsg('No Excel, thus writing csv-file.');
        warning('off','MATLAB:xlswrite:NoCOMServer');
    end
	xlswrite(fullfile(export_path,export_filename),...
        [intensities' awave_amplitudes' bwave_amplitudes']);

    export_filename = [export_basename '_data.png'];
	saveas(gcf,fullfile(export_path,export_filename),'png');


	% plotting wave forms
	figure('Name',['Overlayed wave forms - channel ' num2str(chan)],'NumberTitle','off');
	dstart = max([prepulse_samples,1]);
	dend = min([prepulse_samples+2000,totsamples]);
	X = repmat((dstart-round(prepulse_samples):dend-round(prepulse_samples))/(totsamples/duration),[sweeps_effective,1])';
	Y = avg.resultset(:,dstart:dend)';
	Y = Y /ergConfig.voltage_amplification*1000000;
	plot(X,Y);
	xlim([X(1),X(end)]);
	hold on; 
    plot(0,ylim);
	%plot(repmat(xlim,[sweeps_effective,1])',[bsc.bwave;bsc.bwave]);
	title(['Channel ' num2str(chan) ' averages']);
	ylabel('Amplitude (\muV)');
	xlabel('Time (ms)');

	export_filename = [export_basename '_waveforms.png'];
	saveas(gcf,fullfile(export_path,export_filename),'png');

	% plotting wave forms strectched out
	h = figure('Name',['Stacked wave forms' num2str(chan)],'NumberTitle','off'); 
    clf;
	p = get(h,'position');
	p(3) = p(3) / 3;
	set(h,'position',p);

	dstart = max([prepulse_samples,1]);
	dend = min([prepulse_samples+2000,totsamples]);
	X = repmat((dstart-round(prepulse_samples):dend-round(prepulse_samples))/(totsamples/duration),[sweeps_effective,1])';
	Y = avg.resultset(:,dstart:dend)';
	Y = Y /ergConfig.voltage_amplification*1000000;

	dy = repmat(((1:size(Y,2))-1)*400,size(Y,1),1);
	Y = Y - dy + max(dy(:));
	plot(X,Y);
	xlim([X(1),X(end)]);
	hold on; plot(0,ylim);
	% hold on; plot(repmat(xlim,[sweeps_effective,1])',[bsc.bwave;bsc.bwave]);
	title(['Channel ' num2str(chan) ' averages']);
	ylabel('Amplitude (\muV)');
	xlabel('Time (ms)');

	for i = 1:length(stims)
		text(max(X(:)),Y(end,i),...
			[' ' num2str(log10(stims(i)*ergConfig.convert2cd.blue),'%.1f')]);
	end
	yl = ylim;
	text(max(X(:)),yl(2),'log cd s/m^2');

	export_filename = [export_basename '_separated_waveforms.png'];
	saveas(gcf,fullfile(export_path,export_filename),'png');
end % channels
