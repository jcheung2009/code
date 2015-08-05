function [trns_strct] = make_trns_mtrx(prb_strct,labels,lblprtc,grph,svstrct,name)

%prb_strct: probability structure from prob_of_patterns
%labels: labels to use e.g.'abcde'
%lblprtc: plot individual transition distributions for syllables e.g.
%'abcde'
%grph: 0= no plot,1=yes plot
%svstrct; save the output to a file
%name: name of saved file
%

if (nargin == 2), lblprtc = 'null'; grph = 1; svstrct = 0; name = 'null'; end
if (nargin == 3), grph = 1;svstrct = 0; name = 'null'; end
if (nargin == 4) , svstrct = 0; name = 'null'; end


trns_mtrx = zeros(length(labels),length(labels));

for i = 1:length(prb_strct)-1
    lblindx1 = strfind(char(labels), char(prb_strct(i).cndnt));
    ptn = char(prb_strct(i).ptn);
    lblindx2 = strfind(char(labels), char(ptn(1)));
    if ~isempty(lblindx1) && ~isempty(lblindx2)
        trns_mtrx(lblindx2,lblindx1) = prb_strct(i).prob;
    end
end

lblnmbrs = [1:length(labels)];
if grph
    figure(50); imagesc(trns_mtrx); colorbar('vert');title('Conditional Probability, P(x|y) of Pair-Wise Transitions xy');
    for i = 1:length(labels)
        text(i-.25,length(labels)+.75,char(labels(i)));
    end
    for i = 1:length(labels)
        h=text(.2,i+.25,char(labels(i)));
    end
	if ~strcmp(lblprtc,'null')
        for k = 1:length(char(lblprtc))  
            lblindx = strfind(labels,char(lblprtc(k)));
            vct = trns_mtrx(:,lblindx);
            figure(k*100); plot(lblnmbrs,vct,'b*',lblnmbrs,vct,'r-.'); grid on; title(['Conditional Probabilities, P(x|y), for sylable ' char(lblprtc(k))]);
            for i = 1:length(labels)
                text(i,-.075,char(labels(i)));
            end
            ylabel(['P(syl|' char(lblprtc(k)) ')']);
        end
     end
 end
 
     trns_strct.mtrx = trns_mtrx;
     trns_strct.lbls = char(labels);
 if svstrct
     save([char(name) '.trns_strct.mat'],'trns_strct');
 end
 
 