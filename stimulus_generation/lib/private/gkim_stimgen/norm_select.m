function norm_info = norm_select

% Normalization defaults
Nstd_dflt = 4.0
cutfrac_dflt = 0.1

disp('Normalization Types Menu:')
disp('(0) [None]')
disp('(1) Center cut peak RMS')
disp('(2) Center cut RMS')
disp('(3) RMS')
disp('(4) Set RMS')
disp('(5) Set Gain')
disp('(6) Set Range')
disp(' ')
normcode = input(['What type of normalization do you want: (0-5)? '])
if normcode == 1
  norm_info.type = 'centercut_peakrms'
elseif normcode == 2
  norm_info.type = 'centercut_rms'
elseif normcode == 3
  norm_info.type = 'rms'
elseif normcode == 4
  norm_info.type = 'set_rms'
  norm_info.setrmsval = input('Enter rms value for normalized data: ')
elseif normcode == 5
  norm_info.type = 'set_gain'
  norm_info.setgainval = input('Enter positive gain to apply for normalized data: ')
elseif normcode == 6
  norm_info.type = 'set_range'
  norm_info.setrangeval = input('Enter positive range for normalized data: ')
else
  norm_info.type = 'none'
end

% Normalization parameters
norm_info.cutfrac = cutfrac_dflt
if strcmp(norm_info.type,'centercut_peakrms') | ...
      strcmp(norm_info.type,'centercut_rms') | strcmp(norm_info.type,'rms')
  Nstd = input(['Enter number of standard deviations' ...
	' for clipping the output [', num2str(Nstd_dflt), ']: '])
  if isempty(Nstd)
    Nstd = Nstd_dflt;
  end
  norm_info.nstd = Nstd
end

