clc
clear

%% 1
A = [6 -1 -1; 1 -2 3; 3 4 4];
B = [0; 1; -1];

cond_A = cond(A);
fprintf('Число обусловленности матрицы: %e\n', cond_A);

if cond_A < 10
    fprintf('Матрица хорошо обусловленна\n');
elseif cond_A < 100
    fprintf('Матрица приемлемо обусловленна, погрешности могут привести к ошибкам\n'); 
else
    fprintf('Матрица плохо обусловленна, погрешности могут привести к огромным ошибкам\n');
end

fprintf('Решение СЛАУ методом обратной матрицы:\n');
x = inv(A) * B;
disp(x)

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
if norm(check) < 1e-10
    fprintf('Решение было найдено с высокой точностью\n\n');
else
    fprintf('Норма невязки: %.2e\n\n', norm(check));
end


%% 2

A = [
    9.1 5.6 7.8; 
    3.8 5.1 2.8; 
    4.1 5.7 1.2
    ];
B = [9.8; 6.7; 5.8];

Ab = [A, B];
R = rref(Ab);

cond_A = cond(A);
fprintf('Число обусловленности матрицы: %e\n', cond_A);

if cond_A < 10
    fprintf('Матрица хорошо обусловленна\n');
elseif cond_A < 100
    fprintf('Матрица приемлемо обусловленна, погрешности могут привести к ошибкам\n'); 
else
    fprintf('Матрица плохо обусловленна, погрешности могут привести к огромным ошибкам\n');
end

fprintf('Решение СЛАУ Методом Гаусса:\n');
x = R(:, end);
disp(x);

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
if norm(check) < 1e-10
    fprintf('Решение было найдено с высокой точностью\n\n');
else
    fprintf('Норма невязки: %.2e\n\n', norm(check));
end

%% 3

A = [2.34 -1.42 -0.54 0.21;
     1.44 -0.53 1.43 -1.27;
     0.63 -1.32 -0.65 1.43;
     0.54 0.88 -0.67 -2.38;
];
B = [0.66; -1.44; 0.94; 0.73];

[L, U, P] = lu(A);

fprintf('Матрица L (нижний треугольник):\n'); 
disp(L);
fprintf('Матрица U (верхний треугольник):\n');
disp(U);
fprintf('Матрица перестановок P:\n');
disp(P);

cond_A = cond(A);
fprintf('Число обусловленности матрицы: %e\n', cond_A);

if cond_A < 10
    fprintf('Матрица хорошо обусловленна\n');
elseif cond_A < 100
    fprintf('Матрица приемлемо обусловленна, погрешности могут привести к ошибкам\n'); 
else
    fprintf('Матрица плохо обусловленна, погрешности могут привести к огромным ошибкам\n');
end

fprintf('Решить СЛАУ с помощью LU-разложения:\n');
y = L \ B;
x = U \ y;
disp(x);

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
if norm(check) < 1e-10
    fprintf('Решение было найдено с высокой точностью\n\n');
else
    fprintf('Норма невязки: %.2e\n\n', norm(check));
end

%% 4

A = [
%   Ca  P  N  H  O  F
    5  3  0  0  12 1; % Ca5F(PO4)3
    0  0  1  1  3  0; % HNO3
    1  0  2  0  6  0; % Ca(NO3)2
    0  1  0  3  4  0; % H3PO4
    0  0  0  1  0  1; % HF
    1  0  0  0  1  0; % CaO
    0  0  0  2  1  0  % H2O
];

substances = {'Ca5F(PO4)3', 'HNO3', 'Ca(NO3)2', 'H3PO4', 'HF', 'CaO', 'H2O'};
[m, n] = size(A);
rank_A = rank(A);
num_reactions_expected = m - rank_A;
fprintf('\n\nРанг матрицы A: %d\n', rank_A);
fprintf('Количество независимых реакций (m-rank(A)): %d\n\n', num_reactions_expected);

