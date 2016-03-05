fid = fopen('bird_claim_events','r');
data = textscan(fid,'%q %q %q %q','Delimiter',',');
fclose(fid);

for i = 1:length(data{4})
    out = regexp(cell2mat(data{4}(i)),'\d{1,2}/\d{1,2}/\d{2,4}','match');
    if isempty(out)
        data{4}{i} = '';
    else
        data{4}(i) = out;
    end
end

%%%%%%%%%%%%%%plot bird usage over time by user

users = {'Joanne','Lucas','Paul','SooYoon','Mark','Brad'};
[c ia ic] = unique(data{3});
birdusage = struct();
for i = 1:length(users)
    ind = strfind(c,users{i});
    ind = find(~cellfun(@isempty,ind));
    indices = find(ic == ind);
    birdusage.([users{i}]).nest = data{2}(indices);
    birdusage.([users{i}]).claimdate = data{4}(indices);
end
      

for i = 1:length(users)
    dt = birdusage.([users{i}]).claimdate;
    for ii = 1:length(dt)
        newdt = datevec(birdusage.([users{i}]).claimdate(ii),'mm/dd/yy');
        birdusage.([users{i}]).claimdate(ii) = {newdt};
    end
    birdusage.([users{i}]).claimdate = cell2mat(birdusage.([users{i}]).claimdate);
end

year = 2015;
birds_2015 = zeros(12,length(users));
for i = 1:length(users)
    ind = find(birdusage.([users{i}]).claimdate(:,1) == year);
    for ii = 1:12
        birds_2015(ii,i) = birds_2015(ii,i)+length(find(birdusage.([users{i}]).claimdate(ind,2)==ii));
    end
end
figure;bar(birds_2015,'stack');
legend(gca,users);
title('Bird Usage in 2015');
xlabel('Month');
ylabel('Number of birds claimed');
set(gca,'fontweight','bold');

year = 2014;
birds_2014 = zeros(12,length(users));
for i = 1:length(users)
    ind = find(birdusage.([users{i}]).claimdate(:,1) == year);
    for ii = 1:12
        birds_2014(ii,i) = birds_2014(ii,i)+length(find(birdusage.([users{i}]).claimdate(ind,2)==ii));
    end
end
figure;bar(birds_2014,'stack');
legend(gca,users);
title('Bird Usage in 2014');
xlabel('Month');
ylabel('Number of birds claimed');
set(gca,'fontweight','bold');

%%%%%%%%%%%%%plot bird usage by nests

[c ia ic] = unique(data{2});
nests = c(~cellfun(@isempty,c));
nests = nests(~cellfun(@isempty,cellfun(@(x) strfind(x,'N'),nests,'unif',0)));
nestusage = struct();
for i = 1:length(nests)
    ind = find(strcmp(c,nests{i}));
    indices = find(ic == ind);
    nestusage.([nests{i}]).claimdate = data{4}(indices);
end

for i = 1:length(nests)
    nestusage.([nests{i}]).claimdate = nestusage.([nests{i}]).claimdate(~cellfun(@isempty,...
        nestusage.([nests{i}]).claimdate));
end

for i = 1:length(nests)
    dt = nestusage.([nests{i}]).claimdate;
    for ii = 1:length(dt)
        newdt = datevec(nestusage.([nests{i}]).claimdate(ii),'mm/dd/yy');
        nestusage.([nests{i}]).claimdate(ii) = {newdt};
    end
    nestusage.([nests{i}]).claimdate = cell2mat(nestusage.([nests{i}]).claimdate);
end

year = 2015;
nests_2015 = zeros(12,length(nests));
lname = {};
for i = 1:length(nests)
    if isempty(nestusage.([nests{i}]).claimdate)
        continue
    else
        ind = find(nestusage.([nests{i}]).claimdate(:,1) == year);
        if isempty(ind)
            continue
        else
            for ii = 1:12
                nests_2015(ii,i) = nests_2015(ii,i)+length(find(nestusage.([nests{i}]).claimdate(ind,2)==ii));
            end
        end
        lname = [lname; nests{i}];
    end
end
nests_2015 = nests_2015(:,any(nests_2015,1));

figure;bar(nests_2015,'stack');
legend(gca,nests);
title('Nest Usage in 2015');
xlabel('Month');
ylabel('Number of birds claimed');
set(gca,'fontweight','bold');