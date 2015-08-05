function stim_ramped = gk_make_ramp(stim, ramp_info)

zpad_pre_length = ramp_info.zpad_pre_length;
zpad_post_length = ramp_info.zpad_post_length;
stim_len = length(stim);
tempstim(:,1) = stim;  %GK
stim = tempstim;
ramp(:,1) = ramp_info.ramp;  %GK: make ramp column vector
ramp_length = ramp_info.length;

if ramp_length > stim_len/2
  error('Ramps longer than the stimulus!')
end

stim_ramped = zeros(zpad_pre_length+zpad_post_length+stim_len,1);
stim_ramped(zpad_pre_length+1:zpad_pre_length+ramp_length) = (1-ramp).*stim(1:ramp_length);
stim_ramped(zpad_pre_length+ramp_length+1:zpad_pre_length + stim_len-ramp_length) = stim((ramp_length+1):(stim_len-ramp_length));
stim_ramped(zpad_pre_length+stim_len-ramp_length+1:(zpad_pre_length+stim_len)) = ramp.*stim((stim_len-ramp_length+1):stim_len);

