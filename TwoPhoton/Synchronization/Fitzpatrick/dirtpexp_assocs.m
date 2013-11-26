function dirtpexp_assocs

fitzlabtestid;  % make sure this is in

tpassociatelistglobals;

s = input('Should we clear current associate list? (y/n) :','s');
if s=='y'|s=='Y', tpassociatelist = tpassociatelist([]); end;

r = input('What is PND of ferret? (enter -1 to skip) :');
if r>0, tpassociatelist = [ tpassociatelist struct('type','Age','owner','twophoton','data',r,'desc','')]; end;

r = input('How many days have eyes been open ? (-1 for closed) :');
tpassociatelist = [ tpassociatelist struct('type','Eyes open','owner','twophoton','data',r,'desc','')];

s = input('What is ferret name/number? :','s'); 
tpassociatelist = [ tpassociatelist struct('type','Ferret number','owner','twophoton','data',s,'desc','')];

done = 0;
while ~done,
	r = input('Was the animal dark-reared? (0/1) :');
	if r==0|r==1,
		tpassociatelist = [ tpassociatelist struct('type','Dark reared','owner','twophoton','data',r,'desc','')];
		done = 1;
	end;
end;	

