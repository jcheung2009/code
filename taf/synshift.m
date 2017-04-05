%synshift script
%used to synthetically shift templates, for purposes of maintaining hits
%during pitchshifts.
%takes 'invec' as input, returns 'outvec'  

%for first harmonic what are points to cut out

range=[16 26]
%number of harmonics to shift
npeaks=3;

%positive value for upshift, negative value for downshift
shift=-2;

outvec=zeros(length(invec),1);
for ii=1:npeaks
    outvecind=[ii*(range+shift)];
    invecind=[ii*range];
    outvec(outvecind(1):outvecind(2))=invec(invecind(1):invecind(2));
end