% Ищем базис пространства решений v, где v*A = 0, эквивалентно A''*v'' = 0
K = null(A', 'r');
num_reactions = size(K, 2);

if num_reactions == 0
    fprintf('Ненулевых независимых реакций не найдено (null(A'') пусто).\n');
else
    fprintf('Найдено независимых реакций через null(A''): %d\n\n', num_reactions);

    % Строим 3 разных базиса пространства решений: K_i = K * T_i,
    % где T_i - невырожденная матрица размера num_reactions x num_reactions.
    T_list = cell(1, 3);
    if num_reactions == 1
        T_list{1} = 1;
        T_list{2} = 2;
        T_list{3} = -1;
    else
        T_list{1} = eye(num_reactions);

        T2 = eye(num_reactions);
        T2(:, 1) = T2(:, 1) + T2(:, 2);
        T_list{2} = T2;

        T3 = eye(num_reactions);
        T3(:, 2) = T3(:, 2) - T3(:, 1);
        T_list{3} = T3;
    end

    valid_var_names = matlab.lang.makeValidName(substances, 'ReplacementStyle', 'delete');
    valid_var_names = matlab.lang.makeUniqueStrings(valid_var_names);

    fprintf('Соответствие столбцов таблицы веществам:\n');
    for s = 1:numel(substances)
        fprintf('%s -> %s\n', valid_var_names{s}, substances{s});
    end

    for basis_id = 1:3
        K_basis = K * T_list{basis_id};

        % Преобразуем векторы базиса в целые коэффициенты реакций
        B = zeros(num_reactions, m);
        for r = 1:num_reactions
            v = K_basis(:, r);

            [num_v, den_v] = rat(v, 1e-10);
            lcm_den = 1;
            for t = 1:length(den_v)
                lcm_den = lcm(lcm_den, den_v(t));
            end
            coeff_int = num_v .* (lcm_den ./ den_v);

            nz = coeff_int(coeff_int ~= 0);
            if ~isempty(nz)
                g = abs(nz(1));
                for t = 2:length(nz)
                    g = gcd(g, abs(nz(t)));
                end
                if g > 1
                    coeff_int = coeff_int / g;
                end
            end

            first_nz = find(coeff_int ~= 0, 1);
            if ~isempty(first_nz) && coeff_int(first_nz) > 0
                coeff_int = -coeff_int;
            end

            B(r, :) = coeff_int';
        end

        fprintf('\n=== Базис %d ===\n', basis_id);
        reaction_labels = arrayfun(@(r) sprintf('R%d', r), 1:size(B, 1), 'UniformOutput', false);
        coeff_table = array2table(B, 'VariableNames', valid_var_names, 'RowNames', reaction_labels);
        disp(coeff_table)

        residual = B * A;
        norm_res = norm(residual, 'fro');
        fprintf('Проверка условия B*A = 0: %e\n', norm_res);
        if norm_res < 1e-10
            fprintf('Условие выполняется\n');
        else
            fprintf('Условие НЕ выполняется (погрешность > 1e-10)\n');
        end

        fprintf('Химические реакции:\n');
        for r = 1:size(B, 1)
            left = {};
            right = {};
            row = B(r, :);

            for j = 1:length(row)
                coeff = row(j);
                if coeff == 0
                    continue;
                end

                abs_coeff = abs(coeff);
                if abs_coeff == 1
                    term = sprintf('%s', substances{j});
                else
                    term = sprintf('%d %s', abs_coeff, substances{j});
                end

                if coeff < 0
                    left{end+1} = term;
                else
                    right{end+1} = term;
                end
            end

            if ~isempty(left) && ~isempty(right)
                fprintf('Реакция %d: %s -> %s\n', r, strjoin(left, ' + '), strjoin(right, ' + '));
            else
                fprintf('Реакция %d: не удалось корректно разделить на левую/правую часть\n', r);
            end
        end
    end
end