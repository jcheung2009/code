function [data_norm, norm_info] = norm_data(data,norm_info)
% Rescale data so it will fit into a short int, subject to 
% various criteria.

MAXSHORT = 32767;
MINSHORT = -32768;

% Simple data statistics
datamax = max(abs(data));
datamean = mean(data);
datastd = std(data);
disp(['Data mean: ', num2str(datamean), ' std: ', num2str(datastd)])
data_norm = data - datamean;
data_len = length(data);

% Normalize data to maximize dynamic range
% Several ways to try to do this.

switch lower(norm_info.type)
  case 'centercut_peakrms'
    % Normalization parameters
    % Fix to use defaults if these don't exist!
    cutfrac = norm_info.cutfrac;
    Nstd = norm_info.nstd;
    ccut = datamax*cutfrac;

    [ccvar,ccmean,ncc] = calc_ccpstats(data_norm,ccut);
    ccrms = sqrt(ccvar - ccmean^2);
    disp(['Center clipped peak rms: ', num2str(ccrms)])
    range = Nstd*ccrms;
    gain = (MAXSHORT-MINSHORT)/(2*range+1);
    
  case 'centercut_rms'
    % Normalization parameters
    cutfrac = norm_info.cutfrac;
    Nstd = norm_info.nstd;
    ccut = datamax*cutfrac;

    [ccvar,ccmean,ncc] = calc_ccstats(data_norm,ccut);
    ccrms = sqrt(ccvar - ccmean^2);
    disp(['Center clipped rms: ', num2str(ccrms)])
    range = Nstd*ccrms;
    gain = (MAXSHORT-MINSHORT)/(2*range+1);
    
  case 'rms'
    Nstd = norm_info.nstd;
    range = Nstd*datastd;
    gain = (MAXSHORT-MINSHORT)/(2*range+1);
  
  case 'set_rms'
    gain = norm_info.setrmsval/datastd;
    
  case 'set_gain'
    gain = norm_info.setgainval;

  case 'set_range'
    range = norm_info.setrangeval;
    gain = (MAXSHORT-MINSHORT)/(2*range+1);
    
  otherwise
    disp('Using default normalization of 1')
    gain = 1;
end

% Round used to be fix
data_norm = round(data_norm*gain);

pclip_idx = find(data_norm > MAXSHORT);
npclip = length(pclip_idx);
data_norm(pclip_idx) = MAXSHORT;
nclip_idx = find(data_norm < MINSHORT);
nnclip = length(nclip_idx);
data_norm(nclip_idx) = MINSHORT;
nclip = npclip + nnclip;

disp(['Number of points clipped: ', int2str(nclip), ', ', ...
      num2str(100*nclip/data_len),'%'])

norm_info.gain = gain;
norm_info.nclip = nclip;
