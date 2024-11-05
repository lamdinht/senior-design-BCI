% This script processes EEG data by applying a bandpass filter and generating spectrograms for each channel.
% The EEG data is assumed to be in columns 5 to 18 of a CSV file, representing 14 channels of data.
% The data is first bandpass filtered between 0.5 Hz and 100 Hz, then a spectrogram is computed for each channel
% using a 1-second window with 80% overlap. All spectrograms are plotted with the same color scale for consistency.

% Load the EEG data
data = readtable('RestingStart_segment_5.csv'); % Replace 'eeg_data.csv' with your actual file name

% Extract the relevant EEG channels (columns 5 to 18)
eeg_data = table2array(data(:, 5:18));

% Updated sampling frequency
Fs = 128; % Set to 128 Hz as specified

% Updated bandpass filter parameters
low_cutoff = 0.5;   % Lower cutoff frequency in Hz
high_cutoff = 60;   % Upper cutoff frequency in Hz

% Normalize cutoff frequencies by dividing by Nyquist frequency (Fs/2)
normalized_cutoff = [low_cutoff, high_cutoff] / (Fs / 2);

% Design the 4th-order Butterworth bandpass filter
[b, a] = butter(4, normalized_cutoff, 'bandpass');

% Apply the bandpass filter to each channel
filtered_eeg = zeros(size(eeg_data));
for ch = 1:size(eeg_data, 2)
    filtered_eeg(:, ch) = filtfilt(b, a, eeg_data(:, ch));
end

% Parameters for the spectrogram
window = round(Fs)*3;             % 1-second window (128 samples)
noverlap = round(0.8 * window);  % 80% overlap
nfft = 2^nextpow2(window);       % FFT length

% Create a figure to hold all spectrograms and PSDs
figure;

% Loop through each channel to generate and plot the spectrogram
for ch = 1:14
    % Spectrogram plot
    subplot(14, 2, 2*ch - 1); % Arrange spectrograms and PSDs side-by-side
    [S, F, T, P] = spectrogram(filtered_eeg(:, ch), window, noverlap, nfft, Fs);
    imagesc(T, F, 10*log10(P)); % Convert power to dB
    axis xy;
    title(['Channel ', num2str(ch), ' Spectrogram']);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    ylim([0 20]); % Focus on 0 to 20 Hz frequency range
    colorbar;
    caxis([-30, 0]); % Set color axis limits from -60 to 0 dB

    % PSD plot
    subplot(14, 2, 2*ch); % Plot PSD next to each spectrogram
    [pxx, f] = pwelch(filtered_eeg(:, ch), window, noverlap, nfft, Fs);
    plot(f, 10*log10(pxx)); % Convert power to dB
    title(['Channel ', num2str(ch), ' PSD']);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    xlim([0 60]); % Limit x-axis to 60 Hz for clarity
end

% Adjust overall figure properties
sgtitle('Spectrograms and PSDs for Each EEG Channel (0.5-60 Hz Bandpass)');
colormap jet;