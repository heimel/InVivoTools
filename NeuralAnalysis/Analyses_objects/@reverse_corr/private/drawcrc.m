function drawcrc(rc,r4)
%DRAWCRC draws reverse correlation for selected pixel

p = getparameters(rc);
w = location(rc);
c = rc.computations.crc;
if ~isempty(c)
  a = axes('units',w.units,'position',r4);
  plot(c.lags,c.crc);
  title(['1D CRC for pixel ' int2str(p.crcpixel) '.']);
  xlabel('Time (s)'); 
  ylabel('Rate (Hz)');
  set(a,'uicontextmenu',contextmenu(rc), 'tag','analysis_generic',...
          'userdata','crcaxes');
end
