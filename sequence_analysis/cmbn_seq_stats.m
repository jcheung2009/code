function [mu,sum1] = cmbn_seq_stats(batchall)

fidb = fopen(batchall,'r');
cnt = 0;
while 1
    
    crntfile = fscanf(fidb,'%s',1);
    if isempty(crntfile),break;end
    load(crntfile); cnt=cnt+1;
    mu(cnt,:) = mu_err_est(:,1);
    sum1(cnt,:) = sum_err_est(:,1);
end


figure;
errorbar(mean(mu),stde(mu)); axis([.5 9.5 0 .02])
figure;
semilogy(mean(mu))
axis([.5 9.5 0 1])
figure;
errorbar(mean(sum1),stde(sum1));
