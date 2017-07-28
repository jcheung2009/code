function significance = pval(x)

if x <= 0.001
    significance = '<0.001';
elseif x > 0.001 & x <= 0.05
    significance = '<=0.05';
else
    significance = '>0.05';
end