function [mrk color] = markercolor(fn);
%determine marker and line color from filename 

if (~isempty(strfind(lower(fn),'naspm')) & ~isempty(strfind(lower(fn),'apv')))|...
   (~isempty(strfind(lower(fn),'naspm')) & ~isempty(strfind(lower(fn),'musc')))|... 
   (~isempty(strfind(lower(fn),'apv')) & ~isempty(strfind(lower(fn),'musc')))
   mrk='g.';color='g';
elseif ~isempty(strfind(lower(fn),'naspm')) | ~isempty(strfind(lower(fn),'iem'))
    mrk='r.';color='r';
elseif ~isempty(strfind(lower(fn),'apv'))
    mrk='b.';color='b';
elseif ~isempty(strfind(lower(fn),'musc'))
    mrk='c.';color='c';
elseif ~isempty(strfind(lower(fn),'post'))
    mrk = 'r.';color = 'r';
else
    mrk='k.';color='k';
end

