
%Calculating residuals for bk57w35orig, in order to determine offset time              
inds=[4 5 6 36 37 38 39 41]
drxn={'up' 'up' 'up' 'do' 'do' 'do' 'do' 'do'} 
for ii=1:length(inds)
    ses(ii).inds=[inds(ii)]
    ses(ii).stlen=[40 ]
    ses(ii).datbnds{1}=[.025 .079]
% sps(5).datbnds{5}=[.03 .046]
    ses(ii).catch{1}=[1 ]
% sps(5).catch{5}=[3:8]

    ses(ii).fb{1}=1
    ses(ii).stind=3
    ses(ii).OFF_TMS{1}=[.1 .11]
    ses(ii).RESIDTMS=[.075 .12]
    ses(ii).drxn=drxn{ii};
    if(ii==1||ii==2)
        ses(ii).RESIDTMS=[.08 .115]
    end

end



%  %bk57w35evren 
% sps(6).inds=[35 36]
% sps(6).stlen=[10 10 60 60]
% sps(6).datbnds{1}=[.026 .042]
% sps(6).datbnds{2}=[.042 .056]
% sps(6).datbnds{3}=[.007 .023] 
% sps(6).datbnds{4}=[.019 .035]
% sps(6).catch{1}=[1 2]
% sps(6).catch{2}=[1 2]
% sps(6).catch{3}=[1 2]
% sps(6).catch{4}=[1 2]
% sps(6).fb{1}=[1]
% sps(6).fb{2}=[1]
% sps(6).fb{3}=2
% sps(6).fb{4}=2
% sps(6).stind=4
% sps(6).OFF_TMS=sps(5).OFF_TMS;
% sps(6).RESIDTMS=sps(5).RESIDTMS;

 %bk57w35evren 
sps(6).inds=[35 ]
sps(6).stlen=[10  ]
sps(6).datbnds{1}=[.026 .042]
sps(6).datbnds{2}=[.042 .056]
sps(6).datbnds{3}=[.026 .056]
% sps(6).datbnds{3}=[.007 .023] 
% sps(6).datbnds{4}=[.019 .035]
sps(6).catch{1}=[1 ]
sps(6).catch{2}=[1 ]
sps(6).catch{3}=[1]
% sps(6).catch{3}=[1 2]
% sps(6).catch{4}=[1 ]
sps(6).fb{1}=[1]
sps(6).fb{2}=[1]
sps(6).fb{3}=[1]
% sps(6).fb{3}=2
% sps(6).fb{4}=2
sps(6).stind=4
sps(6).OFF_TMS=sps(5).OFF_TMS;
sps(6).RESIDTMS=sps(5).RESIDTMS;
sps(6).drxn='up'

sps(7).inds=[10 11 12 ]
sps(7).stlen=[10 10 10 ]
sps(7).datbnds{1}=[.028 .042]
sps(7).datbnds{2}=[.042 .056]
sps(7).datbnds{3}=[.056 .068] 
sps(7).datbnds{4}=[.028 .068]

sps(7).catch{1}=[1 2 3 ]
sps(7).catch{2}=[1 2 3 ]
sps(7).catch{3}=[1 2 3 ]
sps(7).catch{4}=[1 2 3]

sps(7).fb{1}=[1 2 3 ]
sps(7).fb{2}=[1 2 3 ]
sps(7).fb{3}=[1 2 3 ]
sps(7).fb{4}=[1 2 3 ]
sps(7).drxn='do'
sps(7).stind=1
sps(7).OFF_TMS=sps(1).OFF_TMS;
sps(7).RESIDTMS=sps(1).RESIDTMS;

sps(8).inds=[45 46 47 ]
sps(8).stlen=[60 60 10 ]
sps(8).datbnds{1}=[.028 .044]
sps(8).datbnds{2}=[.028 .044]
sps(8).datbnds{3}=[.048 .064] 

sps(8).catch{1}=[1 2 3 ]
sps(8).catch{2}=[1 2 3 ]
sps(8).catch{3}=[1 2 3 ]

sps(8).fb{1}=[1  ]
sps(8).fb{2}=[ 2 ]
sps(8).fb{3}=[  3 ]
sps(8).stind=1
%%%FIX
sps(8).drxn='do'

sps(8).OFF_TMS=sps(1).OFF_TMS;
sps(8).RESIDTMS=sps(1).RESIDTMS;


sps(9).inds=[48 49 50 51 ]
sps(9).stlen=[10  10 10 10 ]
sps(9).datbnds{1}=[.004 .014]
sps(9).datbnds{2}=[.014 .024]
sps(9).datbnds{3}=[.024 .034] 
sps(9).datbnds{4}=[.034 .044] 
sps(9).datbnds{5}=[.044 .054] 
sps(9).datbnds{6}=[.054 .064] 
sps(9).datbnds{7}=[.064 .074] 
sps(9).datbnds{8}=[.074 .084]
sps(9).datbnds{9}=[.084 .094]
sps(9).datbnds{10}=[0 0.094];
for ii=1:10
sps(9).catch{ii}=[1:4]
end

for ii=1:10
sps(9).fb{ii}=[1:4]
end

sps(9).stind=1
sps(9).OFF_TMS=sps(1).OFF_TMS;
sps(9).RESIDTMS=sps(1).RESIDTMS;
sps(9).drxn='do'


sps(10).inds=[65]
sps(10).stlen=[10]
sps(10).datbnds{1}=[.000 .085]
sps(10).fb{1}=1;
sps(10).stind=1;
sps(10).catch{1}=1;
sps(10).OFF_TMS=sps(1).OFF_TMS;
sps(10).RESIDTMS=sps(1).RESIDTMS;

%%%%%%%%%FIX
sps(10).drxn='do'



sps(11).inds=[66]
sps(11).stlen=[10]
sps(11).datbnds{1}=[.000 .085]
sps(11).fb{1}=1;
sps(11).stind=1;
sps(11).catch{1}=1;
sps(11).OFF_TMS=sps(1).OFF_TMS;
sps(11).RESIDTMS=sps(1).RESIDTMS;
%%%%%%FIXX
sps(11).drxn='do'


sps(12).inds=[71 72 73 74]
sps(12).stlen=[10 10 10 10]
sps(12).datbnds{1}=[.000 .015]
sps(12).datbnds{2}=[.010 .025]
sps(12).datbnds{3}=[.020 .035] 
sps(12).datbnds{4}=[.030 .045] 
sps(12).datbnds{5}=[.040 .055] 
sps(12).datbnds{6}=[.050 .065] 
sps(12).datbnds{7}=[.060 .075] 
sps(12).datbnds{8}=[.070 .085] 
sps(12).datbnds{9}=[0 0.08]
for ii=1:9
    sps(12).fb{ii}=1:4;
    sps(12).stind=1;
    sps(12).catch{ii}=1:4;
end
sps(12).OFF_TMS=sps(1).OFF_TMS;
sps(12).RESIDTMS=sps(1).RESIDTMS;
sps(12).drxn='up'
