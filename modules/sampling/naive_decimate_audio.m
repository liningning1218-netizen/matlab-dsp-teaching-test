function [y, fsNew] = naive_decimate_audio(x, fs, factor)
%NAIVE_DECIMATE_AUDIO Keep every Nth sample with NO anti-aliasing filter.
% This intentionally exposes aliasing for teaching. It is not recommended
% as a production-quality sample-rate converter.
validateattributes(fs, {'numeric'}, {'scalar','real','finite','positive'}, mfilename, 'fs');
validateattributes(factor, {'numeric'}, {'scalar','integer','>=',1}, mfilename, 'factor');
validateattributes(x, {'numeric'}, {'real','nonempty'}, mfilename, 'x');
y = double(x(1:factor:end, :));
fsNew = double(fs) / factor;
end
