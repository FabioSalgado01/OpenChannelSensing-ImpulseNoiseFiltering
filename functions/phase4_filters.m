function [cleaned_audio, new_SNR] = phase4_filters(corrupted_audio, clean_audio, Filter_Type)
    % Inputs:
    %   corrupted_audio - The audio array with the impulse spike
    %   clean_audio     - Required as a reference to calculate final SNR accurately
    %   Filter_Type     - String identifying the algorithm
    
    switch Filter_Type 
        case 'Clipping'
            cleaned_audio = apply_clipping(corrupted_audio);
        case 'Median'
            cleaned_audio = apply_median(corrupted_audio);
        case 'Wavelet'
            cleaned_audio = apply_wavelet(corrupted_audio);
        case 'Adaptive'
            cleaned_audio = apply_adaptive(corrupted_audio);
        otherwise
            error('Unknown Filter_Type string provided. Check main simulation script.');
    end
    
    % Calculate New SNR
    signal_power = var(clean_audio);
    noise_power = var(cleaned_audio - clean_audio);
    
    if noise_power == 0
        new_SNR = Inf;
    else
        new_SNR = 10 * log10(signal_power / noise_power);
    end
end

%% helper functions
% clips the audio at a threshold
function cleaned_audio = apply_clipping(X)
    % Hard-clip to +/- 1.0.
    threshold = 1.01;
    cleaned_audio = min(max(X, -threshold), threshold);
end

% thresholed median sliding filter (Hampel)
function cleaned_audio = apply_median(X)
    med_filtered = medfilt1(X, 101);
    deviation = abs(X - med_filtered);

    % deviation greater than 2 suggests a spike
    spike_threshold = 2.01; 
    is_spike = deviation > spike_threshold;
    cleaned_audio = X;
    cleaned_audio(is_spike) = med_filtered(is_spike);

end

% wavelet denoising
function cleaned_audio = apply_wavelet(X)
    try
        cleaned_audio = wdenoise(X, 4, 'Wavelet', 'sym4');
    catch
        warning('Wavelet Toolbox not found. Please install the Wavelet Toolbox from Matlab add-ons. Falling back to simple moving average.');
        cleaned_audio = smoothdata(X, 'movmean', 5);
    end
end

% adaptive least mean squares filter
function cleaned_audio = apply_adaptive(X)
    order = 16;            
    mu = 0.1;              
    w = zeros(order, 1);   
    cleaned_audio = zeros(size(X));
    
    % save 16 past data points to compute rolling weights
    x_memory = zeros(order, 1);
    
    for n = 1:length(X)
        % predict next sample based on past points
        y_hat = w' * x_memory;
        
        % calculate error
        e = X(n) - y_hat;
        
        % error greater than 2 suggests a spike
        if abs(e) > 2.0
            % use prediction
            safe_sample = y_hat;
        else
            % update rolling weights
            w = w + (mu) * e * x_memory;
            safe_sample = X(n);
        end
        
        cleaned_audio(n) = safe_sample; 
        
        % shift the saved data points
        x_memory = [safe_sample; x_memory(1:end-1)];
    end
end