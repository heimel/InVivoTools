ReceptiveFieldGlobals;
FlushEvents(['keyDown']);

good=0;
while(~good),
	if CharAvail,
		c = GetChar;
		if c=='q', good = 1; end;
		double(c),
	end;
end;
	
