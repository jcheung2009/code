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
elseif ~isempty(strfind(lower(fn),'mid')) | ~isempty(strfind(lower(fn),'gab')) | ~isempty(strfind(lower(fn),'diaz'))
    mrk='b.';color='b';
else
    mrk='k.';color='k';
end

