function outvec = synshift(invec,npeaks,range,shift);
%npeaks = number of harmonics to shift
%range = x range of template


outvec=zeros(length(invec),1);
for ii=1:npeaks
    outvecind=[ii*(range+shift)];
    invecind=[ii*range];
    outvec(outvecind(1):outvecind(2))=invec(invecind(1):invecind(2));
end