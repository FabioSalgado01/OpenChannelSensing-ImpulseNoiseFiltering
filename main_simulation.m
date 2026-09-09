%% Master Simulation Script
clc; clear; close all;

% Add the subfolder to the MATLAB search path
addpath('functions');

%% Setup
% Variables
N_channels_array = [10, 50, 100, 500];    % Number of channels to test
noise_snr_array  = [-5, 0, 5, 8, 10, 13, 15, 20, 30];     % Background noise levels
impulse_heights  = [2, 5, 10, 20];              % Amplitude multiplier for impulse
impulse_widths   = [1, 5, 20, 50];              % Number of samples the impulse lasts

% Detection and Filtering Methods to test
detection_methods = {'MSE', 'AdThr', 'PSD' , 'AC'}; 
filter_methods    = {'Clipping', 'Median', 'Wavelet', 'Adaptive'}; 

% Array for results saving
detection_results = struct();
filtering_results = struct();

%% Include audio file for phase 3/4
    load handel.mat; % Loads 'y' and 'Fs'
    clean_audio = y; % Use [clean_audio, Fs] = audioread('data/input.wav'); for custom audio 
% Normalize audio
clean_audio = clean_audio / max(abs(clean_audio));

%% Environment

K = 20;  % number of iterations 

for n_idx = 1:length(N_channels_array)
    N = N_channels_array(n_idx);
    
    for noise_idx = 1:length(noise_snr_array)
        noise_snr = noise_snr_array(noise_idx);
        
        for det_idx = 1:length(detection_methods)
            method = detection_methods{det_idx};

            auc_runs = zeros(K,1);
            time_runs = zeros(K,1);

            for k = 1:K
                % Phase 1 (new random environment each run)
                [Channel_Matrix, Ground_Truth] = phase1_generate_env(N, noise_snr, 0.3);
            
                % Phase 2
                % Run detection function and get accuracy variables
                [AUC, Exec_Time] = phase2_detectors(Channel_Matrix, Ground_Truth, method);

                % STORE RESULTS 
                auc_runs(k)  = AUC;
                time_runs(k) = Exec_Time;

            end
            
            % Save data to struct
            detection_results(n_idx, noise_idx, det_idx).Time = mean(time_runs);
            detection_results(n_idx, noise_idx, det_idx).AUC  = mean(auc_runs);
        end
    end
end

% Ensure data folder exists
if ~exist('data', 'dir'), mkdir('data'); end
% Save Phase 1 & 2 Data
save('data/Detection_Data.mat', 'detection_results', 'N_channels_array', 'noise_snr_array');

%% Transmission

for h_idx = 1:length(impulse_heights)
    height = impulse_heights(h_idx);
    
    for w_idx = 1:length(impulse_widths)
        width = impulse_widths(w_idx);
        
        % Phase 3
        [corrupted_audio, baseline_SNR] = phase3_corrupt(clean_audio, height, width);
        
        % Phase 4
        for filt_idx = 1:length(filter_methods)
            f_method = filter_methods{filt_idx};
            
            % Run filter
            [cleaned_audio, new_SNR] = phase4_filters(corrupted_audio, clean_audio, f_method);
            
            % Save data to struct
            filtering_results(h_idx, w_idx, filt_idx).BaselineSNR = baseline_SNR;
            filtering_results(h_idx, w_idx, filt_idx).NewSNR = new_SNR;
            
            % Save filtered audio (Median filter at 10x height, 20 samples)
            if height == 10 && width == 20 && strcmp(f_method, 'Median')
                audiowrite('data/corrupted_audio.wav', corrupted_audio, Fs);
                audiowrite('data/cleaned_audio.wav', cleaned_audio, Fs);
            end
        end
    end
end

% Save Phase 3 & 4 Data
save('data/Filtering_Data.mat', 'filtering_results', 'impulse_heights', 'impulse_widths');
