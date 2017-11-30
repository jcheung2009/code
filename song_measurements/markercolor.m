function [mrk color] = markercolor(fn,varargin);
%determine marker and line color from filename 
if ~isempty(varargin{1})
    runavg = 'y';
else
    runavg = 'n';
end

if (~isempty(strfind(lower(fn),'naspm')) & ~isempty(strfind(lower(fn),'apv')))|...
   (~isempty(strfind(lower(fn),'naspm')) & ~isempty(strfind(lower(fn),'musc')))|... 
   (~isempty(strfind(lower(fn),'apv')) & ~isempty(strfind(lower(fn),'musc')))
   mrk = 'g.';color='g';
   if strcmp(runavg,'y')
      mrk=[0.3 0.7 0.3];mrk=mrk./max(mrk);
   end
elseif ~isempty(strfind(lower(fn),'naspm')) | ~isempty(strfind(lower(fn),'iem'))
    mrk='r.';color='r';
    if strcmp(runavg,'y')
      mrk=[0.53 0.45 0.45];mrk=mrk./max(mrk);
   end
elseif ~isempty(strfind(lower(fn),'apv'))
    mrk='b.';color='b';
    if strcmp(runavg,'y')
      mrk=[0.3 0.3 0.7];mrk=mrk./max(mrk);
   end
elseif ~isempty(strfind(lower(fn),'musc'))
    mrk='c.';color='c';
    if strcmp(runavg,'y')
      mrk=[0.3 0.7 0.7];mrk=mrk./max(mrk);
   end
elseif ~isempty(strfind(lower(fn),'post'))
    mrk = 'r.';color = 'r';
    if strcmp(runavg,'y')
      mrk=[0.7 0.3 0.3];mrk=mrk./max(mrk);
   end
elseif ~isempty(strfind(lower(fn),'mid')) | ~isempty(strfind(lower(fn),'gab')) | ~isempty(strfind(lower(fn),'diaz'))
    mrk='b.';color='b';
    if strcmp(runavg,'y')
      mrk=[0.3 0.3 0.7];mrk=mrk./max(mrk);
   end
else
    mrk='k.';color='k';
    if strcmp(runavg,'y')
      mrk=[0.87 0.87 0.87];
   end
end

