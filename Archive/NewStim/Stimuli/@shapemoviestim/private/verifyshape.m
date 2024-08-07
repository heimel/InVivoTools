function [b,errormsg] = verifyshape(shape)

proceed = 1;

me = struct('type',1,'position',struct('x',0,'y',0),'onset',0,'duration',1,...
            'size',1,'color',struct('r',0,'g',0,'b',0),'contrast',1,...
			'speed',struct('x',0,'y',0),'orientation',0,'eccentricity',1);

fieldnames = {	'type','position','onset','duration','size','color',...
				'contrast','speed','orientation','eccentricity' };
fieldsizes = {[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1],[1 1]};
[proceed,errormsg]=hasAllFields(shape,fieldnames,fieldsizes);
if ~proceed, b=0; end;

if proceed,
	fn = {'x','y'}; fs={[1 1],[1 1]};
	[proceed,errormsg]=hasAllFields(shape.position,fn,fs);
	if proceed,
		[proceed,errormsg]=hasAllFields(shape.speed,fn,fs);
		if proceed,
			fn = {'r','g','b'}; fs = { [1 1],[1 1],[1 1] };
			[proceed,errormsg]=hasAllFields(shape.color,fn,fs);
		end;
	end;
end;

if proceed,

if shape.type~=1&shape.type~=2&shape.type~=3,
	proceed=0; errormsg='type not good'; end;
if ~isint(shape.onset), proceed=0; errormsg='onset not integer'; end;
if ~isint(shape.duration), proceed=0; errormsg='duration not integer'; end;
if shape.size<0, proceed=0;errormsg='size less than zero.'; end;
if shape.color.r<0|shape.color.r>255|shape.color.b<0|shape.color.b>255|...
	shape.color.g<0|shape.color.g>255,
	proceed=0; errormsg='colors must be in [0..255].'; end;
if shape.contrast<0|shape.contrast>1,
	proceed=0; errormsg='contrast must be in [0..1]'; end;
%if shape.speed.x<0|shape.speed.y<0,
%	proceed=0; errormsg='speed must be >= 0.'; end;
if ~isnumeric(shape.orientation)|~isnumeric(shape.eccentricity), proceed=0;
	errormsg = 'orientation and eccentricity must be numeric'; end;
if ~isnumeric(shape.position.x)&~isnumeric(shape.position.y),
	errormsg='position must be numeric'; proceed=0; end;

end;
b = proceed;
