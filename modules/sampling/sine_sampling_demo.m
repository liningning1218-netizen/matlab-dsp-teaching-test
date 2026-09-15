function demo = sine_sampling_demo(f0, fs, duration)
%SINE_SAMPLING_DEMO Data for a classroom sampling/aliasing demonstration.
validateattributes(f0, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'f0');
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
validateattributes(duration, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'duration');
fsRef = max([50000, 40*f0, 20*fs]);
tRef = (0:1/fsRef:duration)';
xRef = sin(2*pi*f0*tRef);
tSample = (0:1/fs:duration)';
xSample = sin(2*pi*f0*tSample);
fa = alias_frequency(f0, fs);
xApparent = sin(2*pi*fa*tRef);
demo = struct('f0', f0, 'fs', fs, 'duration', duration, ...
    'nyquist', fs/2, 'isUndersampled', fs < 2*f0, ...
    'aliasHz', fa, 'tRef', tRef, 'xRef', xRef, ...
    'tSample', tSample, 'xSample', xSample, ...
    'xApparent', xApparent);
end
