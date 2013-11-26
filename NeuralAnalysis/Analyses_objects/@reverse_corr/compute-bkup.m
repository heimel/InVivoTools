function newrc = compute(rc)

%  Part of the NeuralAnalysis package
%
%  NEWRC = COMPUTE(RC)
%
%  Compute the reverse correlation, receptive field maximum, and receptive
%  field rectangle.  These are returned via a call to GETOUTPUT.
%
%  See also:  REVERSE_CORR, GETOUTPUT

 % fix for multiple cells

I = getinputs(rc); p = getparameters(rc); in = rc.internal; c = rc.computations;
 % did timing data change?
td = isempty(in.oldint)|(eqlen(in.oldint,p.interval))|...
              isempty(in.oldtimeres)|(eqlen(in.oldtimeres,p.timeres));
 % did feature parameters change?
fpc = td;
if td,
   offsets = p.interval(1):p.timeres:p.interval(2),
   in.edges = {}; in.counts = {};
   for m=1:length(I.stimtime),
     frameTimes = I.stimtime(m).mti{1}.frameTimes;
     frameTimes(end+1)=frameTimes(end)+mean(diff(frameTimes)); %time last frame
     
     in.edges{m} = sort(
       tmp=repmat(frameTimes,size(offsets(1:end-1),1)+repmat(offsets(1:end-1)',1,size(frameTimes,2));
       
        mn=min(min(in.edges{m})); mx=max(max(in.edges{m}));
     for c=1:length(I.spikes),
        dat=get_data(I.spikes{c},[mn mx],2);
        for o=1:length(offsets),
          if ~isempty(dat),
            [dummy,in.counts{m}(o,:)]=histc(dat,in.edges{m}(o,:));
          else, in.counts{m}(o,:)=zeros(size(in.edges{m}(o,:)));
          end;
        end;
     end;
   end;
end;
if fpc,
   [x,y,rect]=getgrid(I.stimtime(1).stim);
   offsets = p.interval(1):p.timeres:p.interval(2);
   spikecount = [];
   fea = cell(length(I.spikes),length(offsets));
   rc_avg = zeros(length(I.spikes),length(offsets),x,y,3);
   rc_std = zeros(length(I.spikes),length(offsets),x,y,3);
   rc_raw = zeros(length(I.spikes),length(offsets),x,y,3);
   for m=1:length(I.stimtime),
     [x,y,rect]=getgrid(I.stimtime(m).stim);
     v = getgridvalues(I.stimtime(m).stim);
     f = getfeatures(v,I.stimtime(m).stim,p,x,y,rect); % features
     for c=1:length(I.spikes),
       for o=1:size(in.counts{m},1),
         inds=find(in.counts{m}(o,:));
         norms(c,o) = length(inds);
         fea{c,o} = cat(3,fea{c,o},f(:,:,in.counts{m}(o,inds),:));
       end;
     end;
   end;
   for c=1:length(I.spikes),
     for o=1:length(offsets),%size(mean(fea{c,o},3)),
        rc_avg(c,o,:,:,:) = mean(fea{c,o},3);
        rc_std(c,o,:,:,:) =  std(fea{c,o},0,3);
        rc_raw(c,o,:,:,:) =  sum(fea{c,o},3);
     end;
   end;

   in.oldint = p.interval; in.oldtimeres = p.timeres;
   
   r_c=struct('rc_avg',rc_avg,'rc_std',rc_std,'rc_raw',rc_raw,...
          'bins',{in.edges},'norms',norms);
else, r_c = rc.computations.reverse_corr;
end;

%if in.selectedbin==0,
%   st=getstim(rc);p2=getparameters(st);rect=p2.rect;pixSize=p2.pixSize;
%   i=1;j=1; i=i(1);j=j(1); px=rect(1)-1+i; py=rect(2)-1+j;
%
%   width  = rect(3) - rect(1); height = rect(4) - rect(2);
%   if (pixSize(1)>=1), X = pixSize(1); else, X = (width*pixSize(1)); end;
%   if (pixSize(2)>=1), Y = pixSize(2); else, Y = (height*pixSize(2)); end;
%   x=fix((px-rect(1))/X); y = fix((py-rect(2))/Y); b=1+x*fix(Y/height)+y;
%   in.selectedbin = b;
%   thecenter = [px py]; thecenterrect = [px-100 py-100 px+100 py+100];
%else,thecenter=rc.computations.center;thecenterrect=rc.computations.center_rect;
%end;
thecenter=0;thecenterrect=0;   
rc.internal = in;
rc.computations=struct('reverse_corr',r_c,...
     'center',thecenter,'center_rect',thecenterrect);
newrc = rc;
