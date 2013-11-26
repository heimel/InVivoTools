function [imgdata,roi,ror,data]=load_testrecord( record )
%LOAD_TESTRECORDS loads imaging test record
%
%  [imgdata,roi,ror,data]=load_testrecord( record )
%
%  2005, Alexander Heimel
%
  imgdata=[];roi=[];ror=[];data=[];
  
  
analysispath=fullfile(oidatapath(record),'analysis');
  
  if ~isempty(record.imagefile)
    if record.imagefile(1)=='/' % abs path
      imagepath=record.imagefile;
    else
      imagepath=fullfile(analysispath,record.imagefile);
    end
    if ~exist( imagepath,'file')
      disp(['Warning: file ' imagepath ' does not exist.']);
    else
      if strcmp( imagepath(end-2:end),'mat')
	x=load(imagepath,'-mat');
	imgdata=x.data;
	data=x.ks_data;
      else
	imgdata=imread(imagepath);
      end
    end
  end
    
  
  % get ROI
  if ~isempty(record.roifile)
    if record.roifile(1)=='/'  % abs. path
      roifile=record.roifile;
    else
      roifile=fullfile(analysispath,record.roifile);
    end
    if ~exist(roifile,'file')
      disp(['Warning: file ' roifile ' does not exist.']);
    else
      roi=double(imread(roifile));
    end
  end
  
  
  % get ROR  
  if ~isempty(record.rorfile)
    if record.rorfile(1)=='/'  % abs. path
      rorfile=record.rorfile;
    else
      rorfile=fullfile(analysispath,record.rorfile);
    end
    if ~exist(rorfile,'file')
      disp(['Warning: file ' rorfile ' does not exist.']);
    else
      ror=double(imread(rorfile));
    end
    try
      ror=ror.*(1-roi);
    end
  end
