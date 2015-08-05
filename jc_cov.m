

function xy = jc_cov(x,y);

% like cov2 but allows you to specify normalization according to lag (use
% with jc_corrcoef and jc_pccorr+-
if nargin<2, error('Not enough input arguments.'); end
if nargin>3, error('Too many input arguments.'); end
if nargin==2 flag = 0; end;
nin = nargin;

[n m] = size(x);
[n2 p] = size(y);

if (n2 ~= n) error('x and y must have same number of rows'); end;

if n==1,  % Handle special case
  xy = 0;

else
  xc = x - repmat(mean(x),n,1);  % Remove mean
  yc = y - repmat(mean(y),n,1);  % Remove mean
  
  xy = (xc' * yc) / (n-1);
  
end


% Written by Kenneth D. Harris 
% This software is released under the GNU GPL
% www.gnu.org/copyleft/gpl.html
% any comments, or if you make any extensions
% let me know at harris@axon.rutgers.edu