clear; clc;

%   Ca P  N  H  O  F
A = [
    5  3  0  0  12 1;
    0  0  1  1  3  0;
    1  0  2  0  6  0;
    0  1  0  3  4  0;
    0  0  0  1  0  1;
    1  0  0  0  1  0;
    0  0  0  2  1  0;
]

rank_A = rank(A);

cols1 = [1 2 3 4 6];
A_sub1 = A(:, cols1);
det1 = det(A_sub1(1:5, :));
fprintf('\n   Подматрица 1 (столбцы 1,2,3,4,6):\n');
disp(A_sub1);
if abs(det1) > 1e-10
    fprintf('   Определитель = %f (невырожденная)\n', det1);
else
    fprintf('   Определитель = %e (вырожденная, нужно выбрать другие строки)\n', det1);
    row_combs = nchoosek(1:6, 5);
    for i = 1:size(row_combs, 1)
        det_candidate = det(A_sub1(row_combs(i,:), :));
        if abs(det_candidate) > 1e-10
            fprintf('   Используем строки %d: определитель = %f (невырожденная)\n', ...
                row_combs(i,:), det_candidate);
            break;
        end
    end
end

cols2 = [2 3 4 5 6];
A_sub2 = A(:, cols2);
fprintf('\n   Подматрица 2 (столбцы 2,3,5,6,7):\n');
disp(A_sub2);

row_combs = nchoosek(1:6, 5);
det_found = false;
for i = 1:size(row_combs, 1)
    det_candidate = det(A_sub2(row_combs(i,:), :));
    if abs(det_candidate) > 1e-10
        fprintf('   Используем строки %d: определитель = %f (невырожденная)\n', ...
            row_combs(i,:), det_candidate);
        det_found = true;
        break;
    end
end
if ~det_found
    fprintf('   Не удалось найти невырожденную подматрицу\n');
end