% Configure data acquisition session and add analog input channels
clear all
global s
s = daq.createSession('ni');

%Le Dev1 est le nom du daq
Ch_ai0=addAnalogInputChannel(s,'Dev2','ai0','Voltage'); % EMG
%ai1=addAnalogInputChannel(s,'Dev1','ai1','Voltage');
Ch_ai2=addAnalogInputChannel(s,'Dev2','ai2','Voltage'); % Trigger Cortex
Ch_ai3=addAnalogInputChannel(s,'Dev2','ai3','Voltage'); % Trigger Muscle

% Set acquisition configuration for each channel
Ch_ai0.TerminalConfig = 'SingleEnded';
%ai1.TerminalConfig = 'SingleEnded';
Ch_ai2.TerminalConfig = 'SingleEnded';
Ch_ai3.TerminalConfig = 'SingleEnded';

% Set acquisition configuration for each channel
Ch_ai0.Range = [-1,1];
% ai1.Range = [-1,1];
Ch_ai2.Range = [-10,10];
Ch_ai3.Range = [-10,10];

% Parametres de captures et de controle

% Specify the desired parameters for data capture and live plotting.
% The data capture parameters are grouped in a structure data type,
% as this makes it simpler to pass them as a function argument.
s.Rate = 6000;

% Specify triggered capture timespan, in secondss
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
hGui = PAS_Interface_Gui_Callback(s);

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters and the handles to the UI graphics
% elements are passed as additional arguments to the callback function.
dataListener = addlistener(s, 'DataAvailable', @(src,event) PAS_Interface_Acquisition(src, event, capture, hGui));
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
