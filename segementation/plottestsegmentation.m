motif = 'aabb';
fs = 32000;
%%variance ampplitude at syllable onsets and offsets
sm = arrayfun(@(x) log(x.sm),testmotifsegment,'un',0);
sm = cellfun(@(x) x-min(x),sm,'un',0);
sm = cellfun(@(x) x/max(x),sm','un',0);

dtwons = arrayfun(@(x) round((x.dtwsegment(:,1)+0.01)*fs)',testmotifsegment,'un',0);
dtwons = cell2mat(cellfun(@(x,y) y(x)',dtwons,sm','un',0)');

ind = arrayfun(@(x) size(x.ampsegment,1)==4,testmotifsegment,'un',1);
ampons = arrayfun(@(x) round((x.ampsegment(:,1)+0.01)*fs),testmotifsegment(ind),'un',0);
ampons = cell2mat(cellfun(@(x,y) y(x)',ampons,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.pksegment,1)==4,testmotifsegment,'un',1);
pkons = arrayfun(@(x) round((x.pksegment(:,1)+0.01)*fs),testmotifsegment(ind),'un',0);
pkons = cell2mat(cellfun(@(x,y) y(x)',pkons,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.dtwpksegment,1)==4,testmotifsegment,'un',1);
dtwpkons = arrayfun(@(x) round((x.dtwpksegment(:,1)+0.01)*fs),testmotifsegment(ind),'un',0);
dtwpkons = cell2mat(cellfun(@(x,y) y(x)',dtwpkons,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.tonalitysegment,1)==4,testmotifsegment,'un',1);
tonons = arrayfun(@(x) round((x.tonalitysegment(:,1)+0.01)*fs),testmotifsegment(ind),'un',0);
tonons = cell2mat(cellfun(@(x,y) y(x)',tonons,sm(ind)','un',0)');

dtwampons = arrayfun(@(x) round((x.dtwampsegment(:,1)+0.01)*fs)',testmotifsegment,'un',0);
dtwampons = cell2mat(cellfun(@(x,y) y(x)',dtwampons,sm','un',0)');

figure;hold on;
onsvars = [];
for i = 1:length(motif)
    [mn hi lo] = mBootstrapCI_CV(dtwons(:,i));
    plot(1,mn,'ok','markersize',8);hold on;
    errorbar(1,mn,hi-mn,'k','linewidth',2);hold on;
    [mn2 hi2 lo2] = mBootstrapCI_CV(ampons(:,i));
    plot(2,mn2,'or','markersize',8);hold on;
    errorbar(2,mn2,hi2-mn2,'r','linewidth',2);hold on;
    [mn3 hi3 lo3] = mBootstrapCI_CV(pkons(:,i));
    plot(3,mn3,'ob','markersize',8);hold on;
    errorbar(3,mn3,hi3-mn3,'b','linewidth',2);hold on;
    [mn4 hi4 lo4] = mBootstrapCI_CV(dtwpkons(:,i));
    plot(4,mn4,'og','markersize',8);hold on;
    errorbar(4,mn4,hi4-mn4,'g','linewidth',2);hold on;
    [mn5 hi5 lo5] = mBootstrapCI_CV(tonons(:,i));
    plot(5,mn5,'oc','markersize',8);hold on;
    errorbar(5,mn5,hi5-mn5,'c','linewidth',2);hold on;
    [mn6 hi6 lo6] = mBootstrapCI_CV(dtwampons(:,i));
    plot(6,mn6,'oc','markersize',8);hold on;
    errorbar(6,mn6,hi6-mn6,'m','linewidth',2);hold on;
    onsvars = [onsvars [mn mn2 mn3 mn4 mn5 mn6]'];
end
plot(1:6,onsvars','color',[0.5 0.5 0.5],'linewidth',2);


dtwoffs = arrayfun(@(x) round((x.dtwsegment(:,2)-0.01)*fs)',testmotifsegment,'un',0);
dtwoffs = cell2mat(cellfun(@(x,y) y(x)',dtwoffs,sm','un',0)');

ind = arrayfun(@(x) size(x.ampsegment,1)==4,testmotifsegment,'un',1);
ampoffs = arrayfun(@(x) round((x.ampsegment(:,2)-0.01)*fs),testmotifsegment(ind),'un',0);
ampoffs = cell2mat(cellfun(@(x,y) y(x)',ampoffs,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.pksegment,1)==4,testmotifsegment,'un',1);
pkoffs = arrayfun(@(x) round((x.pksegment(:,2)-0.01)*fs),testmotifsegment(ind),'un',0);
pkoffs = cell2mat(cellfun(@(x,y) y(x)',pkoffs,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.dtwpksegment,1)==4,testmotifsegment,'un',1);
dtwpkoffs = arrayfun(@(x) round((x.dtwpksegment(:,2)-0.01)*fs),testmotifsegment(ind),'un',0);
dtwpkoffs = cell2mat(cellfun(@(x,y) y(x)',dtwpkoffs,sm(ind)','un',0)');

ind = arrayfun(@(x) size(x.tonalitysegment,1)==4,testmotifsegment,'un',1);
tonoffs = arrayfun(@(x) round((x.tonalitysegment(:,2)-0.01)*fs),testmotifsegment(ind),'un',0);
tonoffs = cell2mat(cellfun(@(x,y) y(x)',tonoffs,sm(ind)','un',0)');

dtwampoffs = arrayfun(@(x) round((x.dtwampsegment(:,2)-0.01)*fs)',testmotifsegment,'un',0);
dtwampoffs = cell2mat(cellfun(@(x,y) y(x)',dtwampoffs,sm','un',0)');

figure;hold on;
offsvars = [];
for i = 1:length(motif)
    [mn hi lo] = mBootstrapCI_CV(dtwoffs(:,i));
    plot(1,mn,'ok','markersize',4);hold on;
    errorbar(1,mn,hi-mn,'k','linewidth',2);hold on;
    [mn2 hi2 lo2] = mBootstrapCI_CV(ampoffs(:,i));
    plot(2,mn2,'or','markersize',4);hold on;
    errorbar(2,mn2,hi2-mn2,'r','linewidth',2);hold on;
    [mn3 hi3 lo3] = mBootstrapCI_CV(pkoffs(:,i));
    plot(3,mn3,'ob','markersize',4);hold on;
    errorbar(3,mn3,hi3-mn3,'b','linewidth',2);hold on;
    [mn4 hi4 lo4] = mBootstrapCI_CV(dtwpkoffs(:,i));
    plot(4,mn4,'og','markersize',4);hold on;
    errorbar(4,mn4,hi4-mn4,'g','linewidth',2);hold on;
    [mn5 hi5 lo5] = mBootstrapCI_CV(tonoffs(:,i));
    plot(5,mn5,'oc','markersize',4);hold on;
    errorbar(5,mn5,hi5-mn5,'c','linewidth',2);hold on;
    [mn6 hi6 lo6] = mBootstrapCI_CV(dtwampoffs(:,i));
    plot(6,mn6,'oc','markersize',8);hold on;
    errorbar(6,mn6,hi6-mn6,'m','linewidth',2);hold on;
    offsvars = [offsvars [mn mn2 mn3 mn4 mn5 mn6]'];
end
plot(1:6,offsvars','color',[0.5 0.5 0.5],'linewidth',2);
%%
alignby=1;
figure;
h1 = subplot(6,1,1);hold on;
h2 = subplot(6,1,2);hold on;
h3 = subplot(6,1,3);hold on;
h4 = subplot(6,1,4);hold on;
h5 = subplot(6,1,5);hold on;
h6 = subplot(6,1,6);hold on;
for i = 1:50
    tb = [0:length(testmotifsegment(i).sm)-1]/32000;
    tb1 = tb - testmotifsegment(i).dtwsegment(1,2);
     plot(h1,tb1,log(testmotifsegment(i).sm));
    tb1 = tb - testmotifsegment(i).ampsegment(1,2);
    plot(h2,tb1,log(testmotifsegment(i).sm));
    tb1 = tb - testmotifsegment(i).pksegment(1,2);
    plot(h3,tb1,log(testmotifsegment(i).sm));
    tb1 = tb - testmotifsegment(i).dtwpksegment(1,2);
    plot(h4,tb1,log(testmotifsegment(i).sm));
    tb1 = tb - testmotifsegment(i).tonalitysegment(1,2);
    plot(h5,tb1,log(testmotifsegment(i).sm));
    tb1 = tb - testmotifsegment(i).dtwampsegment(1,2);
    plot(h6,tb1,log(testmotifsegment(i).sm));
end