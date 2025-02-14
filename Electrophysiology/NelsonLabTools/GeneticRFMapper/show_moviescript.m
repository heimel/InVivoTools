function testname = show_moviescript(sms_script,verbose)
%SHOW_MOVIESCRIPT transfers and runs moviescript
%
% TESTNAME = SHOW_MOVIESCRIPT(SMS_SCRIPT)
%   needs RunExperiment panel open
%
%   see 'help geneticstimuli' for general information
%   2003, Alexander Heimel (heimel@brandeis.edu)
%
  if nargin<2
    verbose=0;
  end

  if verbose;disp('Transfering script');end
  try
    scriptname='sms_script';
    b = transferscripts({scriptname},{sms_script});
    if b,
      dowait(0.5);
      if verbose;disp('Running script');end
      b=runscriptremote(scriptname);
      if ~b,
	errordlg('Could not run script--check RunExperiment window.');
      end;
      testname = get(findobj(geteditor('RunExperiment'),'Tag','SaveDirEdit'),...
		     'String');
    end;
  catch
    testname='';
    errordlg('Could not get testname');
  end

