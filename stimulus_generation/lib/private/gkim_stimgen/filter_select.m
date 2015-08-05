function filt_info = filter_select

disp('Bandpass Filter Types Menu:')
disp('(0) [None]')
disp('(1) Kaiser window FIR (500-8000 Hz)')
disp('(2) Hanning Window FIR (variable Fc)')
disp('(3) Butterworth IIR (variable Fc)')
disp('(4) High pass Hanning window FIR (variable Fc)')
disp(' ')
filtcode = input(['What type of filter do you want: (0-4)? '])
if filtcode == 1
  filt_info.type = 'kaiserfir'
elseif filtcode == 2
  filt_info.type = 'hanningfir'
  filt_info.F_low = input('Enter low frequency cutoff: ')
  filt_info.F_high = input('Enter high frequency cutoff: ')  
elseif filtcode == 3
  filt_info.type = 'butter'
  filt_info.F_low = input('Enter low frequency cutoff: ')
  filt_info.F_high = input('Enter high frequency cutoff: ')  
elseif filtcode == 4
  filt_info.type = 'hipass'
  filt_info.F_low = input('Enter low frequency cutoff: ')
else
  filt_info.type = 'none'
end

if ~strcmp(filt_info.type,'none')
  if filtcode ~= 3
    yesno = input('Do you want to use matlab ''filtfilt'' function (''filter'' is default) (y/N)? ','s')
    if strncmpi(yesno,'y',1)
      filt_info.do_filtfilt = 1
    else
      filt_info.do_filtfilt = 0
    end
  else
    filt_info.do_filtfilt = 1
  end
end
