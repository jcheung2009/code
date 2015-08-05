function resamp_info = resample_init(Fs)

Fs_new_dflt = 40000;
% User settable?
n_interp_samples_dflt = 50;

resamp_info.Fs_old = Fs;

yesno = input(['Do you want to resample the data (y/N)? '], 's');
if strncmpi(yesno,'y',1)
  resamp_info.Fs_new = input(['Enter the new output sampling rate [', ...
	num2str(Fs_new_dflt), ']: ']);
  if isempty(resamp_info.Fs_new)
    resamp_info.Fs_new = Fs_new_dflt;
  end
  % Resampling algorithm used.
  % Later allow user to select
  resamp_info.type = 'matlab';
  resamp_info.n_interp_samples = n_interp_samples_dflt;
else
  resamp_info.Fs_new = Fs;
  resamp_info.type = 'none';
end

if ~strcmp(resamp_info.type,'none')
  if isint(resamp_info.Fs_old) & isint(resamp_info.Fs_new)
    div = gcd(resamp_info.Fs_old,resamp_info.Fs_new)
    resamp_info.P = resamp_info.Fs_new/div;
    resamp_info.Q = resamp_info.Fs_old/div;
  else
    % Assume board timing resolution is an integer multiple of a nanosec.
    nQ = 1e9/resamp_info.Fs_new
    nP = 1e9/resamp_info.Fs_old
    div = gcd(nP,nQ)
    resamp_info.P = nP/div;
    resamp_info.Q = nQ/div;
  end
end
