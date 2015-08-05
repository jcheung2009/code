
% --- Executes on mouse press over axes background.
function MainPlot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Xax
global StartLine;
global EndLine;

buttonclick=get(gcf,'SelectionType');
ax = get(hObject, 'Parent');
pt = get(ax, 'CurrentPoint');

if strcmp(buttonclick,'normal')    
    Xax=[pt(1) 0];         
    Yax=ylim;
    try
        killhand=findobj(gca,'Tag','StartLine');
        delete(killhand);
    catch
    end;
    StartLine=line(Xax(1),Yax(1):Yax(2),'Color','r','Tag','StartLine');
    
    
  elseif strcmp(buttonclick,'alt')
    try
        killhand=findobj(gca,'Tag','EndLine');
        delete(killhand);
    catch
    end;
      Yax=ylim;
      Xax(2)=pt(1);           
      EndLine=line(Xax(2),Yax(1):Yax(2),'Color','k','Tag','EndLine');      
end;
