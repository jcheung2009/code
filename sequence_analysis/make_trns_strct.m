function [trns_strct] = make_trns_strct(prb_strct,labels,prbnote,lblprtc,grph,svstrct,name)

if (nargin == 3), lblprtc = 'null'; grph = 1; svstrct = 0; name = 'null'; end
if (nargin == 4), grph = 1;svstrct = 0; name = 'null'; end
if (nargin == 5) , svstrct = 0; name = 'null'; end


trns_mtrx = zeros(length(labels),length(labels));

for i = 1:length(prb_strct)-1
    
    if strcmp('last',char(prbnote))
        lblindx1 = strfind(char(labels), char(prb_strct(i).cndnt));
        ptn = char(prb_strct(i).ptn);
        lblindx2 = strfind(char(labels), char(ptn(1)));
    else 
        lblindx1 = strfind(char(labels), char(prb_strct(i).cndnt));
        ptn = char(prb_strct(i).ptn);
        lblindx2 = strfind(char(labels), char(ptn(2)));
    end
    if ~isempty(lblindx1) && ~isempty(lblindx2)
        trns_mtrx(lblindx2,lblindx1) = prb_strct(i).prob;
    end
end




lblnmbrs = [1:length(labels)];
if grph
    figure(50); imagesc(trns_mtrx); colorbar('vert');
    if strcmp('last',char(prbnote))
        title('Conditional Probability, P(x|y) of Pair-Wise Transitions xy');
    else
        title('Conditional Probability, P(y|x) of Pair-Wise Transitions xy');
    end
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
            figure(k*100); plot(lblnmbrs,vct,'b*',lblnmbrs,vct,'r-.'); grid on; 
            title(['Conditional Probabilities, P(x|y), for sylable ' char(lblprtc(k))]);
            ylabel(['P(syl|' char(lblprtc(k)) ')']);
            for i = 1:length(labels)
                text(i,-.075,char(labels(i)));
            end
        end
     end
 end
 
     trns_strct.mtrx = trns_mtrx;
     trns_strct.lbls = char(labels);
 if svstrct
     save([char(name) '.trns_strct.mat'],'trns_strct');
 end
 
 