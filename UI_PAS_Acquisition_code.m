function UI_PAS_Acquisition_code
%% Configure data acquisition session and add analog input channels
clear all
global s
s = daq.createSession('ni');
ai0=addAnalogInputChannel(s,'Dev1','ai0','Voltage'); %Le Dev1 est le nom du daq
ai1=addAnalogInputChannel(s,'Dev1','ai1','Voltage');
ai2=addAnalogInputChannel(s,'Dev1','ai2','Voltage');
ai3=addAnalogInputChannel(s,'Dev1','ai3','Voltage');

% Set acquisition configuration for each channel
ai0.TerminalConfig = 'SingleEnded';
ai1.TerminalConfig = 'SingleEnded';
ai2.TerminalConfig = 'SingleEnded';
ai3.TerminalConfig = 'SingleEnded';

ai0.Range = [-2 2]; 
ai1.Range = [-2 2];
ai2.Range = [-2 2];
ai3.Range = [-2 2]; %[-10.0 10.0];

%% Parametres de captures et de controle

% Specify the desired parameters for data capture and live plotting.
% The data capture parameters are grouped in a structure data type,
% as this makes it simpler to pass them as a function argument.
s.Rate = 2000;

% Specify triggered capture timespan, in seconds
capture.TimeSpan = 1;    % \/\/ À CONVERTIR DANS PARAMS PLUS TARD \/\/

% Specify continuous data plot timespan, in seconds
capture.plotTimeSpan = 10; % \/\/ À CONVERTIR DANS PARAMS PLUS TARD \/\/

% Determine the timespan corresponding to the block of samples supplied
% to the DataAvailable event callback function.
callbackTimeSpan = double(s.NotifyWhenDataAvailableExceeds)/s.Rate;
% Determine required buffer timespan, seconds
capture.bufferTimeSpan = max([capture.plotTimeSpan, capture.TimeSpan*3, callbackTimeSpan*3]);
% Determine data buffer size
capture.bufferSize = round(capture.bufferTimeSpan * s.Rate);

% Display graphical user interface 
hGui = DataCaptureUI_PAS(s);

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
dataListener = addlistener(s, 'DataAvailable', @(src,event) dataCaptureUI(src, event, capture, hGui));

% Add a listener for acquisition error events which might occur during background acquisition
errorListener = addlistener(s, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

% Start continuous background data acquisition
s.IsContinuous = true;
startBackground(s);

% Wait until session s is stopped from the UI
while s.IsRunning
     pause(0.5);
end

delete(dataListener);
delete(errorListener);
delete(s);
end

