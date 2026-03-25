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
num_reactions = m - rank_A;
fprintf('\n\nРанг матрицы A: %d\n', rank_A);
fprintf('Количество независимых реакций: %d\n\n', num_reactions);

% Нужно выбрать все возможные комбинации из num_reactions базисных строк
% которые дают линейно независимую матрицу A_basis
basis_variants = {};
basis_candidates = nchoosek(1:m, num_reactions);

for i = 1:size(basis_candidates, 1)
    candidate = basis_candidates(i, :);
    A_candidate = A(candidate, :);
    if rank(A_candidate) == num_reactions
        basis_variants{end+1} = candidate;
    end
end

fprintf('Найдено %d возможных базисных наборов:\n', length(basis_variants));
for i = 1:min(length(basis_variants), 3) % Показываем первые 3
    fprintf('Вариант %d: ', i);
    fprintf('%d ', basis_variants{i});
    fprintf('\n');
end
fprintf('\n');

% Используем первые 3 варианта для вывода
num_to_show = min(length(basis_variants), 3);
for variant = 1:num_to_show
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
    fprintf('\n\n');
    
    % Создание матрицы для нахождения коэффициентов
    % Решаем систему A_basis * X = -A_free
    A_basis = A(basis_indices, :);
    A_free = A(free_indices, :);
    
    % Находим коэффициенты для базисных веществ
    % Для каждой свободной переменной (num_reactions штук)
    B = zeros(num_reactions, m);
    
    for k = 1:num_reactions
        % Для k-ой свободной переменной
        % Решаем A_basis' * basis_coeffs = -A_free(k, :)'
        % или A_basis * basis_coeffs' = -A_free(k, :)' 
        
        % Переносим свободное вещество в правую часть
        rhs = -A_free(k, :)';
        
        % Решаем систему для базисных коэффициентов
        % Базисные коэффициенты - это коэффициенты при базисных веществах
        % которые вместе со свободным веществом (коэффициент 1) дают нулевую комбинацию
        basis_coeffs = A_basis' \ rhs;
        
        % Заполняем строку B
        for j = 1:length(basis_indices)
            B(k, basis_indices(j)) = basis_coeffs(j);
        end
        B(k, free_indices(k)) = 1;
    end
    
    disp(B)
    
    % Проверка условия: B * A = 0  
    residual = B * A;
    norm_res = norm(residual, 'fro');
    fprintf('Проверка на условие B*A = 0: %e\n', norm_res);
    if norm_res < 1e-10
        fprintf('Условие выполняется\n');
    else
        fprintf('Условие НЕ выполняется (погрешность > 1e-10)\n');
    end
    
    fprintf('\nКоэффициенты (строки - реакции, столбцы - вещества):\n');
    disp(B);
    
    % Вывод химических уравнений
    fprintf('\nХимические реакции:\n');
    for r = 1:size(B, 1)
        left = {};
        right = {};
        
        row = B(r, :);
        % Нормализуем коэффициенты
        nonzeros = row(abs(row) > 1e-10);
        if ~isempty(nonzeros)
            % Находим минимальный положительный коэффициент для нормализации
            pos_coeffs = nonzeros(nonzeros > 0);
            if ~isempty(pos_coeffs)
                min_coeff = min(pos_coeffs);
                if min_coeff > 1e-10
                    row = row / min_coeff;
                end
            end
        end
        
        row(abs(row) < 1e-8) = 0;
        
        for j = 1:length(row)
            coeff = row(j);
            if abs(coeff) < 1e-8
                continue;
            elseif coeff < 0
                left{end+1} = sprintf('%s * (%.2f)', substances{j}, abs(coeff));
            else
                right{end+1} = sprintf('%s * (%.2f)', substances{j}, coeff);
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
        
        if ~strcmp(left_str, '0') && ~strcmp(right_str, '0')
            equation = [left_str, ' -> ', right_str];
            fprintf('Реакция %d: %s\n', r, equation);
        end
    end
end