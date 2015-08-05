function [x]=plot_dur(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);


num_hists=nargin-1;

%set number of bins for histograms
last_arg=eval(['arg',num2str(nargin)]);
if isempty(last_arg)
  bins=20;
  gl_max=0;
  gl_min=0;
  for i=1:num_hists
    gl_max=max(gl_max,max(eval(['arg',num2str(i)])));
    gl_min=max(gl_min,min(eval(['arg',num2str(i)])));
  end
else
  bins=last_arg;
  gl_min=last_arg(1);
  gl_max=last_arg(length(last_arg));
end


for i=1:num_hists
  subplot(num_hists,1,i)
  hist(eval(['arg',num2str(i)]),bins);
  set(gca, 'xlim',[gl_min, gl_max]);
  eval(['legend(''',inputname(i),''')']);
end

subplot(num_hists,1,1);
