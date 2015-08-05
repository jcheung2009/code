function Update_All(handles);

    global Path;
    global FileName;
    global FileIdx;
    global Data;
    global ExpType;
    global ChannelOut;
    global Xax

    
    set(handles.FileNameString,'String',FileName);
    ChannelOut=1;
    disp(ExpType)
    cla(handles.MainPlot);
    cla(handles.StimPlot);
        
    if strmatch(ExpType,'VC');                    
        Out=MakeStim(Data.StepOn,Data.V,Data.VStep,Data.Dur,size(Data.I{1},2),Data.time(2)-Data.time(1));          
        Data.Out=Out;
        plot(handles.StimPlot,Data.time,Out);
        xlabel('time')
        ylabel('mV');        
        hand=plot(handles.MainPlot,Data.time,Data.I{ChannelOut});  
        set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);            
        xlabel('time');
        ylabel('pA');
    elseif strmatch(ExpType,'LTP');             

        
        time=Data(1).time;
        temp=struct2cell(Data);
        Iout=temp(5,:);
        for i=1:size(Iout,2)
            trace(i,1:length(Iout{i}))=Iout{i};
        end;
        
        hand=plot(handles.MainPlot,time,trace);  
       
        Olddata=Data;
        clear global Data;
        global Data;
        Data.dt=Olddata(1).dt/10;
        Data.lMAN.time{1}=time;
        Data.lMAN.signal{1}=trace;
        disp('a')

        xlabel('time')
        ylabel('pA');            
        set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);  
        
    elseif strmatch(ExpType,'IC');
        Out=MakeStim(Data.StepOn,Data.I,Data.IStep,Data.Dur,size(Data.Vm{1},2),Data.time(2)-Data.time(1));          
        Data.Out=Out;
        plot(handles.StimPlot,Data.time,Out);
        xlabel('time')
        ylabel('pA');        
        hand=plot(handles.MainPlot,Data.time,Data.Vm{ChannelOut});  
        set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);            
        xlabel('time');
        ylabel('mV');    
    elseif strmatch(ExpType,'Old_IC');   
        Data.Vm{1}=Data.membvolt;
        Data.Out=zeros(size(Data.Vm{1}));        
        for j=1:size(Data.Out,2)
            Data.Out(1000:6000,j)=Data.I(j);
            disp(j)
        end;        
        Data.time=Data.times(:,1);
        plot(handles.StimPlot,Data.time,Data.Out);
        xlabel('time')
        ylabel('pA');        
        hand=plot(handles.MainPlot,Data.time,Data.Vm{ChannelOut});  
        set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);            
        xlabel('time');
        ylabel('mV');  
        
    elseif strmatch(ExpType,'Pass');
        xlabel('time')
        if ~isfield(Data,'dt')
            Data.dt=0.1;
            Data.Vm=Data.Vm(:,1)*250;
        end;
        hand=plot(handles.MainPlot,Data.dt:Data.dt:Data.dt*length(Data.Vm),Data.Vm);  
        set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);  
    
    elseif strmatch(ExpType,'Stims');
        xlabel('time');
        if isfield(Data,'lMAN');
            for i=1:size(Data.lMAN.signal,2)                                
                try
                    tempout(i,:)=Data.lMAN.signal{i};               
                catch
                end;
            end;
            
            Data.lMAN.signal{1}=tempout;
                        
            if isfield(Data,'time')
                Data.lMAN.time{1}=Data.time{1};
            end;
            hand=plot(handles.StimPlot,Data.lMAN.time{1},tempout);
            set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);                                     
            legend('LMAN');    
            ylabel('pA');            
        end;        
%     keyboard
             try
                clear tempout;
                if isfield(Data,'HVc')
                    for i=1:size(Data.HVc.signal,2)    
                        try
                             tempout(i,:)=Data.HVc.signal{i};           %                             
                        catch
                        end;
                    end;
                end;
             catch
                 
                 
                 
                 
%                  keyboard;
%                  tempout=(Data.I{1}(:,:))                  
             end
                            
       
%            Data.HVc.signal=[];
            Data.HVc.signal{1}=tempout;            
            if isfield(Data,'time')
                Data.HVc.time{1}=Data.time{1};
            end;

            hand=plot(handles.MainPlot,Data.HVc.time{1},tempout);
            set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);                                     
            legend('HVc');      
            ylabel('pA');
         end;        % end isfield(Data,'HVc');
%         
        
        if isfield(Data,'Vm');
            for i=1:size(Data.Vm,2)      
               tempout(i,:)=Data.Vm{i};               
            end;
          
            hand=plot(handles.MainPlot,Data.time,tempout);
            set(hand,'ButtonDownFcn',@MainPlot_ButtonDownFcn);                                     
            legend('Something ');      
            ylabel('pA?');
    end;  
        
 end

