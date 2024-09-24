
streams = load_xdf("E:\Villanova\human-brain-interface\senior-design-BCI\Dataset\Lam_9_23\sub-P001\ses-S003 - eyes open\eeg\sub-P001_ses-S003 - eyes open _task-Default_run-001_eeg.xdf");

eeg_time_series = 0;
eeg_time_stamps = 0;


%% COMBINE TIME STREAMS
for i = 1:size(streams,2)
    if strcmp(streams{i}.info.type ,'EEG')
        eeg_time_series = [eeg_time_series(:,1:end-1) streams{i}.time_series(:,1:end-1)];
        eeg_time_stamps = [eeg_time_stamps(:,1:end-1) streams{i}.time_stamps(:,1:end-1)];
    end
end

eeg_time_stamps = eeg_time_stamps - eeg_time_stamps(1);

%% Preliminary Process:
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