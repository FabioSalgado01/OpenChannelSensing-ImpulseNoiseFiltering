%% Plotting Script
% Load the generated data from main_simulation.m
load('data/Detection_Data.mat');
load('data/Filtering_Data.mat');

detection_methods = {'MSE', 'AdThr', 'PSD' , 'AC'};
filter_methods    = {'Clipping', 'Median', 'Wavelet', 'Adaptive'};

%% 1. Sensing Speed v Channel Count
figure; hold on;
colors = lines(length(detection_methods));

for det_idx = 1:length(detection_methods)
    time_curve = zeros(1, length(N_channels_array));
    for n_idx = 1:length(N_channels_array)
        vals = zeros(length(noise_snr_array),1);
        for noise_idx = 1:length(noise_snr_array)
            vals(noise_idx) = detection_results(n_idx,noise_idx,det_idx).Time;
        end
        time_curve(n_idx) = mean(vals);
    end
    plot(N_channels_array, time_curve, '-o', 'Color', colors(det_idx,:), ...
        'LineWidth', 1.5, 'DisplayName', detection_methods{det_idx});
end

set(gca, 'YScale', 'log')
xlabel('Number of Channels');
ylabel('Execution Time (s)');
title('Computational Cost vs Channel Count');
legend('Location', 'northwest');
grid on;

%% 2. Sensing Accuracy v Background Noise
figure; hold on;
colors = lines(length(detection_methods));

for det_idx = 1:length(detection_methods)
    auc_curve = zeros(1, length(noise_snr_array));
    for noise_idx = 1:length(noise_snr_array)
        % average over channel dimension
        vals = zeros(length(N_channels_array),1);
        for n_idx = 1:length(N_channels_array)
            vals(n_idx) = detection_results(n_idx,noise_idx,det_idx).AUC;
        end
        auc_curve(noise_idx) = mean(vals);
    end
    plot(noise_snr_array, auc_curve, '-o', 'Color', colors(det_idx,:), ...
        'LineWidth', 1.5, 'DisplayName', detection_methods{det_idx});
end

xlabel('Noise (dB)');
ylabel('AUC');
title('Detection Accuracy vs Noise');
legend('Location', 'southeast');
grid on;

%% 3. Channel, Method, and Noise 3D plot
figure;
for det_idx = 1:length(detection_methods)
    Z = zeros(length(N_channels_array), length(noise_snr_array));
    for n_idx = 1:length(N_channels_array)
        for noise_idx = 1:length(noise_snr_array)
            Z(n_idx, noise_idx) = detection_results(n_idx,noise_idx,det_idx).AUC;
        end
    end
    subplot(2,2,det_idx);
    imagesc(noise_snr_array, N_channels_array, Z);
    set(gca,'YDir','normal');
    title(detection_methods{det_idx});
    xlabel('Noise (dB)');
    ylabel('Channels');
    caxis([0.5 1]);
    h = colorbar;
    ylabel(h, 'AUC Strength');
end
sgtitle('AUC Performance Surfaces');

%% 4. Filter Effectiveness (SNR Improvement)
figure('Name', 'SNR Improvement vs Impulse Width'); hold on; grid on;
colors_filt = lines(length(filter_methods));

% Choose a fixed Impulse Height to graph (e.g., index 3 out of 4 -> 10x height)
fixed_h_idx = 3; 
selected_height = impulse_heights(fixed_h_idx);

% Plot the Corrupted (Baseline) SNR
baseline_snr_curve = zeros(1, length(impulse_widths));
for w_idx = 1:length(impulse_widths)
    baseline_snr_curve(w_idx) = filtering_results(fixed_h_idx, w_idx, 1).BaselineSNR;
end
plot(impulse_widths, baseline_snr_curve, '--k', 'LineWidth', 2, 'DisplayName', 'Unfiltered (Corrupted)');

% Plot the Cleaned SNR for each filter method
for filt_idx = 1:length(filter_methods)
    filtered_snr_curve = zeros(1, length(impulse_widths));
    for w_idx = 1:length(impulse_widths)
        filtered_snr_curve(w_idx) = filtering_results(fixed_h_idx, w_idx, filt_idx).NewSNR;
    end
    
    plot(impulse_widths, filtered_snr_curve, '-o', ...
        'Color', colors_filt(filt_idx,:), ...
        'LineWidth', 2, ...
        'MarkerSize', 6, ...
        'DisplayName', filter_methods{filt_idx});
end

xlabel('Impulse Width (Number of Corrupted Samples)');
ylabel('Signal-to-Noise Ratio (dB)');
title(sprintf('Filter Effectiveness vs Impulse Width (Impulse Amplitude = %dx)', selected_height));
legend('Location', 'southwest');

