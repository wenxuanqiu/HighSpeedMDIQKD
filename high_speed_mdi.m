% 'sampleRate' - sampleRate in Hz
sampleRate = 65e9;

% files that contain arrays of high and low voltages
high_voltage_file = 'peak_voltage.dat';
low_voltage_file = 'low_voltage.dat';


% 'pw' - pulse width in s
pw = 50e-12;
rise = 18e-12;
fall = 18e-12;
off = 300e-12;
pulseShape = 'Trapezodial';
alpha = 5;

% shifting the pattern to create delays (in ns)
delay = (pw + rise + fall + off)/2;

% read random numbers from a file
% high = csvread(high_voltage_file);

% generate pseudo random numbers for the peak voltages for 2 channels
high = 2*rand(1, 1000)-1;
high_2 = 2*rand(1, 1000)-1;

low = 0;
correction = 0;
arbConfig = [];
target_channels = [1 0; 0 0; 0 0; 1 0];

waveform = iqpulsegen('pw', floor(pw*sampleRate), 'rise', floor(rise*sampleRate), ...
'fall', floor(fall*sampleRate), 'off', floor(off*sampleRate), 'pulseShape', pulseShape, ...
'alpha', alpha, 'low', low, 'high', high, ...
'correction', correction, 'arbConfig', arbConfig);

% shift the pattern circularly to create delay
shifted_waveform = [waveform(floor(delay*sampleRate) + 1:length(waveform)) waveform(1:floor(delay*sampleRate))];

waveform_2 = iqpulsegen('pw', floor(pw*sampleRate), 'rise', floor(rise*sampleRate), ...
'fall', floor(fall*sampleRate), 'off', floor(off*sampleRate), 'pulseShape', pulseShape, ...
'alpha', alpha, 'low', low, 'high', high_2, ...
'correction', correction, 'arbConfig', arbConfig);

% download waveform into the channels of the AWG
iqdownload(waveform, sampleRate, 'channelmapping', [1 0; 0 0; 0 0; 0 0]);
iqdownload(waveform_2, sampleRate, 'channelmapping', [0 0; 0 0; 0 0; 1 0]);

