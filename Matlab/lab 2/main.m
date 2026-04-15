clc
clear

%% 1
x = 2.5378; dx = 0.0001;
y = 2.536; dy = 0.001;

S1 = x + y;
dS1 = dx + dy;
relS1 = dS1 / abs(S1);

S2 = x - y;
dS2 = dx + dy;
relS2 = dS2 / abs(S2);

fprintf('1:\n');
fprintf('S1 = %.4f, dS1 = %.4f, relS1 = %.2e\n', S1, dS1, relS1);
fprintf('S2 = %.4f, dS2 = %.4f, relS2 = %.2f\n\n', S2, dS2, relS2);

%% 2
x = 37.1; dx = 0.1;
y = 9.87; dy = 0.05;
z = 6.052; dz = 0.02;

u = (x^2 * y^2) / (z^4);
du = u * (2*dx/abs(x) + 2*dy/abs(y) + 4*dz/abs(z));
relu = du / abs(u);

fprintf('2:\n');
fprintf('u = %.4f, du = %.4f, relu = %.2e\n\n', u, du, relu);

%% 3
x = -3.59; dx = 0.01;
y = 0.467; dy = 0.001;
z = 563.2; dz = 0.1;

u = (x^2 * y^2) / (z^4);
du = abs(u) * (2*dx/abs(x) + 2*dy/abs(y) + 4*dz/abs(z));
relu = du / abs(u);

fprintf('3:\n');
fprintf('u = %.2e, du = %.2e, relu = %.2e\n', u, du, relu);

%% 4

%   Ca P  N  H  O  F
A = [
    5  3  0  0  12 1;
    0  0  1  1  3  0;
    1  0  2  0  6  0;
    0  1  0  3  4  0;
    0  0  0  1  0  1;
    1  0  0  0  1  0;
    0  0  0  2  1  0;
];

r = rank(A);
[m, n] = size(A);

% все комбинации
row_combs = nchoosek(1:m, r);
col_combs = nchoosek(1:n, r);  

num_row_combs = size(row_combs, 1);
num_col_combs = size(col_combs, 1);

% cчетчик найденных подматриц
count = 0;
results = {};

for i = 1:num_row_combs
    rows = row_combs(i, :);
    
    for j = 1:num_col_combs
        cols = col_combs(j, :);
        
        B = A(rows, cols);
        
        det_B = det(B);
        
        
        
        if abs(det_B) > 1e-10 % допуск для учета погрешностей вычислений
            count = count + 1;
            
            results{count} = struct(...
                'rows', rows, ...
                'cols', cols, ...
                'det', det_B, ...
                'submatrix', B);
        end
    end
end

fprintf('подматрицы:\n');
fprintf('%-5s %-20s %-20s %-15s\n', '№', 'Строки', 'Столбцы', 'Определитель');
    
for k = 1:min(count) 
    fprintf('%-5d %-20s %-20s %-15.6f\n', ...
        k, ...
        mat2str(results{k}.rows), ...
        mat2str(results{k}.cols), ...
        results{k}.det);
end
