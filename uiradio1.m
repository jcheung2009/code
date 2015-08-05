    function Handle=uiradio1(hfig, p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8, p9,v9,p10,v10)
%UIRADIO1  Makes uicontrol RadioButtons.
%
%           H=UIRADIO1(HFIG, 'P1',V1,'P2',V2,P3,V3...)
%
%
%   
%  ****version modified by msb 9/13/2000 in attempt to work w/ matlab5****
%   *changes flagged w/ 'msb'
%
%    UIRADIO makes the N radio buttons in one single call.
%    It is a very simple way of building radio buttons and 
%    getting the value of the selected one.
%    The parameters are passed in the same way as the uicontrol
%    function. If HFIG is omitted the gcf is chosen.
%    H is the frame handle containing the radio buttons.
%    
%    The function makes a frame uicontrol that is a 'kind' of 
%    parent of the radio buttons the handle of which is returned.
%    When a radio button is 'clicked' it first selects itself,
%    then deselects all the others, sets the frame 'value'
%    property to its own serial number (the first to 1, the
%    second to 2 and so on) and finally evaluates the callback
%    if one has been passed.
%    All the radiobutton's handles and the frame's handle are 
%    stored in the frame 'userdata' property in this order:
%    [FrameHandle; Radio1Handle; Radio2Handle; Radio3Handle ...]
%
%    If a tag is specified it is set to the frame uicontrol only.
%    Therefore, findobj('tag', 'MYTAG') will find only
%    one uicontrol.
%
%    The strings of the radio buttons are passed to the function
%    using the string property in the same way you make
%    popupmenus. They can be either a matrix or a string
%    with '|' characters to separate the fields.
%
%    Now let's say:
%
%         h=uiradio(gcf, 'string', 'radio A|radio B|radio C'....
%
%    Three radio will be built. If you click radio B and then
%    get(h,'value') will return 2.
%
%
%    Starting value:
%    ---------------
%       To build the radios with a predefined selection, pass the
%       parameter 'value' to the function.
%       h=uiradio(gcf, 'string',  'A|B|C', 'value',3);
%       C will be on, A and B off.
%
%    Position and Location:
%    ----------------------
%       The position property is defined as usual together with the
%       units. Here it is the position of the frame in which
%       all the radio buttons will be contained.
%       By default the radios are made vertically arranged but
%       you can arrange them differently using the 'userdata'
%       property. For example to arrange three radio
%       horizontally pass a userdata [1 1 1].
%       [1 1 0 1] will still make them horizontally but the third
%       radio skips one location and goes to the fouth.
%       Or if you want 8 radios in a 3x3 fashion but with a hole in 
%       the middle use the userdata:
%                            1   1   1
%                            1   0   1
%                            1   1   1
%
%    Spacing:   
%    --------
%       By defaulf the radio are spaced by a 15 pixels gap.
%       Different vertical and horizontal spacing (in pixels) can be 
%       passed with the parameters 'min' and 'max'.
%       h=uiradio(gcf, 'string',  'A|B|C', 'min',30, 'max',10);
%
%    Callback:
%    ---------
%       Using the 'callback' parameter you can define the callback
%       that will be evaluated when cliking one of the radio.
%       All the radios will have the same callback.
%
%    How to know which radio is selected:
%    ------------------------------
%       The number of the radio button selected is saved in the
%       'value' property of the frame. get(h, 'value') return
%       the radio selected. The number reflects the order of 
%       the string property as in the popupmenus.
%       Note: The order number is stored, devided by 1000,
%       in the 'min' property of the radio.
%       
%
%    Other properties can be set as well.
%
%    How to delete, enable(on/off), visible(on/off)
   %    ----------------------------------------------
   %       Once the radios are built all their handles and the frame
   %       handle are in the frame userdata the which handle is returned.
   %       h=uiradio(gcf, 'string',  'A|B|C',....
   %       delete(get(h, 'userdata'))  %delete all the radios and frame
   %       set(get(h, 'userdata'), 'enable', 'off') 
   %       set(get(h, 'userdata'), 'visible', 'off')
   %
  %    Note:
  %    -----
  %       All the frame parameters except 'Userdata' and 'Value',
  %       can be modified freely after the radios have been made.
  %       h=uiradio(gcf, 'string',  'A|B|C',....
  %       set(h, 'backgroundcolor', [1 0 0]); %makes the frame red.
  %
  %    EXAMPLE
  %       h=uiradio(gcf, 'string', '1|2|3|4|5|6|7|8',...
  %            'value',3, 'units', 'norm', 'pos', [.1 .1 .5 .2],...
  %            'user', [1 1 1;1 0 1;1 1 1],...
  %            'min', 5, 'max', 5, 'horiz', 'center',...
  %            'callback', 'set(gcf, ''color'', ''b'')');
  %
  %
  %    See Also: UICONTROL, EDITNUM, EDITTEXT.
  %
  
  % This function can be modified with the only restriction that the
  % next two lines have to be reteined.
  %             Copyright (c) 1996 by Claudio Rivetti 
  %
  % Last version: September 2, 1996.
  % ENJOY IT!
  
  
  % definition of the  default horizontal and vertical spacing.
  hsp=15;  %in pixels
  vsp=15;  %in pixels
  
  if nargin > 21
     error('Too many input arguments.');
  end
  
  % Get the passed parameters
  if nargin > 0,
     if isstr(hfig)
             if (nargin)/2-fix((nargin)/2),
                     error('Incorrect number of input arguments')
             else
                     cmdstr=['hfig, p1,'];
                     for i=2:(nargin)/2,
                                     cmdstr = [cmdstr,'v',num2str(i-1),',p',num2str(i),','];
                     end
                     fig=gcf;
             end
     else
             if (nargin-1)/2-fix((nargin-1)/2),
                     error('Incorrect number of input arguments')
             else
                     cmdstr='';
                     for i=1:(nargin-1)/2,
                                     cmdstr = [cmdstr,'p',num2str(i),',v',num2str(i),','];
                     end
             end
             fig=hfig;
     end
     cmdstr(length(cmdstr))=' ';
  else
     fig=gcf;
  end
  
  %Builds the frame uicontrol that will contain the radio buttons
  h=uicontrol(fig, 'style', 'frame', 'min',99, 'max', 99);  %changed 'nan' to 99
  eval(['set(h,',cmdstr,');']);
  
  %Define the radio buttons callback
  cbk1='set(get(gco, ''user''), ''value'', 0);set(findobj(get(gco, ''user''), ''style'', ''frame''), ''value'', get(gco, ''min'')*100169  0);set(gco, ''value'', 1);';
  cbk2=get(h, 'callback');
  cbk=[cbk1 'drawnow;' cbk2];
  
  
  old_units=get(h, 'units');
  set(h, 'units', 'pixels');
  
  Str=get(h, 'string');
  Str=Str';   %msb  string handling all screwed up...
  n=max(size(Str));     %msb  row vs col vect issue...this may need to be made into a matrix with one row
                        % for each label?
  M=get(h, 'Userdata');
  
  
  if isempty(M)
     M=ones(n,1);
  end
  
  %Determine the positions of the radio buttons
  pos=get(h, 'pos');
  px=pos(1);
  py=pos(2);
  W=pos(3);
  H=pos(4);
  
  mn=get(h, 'min');
  if mn~=99
     vsp=mn;
  end
  
  mx=get(h, 'max');
  if mx~=99
     hsp=mx;
  end
  
  r=size(M,1);
  c=size(M,2);
  
  width=(W-(c+1)*hsp)/c;
  hight=(H-(r+1)*vsp)/r;
  
  POS=[];
  
  for j=1:r
     for i=1:c
             p=[px+hsp*i+(i-1)*width  py+(r+1-j)*vsp+(r-j)*hight  width  hight];
             POS=[POS;p];
     end
  end
  
  ret_value=0;
  hradio=[];
  i=0;
  j=0;
  
  %Builds the Radio buttons
  while i<n
     j=j+1;
     if prod(size(M)) < i
             fprintf('Warning: Location matrix insufficient. Radiobuttons truncated.\n');
             break;
     end
  
     if M(j)
             i=i+1;
             ret_value=ret_value+1;
             val=get(h, 'value')==(length(hradio)+1);
             hr=uicontrol(fig, 'style', 'radiobutton',...
                             'BackgroundColor',     get(h, 'BackgroundColor'),...
                             'CallBack',            cbk,...
                             'ForegroundColor',     get(h, 'ForegroundColor'),...
                             'HorizontalAlignment', get(h, 'HorizontalAlignment'),...            
                             'Min',                 0,...
                             'Position',            POS(j,:),...
                             'String',              deblank(Str(i,:)),...
                             'Units',               get(h, 'units'),...
                             'Value',               val,...
                             'ButtonDownFcn',       get(h, 'ButtonDownFcn'),... 
                             'Clipping',            get(h, 'Clipping'),... 
                             'Interruptible',       get(h, 'Interruptible'),... 
                             'Visible',             get(h, 'Visible'));
  
             hradio=[hradio;hr];
     end
  
  end
  
  
  %msb above used to set 'Min',                 ret_value/1000;  now set to 0
  
  
  %In each radio userdata puts the handle of the frame and
  %all the radio buttons but itself
  handles=[h;hradio];
  for i=2:length(handles)
     hh=handles(handles~=handles(i));
     set(handles(i), 'userdata', hh);
  end
  
  %In the frame userdata puts the handles of the radio buttons
  %plus the frame handle
  set(h, 'userdata', handles);
  
  set(handles, 'units', old_units);
  
  if nargout >0
     Handle=h;
  end
  
  return
