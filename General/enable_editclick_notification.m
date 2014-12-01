function enable_editclick_notification(figh)
%enable_editclick_notification(figure_handle)
%modifies a figure so that clicking its edit fields will update its currentobject property
%
% Copyright (c) 2011, David Greenberg, david.greenberg@caesar.de
% All rights reserved.

edith = findobj(figh,'style','edit');
invistext = uicontrol('style','text','string','','visible','on','parent',figh,'units','pixels','position',[0 0 1 1]);
for u = 1:numel(edith)
    origfunc = get(edith(u),'callback');
    try
        assert(nargin(origfunc) == 2);
    catch
        origfunc = '';
    end    
    set(edith(u),'buttondownfcn',@(edith, eventdata) unprotect_edit(edith, eventdata),'callback',@(edith, eventdata) protect_edit(origfunc, invistext, figh, edith, eventdata));
    if ~strcmpi(get(edith(u),'enable'),'off')
        set(edith(u),'enable','inactive');
    end
end
origwbdf = get(figh,'windowbuttondownfcn');
try
    assert(nargin(origwbdf) == 2);
catch
    origwbdf = '';
end
set(figh,'windowbuttondownfcn',@(figh, eventdata) editprotect_wbdf(edith, origwbdf, invistext, figh, eventdata));

function editprotect_wbdf(edith, origwbdf, invistext, figh, eventdata)
set(edith,'enable','inactive','style','text');
set(edith,'style','edit');
if ~isempty(origwbdf)
    origwbdf(figh, eventdata);
end
co = get(figh,'currentobj');
if ~(strcmpi(get(co,'type'),'uicontrol') && strcmpi(get(co,'style'),'edit'))    
    uicontrol(invistext);
end

function unprotect_edit(edith, eventdata)
if strcmpi(get(edith,'enable'),'off')
    return;
end
set(edith,'enable','on');
uicontrol(edith);

function protect_edit(origfunc, invistext, figh, edith, eventdata)
if ~isempty(origfunc)
    origfunc(edith, eventdata);
end
set(edith,'style','text','enable','inactive');
uicontrol(invistext);
set(edith,'style','edit');