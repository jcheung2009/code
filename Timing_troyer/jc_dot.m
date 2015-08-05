function overlap = jc_dot(x,y)
%another distance measurement that could be used by dtw in Timing_troyer
%in that case, make sure to use the inverse of the dot product because dtw finds
%smallest distance 
x = x(:) *ones(1,size(y,2));
overlap = dot(x,y,1);
%overlap = 1./overlap;
