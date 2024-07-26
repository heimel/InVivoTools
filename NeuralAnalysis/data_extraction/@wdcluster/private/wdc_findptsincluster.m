function inds = wdc_findptsincluster(fea,cl)
if length(cl)==0, inds = zeros(size(fea,1),1); return; end;
if cl(1).op=='|',inds = zeros(size(fea,1),1); cmp=0;
elseif cl(1).op=='&', inds = ones(size(fea,1),1); cmp=1;
end;
for i=1:length(cl),
  subinds = find(inds==cmp); disp(['length(subinds) = ' int2str(length(subinds))]);
  inds(subinds) = 0; % turn them off; if or, they are already off, if and, they will only be on if turned on again anyway
      if strcmp(cl(i).type,'circle'),
         si2=find(eucnorm((fea(subinds,cl(i).params.chans)-repmat([cl(i).params.center],length(subinds),1))')<...
                cl(i).params.radius),
         inds(subinds(si2)) = 1;
  elseif strcmp(cl(i).type,'elipse'),
         [V,D] = eig(cl(i).params.sqspan);
         T = (V*sqrt(inv(D)));
         global siiii2;
         siiii2 = (((fea(subinds,cl(i).params.chans)-repmat([cl(i).params.center],length(subinds),1))*T)');
         si2=find(eucnorm(((fea(subinds,cl(i).params.chans)-repmat([cl(i).params.center],length(subinds),1))*T)')<=...
              cl(i).params.mult);
         disp(['Found ' int2str(length(si2)) ' matches.']);
         inds(subinds(si2)) = 1;
  elseif strcmp(cl(i).type,'polygon'),
  elseif strcmp(cl(i).type,'selected'),
         inds(intersect(cl(i).params.inds,subinds)) = 1;
  end;
end;

