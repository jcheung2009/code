function [ind] = jc_findoutliers(invect,nstd)

if isempty(nstd)
    nstd = 2.5;
end

if size(invect,2) == 2
    hithrsh = nanmean(invect(:,2)) + nstd*nanstd(invect(:,2));
    lothrsh = nanmean(invect(:,2)) - nstd*nanstd(invect(:,2));

    i = find(invect(:,2) < lothrsh);
    ii = find(invect(:,2) > hithrsh);

    ind = [i;ii];
elseif size(invect,2) == 1
    hithrsh = nanmean(invect) + nstd*nanstd(invect);
    lothrsh = nanmean(invect) - nstd*nanstd(invect);

    i = find(invect < lothrsh);
    ii = find(invect > hithrsh);

    ind = [i;ii];
end

