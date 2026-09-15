function [y, noise] = add_demo_noise(x, fs, mode, amount, toneHz)
%ADD_DEMO_NOISE Add controllable teaching noise to audio.
if nargin < 3 || isempty(mode), mode = 'mixed'; end
if nargin < 4 || isempty(amount), amount = 0.25; end
if nargin < 5 || isempty(toneHz), toneHz = 1000; end
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(amount, {'numeric'}, {'scalar','real','finite','nonnegative'});
validateattributes(toneHz, {'numeric'}, {'scalar','real','finite','nonnegative','<',fs/2});
x = normalize_audio(x, 0.9);
N = numel(x);
t = (0:N-1)'/fs;
r = sqrt(mean(x.^2));
if r < eps, r = 0.1; end
mode = lower(char(string(mode)));
noise = zeros(size(x));
switch mode
    case {'none','无'}
    case {'tone','单频干扰'}
        noise = amount*r*sqrt(2)*sin(2*pi*toneHz*t);
    case {'white','白噪声'}
        rng(20260915, 'twister');
        z = randn(N,1); z = z/max(sqrt(mean(z.^2)), eps);
        noise = amount*r*z;
    case {'mixed','混合噪声'}
        rng(20260915, 'twister');
        z = randn(N,1); z = z/max(sqrt(mean(z.^2)), eps);
        noise = 0.65*amount*r*z + 0.75*amount*r*sqrt(2)*sin(2*pi*toneHz*t);
    otherwise
        error('add_demo_noise:UnknownMode', '未知噪声模式: %s', mode);
end
y = normalize_audio(x + noise, 0.98);
end
