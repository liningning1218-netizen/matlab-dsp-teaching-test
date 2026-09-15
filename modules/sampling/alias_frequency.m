function fa = alias_frequency(f0, fs)
%ALIAS_FREQUENCY Apparent baseband frequency after ideal point sampling.
% Result lies in [0, fs/2].
validateattributes(f0, {'numeric'}, {'scalar','real','finite','nonnegative'}, mfilename, 'f0');
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
fa = abs(mod(f0 + fs/2, fs) - fs/2);
end
