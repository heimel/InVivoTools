function [features,descript]=feature_extraction(csp,parameters,channels)
%FEATURE_EXTRACTION extract selected features
%
% [FEATURES,DESCRIPT]=FEATURE_EXTRACTION(CSP,PARAMETERS) extracts features 
% and gives a description of extracted features
%
% PARAMETERS (all per channel):
%   USEPCAS=number of principal components to use
%   USEMAXS=use value of maximum (boolean) 
%   USEMINS=use value of minimum (boolean)
%   USELOCMAXS=use location of maximum (boolean)
%   USELOCMINS=use location of minimum (boolean)
%
% Jan 2002, Alexander Heimel

timewindow=size(csp,1)/channels;
splitcsp=reshape(csp,timewindow,channels,size(csp,2));
features=[];

attrib.index=0;

for ch=1:channels
  % select single channel data
  cspch(:,:)=splitcsp(:,ch,:);

  if parameters.usepcas>0 
    pcas=swf_pca(cspch,parameters.usepcas);
    for i=1:parameters.usepcas
      features(size(features,1)+1,:)=pcas(i,:);
      attrib.index=attrib.index+1;
      attrib.type='real';
      attrib.subtype='location';
      attrib.description=sprintf('"channel %d pca %d"',ch,i);
      attrib.parameter=sprintf('error %f',0.05);
         %error estimate needs to be improved!!
      descript(attrib.index) =attrib;
    end 
  end


  %use cumsum of signal for pcas
  % just another linear combination of original signal
  if parameters.usecumsumpcas>0 
    cumsum_cspch=cumsum(cspch);
    meancumsum=mean(cumsum_cspch);
    cumsum_cspch=cumsum_cspch-ones(40,1)*meancumsum;
    cumsum_cspch=cumsum(cspch);
    cumsumpcas=swf_pca(cumsum_cspch,parameters.usecumsumpcas);
    for i=1:parameters.usecumsumpcas
      features(size(features,1)+1,:)=cumsumpcas(i,:);
      attrib.index=attrib.index+1;
      attrib.type='real';
      attrib.subtype='location';
      attrib.description=sprintf('"channel %d pca %d"',ch,i);
      attrib.parameter=sprintf('error %f',0.05);
         %error estimate needs to be improved!!
      descript(attrib.index) =attrib;
    end 
  end

  if parameters.usemaxs 
    features(size(features,1)+1,:)=max(cspch);
    attrib.index=attrib.index+1;
    attrib.type='real';
    attrib.subtype='location'; 
    attrib.description=sprintf('"channel %d maximum"',ch);
    attrib.parameter=sprintf('error %f',0.05);
         %error estimate needs to be improved!!
    descript(attrib.index) =attrib;
  end

  if parameters.usemins 
    features(size(features,1)+1,:)=min(cspch);
    attrib.index=attrib.index+1;
    attrib.type='real';
    attrib.subtype='location'; 
    attrib.description=sprintf('"channel %d minimum"',ch);
    attrib.parameter=sprintf('error %f',0.05);
         %error estimate needs to be improved!!
    descript(attrib.index) =attrib;
  end

  if parameters.uselocmaxs 
    [ma,mai]=max(cspch);
    features(size(features,1)+1,:)=mai;
    attrib.index=attrib.index+1;
    attrib.type='real';
    attrib.subtype='location'; 
    attrib.description=sprintf('"channel %d pos. max."',ch);
    attrib.parameter=sprintf('error %f',1);
    descript(attrib.index) =attrib;
  end

  if parameters.uselocmins 
     [mi,mii]=min(cspch);
     features(size(features,1)+1,:)=mii;
    attrib.index=attrib.index+1;
    attrib.type='real';
    attrib.subtype='location'; 
    attrib.description=sprintf('"channel %d pos. min."',ch);
    attrib.parameter=sprintf('error %f',1);
    descript(attrib.index) =attrib;
  end


end
