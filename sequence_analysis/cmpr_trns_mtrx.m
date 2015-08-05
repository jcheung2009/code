function cmpr_trns_mtrx(mtrx1,labels1,mtrx2,labels2,name1,name2)

%for now labels1 and labels2 must be the same
%perhaps an optional conversion table if labels are different
%

if length(labels1) == length(labels2)
    eql = eval(['labels1 == labels2']);
    if sum(eql) == length(labels1)
        trns_diff_mtrx = mtrx1-mtrx2;
        labels = labels1;
        mtrx1_trnsfrmd = mtrx1;
        mtrx2_trnsfrmd = mtrx2;
    elseif isempty(setxor(labels1,labels2))
         [mtrx1_trnsfrmd,mtrx2_trnsfrmd,con_cat] = make_eql_sqrmtrx_cat(mtrx1,labels1,mtrx2,labels2);
         trns_diff_mtrx = mtrx1_trnsfrmd-mtrx2_trnsfrmd;
         labels = con_cat;
    else
        error('Labels1 and labels2 must have the same elements... will fix this soon...sorry');
        %[mtrx1_trnsfrmd,mtrx2_trnsfrmd,con_cat] = make_eql_mtrx_cat(mtrx1,labels1,mtrx2,labels2);
    end
else
    error('Labels1 and labels2 must have the same elements... will fix this soon...sorry');
    %[mtrx1_trnsfrmd,mtrx2_trnsfrmd,con_cat] = make_eql_mtrx_cat(mtrx1,labels1,mtrx2,labels2);
end
    
figure; imagesc(abs(trns_diff_mtrx));colorbar('vert');title('Difference of Transition Matrices');
    for i = 1:length(labels)
        text(i-.25,length(labels)+.75,char(labels(i)));
    end
    for i = 1:length(labels)
        h=text(.2,i+.25,char(labels(i)));
    end
    lblnmbrs = [1:length(labels)];
    for k = 1:length(char(labels))  
        crntlbl = char(labels(k));
        vct1 = mtrx1_trnsfrmd(:,k);
        vct2 = mtrx2_trnsfrmd(:,k);
        figure(k*100); plot(lblnmbrs,vct1,'k-',lblnmbrs,vct2,'r-.'); grid on; 
        title(['Conditional Probabilities, P(x|y), for sylable ' char(crntlbl)]);
        legend(char(name1),char(name2))
        for i = 1:length(labels)
            text(i,-.075,char(labels(i)));
        end
        ylabel(['P(syl|' char(labels(k)) ')']);
    end


