function y = apply_fir_filter(x, b)
%APPLY_FIR_FILTER Offline centered FIR filtering with input-length output.
validateattributes(x, {'numeric'}, {'real','nonempty'});
validateattributes(b, {'numeric'}, {'real','vector','nonempty'});
x = double(x);
b = double(b(:));
y = zeros(size(x));
for c = 1:size(x,2)
    y(:,c) = conv(x(:,c), b, 'same');
end
end
