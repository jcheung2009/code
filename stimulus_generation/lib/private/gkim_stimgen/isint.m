function intflag = isint(x)

if isequal(round(x),x) 
  intflag = 1
else
  intflag = 0
end
