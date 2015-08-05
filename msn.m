function [out]=msn(in1,in2)

out=[in1,in2];
stdev=std(out);
n=length(out);
stderr=stdev/(sqrt(n));
disp(['m=',num2str(mean(out)),' std=',num2str(stdev),' stderr=',num2str(stderr),' n=',num2str(length(out))]);


