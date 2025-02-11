function [cell,data_units,data_ec,data_ttl]=load_sonwave( file )

if nargin<1
	file='';
end
%if isempty(file)
%	file='/home/data/InVivo/Electrophys/2007/11/12/t00009/data.smr'
%end




ttlchannelname='TTL';
unitchannelname='Spikes';
ecchannelname='singleEC';

fid=fopen(file);
if fid==-1
	disp(['Error: failed to open  ' smrfilename]);
	cells=[];
	return;
end

list_of_channels=SONChanList(fid);

list_of_channels(:).title


unitchannel=findchannel(list_of_channels,unitchannelname);
ttlchannel=findchannel(list_of_channels,ttlchannelname);
ecchannel=findchannel(list_of_channels,ecchannelname);
if unitchannel==-1 | ttlchannel==-1
	return  % didn't find one of the channels
end
[data_units,header_units]=SONGetChannel(fid,unitchannel);
if header_units.kind~=6
	disp('Warning: unitchannel is of unexpected kind');
end
[data_ec,header_ec]=SONGetChannel(fid,ecchannel);
if header_ec.kind~=6
	disp('Warning: unitchannel is of unexpected kind');
end
[data_ttl,header_ttl]=SONGetChannel(fid,ttlchannel);
if header_ttl.kind~= 3
	disp('Warning: ttlchannel is of unexpected kind');
end
if length(data_ttl)>1
	disp('Warning: expected just one ttl');
end
fclose(fid);

data_units.markers=double(data_units.markers(:,1));


n_cells=max(data_units.markers)+1;
for c=1:n_cells
	ind=find(data_units.markers==(c-1));
	dat.adc=double(data_units.adc(ind,:));
	dat.timings=data_units.timings(ind,:);
	dat.wave=mean(dat.adc,1);
	dat.noise=mean(std(dat.adc));
	
	dat.snr=(max(dat.wave)-min(dat.wave))/dat.noise
	
	cell(c)=dat;

	
end




% plot waveform
figure;
for c=1:n_cells

	subplot(n_cells,1,c)
	if ~isempty(cell(c).adc)
		h=plot(cell(c).adc','color',[0.7 0.7 0.7]);
		hold on;
		plot(mean(cell(c).adc,1),'r','linewidth',3)
	end
end


return



%
function channel=findchannel(list_of_channels,channelname)
ch=1;
channel=-1;
while ch<=length(list_of_channels)
	if strcmp(list_of_channels(ch).title,channelname)==1
		channel=list_of_channels(ch).number;
		break;
	else
		ch=ch+1;
	end
end
if channel==-1
	disp(['Error: could not find channel named ' channelname]);
end
return

