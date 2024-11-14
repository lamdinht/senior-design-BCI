% This script processes EEG data by applying a bandpass filter and generating spectrograms for each channel.
% The EEG data is assumed to be in columns 5 to 18 of a CSV file, representing 14 channels of data.
% The data is first bandpass filtered between 0.5 Hz and 100 Hz, then a spectrogram is computed for each channel
% using a 1-second window with 80% overlap. All spectrograms are plotted with the same color scale for consistency.

% Define channel names
channel_names = {'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', 'O1', 'O2', 'P8', 'T8', 'FC6', 'F4', 'F8', 'AF4'};

% Get list of all CSV files in the current folder
csv_files = dir('*.csv');

% Loop through each CSV file
for file_idx = 1:length(csv_files)
    % Load the EEG data
    data = readtable(csv_files(file_idx).name);
    
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
    window = 1*round(Fs);             % 1-second window (128 samples)
    noverlap = round(0.8 * window);  % 80% overlap
    nfft = 2^nextpow2(window);       % FFT length

    % Create a figure to hold all spectrograms and PSDs
    figure;
    set(gcf, 'WindowState', 'maximized');


% Loop through each channel to generate and plot the spectrogram
    for ch = 1:14
        % Spectrogram plot
        subplot(7, 2, ch); % Arrange spectrograms and PSDs side-by-side
        [S, F, T, P] = spectrogram(filtered_eeg(:, ch), window, noverlap, nfft, Fs);
        imagesc(T, F, 10*log10(P)); % Convert power to dB
        axis xy;
        title([channel_names{ch}, ' Spectrogram']);
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        ylim([0 60]); % Focus on 0 to 20 Hz frequency range
        colorbar;
        caxis([-20, 20]); % Set color axis limits from -30 to 0 dB
    
        % % PSD plot
        % subplot(14, 2, 2*ch); % Plot PSD next to each spectrogram
        % [pxx, f] = pwelch(filtered_eeg(:, ch), window, noverlap, nfft, Fs);
        % plot(f, 10*log10(pxx)); % Convert power to dB
        % title(['Channel ', num2str(ch), ' PSD']);
        % xlabel('Frequency (Hz)');
        % ylabel('Power/Frequency (dB/Hz)');
        % xlim([0 60]); % Limit x-axis to 60 Hz for clarity
    end

    % Adjust overall figure properties
    sgtitle(['EEG Spectrograms (0.5-60 Hz Bandpass) - ', csv_files(file_idx).name]);
    colormap jet;

    % Save the figure
    saveas(gcf, [csv_files(file_idx).name(1:end-4), '_spectrogram.png']);
    close;

    % Calculate power bands for each channel
    power_bands = zeros(14, 4); % Delta, Theta, Alpha, Beta
    for ch = 1:14
        % Power band calculations using bandpass filters
        delta_band = bandpower(filtered_eeg(:, ch), Fs, [0.5 4]);
        theta_band = bandpower(filtered_eeg(:, ch), Fs, [4 8]);
        alpha_band = bandpower(filtered_eeg(:, ch), Fs, [8 13]);
        beta_band = bandpower(filtered_eeg(:, ch), Fs, [13 30]);
        
        % Store power values
        power_bands(ch, :) = [delta_band, theta_band, alpha_band, beta_band];
    end

    % Save power bands to a text file
    power_band_file = [csv_files(file_idx).name(1:end-4), '_power_bands.txt'];
    fileID = fopen(power_band_file, 'w');
    fprintf(fileID, 'Channel	Delta	Theta	Alpha	Beta');
    for ch = 1:14
        fprintf(fileID, '\n%s	%.4f	%.4f	%.4f	%.4f', channel_names{ch}, power_bands(ch, 1), power_bands(ch, 2), power_bands(ch, 3), power_bands(ch, 4));
    end
    fclose(fileID);
end

%% MATLAB script to calculate average power per frequency band per channel with summary statistics

% Get a list of all TXT files in the current folder
files = dir('*.txt');

% Initialize an empty cell array to store data from all files
all_data = [];

