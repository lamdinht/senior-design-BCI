filename = "Lam_1";

streams = load_xdf(filename + ".xdf");
eeg_time_series = [];
eeg_time_stamps = [];


marker_time_series = [];
marker_time_stamps = [];


%% COMBINE TIME STREAMS

has_marker = false;
write_to_csv = false;

for i = 1:size(streams,2)
    if strcmp(streams{i}.info.type ,'EEG')
        eeg_time_series = [eeg_time_series streams{i}.time_series];
        eeg_time_stamps = [eeg_time_stamps streams{i}.time_stamps];
    end
    
    if strcmp(streams{i}.info.type, 'Markers')
        marker_time_series = [marker_time_series streams{i}.time_series];
        marker_time_stamps = [marker_time_stamps streams{i}.time_stamps];
    end
end

if has_marker
    marker_time_stamps = marker_time_stamps - marker_time_stamps(1);
    eeg_time_stamps = eeg_time_stamps - eeg_time_stamps(1);
else
    if write_to_csv
        eeg_time_stamps = eeg_time_stamps - eeg_time_stamps(1);
        % Combine the eeg_time_stamps and eeg_time_series
        combined_data = [eeg_time_stamps; eeg_time_series];
        
        % Define the filename for saving
        filename = 'eeg_combined_data.csv'; % Specify the desired filename
        
        % Save the combined data as a CSV file
        writematrix(combined_data, filename);
        
        disp('Data has been successfully saved as CSV!');
    end
end

%% If has marker, run this chunk of code.

% Variables (assumed to be given):
% eeg_time_stamps: an array of size (1, n) (time points for each sample)
% eeg_time_series: an array of size (channels, n) (EEG data for each channel)
% marker_time_stamps: an array of size (1, m)
% marker_time_series: a cell array of size (1, m) (markers for events)

% Prompt the user to input whether 'resting' or 'focusing' starts first
starting_state = input('Enter starting state (resting or focusing): ', 's');

% Predefine output structure
output = [];

% Initialize the segment counter and state alternation
segment_counter = 1;
current_state = starting_state;

% Loop through the marker_time_series
for i = 1:length(marker_time_series)
    % Check if the current marker contains 'released'
    if contains(marker_time_series{i}, 'released')

        % If i is the last marker, stop to avoid out-of-bounds error
        if i == length(marker_time_series)
            disp('Reached the last marker, stopping...');
            break;
        end

        % Get time_start and time_stop
        time_start = marker_time_stamps(i);  % When recording starts
        time_stop = marker_time_stamps(i+1); % When recording stops

        % Get the indexes of the EEG time stamps within this range
        eeg_indexes = find(eeg_time_stamps > time_start & eeg_time_stamps < time_stop);
        
        % If there are valid indexes, proceed
        if ~isempty(eeg_indexes)
            % Get the time stamps for the segment
            segment_time_stamps = eeg_time_stamps(eeg_indexes);
            
            % Get the corresponding EEG data for all channels
            segment_eeg_data = eeg_time_series(:, eeg_indexes);

            % Concatenate time stamps as the first row and EEG data below
            output = [segment_time_stamps; segment_eeg_data];

            % Determine the current state for naming
            if strcmpi(current_state, 'resting')
                prefix = 'Resting_';
            elseif strcmpi(current_state, 'focusing')
                prefix = 'Focusing_';
            else
                error('Invalid starting state. Must be "resting" or "focusing".');
            end

            % Create the CSV filename for this segment
            filename = [prefix num2str(segment_counter) '.csv'];

            % Write the output to CSV
            csvwrite(filename, output);

            % Increment the segment counter for the next segment
            segment_counter = segment_counter + 1;

            % Toggle the current state for the next segment
            if strcmpi(current_state, 'resting')
                current_state = 'focusing';
            else
                current_state = 'resting';
            end
        end
    end
end



%% Preliminary Process:

