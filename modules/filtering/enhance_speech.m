function [y, bEff] = enhance_speech(x, fs, strength)
%ENHANCE_SPEECH Gentle speech-band spectral shaping for teaching.
if nargin < 3 || isempty(strength), strength = 0.55; end
validateattributes(strength, {'numeric'}, {'scalar','real','>=',0,'<=',1});
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
x = normalize_audio(x, 0.9);
fLow = min(120, 0.10*fs);
fHigh = min(3800, 0.45*fs);
if fHigh <= fLow
    y = x;
    bEff = 1;
    return;
end
b = design_fir_filter('bandpass', fs, 160, fLow, fHigh);
xb = apply_fir_filter(x, b);
delta = zeros(size(b));
delta((numel(b)+1)/2) = 1;
bEff = (1-strength)*delta + strength*b;
y = (1-strength)*x + strength*xb;
y = normalize_audio(y, 0.98);
end
