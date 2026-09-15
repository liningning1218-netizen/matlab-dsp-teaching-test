function y = change_pitch_speed(x, factor)
%CHANGE_PITCH_SPEED Combined pitch and duration change via interpolation.
validateattributes(x, {'numeric'}, {'real','nonempty'});
validateattributes(factor, {'numeric'}, {'scalar','real','finite','positive'});
x = double(x);
N = size(x,1);
newN = max(2, round(N/factor));
q = linspace(1, N, newN)';
y = zeros(newN, size(x,2));
base = (1:N)';
for c = 1:size(x,2)
    y(:,c) = interp1(base, x(:,c), q, 'linear');
end
y(~isfinite(y)) = 0;
end
