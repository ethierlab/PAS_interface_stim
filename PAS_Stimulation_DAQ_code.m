function stim_control = PAS_Stimulation_DAQ_code(GUI_h)
%% Creation of a session-based interface with the NI DAQ

d=daq.getDevices;
v=daq.getVendors;
s=daq.createSession('ni');

%% Load the parameters
params = GUI_h.params;
GUI_h.params = [];

%% Initialisation

reset_gui_counters(GUI_h);
experiment_start=tic;
experiment_start_time = datetime('now');
disp('experiment started!')

% structure to save all results, as well as experimental parameters
 data_emg_PAS = struct(...
    'params'            ,params,...
    'session_time'      ,experiment_start_time,...
    'num_stim'          ,zeros(size(params.trial_type)),...
    'pulses_gen'        ,{{}},...
    'emg_data'          ,{{}},...
    'session_time'      ,experiment_start_time,...
    'results'           ,[]...
    );

temp_emg_buffer    = [nan nan]; % [time force], first row is oldest data
trial_emg_buffer   = [nan nan];
trial_started      = false;
post_trial_pause   = false;
pause_duration     = 0;
numb_pulses_done   = 0;
pulse_counter      = 0;
last_pulse         = toc(experiment_start);
stop_button        = set(GUI_h.stop_button,'userdata',0);
stim_type_button   = set(GUI_h.uibuttongroup3);

% Adding the channels of NI DAQ
s.Rate=params.fsampling;
s.IsContinuous=true;
ai0=addAnalogInputChannel(s,'Dev1','ai0','Voltage'); %Le Dev1 est le nom du daq
ai1=addAnalogInputChannel(s,'Dev1','ai1','Voltage');
ai2=addAnalogInputChannel(s,'Dev1','ai2','Voltage');
ai3=addAnalogInputChannel(s,'Dev1','ai3','Voltage');


% ao0=addAnalogOutputChannel(s,'Dev1','ao0','Voltage'); %Cortex
% ao1=addAnalogOutputChannel(s,'Dev1','ao1','Voltage'); %Muscle
% lh1=addlistener(s,'DataAvailable',@plotData);
% s.NotifyWhenDataAvailableExceeds = params.refresh_ratio; %s.Rate/s.Notify=freq de display; 

%% Stimulation Type



%% Program loop

while  toc(experiment_start)<params.duration_max || ~get(GUI_h.stop_button,'userdata') || nb_pulses_delivered==params.nb_pulses
        time_now     = toc(experiment_start);
        time_rec_bef = time_now-experiment_start;
        emg_now      = [tmp_force_buffer(time_now-tmp_force_buffer(:,1)<=0.5,:); time_now force_now];
        
        %limiter taille buffer temporaire à 0.5s
        temp_emg_buffer = [temp_emg_buffer(time_now-temp_emg_buffer(:,1)<=1.5,:); time_now emg_now];
        if 
end

% if stim_type='radiobuttoncortex'
% elseif stim_type='radiobuttonmuscle'
% elseif stim_type='radiobuttoncm'
% elseif stim_type='radiobuttonauto'
%     if emg_now<params.emg_high_limit
%        s.startBackground()
%     end
% else 
%     disp('There''s no type of stimulation choose')
% end

end

        
