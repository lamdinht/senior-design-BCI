file_name = 'sub-P001_ses-S002_task-Default_run-001_eeg.xdf'

streams = load_xdf(file_name);


eeg = streams{1};
eeg_time_series = eeg.time_series;

% TIME SERIES:
%     eeg_time_series(1,:): AF7
%     eeg_time_series(2,:): TP9
%     eeg_time_series(3,:): TP10
%     eeg_time_series(4,:): AF8

eeg_time_stamps = eeg.time_stamps;
eeg_time_stamps = eeg_time_stamps - eeg_time_stamps(1);

% Reject the final column from eeg_time_series
eeg_time_series = eeg_time_series(:, 1:end-1);
% Reject the final column from eeg_time_stamps
eeg_time_stamps = eeg_time_stamps(1:end-1);


plot(eeg_time_stamps, eeg_time_series(1,:))

% % Bandpass Filter
% fs = 256;
% x1=eeg_time_series(2,:);
% upper_freq_limit=20;
% lower_freq_limit=1;
% x = bandpass(x1,[lower_freq_limit upper_freq_limit],fs);
% 
% % Highpass Filter
% fs = 256;
% x1=eeg_time_series(2,:);
% upper_freq_limit=20;
% x = highpass(x1,upper_freq_limit,fs);

%Lowpass Filter
fs = 256;
x1=eeg_time_series(4,:);
lower_freq_limit=20;
x = lowpass(x1,lower_freq_limit,fs);

% Frequency Density
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(x):fs/2;
show_limit=20; % Enter the freq want to show
freq_n=freq(freq<=show_limit);
psdx_n=psdx(freq<=show_limit);
plot(freq_n,pow2db(psdx_n))
grid on
title("Periodogram Using FFT")
xlabel("Frequency (Hz)")
ylabel("Power/Frequency (dB/Hz)")