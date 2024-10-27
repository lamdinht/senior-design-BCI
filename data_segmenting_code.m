%% UPDATE 10/7/2024

% Below is the MATLAB code that processes .xdf files according to your 
% description. It handles EEG data segmentation based on "pressed" and 
% "released" markers or processes the data as one long stream. If segments 
% exist, the code classifies them as "resting" or "active," depending on 
% their length, and saves the results into appropriate directories.

% Define parameters (customize these as needed)
a = 1;   % Lower cutoff frequency for bandpass filter (Hz)
b = 30;  % Upper cutoff frequency for bandpass filter (Hz)
num_start = 256;  % Number of data points to cancel from the start
num_end = 256;     % Number of data points to cancel from the end
window_size = 256;  % Window size for each segment
overlap_percentage = 0.75;  % Overlap percentage (e.g., 0.125 for 12.5% overlap)
fs = 256;  % Sampling rate (Hz)

% Time threshold for determining active vs resting states (in seconds)
active_threshold_sec = 15;
active_threshold_samples = active_threshold_sec * fs;

% Option to snip between markers ('yes' to snip, 'no' to process as a long stream)
snip_option = 'yes';  % Change to 'no' if you want to process the data as a long stream

% Ask the user if they want to process a specific .xdf file or all files in the folder
file_choice = input('Do you want to process a single file or all files? Enter "single" or "all": ', 's');

% Based on user choice, either process one file or scan the folder for all .xdf files
if strcmpi(file_choice, 'single')
    % Ask the user to specify the file name
    [file_name, file_path] = uigetfile('*.xdf', 'Select the .xdf file to process');
    xdf_files = dir(fullfile(file_path, file_name));
else
    % Process all .xdf files in the current folder
    xdf_files = dir('*.xdf');
end

% Ensure the required directories exist
if ~exist('time_domain', 'dir')
    mkdir('time_domain');
end
if ~exist('frequency_domain', 'dir')
    mkdir('frequency_domain');
end

% Process each .xdf file based on the user's choice
for file_idx = 1:length(xdf_files)
    % Load the current .xdf file
    xdf_filename = xdf_files(file_idx).name;
    disp(['Processing ', xdf_filename, '...']);
    [streams, fileheader] = load_xdf(xdf_filename);
    
    % Initialize variables to hold EEG and Marker streams
    eeg_time_series = [];
    eeg_time_stamps = [];
    marker_stream = [];
    marker_time_stamps = [];
    
    % Combine streams of the same type (e.g., EEG or Marker)
    for stream_idx = 1:length(streams)
        stream_type = streams{stream_idx}.info.type;  % Get stream type
        
        if strcmpi(stream_type, 'EEG')
            % Concatenate EEG streams (take only the first 4 channels: rows 1 to 4)
            if isempty(eeg_time_series)
                eeg_time_series = streams{stream_idx}.time_series(1:4, :);
                eeg_time_stamps = streams{stream_idx}.time_stamps;
            else
                eeg_time_series = [eeg_time_series, streams{stream_idx}.time_series(1:4, :)];
                eeg_time_stamps = [eeg_time_stamps, streams{stream_idx}.time_stamps];
            end
        elseif strcmpi(stream_type, 'Markers')
            % Concatenate marker streams
            if isempty(marker_stream)
                marker_stream = streams{stream_idx}.time_series;
                marker_time_stamps = streams{stream_idx}.time_stamps;
            else
                marker_stream = [marker_stream, streams{stream_idx}.time_series];
                marker_time_stamps = [marker_time_stamps, streams{stream_idx}.time_stamps];
            end
        end
    end
    
    % Proceed if EEG data is found
    if isempty(eeg_time_series)
        disp(['No EEG data found in ', xdf_filename]);
        continue;
    end

    % Synchronize timestamps by subtracting the first timestamp
    if ~isempty(eeg_time_stamps)
        eeg_time_stamps = eeg_time_stamps - eeg_time_stamps(1);
    end

    if ~isempty(marker_time_stamps)
        marker_time_stamps = marker_time_stamps - marker_time_stamps(1);
    end
    
    % Remove unwanted data points from the start and end of the EEG stream
    eeg_time_series = eeg_time_series(:, num_start+1:end-num_end);
    eeg_time_stamps = eeg_time_stamps(num_start+1:end-num_end);

    % If snip option is 'yes', process each segment between "pressed" and "released" markers
    if strcmpi(snip_option, 'yes') && ~isempty(marker_stream)
        % Find "pressed" and "released" markers
        pressed_indices = find(contains(marker_stream, 'pressed'));
        released_indices = find(contains(marker_stream, 'released'));
        
        % Initialize the starting point for searching the next "pressed"
    current_index = 1;
    
    while current_index <= length(released_indices)
        % Get the time at the current "released" marker
        release_time = marker_time_stamps(released_indices(current_index));
        
        % Find the next "pressed" marker that occurs after this "released" marker
        next_press_idx = find(pressed_indices > released_indices(current_index), 1, 'first');
        
        % Break the loop if there is no next "pressed" marker
        if isempty(next_press_idx)
            break;
        end
        
        % Get the time at the next "pressed" marker for the start of the segment
        press_time = marker_time_stamps(pressed_indices(next_press_idx));
        
        % Find EEG data between release and next press events
        segment_indices = find(eeg_time_stamps >= release_time & eeg_time_stamps <= press_time);
        
        if isempty(segment_indices)
            current_index = current_index + 1;  % Move to the next "released" marker if no segment found
            continue;
        end
        
        % Determine if it's an active or resting state
        segment_length = length(segment_indices);
        if segment_length < active_threshold_samples
            state = 'resting';
        else
            state = 'active';
        end
        
        % Create subfolders for "resting" and "active" segments in both time and frequency domain
        time_domain_dir = fullfile('time_domain', state);
        frequency_domain_dir = fullfile('frequency_domain', state);
        
        if ~exist(time_domain_dir, 'dir')
            mkdir(time_domain_dir);
        end
        if ~exist(frequency_domain_dir, 'dir')
            mkdir(frequency_domain_dir);
        end
        
        % Process the EEG segment (first 4 channels only)
        process_eeg_segment(eeg_time_series(:, segment_indices), fs, a, b, window_size, overlap_percentage, time_domain_dir, frequency_domain_dir, xdf_filename, current_index);
        
        % Move to the next "released" marker
        current_index = current_index + 1;
    end
        
    else
        % Process the entire EEG stream as one segment if snipping is disabled
        state = 'entire_stream';
        
        % No subfolders for long streams, just save directly to the main folders
        time_domain_dir = 'time_domain';
        frequency_domain_dir = 'frequency_domain';
        
        % Process the whole EEG stream (first 4 channels only)
        process_eeg_segment(eeg_time_series, fs, a, b, window_size, overlap_percentage, time_domain_dir, frequency_domain_dir, xdf_filename, 1);
    end
