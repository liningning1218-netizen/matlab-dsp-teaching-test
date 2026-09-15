function y = normalize_audio(x, targetPeak)
%NORMALIZE_AUDIO Convert audio to finite mono column and limit its peak.
if nargin < 2 || isempty(targetPeak)
    targetPeak = 0.98;
end
validateattributes(x, {'numeric'}, {'real','nonempty'}, mfilename, 'x');
validateattributes(targetPeak, {'numeric'}, {'scalar','real','finite','positive','<=',1}, mfilename, 'targetPeak');
if size(x,2) > 1
    x = mean(x, 2);
end
y = double(x(:));
y(~isfinite(y)) = 0;
peak = max(abs(y));
if peak > targetPeak && peak > 0
    y = y * (targetPeak / peak);
end
end
