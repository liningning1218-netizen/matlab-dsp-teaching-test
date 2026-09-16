function demo = sine_sampling_demo(f0, fs, duration)
%SINE_SAMPLING_DEMO Data for a classroom sampling/aliasing demonstration.
% The displayed apparent sinusoid uses the signed baseband alias frequency,
% so it passes through the actual discrete samples.  The reported aliasHz
% remains the usual nonnegative frequency magnitude used by a spectrum.
validateattributes(f0, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'f0');
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
validateattributes(duration, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'duration');

fsRef = max([50000, 40*f0, 20*fs]);
tRef = (0:1/fsRef:duration)';
xRef = sin(2*pi*f0*tRef);
tSample = (0:1/fs:duration)';
xSample = sin(2*pi*f0*tSample);

% Fold the original sinusoid into [-fs/2, fs/2).  Keeping the sign is
% important for a sine wave: e.g. 800 Hz sampled at 1000 Hz is equivalent
% at the sample instants to -200 Hz, not +200 Hz with zero phase.
signedAliasHz = mod(f0 + fs/2, fs) - fs/2;
fa = abs(signedAliasHz);
xApparent = sin(2*pi*signedAliasHz*tRef);

demo = struct('f0', f0, 'fs', fs, 'duration', duration, ...
    'nyquist', fs/2, 'isUndersampled', fs < 2*f0, ...
    'aliasHz', fa, 'signedAliasHz', signedAliasHz, ...
    'sampleCount', numel(tSample), ...
    'tRef', tRef, 'xRef', xRef, ...
    'tSample', tSample, 'xSample', xSample, ...
    'xApparent', xApparent);
end
