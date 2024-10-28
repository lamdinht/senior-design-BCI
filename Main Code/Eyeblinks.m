% Load EEG data and marker information from CSV files
eegData = readmatrix('Eyeblinks_EPOCX_242013_2024.10.24T13.35.44.04.00.md.pm.bp.csv');  % Replace with actual filename
markers = readmatrix('Eyeblinks_EPOCX_242013_2024.10.24T13.35.44.04.00_intervalMarker.csv');   % Replace with actual filename

samplingRate = 256;  % Replace with your EEG data's sampling rate (samples per second)
segmentDuration = 1; % 1-second duration for each segment
timeAxis = (0:1/samplingRate:(segmentDuration - 1/samplingRate));  % Time vector for plotting

% Create output folder if it doesn't exist
outputFolder = 'eyeblinks';
if ~exist(outputFolder, 'dir')
% Define parameters
    mkdir(outputFolder);
end

% Process each marker
for i = 1:length(markers)
    % Get marker time and calculate start and end sample indices
    markerTime = markers(i);
    startSample = round(markerTime * samplingRate);
    endSample = startSample + segmentDuration * samplingRate - 1;
    
    % Check for bounds to avoid out-of-range indices
    if endSample > size(eegData, 1)
        warning('Skipping marker at %.2f seconds: Insufficient data for 1 second window.', markerTime);
        continue;
    end
    
    % Extract 1-second segment for all channels
    segmentData = eegData(startSample:endSample, :);
    
    % Save the segment to a CSV file
    filename = sprintf('%s/eyeblink_%d.csv', outputFolder, i);
    writematrix(segmentData, filename);

    % Generate legend labels for the 14-channel EEG system
    legendLabels = arrayfun(@(x) sprintf('Channel %d', x), 1:14, 'UniformOutput', false);

    % Plot the segment
    figure;
    plot(timeAxis, segmentData);
    title(sprintf('EEG Segment Around Marker %d (%.2f seconds)', i, markerTime));
    xlabel('Time (s)');
    ylabel('Amplitude');
    legend(legendLabels); % Add more channels as needed
    grid on;
end

disp('Eyeblink segments have been saved and plotted.');
