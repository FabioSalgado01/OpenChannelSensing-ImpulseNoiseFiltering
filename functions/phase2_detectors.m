function [AUC, Exec_Time] = phase2_detectors(Channel_Matrix, Ground_Truth, Method_String)
% Returns:
% AUC     - ROC performance (area under curve )
% Exec_Time        - feature extraction runtime ONLY

% Select Method
tic;

switch Method_String

    case 'MSE'
        score = MSE_score(Channel_Matrix);

    case 'AdThr'
        score = AdThr_score(Channel_Matrix);

    case 'PSD'
        score = PSD_score(Channel_Matrix);

    case 'AC'
        score = AC_score(Channel_Matrix);

    otherwise
        error('Unknown Method_String');
end

Exec_Time = toc;   % detector runtime

% ROC accuracy results
[AUC] = ROC(score, Ground_Truth);

end


% compute score for ROC with MSE method
function score = MSE_score(X)
    score = mean(X.^2, 2);
end

% compute score for ROC with Adaptive Threshold method
function score = AdThr_score(X)
    energy = mean(X.^2, 2);
    score = energy ./ (median(energy) + eps);
end

% compute score for ROC with PSD method
function score = PSD_score(X)

    N = size(X,1);
    score = zeros(N,1);

    % Persistent Welch parameters (created once)
    persistent win noverlap nfft Fs
    if isempty(win)
        Fs = 1000;              % sample rate
        win = hamming(512);     % longer window so fewer segments
        noverlap = 256;         % moderate overlap
        nfft = 512;             % balanced resolution/speed
    end

    for i = 1:N
        x = single(X(i,:));     % single precision = faster FFT

        % Welch PSD
        Pxx = pwelch(x, win, noverlap, nfft, Fs);

        % Feature: peak PSD
        score(i) = max(Pxx);
    end
end


% compute score for ROC with AC method
function score = AC_score(X)

N = size(X,1);
score = zeros(N,1);

for i = 1:N
    x = X(i,:);

    % see how similiar the signal is to a shifted copy of itself
    % noisy signals will not look similar
    r = xcorr(x, 'coeff');

    % mid is always a match, remove it
    mid = ceil(length(r)/2);
    r(mid) = 0;

    score(i) = max(abs(r));
end

end

% compute accuracy variables using method score
function [AUC] = ROC(score, GT)

% choose ROC thresholds
thresholds = prctile(score, linspace(0,100,200));

% instantiate false alarm rate and detection rate
Pfa = zeros(length(thresholds),1);
Pd  = zeros(length(thresholds),1);

for i = 1:length(thresholds)

    thr = thresholds(i);

    % determine occupation
    preds = score > thr;
    
    % calculate accuracy stats from actual known results
    TP = sum(preds == 1 & GT == 1); % true positives
    FP = sum(preds == 1 & GT == 0); % false positives
    FN = sum(preds == 0 & GT == 1); % false negatives
    TN = sum(preds == 0 & GT == 0); % true negatives

    % calculate false alarm rate and detection rate
    Pd(i)  = TP / (TP + FN + eps);
    Pfa(i) = FP / (FP + TN + eps);

end

% sort the rates and calculate area under curve (for graph)
[Pfa_sorted, idx] = sort(Pfa);
Pd_sorted = Pd(idx);

AUC = trapz(Pfa_sorted, Pd_sorted);

end