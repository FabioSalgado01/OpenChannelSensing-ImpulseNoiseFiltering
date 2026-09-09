function [corrupted_audio, baseline_SNR] = phase3_corrupt(audio, impulse_height, impulse_width)
    % Inputs:
    %   audio          - Column vector of original clean audio
    %   impulse_height - Amplitude multiplier of the spike
    %   impulse_width  - Number of samples the spike lasts
    
    corrupted_audio = audio;
    N_samples = length(audio);
    
    % Generate a random index within the bounds of the audio length
    start_idx = randi([1, max(1, N_samples - impulse_width + 1)]);
    end_idx = min(start_idx + impulse_width - 1, N_samples);
    
    % Apply the impulse_height to the audio starting at the random index
    spike_amplitude = impulse_height * max(abs(audio));
    
    % Create an alternating sign burst to simulate broadband impulse scatter
    burst_signs = sign(randn(end_idx - start_idx + 1, 1));
    corrupted_audio(start_idx:end_idx) = corrupted_audio(start_idx:end_idx) + (spike_amplitude * burst_signs);

    % Calculate Baseline SNR
    signal_power = var(audio);
    noise_power = var(corrupted_audio - audio);
    
    if noise_power == 0
        baseline_SNR = Inf;
    else
        baseline_SNR = 10 * log10(signal_power / noise_power);
    end
end