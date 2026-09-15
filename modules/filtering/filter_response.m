function [f, H] = filter_response(b, fs, nfft)
%FILTER_RESPONSE Magnitude/complex frequency response using FFT only.
if nargin < 3 || isempty(nfft), nfft = 4096; end
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'});
validateattributes(nfft, {'numeric'}, {'scalar','integer','>=',64});
B = fft(double(b(:)), nfft);
K = floor(nfft/2)+1;
H = B(1:K);
f = (0:K-1)'*(fs/nfft);
end
