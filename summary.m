function summary(fignum,subrow,subcol,subnum,invect1,invect2,invect3,invect4)

% %%fundamental frequency boostrapping
[hi1 lo1] = mBootstrapCI(invect1,'');
[hi2 lo2] = mBootstrapCI(invect2,'');
[hi3 lo3] = mBootstrapCI(invect3,'');

    
if isempty(invect4)
    
    figure(fignum);
    hold on;
    subplot(subrow,subcol,subnum);
    plot(1,mean(invect1),'ok'); hold on;
    plot([1 1],[hi1 lo1],'k'); hold on;
    plot(2,mean(invect2),'or'); hold on;
    plot([2 2],[hi2 lo2],'r'); hold on;
    plot(3,mean(invect3),'ok');hold on;
    plot([3 3],[hi3 lo3],'k'); hold on;
    plot([1 2],[mean(invect1) mean(invect2)],'k');hold on;
    plot([2 3],[mean(invect2) mean(invect3)],'k'); hold on;
    

else
 
    [hi4 lo4] = mBootstrapCI(invect4,'');
    
    figure(fignum);
    hold on;
    subplot(subrow,subcol,subnum);
    plot(1,mean(invect1),'ok'); hold on;
    plot([1 1],[hi1 lo1],'k'); hold on;
    plot(2,mean(invect2),'or'); hold on;
    plot([2 2],[hi2 lo2],'r'); hold on;
    plot(3,mean(invect3),'ob');hold on;
    plot([3 3],[hi3 lo3],'b'); hold on;
    plot(4,mean(invect4),'ok');hold on;
    plot([4 4],[hi4 lo4],'k');hold on;
    plot([1 2],[mean(invect1) mean(invect2)],'k');hold on;
    plot([2 3],[mean(invect2) mean(invect3)],'k'); hold on;
    plot([3 4],[mean(invect3) mean(invect4)],'k'); hold on;
    

 end
% % 
% % %%normalized CV bootstrapping
% if isempty(invect3)
%     
%     [normcv hi lo] = mBootstrapCI_CV(invect1,'');
%     [meancv1 hi1 lo1] = mBootstrapCI_CVnorm(invect1,normcv,'');
%     [meancv2 hi2 lo2] = mBootstrapCI_CVnorm(invect2,normcv,'');
% %     [meancv3 hi3 lo3] = mBootstrapCI_CVnorm(invect3,normcv,'');
% 
%     figure(fignum);
%     hold on;
%     subplot(subrow,subcol,subnum);
%     plot(1,meancv1,'ok'); hold on;
%     plot([1 1],[hi1 lo1],'k'); hold on;
%     plot(2,meancv2,'or'); hold on;
%     plot([2 2],[hi2 lo2],'r'); hold on;
% %     plot(3,meancv3,'ob');hold on;
% %     plot([3 3],[hi3 lo3],'b');hold on;
%     plot([1 2],[meancv1 meancv2],'k');hold on;
% %     plot([2 3],[meancv2 meancv3],'k');
%     
% else
%     [normcv hi lo] = mBootstrapCI_CV(invect1,'');
%     [meancv1 hi1 lo1] = mBootstrapCI_CVnorm(invect1,normcv,'');
%     [meancv2 hi2 lo2] = mBootstrapCI_CVnorm(invect2,normcv,'');
%     [meancv3 hi3 lo3] = mBootstrapCI_CVnorm(invect3,normcv,'');
% %     [meancv4 hi4 lo4] = mBootstrapCI_CVnorm(invect4,normcv,'');
% 
%     
%     figure(fignum);
%     hold on;
%     subplot(subrow,subcol,subnum);
%     plot(1,meancv1,'ok'); hold on;
%     plot([1 1],[hi1 lo1],'k'); hold on;
%     plot(2,meancv2,'or'); hold on;
%     plot([2 2],[hi2 lo2],'r'); hold on;
%     plot(3,meancv3,'ob');hold on;
%     plot([3 3],[hi lo],'b');hold on;
% %     plot(4,meancv4,'ok');hold on;
% %     plot([4 4],[hi lo],'k');hold on;
%     plot([1 2],[meancv1 meancv2],'k');hold on;
%     plot([2 3],[meancv2 meancv3],'k'); hold on;
% %     plot([3 4],[meancv3 meancv4],'k'); hold on;
% end



