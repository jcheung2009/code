function [clrmap] = make_clr_map_pure(nclrs)


clrspan = linspace(.2,1,ceil((nclrs-4)/3));

semiclrs = linspace(.3,.8,ceil((nclrs-5)/3));
semiclrs = [semiclrs 0];

for i = 1:length(clrspan)
blues(i,:) = [clrspan(i) 0 semiclrs(i)];
end

blues(i+1,:) = [1 0 0];
for i = 1:length(clrspan)
reds(i,:) = [semiclrs(i) clrspan(i) 0];
end
reds(i+1,:) = [0 1 0];
for i = 1:length(clrspan)
greens(i,:) = [0 semiclrs(i) clrspan(i)];
end
greens(i+1,:) = [0 0 1];

clrmap  = [0 0 0; blues; reds; greens];
