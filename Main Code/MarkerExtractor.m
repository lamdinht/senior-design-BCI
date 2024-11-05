%% HOW TO USE THIS CODE

% This script processes EEG data based on synchronized marker events in a 
% separate marker file. It offers three modes of segmentation:
% 
% 1. **Fixed Segment Extraction at Each Marker**: 
%    - Use this section to extract a 1-second segment of EEG data starting 
%      at each marker timestamp. The script will save each segment in a 
%      subfolder named after the marker’s type.
% 
%    - To run this section:
%      - Ensure the 'eegFile' and 'markersFile' variables point to the 
%        correct EEG and markers files.
%      - Set the desired sampling rate (e.g., `samplingRate = 128`) and 
%        segment duration (e.g., `segmentDuration = 1` second).
%      - Uncomment this section to enable it.
%
% 2. **Fixed Segment Extraction at Non-Markers**: 
%    - This section extracts 1-second segments that occur at least 1 second 
%      before or after any marker. Non-marker segments are saved in a 
%      folder named 'non_marker_segments'.
%
%    - To run this section:
%      - Ensure 'eegFile' and 'markersFile' are set correctly.
%      - Set the sampling rate, which determines the duration of each 
%        non-marker segment.
%      - Uncomment this section to enable it.
%
% 3. **Continuous Segment Extraction between Markers**: 
%    - Use this part to extract EEG data starting at each marker and 
%      ending at the next marker. Each segment is saved in a folder named 
%      after the marker type.
%
%    - To run this section:
%      - Confirm the 'eegFile' and 'markersFile' variables are correctly 
%        specified.
%      - Adjust the sampling rate as needed for accurate segmenting.
%      - Uncomment this section to enable it.

% **General Notes:**
% - The code requires synchronized EEG and marker files, with timestamps in 
%   both files aligned.
% - Ensure that each marker has a 'timestamp' and 'type' field in the marker 
%   file. The 'type' field will be used for organizing and naming segments.
% - Results are saved as CSV files, organized in folders by segment type 
%   (marker or non-marker) and marker name (for segments around markers).

% **Running the Code**:
% Uncomment the section(s) you want to run and execute the script. Each 
% section can be run independently based on the type of segmentation required. 
% The output will be organized in the 'segmented_data' folder.


%% FILE LOADING
eegFile = 'Resting+S7_EPOCX_242571_2024.10.27T15.29.19.05.00.md.bp.csv';
markersFile = 'Resting+S7_EPOCX_242571_2024.10.27T15.29.19.05.00_intervalMarker.csv';

%% MARKER TIMESTAMPS
%       RUN THIS CODE FOR:
%           extracting a FIXED segment AT EACH MARKER

% Load EEG data and marker information from CSV files
eegData = readtable(eegFile);  % EEG data file
markers = readtable(markersFile);  % Markers file

samplingRate = 128;  % Sampling rate (samples per second)
segmentDuration = 1; % 1-second duration for each segment
timeAxis = (0:1/samplingRate:(segmentDuration - 1/samplingRate));  % Time vector for plotting

% Create output folder if it doesn't exist
outputFolder = 'segmentedData';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Process each marker
for i = 1:height(markers)
    % Get marker timestamp from 'timestamp' column
    markerTime = markers.timestamp(i);  % Assuming the 'timestamp' column is named 'timestamp'
    
    % Find EEG data within the range of markerTime to markerTime + 1 second
    segmentIndices = eegData.Timestamp >= markerTime & eegData.Timestamp < (markerTime + segmentDuration);
    segmentData = eegData{segmentIndices, 5:18};  % Extracting columns 5 to 18 for EEG channels and converting to array
    
    % Check if sufficient data is available
    if isempty(segmentData)
        warning('Skipping marker at %.2f seconds: Insufficient data for 1 second window.', markerTime);
        continue;
    end
    
    % Save the segment to a CSV file
    markerType = string(markers{i, 'type'});  % Assuming the marker type is in the 'type' column
    typeFolder = fullfile(outputFolder, sprintf('type_%s', markerType));
    if ~exist(typeFolder, 'dir')
        mkdir(typeFolder);
    end
    filename = sprintf('%s/eyeblink_%d.csv', typeFolder, i);
    writematrix(segmentData, filename);

    % Generate legend labels for the 14-channel EEG system
    numChannels = size(segmentData, 2);  % Get the actual number of channels in the data
    legendLabels = arrayfun(@(x) sprintf('Channel %d', x), 1:numChannels, 'UniformOutput', false);

    % Plot the segment
