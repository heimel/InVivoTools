function h = plot_periodicscript_cont(comps,fignum)

%  PLOT_PERIODICSCRIPT_CONT Plot periodicscript analysis results
%
%  H = PLOT_PERIODICSCRIPT_CONT(COMPS, [FIGNUM])
%
%  Plots periodicscript computations in an existing or a new figure.
%  Draws four panels with F0 component, F1 component, F2 component, and
%  the remaining panel is left blank.  If FIGNUM is provided, then the
%  drawing is made in that figure number.  COMPS is a structure returned
%  from analyze_periodicscript_cont.
%
%  See ANALYZE_PERIODICSCRIPT_CONT


if nargin<2, h = figure; else, h = figure(fignum); clf; end;


pos1=[0.10 0.55 0.35 0.4]; pos2=[0.55 0.55 0.35 0.4];
pos3=[0.10 0.05 0.35 0.4]; pos4=[0.55 0.05 0.35 0.4];

ax=axes('position',pos1);
myerrorbar(comps.curve,comps.f0mean,comps.f0stddev,'b');
hold on;
myerrorbar(comps.curve,comps.f0mean,comps.f0stderr,'r');
ylabel('Membrane Potential (V)'); title('F0');

ax=axes('position',pos2);
myerrorbar(comps.curve,abs(comps.f1mean),comps.f1stddev,'b');
hold on;
myerrorbar(comps.curve,abs(comps.f1mean),comps.f1stderr,'r');
ylabel('Membrane Potential (V)'); title('F1');

ax=axes('position',pos3);
myerrorbar(comps.curve,abs(comps.f2mean),comps.f2stddev,'b');
hold on;
myerrorbar(comps.curve,abs(comps.f2mean),comps.f2stderr,'r');
ylabel('Membrane Potential (V)'); title('F2');
