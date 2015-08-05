function ramp_info = gk_ramp_setup(Fs)

ramp_info.zpad_pre_length_sec = input('Enter the pre pad of silence in seconds: ');
ramp_info.zpad_post_length_sec = input('Enter the post pad of silence in seconds: ');
ramp_info.zpad_pre_length = fix(Fs*ramp_info.zpad_pre_length_sec);
ramp_info.zpad_post_length = fix(Fs*ramp_info.zpad_post_length_sec);
ramp_info.length_sec = input('Enter the ramp time in seconds: ');
ramp_info.length = fix(Fs*ramp_info.length_sec);

if ramp_info.length == 0
  ramp_info.length = 1;
end	
ir = 1:ramp_info.length;
gr = ir/ramp_info.length;
%ramp_info.ramp = gr;
ramp_info.ramp = 0.5*(cos(pi*gr) +1);
