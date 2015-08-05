function [in_features in_RGB] = makeScatterIn(struct_list)
%
%
% in progress 10.15.09
%
%

% concatenate feature vectors:
for i=1:length(struct_list);
    the_struct = struct_list(i);

    if(i == 1)
        in_features = the_struct.templates;
    else
        in_features = vertcat(in_features,the_struct.templates);
    end

end


% construct RGB vector:
cmap = colormap(hot);
d_RGB = floor(length(cmap) / length(struct_list));
start = 1; cstart = 1;
stop = 1; cstop = 1;

r_vect = zeros(length(in_features),1);
g_vect = r_vect;
b_vect = r_vect;

for i=1:length(struct_list)
    the_struct = struct_list(i);
    if(i == 1)
        start = 1;
        stop = length(the_struct.templates);
        cstart = 1;
    else
        start = stop;
        stop = start + length(the_struct.templates);
        cstop = d_RGB;
    end

    r_vect(start:stop) = cmap(cstart,1);
    g_vect(start:stop) = cmap(cstart,2);
    b_vect(start:stop) = cmap(cstart,3);

    cstart = cstart + d_RGB;
    cstop = cstop + d_RGB;
end

in_RGB = horzcat(r_vect,g_vect,b_vect);

%in_features = in_features(1:length(in_features)-1);