% Loop through each file in the folder
for i = 1:length(files)
    file_path = files(i).name;
    % Read the TXT file into a table
    data = readtable(file_path, 'Delimiter', '\t'); % Assuming tab-delimited text files
    all_data = [all_data; data];
end

% Group by 'Channel' and calculate average power per frequency band
channels = unique(all_data.Channel);
summary_stats = table;

% Define frequency band names
band_names = {'Delta', 'Theta', 'Alpha', 'Beta'};

for i = 1:length(channels)
    channel = channels{i};
    % Extract data for the current channel
    channel_data = all_data(strcmp(all_data.Channel, channel), :);
    % Calculate mean, min, max, and std for each frequency band
    mean_vals = mean(channel_data{:, 2:end}, 1);
    min_vals = min(channel_data{:, 2:end}, [], 1);
    max_vals = max(channel_data{:, 2:end}, [], 1);
    std_vals = std(channel_data{:, 2:end}, 0, 1);
    % Append to the summary table
    summary_stats = [summary_stats; table({channel}, mean_vals, min_vals, max_vals, std_vals, 'VariableNames', [{'Channel'}, strcat('Mean_', band_names), strcat('Min_', band_names), strcat('Max_', band_names), strcat('Std_', band_names)])];
end

% Save the summary statistics to a new CSV file
writetable(summary_stats, 'eeg_summary_statistics.csv');

disp('Summary statistics saved to ''eeg_summary_statistics.csv''');

%% ANALYZE 1 FILE ONLY

% Define channel names
channel_names = {'AF3', 'F7', 'F3', 'FC5', 'T7', 'P7', 'O1', 'O2', 'P8', 'T8', 'FC6', 'F4', 'F8', 'AF4'};

% Load the EEG data from a single CSV file
csv_file = 'Resting(10 min)_EPOCX_242571_2024.10.27T15.49.01.05.00.md.csv'; % Specify the CSV file name
data = readtable(csv_file);

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
window = 1*round(Fs);             % 1-second window (128 samples)
overlap = round(0.8 * window);  % 80% overlap
nfft = 2^nextpow2(window);       % FFT length

% Create a figure to hold all spectrograms
figure;
set(gcf, 'WindowState', 'maximized');

% Loop through each channel to generate and plot the spectrogram
for ch = 1:14
    % Spectrogram plot
    subplot(7, 2, ch); % Arrange spectrograms side-by-side
    [S, F, T, P] = spectrogram(filtered_eeg(:, ch), window, overlap, nfft, Fs);
    imagesc(T, F, 10*log10(P)); % Convert power to dB
    axis xy;
    title([channel_names{ch}, ' Spectrogram']);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    ylim([0 60]); % Focus on 0 to 20 Hz frequency range
    colorbar;
    caxis([-20, 20]); % Set color axis limits from -30 to 0 dB
end

% Adjust overall figure properties
sgtitle(['EEG Spectrograms (0.5-60 Hz Bandpass) - ', csv_file]);
colormap jet;

% Save the figure
saveas(gcf, [csv_file(1:end-4), '_spectrogram.png']);

% Calculate power bands for each channel
power_bands = zeros(14, 4); % Delta, Theta, Alpha, Beta
for ch = 1:14
    % Power band calculations using bandpass filters
    delta_band = bandpower(filtered_eeg(:, ch), Fs, [0.5 4]);
    theta_band = bandpower(filtered_eeg(:, ch), Fs, [4 8]);
    alpha_band = bandpower(filtered_eeg(:, ch), Fs, [8 13]);
    beta_band = bandpower(filtered_eeg(:, ch), Fs, [13 30]);
    
    % Store power values
    power_bands(ch, :) = [delta_band, theta_band, alpha_band, beta_band];
end

% Save power bands to a text file
power_band_file = [csv_file(1:end-4), '_power_bands.txt'];
fileID = fopen(power_band_file, 'w');
fprintf(fileID, 'Channel\tDelta\tTheta\tAlpha\tBeta');
for ch = 1:14
    fprintf(fileID, '\n%s\t%.4f\t%.4f\t%.4f\t%.4f', channel_names{ch}, power_bands(ch, 1), power_bands(ch, 2), power_bands(ch, 3), power_bands(ch, 4));
end
fclose(fileID);