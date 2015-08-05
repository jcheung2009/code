function plotruns(fignum,subrow,subcol,subnum,invect1,invect2,invect3,invect4,invect5)

figure(fignum); hold on;
subplot(subrow,subcol,subnum); 
plot(invect1(:,1), invect1(:,2),'k.');hold on;
plot(invect2(:,1),invect2(:,2),'r.');hold on;
plot(invect3(:,1),invect3(:,2),'k.');hold on;
plot(invect4(:,1),invect4(:,2),'r.');hold on;
plot(invect5(:,1),invect5(:,2),'k.');hold on;