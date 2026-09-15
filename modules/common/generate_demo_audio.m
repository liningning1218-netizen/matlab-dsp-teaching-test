function [x, fs] = generate_demo_audio(outFile)
%GENERATE_DEMO_AUDIO Generate a deterministic speech-like teaching signal.
if nargin < 1
    outFile = '';
end
fs = 16000;
duration = 4.0;
t = (0:round(duration*fs)-1)'/fs;
f0 = 135 + 18*sin(2*pi*0.45*t) + 8*sin(2*pi*0.12*t);
phase = 2*pi*cumsum(f0)/fs;
x = zeros(size(t));
for k = 1:10
    x = x + (1/k) * sin(k*phase);
end
env = 0.20 + 0.80*(0.5 + 0.5*sin(2*pi*1.15*t)).^1.6;
rng(20260915, 'twister');
breath = 0.025*randn(size(t));
x = env .* x + breath;
x = normalize_audio(x, 0.85);
if ~isempty(outFile)
    folder = fileparts(outFile);
    if ~isempty(folder) && ~exist(folder, 'dir')
        mkdir(folder);
    end
    audiowrite(outFile, x, fs);
end
end
