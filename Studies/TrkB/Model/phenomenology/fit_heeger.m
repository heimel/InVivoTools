function param=fit_heeger

[param,rmserror]=fminsearch('heeger_modelfit',[2 1.1]);
disp(['Heeger model fit, n = ' num2str(param(1)) ...
	', k = ',  num2str(param(2)) ', rms error = ' num2str(rmserror)]);