%    - Recenter signal: subtracting mean from array
%    - Reject powerline: notch from 59.9 to 60.1hz

%    - Plot fft and time series of all bands
%    - Recenter data by subtracting the average, plot fft and time series
%    - Focus on 0 to 20Hz on another graph

% BANDPASS FILTER
% fs = 256;
% x1=eeg_time_series(2,:);
% upper_freq_limit=20;
% lower_freq_limit=1;
% x = bandpass(x1,[lower_freq_limit upper_freq_limit],fs);
% 
% HIGHPASS FILTER
% fs = 256;
% x1=eeg_time_series(2,:);
% upper_freq_limit=20;
% x = highpass(x1,upper_freq_limit,fs);

% Select Channel:
%     eeg_time_series(1,:): AF7
%     eeg_time_series(2,:): TP9
%     eeg_time_series(3,:): TP10
%     eeg_time_series(4,:): AF8
for i = 1:4
    x1 = eeg_time_series(i,:);
    N = length(x1);
    fs = 256;
    
    % Preprocess data:
    % - Recenter signal: subtracting mean from array
    % - Reject powerline: notch from 59.9 to 60.1hz
    x1 = x1 - sum(x1)/size(x1,2);
    x1 = bandstop(x1,[59.9, 60.1],fs);
    f = [0:fs/N:fs];
    f = f(1:end-1);
    subplot(4,2,i*2-1);
    plot(f,abs(fft(x1)));
    
    % Frequency Density
    xdft = fft(x1);
    xdft = xdft(1:N/2+1);
    psdx = (1/(fs*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:fs/length(x1):fs/2;
    show_limit=fs/2; % Enter the freq want to show
    freq_n=freq(freq<=show_limit);
    psdx_n=psdx(freq<=show_limit);
    plot(freq_n,pow2db(psdx_n),'LineWidth', 0.05);
    grid on
    title("Periodogram Using FFT")
    xlabel("Frequency (Hz)")
    ylabel("Power/Frequency (dB/Hz)")

    % Lowpass Filter
    fs = 256;
    lower_freq_limit=20;
    x1 = lowpass(x1,lower_freq_limit,fs);

    % Frequency Density After Lowpass
    xdft = fft(x1);
    xdft = xdft(1:N/2+1);
    psdx = (1/(fs*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:fs/length(x1):fs/2;
    show_limit=20; % Enter the freq want to show
    freq_n=freq(freq<=show_limit);
    psdx_n=psdx(freq<=show_limit);
    subplot(4,2,i*2);
    plot(freq_n,pow2db(psdx_n))
    
    grid on
    title("Periodogram Using FFT")
    xlabel("Frequency (Hz)")
    ylabel("Power/Frequency (dB/Hz)")
end

%% PROCESS DATA FROM CSV
fs = 256;
import_csv = true;
csv_file = "A1Push";

% Step 1: Import the CSV file
if import_csv
    data = csvread(csv_file + ".csv"); 
end

% Step 2: Separate the timestamps and EEG time series
timestamps = data(1, :);           % 1st row contains timestamps
eeg_time_series = data(2:end-1, :); % 2nd row onwards are EEG channels, drop the final line

% Step 3: Normalize the timestamps (subtract the first value)
timestamps = timestamps - timestamps(1);

% Step 4: Determine subplot size (2 columns by number of channels)
figure;
num_channels = size(eeg_time_series, 1);
num_subplots = num_channels * 2;  % Two subplots per channel (time series and PSD)
set(gcf, 'Position', get(0, 'Screensize'));  % Maximize figure window

% Step 5: Initialize output for wave powers
output_band_powers = [];

% Step 6: Loop through each EEG channel
for ch = 1:num_channels
    % Step 6a: Extract the current channel's data
    eeg_channel_data = eeg_time_series(ch, :);
    
    % Step 6b: Apply filters (lowpass, highpass, notch)
    % Lowpass @0.5Hz
    eeg_filtered = highpass(eeg_channel_data, 0.5, fs);  % 'fs' is the sampling frequency
    
    % Highpass @100Hz
    eeg_filtered = lowpass(eeg_filtered, 40, fs);
    
    % Notch filter from 59.9Hz to 60.1Hz
    d = designfilt('bandstopiir', 'FilterOrder', 2, ...
                   'HalfPowerFrequency1', 59.9, 'HalfPowerFrequency2', 60.1, ...
                   'DesignMethod', 'butter', 'SampleRate', fs);
    
    % Apply the notch filter to remove 60Hz power line noise
    eeg_filtered = filtfilt(d, eeg_filtered);
    
    % Step 6c: Perform FFT on the filtered channel
    eeg_fft = fft(eeg_filtered);
    
    % Step 6d: Plot the time series in the left subplot
    subplot(num_channels, 2, (ch-1)*2 + 1);
    plot(timestamps, eeg_filtered);
    title(['Time Series - Channel ' num2str(ch)]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    % Step 6e: Calculate and plot the power spectral density (PSD) on the right subplot
    subplot(num_channels, 2, (ch-1)*2 + 2);
    [psd_data, f] = pwelch(eeg_filtered, [], [], [], fs); % PSD using Welch's method
    plot(f, 10*log10(psd_data));
    title(['PSD - Channel ' num2str(ch)]);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    
    % Step 6f: Calculate band powers (delta, theta, alpha, beta, gamma)
    delta_power = bandpower(psd_data, f, [0.5 4], 'psd');
    theta_power = bandpower(psd_data, f, [4 8], 'psd');
    alpha_power = bandpower(psd_data, f, [8 13], 'psd');
    beta_power = bandpower(psd_data, f, [13 30], 'psd');
    gamma_power = bandpower(psd_data, f, [30 100], 'psd');
    
    % Append the band powers to the output
    output_band_powers = [output_band_powers; delta_power, theta_power, alpha_power, beta_power, gamma_power];
end

saveas(gcf, filename + ".png");

% Step 7: Prepare the data for appending
output_table = [(1:num_channels)', output_band_powers]; % Channel numbers and band powers

% Step 8: Check if the file exists, and either append or create the file
filename = 'band_powers_output.csv';
if isfile(filename)
    % File exists, so append the new data
    dlmwrite(filename, output_table, '-append');
else
    % File does not exist, create the file and write header and data
    csv_header = {'Channel', 'Delta Power (0.5-4 Hz)', 'Theta Power (4-8 Hz)', ...
                  'Alpha Power (8-13 Hz)', 'Beta Power (13-30 Hz)', 'Gamma Power (30-100 Hz)'};
    fid = fopen(filename, 'w');
    fprintf(fid, '%s,%s,%s,%s,%s,%s\n', csv_header{:});  % Write header
    fclose(fid);
    dlmwrite(filename, output_table, '-append');
end

%% PARSE CSV FOR NN TRAINING
% Load the dataset from CSV file
filename = 'eeg_combined_data.csv'; % Replace with the actual file name
data = readtable(filename, 'ReadVariableNames', false); % Read the CSV file into a table

% Convert table to array for easier indexing
data = table2array(data);

% Extract data rows (assuming structure: time (row 1), 4 EEG channels (rows 2-5), auxiliary channel (row 6))
timestamps = data(1, :);     % First row: timestamps
eeg_data = data(2:5, :);     % Rows 2 to 5: EEG channels
aux_data = data(6, :);       % Last row: auxiliary channel

% Define the number of data points in each section and step size
section_size = 256;
step_size = 64;
counter = 1; % Initialize counter

% Total number of data points (columns)
total_data_points = size(data, 2);

% Create folder for training data if it does not exist
if ~exist('training', 'dir')
    mkdir('training');
end

% Iterate over the dataset, incrementing by 64 columns
for idx = 1:step_size:(total_data_points - section_size + 1)
    
    % Extract the section of 256 data points (columns)
    section_timestamps = timestamps(idx:(idx + section_size - 1));
    section_eeg_data = eeg_data(:, idx:(idx + section_size - 1));
    section_aux_data = aux_data(:, idx:(idx + section_size - 1));
    
    % Combine the extracted section into a single matrix (concatenate rows)
    section_data = [section_timestamps; section_eeg_data; section_aux_data];
    
    % Name and save the section in the training folder
    training_filename = sprintf('training/%s_%d.csv', filename, counter);
    writematrix(section_data, training_filename);
    
    % Increment the counter for the next file
    counter = counter + 1;
end

disp('Processing complete!');

%% UPDATE 10/7/2024
%   DATA MANIPULATION FOR MACHINE LEARNING
%   Process:
%   - Load XDF, get eeg & marker streams
%   - Cancel first/last data points accordingly
%   - For each XDF:
%       Extract 256 data points
%       Bandpass 1Hz to 30Hz
%       Combine 4 channel data at 256 data points into vector size of 1024
%       Save as csv

% Parameters (Set these as needed)
fs = 256;              % Sampling rate in Hz
a = 1;                 % Lower cutoff frequency for bandpass filter (Hz)
b = 30;                % Upper cutoff frequency for bandpass filter (Hz)
num_start = 1024;      % Number of data points to remove from the start
num_end = 256;         % Number of data points to remove from the end
window_size = 256;     % Window size for each segment
overlap_percentage = 0.75;  % Overlap percentage (e.g., 0.75 for 75% overlap)

% Define your actual file name
original_file_name = 'Audrey_3';  % Replace with your actual file name

% Calculate overlap size
overlap_size = floor(overlap_percentage * window_size);
step_size = window_size - overlap_size;  % The step size for moving the window

% Ensure the required directories exist
if ~exist('time_domain', 'dir')
    mkdir('time_domain');
end
if ~exist('frequency_domain', 'dir')
    mkdir('frequency_domain');
end

% Assume eeg_time_series and eeg_time_stamps are loaded into the workspace
% eeg_time_series: 5 x n matrix
% eeg_time_stamps: 1 x n vector

% Remove unwanted data points from the start and end
eeg_time_series = eeg_time_series(:, num_start+1:end-num_end);
eeg_time_stamps = eeg_time_stamps(num_start+1:end-num_end);

% Determine number of segments based on step size
total_points = size(eeg_time_series, 2);
num_segments = floor((total_points - window_size) / step_size) + 1;

% Bandpass filter design
[b_bp, a_bp] = butter(2, [a b]/(fs/2), 'bandpass');

% Process each segment with overlap
for i = 1:num_segments
    % Calculate start and end indices of the current window
    idx_start = (i-1)*step_size + 1;
    idx_end = idx_start + window_size - 1;

    % Check if idx_end exceeds the total data points
    if idx_end > total_points
        idx_end = total_points;
        idx_start = total_points - window_size + 1;  % Adjust idx_start accordingly
    end

    % Extract segment for channels 1 to 4
    segment = eeg_time_series(1:4, idx_start:idx_end);

    % Apply bandpass filter to each channel
    filtered_segment = zeros(size(segment));
    for ch = 1:4
        filtered_segment(ch, :) = filtfilt(b_bp, a_bp, segment(ch, :));
    end

    % Combine 4 channels into a vector of size 1024
    time_domain_vector = reshape(filtered_segment, [], 1);

    % Save time-domain data as CSV
    time_domain_filename = fullfile('time_domain', [original_file_name '_' num2str(i) '.csv']);

    % Debug statements
    disp(['Time domain filename: ', time_domain_filename]);
    disp(['Class of time_domain_filename: ', class(time_domain_filename)]);

    % Save the data
    csvwrite(time_domain_filename, time_domain_vector);

    % ... rest of the code ...
end