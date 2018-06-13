function dataCaptureUI(src, event, c, hGui)
%dataCapture Process DAQ acquired data when called by DataAvailable event.
%  dataCapture (SRC, EVENT, C, HGUI) processes latest acquired data (EVENT.DATA)
%  and timestamps (EVENT.TIMESTAMPS) from session (SRC), and, based on specified
%  capture parameters (C structure) and trigger configuration parameters from
%  the user interface elements (HGUI handles structure), updates UI plots
%  and captures data.
%
%   c.TimeSpan        = triggered capture timespan (seconds)
%   c.bufferTimeSpan  = required data buffer timespan (seconds)
%   c.bufferSize      = required data buffer size (number of scans)
%   c.plotTimeSpan    = continuous acquired data timespan (seconds)
%

% The incoming data (event.Data and event.TimeStamps) is stored in a
% persistent buffer (dataBuffer), which is sized to allow triggered data
% capture.

% Since multiple calls to dataCapture will be needed for a triggered
% capture, a trigger condition flag (trigActive) and a corresponding
% data timestamp (trigMoment) are used as persistent variables.
% Persistent variables retain their values between calls to the function.

% persistent trigActive trigMoment 
persistent dataBuffer dataBufferSelect dataBufferProbe dataBufferSelectProbe
global BufferSelect BufferSelectProbe SelectionState

% If dataCapture is running for the first time, initialize persistent vars
if event.TimeStamps(1)==0
    data = {};
    ParamCap = {};
    dataBuffer = [];          % data buffer
    dataBufferSelect = [];    % data buffer with selected colums to display
    prevData = [];            % last data point from previous callback execution
else
    prevData = dataBuffer(end, :);
end
        
if get(hGui.RandomProbe,'value')
    BufferSizeProbe = (round(str2double(hGui.MaxProbeTime.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
else
    BufferSizeProbe = (round(str2double(hGui.InterProbe.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
end

% Store continuous acquisition data in persistent FIFO buffer dataBuffer
% (display and single scan)
latestData = [event.TimeStamps, event.Data];
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% Store continuous acquisition data in persistent FIFO buffer dataBuffer
% for the probe option
dataBufferProbe = [dataBufferProbe; latestData];
numSamplesToDiscardProbe = size(dataBufferProbe,1) - BufferSizeProbe;
if (numSamplesToDiscardProbe > 0)
    dataBufferProbe(1:numSamplesToDiscardProbe, :) = [];
end

% Display selection code for the live plot
AIContSelect = get(hGui.ContSelect,'value');
switch AIContSelect
    case 1 % AI0 + AI2
        dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4),NaN(length(dataBuffer(:,1)),1)];
        dataBufferSelectProbe = [dataBufferProbe(:,1),dataBufferProbe(:,2),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,4),NaN(length(dataBufferProbe(:,1)),1)];
    case 2 % AI1 + AI3
        dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,5)];
        dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,3),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,5)];
    case 3 % AI0
        dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),NaN(length(dataBuffer(:,1)),3)];
        dataBufferSelectProbe = [dataBufferProbe(:,1),dataBufferProbe(:,2),NaN(length(dataBufferProbe(:,1)),3)];
    case 4 % AI1
        dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,3),NaN(length(dataBuffer(:,1)),2)];
        dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,3),NaN(length(dataBufferProbe(:,1)),2)];
    case 5 % AI2
        dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),2),dataBuffer(:,4),NaN(length(dataBuffer(:,1)),1)];
        dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),2),dataBufferProbe(:,4),NaN(length(dataBufferProbe(:,1)),1)];
    case 6 % AI3
        dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),3),dataBuffer(:,5)];
         dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),3),dataBufferProbe(:,5)];
    case 7 % ALL
        dataBufferSelect = dataBuffer;
        dataBufferSelectProbe = dataBufferProbe;
end

SelectionState = AIContSelect;
BufferSelect = dataBufferSelect; % Global = persistent (type de variable)
BufferSelectProbe = dataBufferSelectProbe;

% Update live data plot
% Plot latest plotTimeSpan seconds of data in dataBuffer
samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBufferSelect,1)]);
firstPoint = size(dataBufferSelect, 1) - samplesToPlot + 1;
% Update x-axis limits
xlim(hGui.Axes1, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
% Update y-axis limits

% Live plot has one line for each acquisition channel
for ii = 1:numel(hGui.LivePlot)
    set(hGui.LivePlot(ii), 'XData', dataBufferSelect(firstPoint:end, 1), ...
                           'YData', dataBufferSelect(firstPoint:end, 1+ii))
    drawnow limitrate
end

%drawnow

% if get(hGui.test,'value')
%     hGui.NumPushTime = hGui.NumPushTime + 1;
%     EMGcount = 0;
%     BStim = str2double(hGui.BeforeStim.String)/1000;
%     AStim = str2double(hGui.AfterStim.String)/1000;
%     decalageEMGbuffer = length(hGui.databufferCapture(:,1))-round(hGui.SourceRate*BStim);
%     maxEMGbuffer = round(hGui.SourceRate*(AStim+BStim));
%     dataEMG = zeros(maxEMGbuffer,length(hGui.databufferCapture(1,:)));
%     while EMGcount < maxEMGbuffer
%         EMGcount = EMGcount + 1;
%         dataEMG(EMGcount,:) = hGui.databufferCapture(decalageEMGbuffer,:);
%     end
%     hGui.data{hGui.NumPushTime,1} = dataEMG;
%     set(hObject, 'Value', 0);
% end


% % Read current text and convert it to a number.
% currentCounterValue = str2double(get(handles.Counter, 'String'));
% % Create a new string with the number being 1 more than the current number.
% newString = sprintf('%d', int32(currentCounterValue +1));

% % Update live data plot (ANCIEN)
% % Plot latest plotTimeSpan seconds of data in dataBuffer
% samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBuffer,1)]);
% firstPoint = size(dataBuffer, 1) - samplesToPlot + 1;
% % Update x-axis limits
% xlim(hGui.Axes1, [dataBuffer(firstPoint,1), dataBuffer(end,1)]);
% % Live plot has one line for each acquisition channel
% for ii = 1:numel(hGui.LivePlot)
%     set(hGui.LivePlot(ii), 'XData', dataBuffer(firstPoint:end, 1), ...
%                            'YData', dataBuffer(firstPoint:end, 1+ii))
%     drawnow limitrate
% end
% 
% drawnow

end
