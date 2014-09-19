function [outstims,binvals]=reverse_corr(BLstim, frameTimes, spikedata, interv)
% broken, needs work big time, get some data
 % no error handling yet

  width  = BLstim.rect(3) - BLstim.rect(1);
  height = BLstim.rect(4) - BLstim.rect(2);

  % set up grid
  if (BLstim.pixSize(1)>=1),
 	 X = BLstim.pixSize(1);
  else, X = (width*BLstim.pixSize(1)); 
  end;

  if (BLstim.pixSize(2)>=1),
 	 Y = BLstim.pixSize(2);
  else, Y = (height*BLstim.pixSize(2)); 
  end;

  i = 1:width;
  x = fix((i-1)/X)+1;
  i = 1:height;
  y = fix((i-1)/Y)+1;
  XY = x(end)*y(end);

  grid = ([(x-1)*y(end)]'*ones(1,length(y))+ones(1,length(x))'*y)';
  g = reshape(1:width*height,height,width);
  corner = zeros(Y,X); corner(1) = 1;
  cc=reshape(repmat(corner,height/Y,width/X).*g,width*height,1);
  corners = cc(find(cc))';
  footprint = reshape(g(1:Y,1:X),X*Y,1)-1;
  inds=ones(1,X*Y)'*corners+footprint*ones(1,XY);
  
  blinkList = repmat(1:size(inds,2),1,BLstim.repeat);
  if (BLstim.random),
	rand('state',BLstim.randState);
	in = randperm(length(blinkList));
	blinkList = blinkList(in);
	%blinkList(1:10),
  end;

  %outstims = cell(length(spikedata),3);
  bins = cell(length(spikedata),1);
  plus = interv(2); minus = interv(1);
  intervals = [frameTimes+minus ;frameTimes+plus];
  Je = ones(1,size(inds,1));

  outstims = {};
  for i=1:length(spikedata),
     s_d{i} = get_data(spikedata(i),[frameTimes(1)+minus frameTimes(end)+plus]);
     bins{i}=zeros(1,size(inds,2));
     for k=1:length(s_d{i}),  % loop over spikes, since potentially fewer
           % speed up possible here - do later
        p=find(s_d{i}(k)>=intervals(1,:)&s_d{i}(k)<=intervals(2,:));
        if ~isempty(p), bins{i}(blinkList(p))=bins{i}(blinkList(p))+1; end;
     end;
     for j=1:1,  % maybe return one for each color channel
	image = repmat(0,size(grid));
	image(inds(:,1:size(inds,2)));
	image(inds(:,1:size(inds,2))) = (bins{i}'*Je)'; % *BLstim.value(j);
	os{1,j} = image;
     end;
        binvals = bins;
	%outstims{i,2} = bins{i};
  end;
