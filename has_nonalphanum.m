function s = has_nonalphanum(str)
%determine if string contains non-alphanumeric character (excludes
%underscore)

s = ~isempty(regexp(str,'\W'));
