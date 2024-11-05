%% FILE LOADING
eegFile = 'Eyeblinks_EPOCX_242013_2024.10.24T13.35.44.04.00.md.pm.bp.csv';
markersFile = 'Eyeblinks_EPOCX_242013_2024.10.24T13.35.44.04.00_intervalMarker.csv';

%%

% Load EEG data and marker information from CSV files
eegData = readtable(eegFile);  % EEG data file
markers = readtable(markersFile);  % Markers file

samplingRate = 256;  % Sampling rate (samples per second)
segmentDuration = 1; % 1-second duration for each segment
timeAxis = (0:1/samplingRate:(segmentDuration - 1/samplingRate));  % Time vector for plotting

% Create output folder if it doesn't exist
outputFolder = 'eyeblinks';
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
