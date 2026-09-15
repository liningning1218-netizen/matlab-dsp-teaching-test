function [S, f, t] = frame_spectrogram(x, fs, frameMs, overlapFraction)
%FRAME_SPECTROGRAM Toolbox-independent short-time magnitude spectrum.
if nargin < 3 || isempty(frameMs), frameMs = 30; end
if nargin < 4 || isempty(overlapFraction), overlapFraction = 0.75; end
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(frameMs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(overlapFraction, {'numeric'}, {'scalar','>=',0,'<',1});
if size(x,2) > 1, x = mean(x,2); end
x = double(x(:));
L = max(16, round(frameMs*1e-3*fs));
hop = max(1, round(L*(1-overlapFraction)));
if numel(x) < L
    x(end+1:L,1) = 0;
end
starts = 1:hop:(numel(x)-L+1);
if isempty(starts), starts = 1; end
n = (0:L-1)';
if L == 1
    w = 1;
else
    w = 0.5 - 0.5*cos(2*pi*n/(L-1));
end
K = floor(L/2)+1;
S = zeros(K, numel(starts));
for i = 1:numel(starts)
    frame = x(starts(i):starts(i)+L-1) .* w;
    Y = fft(frame);
    S(:,i) = abs(Y(1:K));
end
f = (0:K-1)'*(fs/L);
t = ((starts-1) + (L-1)/2)/fs;
end
