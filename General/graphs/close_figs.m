function close_figs
%CLOSE_FIGS closes all figures that do not have userdata.persistent == 1
%
%  CLOSE_FIGS
%
% 2007, Alexander Heimel
%

c=get(0,'Children');
for i=1:length(c)
	cb='';
	try
		fud=get(c(i),'UserData');
		if fud.persistent==0
			close(c(i));
	end
	catch
		close(c(i));
	end
end
