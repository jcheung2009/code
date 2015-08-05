
a = naspm_a;


for i = 1:length(a)
    [hi lo] = mBootstrapCI(a{i}(:,2),'');
    figure(4);hold on;
    plot(mean(a{i}(:,1)),mean(a{i}(:,2)),'r.','MarkerSize',20);hold on;
    plot([mean(a{i}(:,1)) mean(a{i}(:,1))],[hi lo],'r');
end

a = sal_b;
b = naspm_b;

figure(9);hold on;
subplot(3,1,1);plot(a{1}(:,1), a{1}(:,2),'k.');hold on;
plot(a{2}(:,1),a{2}(:,2),'k.');hold on
plot(b{1}(:,1),b{1}(:,2),'r.');
figure(9);hold on;subplot(3,1,2);plot(a{3}(:,1),a{3}(:,2),'k.');hold on;
plot(a{4}(:,1),a{4}(:,2),'k.');hold on;
plot(b{2}(:,1),b{2}(:,2),'r.');
figure(9);hold on;subplot(3,1,3);plot(a{5}(:,1),a{5}(:,2),'k.');hold on;
plot(a{6}(:,1),a{6}(:,2),'k.');hold on;
plot(b{3}(:,1),b{3}(:,2),'r.');






a = sal_3_2_b;
b = sal_3_4_b;
nsamp = 50;

a_n = a(1:50,2)/mean(a(1:50,2));
b_n = b(1:50,2)/mean(a(1:50,2));


[hi lo] = mBootstrapCI(a_n,'');
[hi2 lo2] = mBootstrapCI(b_n,'');
figure(10);hold on;
plot(1,mean(a_n),'ok','MarkerSize',8);hold on;
plot([1 1],[hi lo],'k');hold on;
plot(2,mean(b_n),'ok','MarkerSize',8);hold on;
plot([2 2],[hi2 lo2],'k');hold on;
plot([1 2],[mean(a_n) mean(b_n)],'g');


a = naspmmusc_b;
tb = naspmmusc_tb_b;

for i = 1:length(naspmmusc_b)
    ii = find(tb{i} > 1.5e4);
    [hi lo] = mBootstrapCI(naspm_a{i}(ii:end,2),'');
    figure(12);hold on;
    plot(2,mean(naspm_a{i}(ii:end,2)),'og','MarkerSize',8);hold on;
    plot([2 2],[hi lo],'g');
end
