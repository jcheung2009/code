fvsal = fv_syllB2_4_10_2014_sal;
fvcond = fv_syllB2_4_11_2014_naspm2;

figure;hold on;ax=subtightplot(3,1,1,0.05,0.1,0.1);hold on;
jc_plotsyllspec(fvsal(end),32000,ax);
x = get(gca,'xlim');set(ax,'fontweight','bold');

pcsal = jc_getpc(fvsal);
pccond = jc_getpc(fvcond);

ax=subtightplot(3,1,2,0.05,0.1,0.1);hold on;
patch([pcsal.tm',fliplr(pcsal.tm')],[nanmean(pcsal.pc,2)'-nanstderr(pcsal.pc,2)' fliplr(nanmean(pcsal.pc,2)'+nanstderr(pcsal.pc,2)')],[0.5 0.5 0.5],'edgecolor','none');
patch([pccond.tm',fliplr(pccond.tm')],[nanmean(pccond.pc,2)'-nanstderr(pccond.pc,2)' fliplr(nanmean(pccond.pc,2)'+nanstderr(pccond.pc,2)')],[0.7 0.3 0.3],'edgecolor','none');
xlim(x);set(ax,'fontweight','bold');

smsal = jc_getsm(fvsal);
smcond = jc_getsm(fvcond);
tmsal = ([0:length(smsal.tm)-1]./32000)-0.016;
tmcond = ([0:length(smcond.tm)-1]./32000)-0.016;

ax = subtightplot(3,1,3,0.05,0.1,0.1);hold on;
patch([tmsal,fliplr(tmsal)],[nanmean(log(smsal.sm),2)'-nanstderr(log(smsal.sm),2)' fliplr(nanmean(log(smsal.sm),2)'+nanstderr(log(smsal.sm),2)')],[0.5 0.5 0.5],'edgecolor','none');
patch([tmcond,fliplr(tmcond)],[nanmean(log(smcond.sm),2)'-nanstderr(log(smcond.sm),2)' fliplr(nanmean(log(smcond.sm),2)'+nanstderr(log(smcond.sm),2)')],[0.7 0.3 0.3],'edgecolor','none');
xlim(x);set(ax,'fontweight','bold');