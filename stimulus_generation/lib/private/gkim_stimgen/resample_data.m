function data_resamp = resample_data(data, resamp_info)

% Add more resampling methods here
switch resamp_info.type
  case 'matlab'
    data_resamp = resample(data, resamp_info.P, resamp_info.Q, resamp_info.n_interp_samples);
  case 'none'
    data_resamp = data;
  otherwise
    error('Invalid resample method.')	
end
