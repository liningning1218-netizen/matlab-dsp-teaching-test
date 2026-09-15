function [f, mag] = one_sided_spectrum(x, fs)
%ONE_SIDED_SPECTRUM One-sided amplitude spectrum with correct scaling.
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
validateattributes(x, {'numeric'}, {'real','nonempty'}, mfilename, 'x');
if size(x,2) > 1
    x = mean(x,2);
end
x = double(x(:));
N = numel(x);
Y = fft(x);
P2 = abs(Y/N);
K = floor(N/2) + 1;
mag = P2(1:K);
if N > 1
    if rem(N,2) == 0
        if K > 2
            mag(2:end-1) = 2*mag(2:end-1);
        end
    else
        if K > 1
            mag(2:end) = 2*mag(2:end);
        end
    end
end
f = (0:K-1)' * (fs/N);
end