% figure;
% plot(timeAxis(1:size(segmentData, 1)), segmentData);
% title(sprintf('EEG Segment Around Marker %d (%.2f seconds)', i, markerTime));
% xlabel('Time (s)');
% ylabel('Amplitude');
% legend(legendLabels);
% grid on;
end

disp('Eyeblink segments have been saved and plotted.');

%% Non-marker segments
%       RUN THIS CODE FOR:
%           extracting a FIXED segment AT EACH NON-MARKER

% Extract non-marker segments
nonMarkerFolder = fullfile(outputFolder, 'non_marker_segments');
if ~exist(nonMarkerFolder, 'dir')
    mkdir(nonMarkerFolder);
end

markerTimestamps = markers.timestamp;

% Process non-marker segments
nonMarkerCount = 1;
for i = 1:height(eegData)
    startTime = eegData.Timestamp(i);
    % Check if the segment is within 1 second before or after any marker
    if any((startTime >= (markerTimestamps - 1)) & (startTime <= (markerTimestamps + 1)))
        continue;
    end
    
    % Extract 128 data points starting from the current timestamp
    endIndex = i + samplingRate - 1;
    if endIndex > height(eegData)
        break;
    end
    segmentData = eegData{i:endIndex, 5:18};  % Extracting columns 5 to 18 for EEG channels and converting to array
    
    % Save the segment to a CSV file
    filename = sprintf('%s/non_marker_%d.csv', nonMarkerFolder, nonMarkerCount);
    writematrix(segmentData, filename);
    nonMarkerCount = nonMarkerCount + 1;
end

disp('Eyeblink and non-marker segments have been saved.');

%% Continuous Marker Segment
%       RUN THIS CODE FOR:
%           Extracting EEG at a marker until the next marker appears

% Load EEG data and marker information
eegData = readtable(eegFile);          % Load EEG data as a table
markers = readtable(markersFile);      % Load marker data as a table

% Define EEG and marker columns
eegTimestamps = eegData.Timestamp;     % Assumes the EEG data table has a 'Timestamp' column
samplingRate = 128;                    % Define your sampling rate here (samples per second)

% Create main output folder if it doesn't exist
outputFolder = 'segmented_data';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Create main output folder if it doesn't exist
outputFolder = 'segmented_data';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

numMarkers = height(markers);

% Loop through each marker to define segments
for i = 1:numMarkers
    % Get the start time and type of the current marker
    startTime = markers.timestamp(i);  % Assumes markers have a 'timestamp' field
    segmentType = markers.type{i};     % Assumes markers have a 'type' field containing the name
    
    % Define the subfolder based on marker type
    typeFolder = fullfile(outputFolder, segmentType);
    if ~exist(typeFolder, 'dir')
        mkdir(typeFolder);
    end
    
    if i < numMarkers
        endTime = markers.timestamp(i+1);
    else
        % For the last marker, the segment goes to the end of the EEG data
        endTime = eegTimestamps(end);
    end
    
    % Find the corresponding EEG data rows for the start and end times
    startSample = find(eegTimestamps == startTime, 1); % Directly synced, so exact match
    endSample = find(eegTimestamps < endTime, 1, 'last');
    
    % Validate indices to avoid out-of-range errors
    if isempty(startSample) || isempty(endSample) || startSample > endSample
        warning('Skipping marker at %.2f seconds: Invalid segment range.', startTime);
        continue;
    end
    
    % Extract segment data based on start and end samples
    segmentData = eegData(startSample:endSample, :);
    
    % Define the filename based on the marker's type
    filename = sprintf('%s/%s_segment_%d.csv', typeFolder, segmentType, i);
    writetable(segmentData, filename);
    
    fprintf('Segment %d of type "%s" saved from %.2f to %.2f seconds in folder %s.\n', i, segmentType, startTime, endTime, typeFolder);
end

disp('All segments have been saved.');