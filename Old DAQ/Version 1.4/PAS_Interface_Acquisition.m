function PAS_Interface_Acquisition(src, event, c, hGui)

% Declaration de variable global et persistent
persistent dataBuffer dataBufferSelect %dataBufferProbe dataBufferSelectProbe
global BufferSelect SelectionState FlagEMG%BufferSelectProbe 

% If dataCapture is running for the first time, initialize persistent vars
if event.TimeStamps(1)==0
    data = {};
    dataBuffer = [];          % data buffer
    dataBufferSelect = [];    % data buffer with selected colums to display
    prevData = [];            % last data point from previous callback execution
else
    prevData = dataBuffer(end, :);
end
        
% if get(hGui.RandomProbe,'value')
%     BufferSizeProbe = (round(str2double(hGui.MaxProbeTime.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
% else
%     BufferSizeProbe = (round(str2double(hGui.InterProbe.String)*str2double(hGui.PulseProbe.String)+5)*src.Rate);
% end

% Store continuous acquisition data in persistent FIFO buffer dataBuffer
% (display and single scan)
latestData = [event.TimeStamps, event.Data];
dataBuffer = [dataBuffer; latestData];
numSamplesToDiscard = size(dataBuffer,1) - c.bufferSize;
if (numSamplesToDiscard > 0)
    dataBuffer(1:numSamplesToDiscard, :) = [];
end

% % Store continuous acquisition data in persistent FIFO buffer dataBuffer
% % for the probe option
% dataBufferProbe = [dataBufferProbe; latestData];
% numSamplesToDiscardProbe = round(size(dataBufferProbe,1) - BufferSizeProbe);
% if (numSamplesToDiscardProbe > 0)
%     dataBufferProbe(1:numSamplesToDiscardProbe, :) = [];
% end

% Filter the EMG to get the enveloppe of the signal
% windowSize = round(src.Rate/20); 
% b = (1/windowSize)*ones(1,windowSize);
% a = 1;
% dataFiltered = abs(filter(b,a,dataBuffer(:,2)));

[b,a] = butter(4,2*50/src.Rate,'high'); % High pass avec une freq de coupure � 50 Hz
dataFiltered = filter(b,a,dataBuffer(:,2));
[yupper,~] = envelope(dataFiltered,70,'peak'); %50,'rms'
dataEnveloppe = abs(yupper);
    
if dataEnveloppe() < str2double(hGui.EMGWindowLow.String)/1000
    FlagEMG = true;
    set(hGui.FlagDisplay, 'string', 'Rising');
elseif dataEnveloppe(end) > str2double(hGui.EMGWindowHigh.String)/1000
    FlagEMG = false;
    set(hGui.FlagDisplay, 'string', 'Falling');
end

% [yupper,~] = envelope(dataBuffer(:,2),150,'rms');
% dataFiltered = abs(yupper);

% Display selection code for the live plot
AIContSelect = get(hGui.ContSelect,'value');
% switch AIContSelect
%     case 1 % AI0 + AI2
%         dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),dataFiltered,dataBuffer(:,4),NaN(length(dataBuffer(:,1)),1)]; %NaN(length(dataBuffer(:,1)),1)
%         dataBufferSelectProbe = [dataBufferProbe(:,1),dataBufferProbe(:,2),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,4),NaN(length(dataBufferProbe(:,1)),1)];
%     case 2 % AI1 + AI3
%         dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,5)];
% %         dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,3),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,5)];
%     case 3 % AI0
%         dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),NaN(length(dataBuffer(:,1)),3)];
% %         dataBufferSelectProbe = [dataBufferProbe(:,1),dataBufferProbe(:,2),NaN(length(dataBufferProbe(:,1)),3)];
%     case 4 % AI1
%         dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,3),NaN(length(dataBuffer(:,1)),2)];
% %         dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),1),dataBufferProbe(:,3),NaN(length(dataBufferProbe(:,1)),2)];
%     case 5 % AI2
%         dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),2),dataBuffer(:,4),NaN(length(dataBuffer(:,1)),1)];
% %         dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),2),dataBufferProbe(:,4),NaN(length(dataBufferProbe(:,1)),1)];
%     case 6 % AI3
%         dataBufferSelect = [dataBuffer(:,1),NaN(length(dataBuffer(:,1)),3),dataBuffer(:,5)];
% %         dataBufferSelectProbe = [dataBufferProbe(:,1),NaN(length(dataBufferProbe(:,1)),3),dataBufferProbe(:,5)];
%     case 7 % ALL
%         dataBufferSelect = dataBuffer;
% %         dataBufferSelectProbe = dataBufferProbe;
% end

switch AIContSelect
    case 1 % EMG + Trig Cortex + filtre
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)];
    case 2 % EMG + Trig Cortex
        dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),NaN(length(dataBuffer(:,1)),1),dataBuffer(:,3),NaN(length(dataBuffer(:,1)),1)];
    case 3 % EMG + Trig Muscle + filtre
        dataBufferSelect = [dataBuffer(:,1),dataFiltered,dataEnveloppe,NaN(length(dataBuffer(:,1)),1),dataBuffer(:,4)];
    case 4 % EMG + Trig Muscle
        dataBufferSelect = [dataBuffer(:,1),dataBuffer(:,2),NaN(length(dataBuffer(:,1)),2),dataBuffer(:,4)];
end

SelectionState = AIContSelect;
BufferSelect = dataBufferSelect; % Global = persistent (type de variable)
% BufferSelectProbe = dataBufferSelectProbe;

% Live plot has one line for each acquisition channel

if get(hGui.StopTimeAxis,'value')
    set(hGui.StatusText, 'String', 'Live plot is stop!');
else
    % Update live data plot
    % Plot latest plotTimeSpan seconds of data in dataBuffer
    samplesToPlot = min([round(c.plotTimeSpan * src.Rate), size(dataBufferSelect,1)]);
    firstPoint = size(dataBufferSelect, 1) - samplesToPlot + 1;
    % Update x-axis limits
    xlim(hGui.Axes1, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    xlim(hGui.Axes2, [dataBufferSelect(firstPoint,1), dataBufferSelect(end,1)]);
    for ii = 1:2
        set(hGui.LivePlotEMG(ii), 'XData', dataBufferSelect(firstPoint:end, 1), ...
            'YData', dataBufferSelect(firstPoint:end, 1+ii));
        set(hGui.LivePlotTrig(ii), 'XData', dataBufferSelect(firstPoint:end, 1), ...
            'YData', dataBufferSelect(firstPoint:end, 3+ii));
        drawnow limitrate
    end
end

end