function [pc_rom,pc_ror]=oi_pca(frames,roi,ror)
%OI_PCA computes first principal component of frames of ROM 
%
%  [PC_ROM,PC_ROR]=OI_PCA(FRAMES,ROI,ROR)
%
%    FRAMES = MxNxT array of images 
%    ROI    = MxN array of indices of Region of Interest pixels
%    ROR    = MxN array of indices of Region of Measurement pixels
%
%    PC_ROM = MxN image of first principal component of Region of Measurement,
%             which is the union of ROI and ROR (normalized)
%    PC_ROR = PC_ROR with only non-zeros in Region of Reference
%               (normalized such that PC_ROR*PC_ROM=1)
%
%    Function used to estimate (from blank frames) the global noise in
%    the ROM.
% 
%  2005, Alexander Heimel
%
  
  ind_roi=find(roi>0);
  ind_ror=find(ror>0);
  
  ind_rom=union(ind_roi,ind_ror);
  
  data=reshape(frames,size(frames,1)*size(frames,2),size(frames,3));
  data=data(ind_rom,:);
  if length(size(data))>2
    disp('Warning: frames array does not have expected dimension');
    return
  end
  datacov=cov(data');
  disp('Calculating principal components');
  [pc,latent,explained]=pcacov(datacov);
  
  disp(['First principal component explains ' num2str(explained(1),2) ...
	' % of data variance']);
  
  pc_rom=zeros(size(frames,1),size(frames,2));
  pc_rom(ind_rom)=pc(:,1);
  pc_ror=pc_rom;
  pc_ror=pc_ror.*ror.*(1-roi);  % leave pixels that are in ROR only
  pc_ror=pc_ror/(pc_ror(:)'*pc_rom(:));
  
  
  
                                                                   