end

% Function to process EEG segment (time-domain and frequency-domain analysis)
function process_eeg_segment(segment, fs, a, b, window_size, overlap_percentage, time_domain_dir, frequency_domain_dir, xdf_filename, event_idx)
    % Bandpass filter design
    [b_bp, a_bp] = butter(2, [a b]/(fs/2), 'bandpass');
    
    % Apply bandpass filter to each channel
    filtered_segment = zeros(size(segment));
    for ch = 1:4
        filtered_segment(ch, :) = filtfilt(b_bp, a_bp, segment(ch, :));
    end
    
    % Windowing: process each segment with overlap
    overlap_size = floor(overlap_percentage * window_size);
    step_size = window_size - overlap_size;
    num_windows = floor((size(filtered_segment, 2) - window_size) / step_size) + 1;
    
    for win_idx = 1:num_windows
        idx_start = (win_idx-1) * step_size + 1;
        idx_end = idx_start + window_size - 1;
        
        % Extract window
        window_segment = filtered_segment(:, idx_start:idx_end);
        
        % Combine 4 channels into a vector of size 1024
        time_domain_vector = reshape(window_segment, [], 1);
        
        % Save time-domain data in the correct folder (active/resting or entire_stream)
        time_domain_filename = fullfile(time_domain_dir, [xdf_filename '_segment_' num2str(event_idx) '_win_' num2str(win_idx) '.csv']);
        writematrix(time_domain_vector', time_domain_filename);  % Save as row in CSV
        
        % Frequency domain analysis (FFT)
        NFFT = window_size;  % FFT length
        freq_bins = (0:NFFT/2-1)*(fs/NFFT);
        
        power_values = [];
        for ch = 1:4
            Y = fft(window_segment(ch, :), NFFT);
            P2 = abs(Y/NFFT).^2;
            P1 = P2(1:NFFT/2);
            P1(2:end-1) = 2*P1(2:end-1);
            PSD = P1 / fs;
            
            % Calculate power in different bands
            power_05_4 = bandpower(PSD, freq_bins, [0.5 4], 'psd');
            power_4_8 = bandpower(PSD, freq_bins, [4 8], 'psd');
            power_8_12 = bandpower(PSD, freq_bins, [8 12], 'psd');
            power_12_30 = bandpower(PSD, freq_bins, [12 30], 'psd');
            
            power_values = [power_values, power_05_4, power_4_8, power_8_12, power_12_30];
        end
        
        % Save frequency-domain data in the correct folder (active/resting or entire_stream)
        frequency_domain_vector = power_values;
        frequency_domain_filename = fullfile(frequency_domain_dir, [xdf_filename '_segment_' num2str(event_idx) '_win_' num2str(win_idx) '.csv']);
        writematrix(frequency_domain_vector', frequency_domain_filename);  % Save as row in CSV
    end
end