% 'sampleRate' - sampleRate in Hz
sampleRate = 65e9;

% files that contain arrays of high and low voltages
high_voltage_file = "peak_voltage.dat"
low_voltage_file = "low_voltage.dat"

% shifting the pattern to create delays (in ns)
delay = 20e-7;

% 'pw' - pulse width in ns
pw = 100e-12;
rise = 78e-12;
fall = 78e-12;
off = 500e-12;
pulseShape = 'Trapezodial';
alpha = 5;

% read random numbers from a file
% high = csvread(high_voltage_file);

% generate pseudo random numbers
high = 2*rand(1, 5000)-1

low = 0;
correction = 0;
arbConfig = [];
target_channels = [1 0; 0 0; 0 0; 1 0];

waveform = iqpulsegen('pw', floor(pw*sampleRate), 'rise', floor(rise*sampleRate), ...
'fall', floor(fall*sampleRate), 'off', floor(off*sampleRate), 'pulseShape', pulseShape, ...
'alpha', alpha, 'low', low, 'high', high, ...
'correction', correction, 'arbConfig', arbConfig);

% shift the pattern circularly to create delay
shifted_waveform = circshift(waveform, delay*sampleRate);

% MATLAB simulation of waveforms
%plot(waveform);
%figure();
%plot(shifted_waveform);

% download waveform into the channels of the AWG
% iqdownload(shifted_waveform, 'channelMapping', target_channels);
% suppress output
% arbConfig = loadArbConfig(arbConfig);
% f = iqopen(arbConfig);
% xfprintf(f, ':outp off');

% Wrapper for communicating with the AWG using SPCI commands
function xfprintf(f, s, ignoreError)
% Send the string s to the instrument object f
% and check the error status

% set debugScpi=1 in MATLAB workspace to log SCPI commands
    if (evalin('base', 'exist(''debugScpi'', ''var'')'))
        fprintf('cmd = %s\n', s);
    end
    fprintf(f, s);
    result = query(f, ':syst:err?');
    if (length(result) == 0)
        fclose(f);
        errordlg('Instrument did not respond to :SYST:ERR query. Check the instrument.', 'Error');
        error(':syst:err query failed');
    end
    if (~exist('ignoreError', 'var'))
        if (~strncmp(result, '0,No error', 10) && ~strncmp(result, '0,"No error"', 12))
            errordlg(sprintf('Instrument returns error on cmd "%s". Result = %s\n', s, result));
        end
    end
end

