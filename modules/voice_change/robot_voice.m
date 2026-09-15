function y = robot_voice(x, fs, modHz)
%ROBOT_VOICE Ring-modulation effect for explainable spectral translation.
if nargin < 3 || isempty(modHz), modHz = 35; end
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(modHz, {'numeric'}, {'scalar','real','finite','positive','<',fs/2});
x = normalize_audio(x, 0.9);
t = (0:numel(x)-1)'/fs;
y = x .* cos(2*pi*modHz*t);
y = normalize_audio(y, 0.98);
end
