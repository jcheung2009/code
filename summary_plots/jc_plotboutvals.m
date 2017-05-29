function jc_plotboutvals(boutinfo,marker,linecolor,tbshift,fignum,params)
%plot bout values for script_plotdata 

nummotifs = [boutinfo(:).nummotifs]';
if ~isempty(tbshift)
    tb = jc_tb([boutinfo(:).datenm]',7,0);
    tb = tb+(tbshift*24*3600);
else
    tb = [boutinfo(:).datenm]';
end

if isempty(fignum)
    fignum = input('fig number for singing rate:');
end
figure(fignum);hold on; 
if strcmp(params.measure_intro,'y')
    h1 = subtightplot(3,1,1,0.07,0.05,0.08);hold on;
    h2 = subtightplot(3,1,2,0.07,0.05,0.08);hold on;
    h3 = subtightplot(3,1,3,0.07,0.05,0.08);hold on;
else
    h1 = subtightplot(2,1,1,0.07,0.05,0.08);hold on;
    h2 = subtightplot(2,1,2,0.07,0.05,0.08);hold on;
end

%% plot number of motifs in bout over time
axes(h1);hold on;
plot(h1,tb,nummotifs,marker);
if ~isempty(tbshift)
    xscale_hours_to_days(h1);
    xlabel('','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel('Number of motifs in bout');

%% plot number of intronotes in bout over time
if strcmp(params.measure_intro,'y')
    numintro = [boutinfo(:).numintro]';
    axes(h3);hold on;
    plot(h3,tb,numintro,marker);
    if ~isempty(tbshift)
        xscale_hours_to_days(h3);
        xlabel('','fontweight','bold');
    else
        xlabel('Time','fontweight','bold');
    end
    ylabel('Number of intro notes');
end

%% plot singing rate
if ~isempty(tbshift)
    tb_secs = tb;
else
    tb_secs = jc_tb(tb,7,0);
end
numseconds = tb_secs(end)-tb_secs(1);
timewindow = 3600; %half hr in seconds
jogsize = 900;%15 minutes
numtimewindows = ceil(numseconds/jogsize)-(timewindow/jogsize)/2;
if numtimewindows < 0
    numtimewindows = 1;
end

timept1 = tb_secs(1);
numsongs = [];
nummotifs_per_window = [];
for i = 1:numtimewindows
    timept2 = timept1+timewindow;
    ind = find(tb_secs >= timept1 & tb_secs < timept2);
    numsongs(i,:) = [timept1+jogsize length(ind)];
    timept1 = timept1+jogsize;
end
if numtimewindows == 1
    numsongs = [numsongs; timept1+jogsize 0];
end
if isempty(tbshift)
    numsongs(:,1) = arrayfun(@(x) addtodate(tb(1),round(x),'second'),numsongs(:,1));
end
axes(h2);hold on;
stairs(h2,numsongs(:,1),numsongs(:,2),linecolor);
if ~isempty(tbshift)
    xscale_hours_to_days(h2);
    xlabel('Days','fontweight','bold');
else
    xlabel('Time','fontweight','bold');
end
ylabel(h2,'Number of songs per hour');






    

    
    
    