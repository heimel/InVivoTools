function UpdateNewStimEditors

%  UPDATENEWSTIMEDITORS  Updates displays for NewStim editors
%
%  Updates displays for the StimEditor, RemoteScriptEditor, and
%  ScriptEditor.

strs = {'ScriptEditor','RemoteScriptEditor','StimEditor'};

for i=1:length(strs),
  z = geteditor(strs{i});
  if ~isempty(z),
     try, eval([strs{i} '(''Update'',z);']); end;
  end;
end;
