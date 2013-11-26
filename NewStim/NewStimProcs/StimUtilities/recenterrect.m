function newrect = recenterrect(recenterrect, oldrect, screenrect)

  % could remove this code from recenterstim but not now
rect=recenterrect;
xmins = min(screenrect([1 3])); xmaxs = max(screenrect([1 3]));
ymins = min(screenrect([2 4])); ymaxs = max(screenrect([2 4]));
xCtr = (0.5 * [ rect(3)+rect(1) ]);
yCtr = (0.5 * [ rect(4)+rect(2) ]);

        r = oldrect;  % gotta be a briefer way than below, but ...
        xmino = min(r([1 3])); xmaxo = max(r([1 3]));
        ymino = min(r([2 4])); ymaxo = max(r([2 4]));
        dx = fix(xCtr - 0.5*(xmaxo+xmino));
        dy = fix(yCtr - 0.5*(ymaxo+ymino));
        w = xmaxo-xmino; h = ymaxo-ymino;
        if dx<0,
                xmino=max(xmino+dx,xmins);
                xmaxo=max(xmaxo+dx,xmins+w);
        else, % dx>=0
                xmino=min(xmino+dx,xmaxs-w);
                xmaxo=min(xmaxo+dx,xmaxs);
        end;
        if dy<0,
                ymino=max(ymino+dy,ymins);
                ymaxo=max(ymaxo+dy,ymins+h);
        else, % dy>=0
                ymino=min(ymino+dy,ymaxs-h);
                ymaxo=min(ymaxo+dy,ymaxs);
        end;
        newrect = [xmino ymino xmaxo ymaxo];

