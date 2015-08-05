function plot_data(b,invect1,invect2,invect3,color,line)

figure(b);hold on;

subplot(1,2,1);
plot(mean(invect1),mean(invect2),color);hold on;
plot([mean(invect1),mean(invect1)],[mean(invect2)+stderr(invect2),mean(invect2)-stderr(invect2)],line);hold on;
plot([mean(invect1)-stderr(invect1),mean(invect1)+stderr(invect1)],[mean(invect2),mean(invect2)],line);

subplot(1,2,2);
plot(mean(invect1),mean(invect3),color);hold on;
plot([mean(invect1),mean(invect1)],[mean(invect3)+stderr(invect3),mean(invect3)-stderr(invect3)],line);
plot([mean(invect1)-stderr(invect1),mean(invect1)+stderr(invect1)],[mean(invect3),mean(invect3)],line);

