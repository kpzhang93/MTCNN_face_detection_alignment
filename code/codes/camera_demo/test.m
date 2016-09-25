function varargout = test(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end




function test_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = test_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function pushbutton1_Callback(hObject, eventdata, handles)
    threshold=[0.6 0.7 str2num(get(findobj('tag','edit4'),'string'))]
	factor=0.709;
    minsize=str2num(get(findobj('tag','edit6'),'string'));
    stop=0.03;
    mypath=get(findobj('tag','edit1'),'string')
    addpath(mypath);
    caffe.reset_all();
    caffe.set_mode_cpu();
    mypath=get(findobj('tag','edit3'),'string')
    addpath(mypath);
    cameraid=get(findobj('tag','edit2'),'string')
    camera=imaqhwinfo;
    camera=camera.InstalledAdaptors{str2num(cameraid)}
    vid1= videoinput(camera,1,get(findobj('tag','edit5'),'string'));
    warning off all    
    usbVidRes1=get(vid1,'videoResolution');
    nBands1=get(vid1,'NumberOfBands');
    hImage1=imshow(zeros(usbVidRes1(2),usbVidRes1(1),nBands1));
    preview(vid1,hImage1);
    
    prototxt_dir = './model/det1.prototxt';
    model_dir = './model/det1.caffemodel';
    PNet=caffe.Net(prototxt_dir,model_dir,'test');
	prototxt_dir = './model/det2.prototxt';
    model_dir = './model/det2.caffemodel';
    RNet=caffe.Net(prototxt_dir,model_dir,'test');
	prototxt_dir = './model/det3.prototxt';
    model_dir = './model/det3.caffemodel';
    ONet=caffe.Net(prototxt_dir,model_dir,'test');  
    prototxt_dir = './model/det4.prototxt';
    model_dir = './model/det4.caffemodel';
    LNet=caffe.Net(prototxt_dir,model_dir,'test');  
    rec=rectangle('Position',[1 1 1 1],'Edgecolor','r');
    while (1)
        img=getsnapshot(vid1);
        [total_boxes point]=detect_face(img,minsize,PNet,RNet,ONet,threshold,false,factor);
        try
            delete(rec);
        catch
        end
        numbox=size(total_boxes,1);
        for j=1:numbox;       
            rec(j)=rectangle('Position',[total_boxes(j,1:2) total_boxes(j,3:4)-total_boxes(j,1:2)],'Edgecolor','g','LineWidth',3);
            rec(6*numbox+j)=rectangle('Position',[point(1,j),point(6,j),5,5],'Curvature',[1,1],'FaceColor','g','LineWidth',3);
            rec(12*numbox+j)=rectangle('Position',[point(2,j),point(7,j),5,5],'Curvature',[1,1],'FaceColor','g','LineWidth',3);
            rec(18*numbox+j)=rectangle('Position',[point(3,j),point(8,j),5,5],'Curvature',[1,1],'FaceColor','g','LineWidth',3);
            rec(24*numbox+j)=rectangle('Position',[point(4,j),point(9,j),5,5],'Curvature',[1,1],'FaceColor','g','LineWidth',3);
            rec(30*numbox+j)=rectangle('Position',[point(5,j),point(10,j),5,5],'Curvature',[1,1],'FaceColor','g','LineWidth',3);
        end
        pause(stop)
    end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
