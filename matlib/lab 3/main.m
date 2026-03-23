clc
clear

%% 1
A = [6 -1 -1; 1 -2 3; 3 4 4];
B = [0; 1; -1];

fprintf('Решение СЛАУ методом обратной матрицы:\n');
x = inv(A) * B;
disp(x)

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
disp(check)

%% 2

A = [
    9.1 5.6 7.8; 
    3.8 5.1 2.8; 
    4.1 5.7 1.2
    ];
B = [9.8; 6.7; 5.8];

Ab = [A, B];
R = rref(Ab);

fprintf('Решение СЛАУ Методом Гаусса:\n');
x = R(:, end);
disp(x);

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
disp(check);
fprintf('Очень близкое к нулю\n');

%% 3


A = [2.34 -1.42 -0.54 0.21;
     1.44 -0.53 1.43 -1.27;
     0.63 -1.32 -0.65 1.43;
     0.54 0.88 -0.67 -2.38;
];
B = [0.66; -1.44; 0.94; 0.73];

[L, U] = lu(A);
% L*y = b  U*x = y

fprintf('Решить СЛАУ с помощью LU-разложения:\n');
x = U \ (L \ B);
disp(x);

fprintf('Проверка на условие B-Ax=0:\n');
check = B-A*x;
disp(check);
fprintf('Очень близкое к нулю\n');


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
num_reactions = m - rank_A;
fprintf('\n\nРанг матрицы A: %d\n', rank_A);
fprintf('Количество независимых реакций: %d\n', num_reactions);

basis_variants = {
    [1 2 3 4 6],
    [1 2 3 5 6],
    [2 3 4 5 6]
};

for variant = 1:length(basis_variants)
    fprintf('\nВариант %d\n', variant);
    basis_indices = basis_variants{variant};
    free_indices = setdiff(1:m, basis_indices);
    
    fprintf('Базисные индексы (основные): ');
    fprintf('%d ', basis_indices);
    fprintf('\nСвободные индексы (неосновные): ');
    fprintf('%d ', free_indices);
    fprintf('\n\n');
    
    fprintf('Базисные вещества: ');
    for i = basis_indices
        fprintf('%s, ', substances{i});
    end
    fprintf('\nСвободные вещества: ');
    for i = free_indices
        fprintf('%s, ', substances{i});
    end
    fprintf('\n');
    
    % Создание матрицы базиса
    A_basis = A(basis_indices, :);
    
    % Матрица для свободных коэффициентов
    I_free = eye(num_reactions);
    
    % Нулевая матрица
    B = zeros(num_reactions, m);
    
    for k = 1:num_reactions
        rhs = zeros(n, 1);
        for j = 1:length(free_indices)
            free_idx = free_indices(j);
            coeff = I_free(k, j);
            if abs(coeff) > 1e-10 % если коэффициент не нулевой
                % Перенос слагаемых со свободными переменными
                rhs = rhs - coeff * A(free_idx, :)';
            end
        end
        
        % Решение системы A_basis' * x = rhs
        basis_coeffs = A_basis' \ rhs;
        
        % Заполнение коэффициентов
        for j = 1:length(basis_indices)
            B(k, basis_indices(j)) = basis_coeffs(j);
        end
        % Свободные коэффициенты
        for j = 1:length(free_indices)
            B(k, free_indices(j)) = I_free(k, j);
        end
    end
    
    % Проверка условия: BA=0
    residual = B * A;
    norm_res = norm(residual, 'fro');
    fprintf('Проверка на условие B*A = 0: %e\n', norm_res);
    
    fprintf('Коэффициенты: \n');
    disp(B)
    
    % Вывод химических уравнений
    for r = 1:size(B, 1)
        left = {};
        right = {};
        
        row = B(r, :);
        nonzeros = row(abs(row) > 1e-10);
        if ~isempty(nonzeros)
            min_coeff = min(abs(nonzeros));
            if min_coeff > 1e-10
                row = row / min_coeff;
            end
        end
        
        row(abs(row) < 1e-8) = 0;
        
        for j = 1:length(row)
            coeff = row(j);
            if abs(coeff) < 1e-8
                continue;
            elseif coeff < 0
                left{end+1} = sprintf('%s * (%.4f)', substances{j}, abs(coeff));
            else
                right{end+1} = sprintf('%s * (%.4f)', substances{j}, coeff);
            end
        end
        
        if isempty(left)
            left_str = '0';
        else
            left_str = strjoin(left, ' + ');
        end
        
        if isempty(right)
            right_str = '0';
        else
            right_str = strjoin(right, ' + ');
        end
        
        equation = [left_str, ' -> ', right_str];
        fprintf('Реакция %d: %s\n', r, equation);
    end
end