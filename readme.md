# ECE 4271 Final Project
**Open Channel Sensing and Impulse Noise Filtering in Noisy Communication Systems**

---

## Phase 1: Simulation Setup
**Create a scalable, randomized simulation environment of $N$ communication channels with varying noise floors and signal occupancies.**

### Steps:
1. **Initialize Channel Matrix:** Create a 2D matrix where rows represent channels and columns represent time samples.
2. **Inject Background Noise:** Iterate through the channels and apply varying levels of White Gaussian Noise (WGN).
3. **Simulate Occupancy:** Randomly select a subset of channels to act as "occupied." Inject a simulated transmission signal into these specific channels. In this case a varying random sin signal. Implement bursts to simulate a reliable but not perfect transmission system.
4. **Establish Ground Truth:** Create a boolean array indicating occupied and empty status. 

---

## Phase 2: Spectrum Sensing

**Evaluate different detection methods for identifying vacant channels based on speed and accuracy.**

### Steps:
1. Generate the channel environment using the simulation from Phase 1, sweeping across noise levels {−5, 0, 5, 8, 10, 13, 15, 20, 30} dB and channel counts {10, 50, 100, 500}.
2. Apply each of the four detection methods — MSE energy detector, adaptive threshold detector, Welch PSD detector, and autocorrelation detector — to the generated Channel Matrix.
3. For each method, compute a per-channel occupancy score and sweep the decision threshold across its full range to generate a ROC curve by comparing detections against the Ground Truth vector.
4. Compute the AUC of each ROC curve using the trapezoidal rule as the primary accuracy metric.
5. Repeat steps 1–4 over 20 independent Monte Carlo trials for each combination of method, noise level, and channel count. Average the AUC values across trials to obtain stable performance estimates.
6. Record the wall-clock execution time for each detection method at each channel count.
7. Plot mean AUC versus noise level (dB) for all methods to compare detection robustness under varying SNR conditions.
8. Plot execution time versus channel count for all methods to compare computational scalability.

### Metrics to Record:
* **Execution Time:** Wall-clock time for each detection method as a function of channel count, used to compare computational scalability across methods.
* **Detection Accuracy:** Mean AUC computed over 20 Monte Carlo trials for each combination of detection method, noise level, and channel count, used to evaluate the reliability and robustness of each approach across SNR conditions.

---

## Phase 3: Signal Transmission & Impulse Corruption
**Transmit a desired signal over the identified open channel and simulate real-world scenario.**

### Steps:
1. **Channel Selection:** Program the system to select the first channel flagged as empty
2. **Audio Injection:** Load a `.wav` file into this channel. Retain a hidden, uncorrupted copy of signal.
3. **Generate Noise:** Create a sudden, high-amplitude burst of noise at a random timestamp within the transmission.
4. **Calculate SNR:** Compute the SNR of this newly corrupted signal. This serves as the "Before Filtering" baseline.

### Variables to Sweep:
* **Impulse Height:** Amplitude of the noise spike.
* **Impulse Width:** Duration of the spike.

---

## Phase 4: Receiver Filtering & Data Analysis
**Mitigate the impulse noise at the receiver end, measure the effectiveness of DSP filters, and visualize the results.**

### Filters to consider:
1. **Threshold-Based Clipping:** Chops off amplitudes exceeding a maximum allowed value. .
2. **Median Filter:** Uses a sliding window to replace the center sample with the median of its neighbors.
3. **Wavelet Denoising:** Decomposes the signal into wavelets, removes spike-like frequencies, and reconstructs.
4. **Adaptive Filter / Moving Average:** Subtracts learned noise profiles or applies a low-pass smoothing effect. 

### Steps & Analysis:
1. **Apply Filters:** Run the corrupted signal through all four filters independently.
2. **Calculate SNR:** Measure the SNR of the filtered signals against the hidden, original clean speech file.
3. **Qualitative Audio Test:** Export the filtered signals as `.wav` files to listen to the perceptual audio quality.
4. **Visualizations:**
   * *Line Graph 1:* Sensing Speed vs. Channel Count ($N$).
   * *Line Graph 2:* Detection Accuracy vs. Background Noise Level.
   * *Surface/Bar Plots:* Filtered SNR Improvement vs. Impulse Width & Height.
