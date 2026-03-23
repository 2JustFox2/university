clear; clc;

A = [3, 2, 1, 5;
     1, 2, 3, 4;
     8, 9, 5, 4;
     8, 4, 2, 3];
b = [42; 47; 142; 89];

fprintf('Матрица A:\n');
disp(A);
fprintf('Вектор b:\n');
disp(b);

%% Анализ матрицы
fprintf('\nАнализ матрицы n');

det_A = det(A);
fprintf('Определитель (det(A)): %.4f\n', det_A);

if abs(det_A) > 1e-10
    fprintf('Матрица близка к вырожденной (det = 0).\n');
else
    fprintf('Матрица невырожденная, система имеет единственное решение.\n');
end

% Ранг матрицы
rank_A = rank(A);
fprintf('Ранг матрицы (rank(A)): %d\n', rank_A);
if rank_A == size(A, 1)
    fprintf('Ранг равен размерности матрицы. Система совместна.\n');
end

% Норма матрицы (используем бесконечную норму - по строкам)
norm_A = norm(A, inf);
fprintf('Норма матрицы norm(A, inf): %.4f\n', norm_A);

% Число обусловленности
cond_A = cond(A, inf);
fprintf('Число обусловленности (cond(A)): %.4f\n', cond_A);
if cond_A > 1000
    fprintf('Система плохо обусловлена. Решение чувствительно к погрешностям.\n');
else
    fprintf('Система обусловлена хорошо.\n');
end

% Точность решения
epsilon = 1e-6;
fprintf('\nЗаданная точность вычислений: %.0e\n', epsilon);

%% Точное решение через linsolve
fprintf('\nРешение методом linsolve \n');
% linsolve решает систему прямым методом
x_exact = linsolve(A, b);
fprintf('Решение:\n');
for i = 1:length(x_exact)
    fprintf('x%d = %.6f\n', i, x_exact(i));
end

% Округляем до целых
x_code = round(x_exact);
fprintf('\nВероятный целочисленный код: %d %d %d %d\n', x_code(1), x_code(2), x_code(3), x_code(4));

%% Подготовка к итерационным методам
fprintf('\nПодготовка к итерационным методам \n');

% Для методов Якоби и Зейделя требуется диагональное преобладание
% Проверим условие диагонального преобладания (достаточное условие сходимости)
diag_dominance = true;
n = size(A, 1);
for i = 1:n
    sum_row = sum(abs(A(i, :))) - abs(A(i, i));
    if abs(A(i, i)) <= sum_row
        diag_dominance = false;
        fprintf('Условие диагонального преобладания НЕ выполнено для строки %d: |%d| <= %.2f\n', i, A(i,i), sum_row);
    end
end

if diag_dominance
    fprintf('Условие диагонального преобладания выполнено. Итерационные методы должны сходиться.\n');
else
    fprintf('ВНИМАНИЕ: Условие диагонального преобладания не выполнено.\n');
    fprintf('Итерационные методы могут расходиться. Для сходимости попробуем привести систему к нужному виду.\n');
    
    % Попытка привести матрицу к диагональному преобладанию перестановкой строк
    % Простая эвристика: сортируем строки так, чтобы диагональный элемент был максимальным в строке
    % [~, idx] = max(abs(A'), [], 1); % Индексы максимальных элементов в столбцах (но нам нужны строки)
    % Более надежный способ - переставить строки вручную, если это возможно
    % В данной матрице 3-я строка имеет большие элементы, попробуем поставить её на место 1-й строки, если нужно
    % Но для простоты оставим как есть, проверим спектральный радиус
    
    % Проверим спектральный радиус матрицы итераций Якоби
    D = diag(diag(A));
    L = tril(A, -1);
    U = triu(A, 1);
    
    % Матрица итераций для метода Якоби
    Bj = -D \ (L + U);
    spectral_radius_jacobi = max(abs(eig(Bj)));
    fprintf('Спектральный радиус матрицы Якоби: %.4f\n', spectral_radius_jacobi);
    
    if spectral_radius_jacobi < 1
        fprintf('Спектральный радиус < 1. Метод Якоби должен сходиться.\n');
    else
        fprintf('Спектральный радиус >= 1. Метод Якоби может расходиться!\n');
    end
    
    % Проверим сходимость для метода Зейделя (достаточное условие - спектральный радиус матрицы итераций Зейделя < 1)
    Bgs = -(D + L) \ U;
    spectral_radius_gs = max(abs(eig(Bgs)));
    fprintf('Спектральный радиус матрицы Зейделя: %.4f\n', spectral_radius_gs);
    
    if spectral_radius_gs < 1
        fprintf('Спектральный радиус < 1. Метод Зейделя должен сходиться.\n');
    else
        fprintf('Спектральный радиус >= 1. Метод Зейделя может расходиться!\n');
    end
end

%%  Реализация методов 
fprintf('\n Решение итерационными методами \n');

% Начальное приближение
x0 = zeros(n, 1);
max_iter = 1000; % Максимальное число итераций

% 4.1 Метод Якоби
fprintf('\n--- Метод Якоби ---\n');
[x_jacobi, iter_jacobi] = jacobi_method(A, b, x0, epsilon, max_iter);
if ~isempty(x_jacobi)
    fprintf('Решение методом Якоби (итераций: %d):\n', iter_jacobi);
    disp(x_jacobi);
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_jacobi - x_exact, inf));
else
    fprintf('Метод Якоби не сошелся за %d итераций.\n', max_iter);
end

% 4.2 Метод Зейделя (Gauss-Seidel)
fprintf('\n--- Метод Зейделя ---\n');
[x_seidel, iter_seidel] = seidel_method(A, b, x0, epsilon, max_iter);
if ~isempty(x_seidel)
    fprintf('Решение методом Зейделя (итераций: %d):\n', iter_seidel);
    disp(x_seidel);
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_seidel - x_exact, inf));
else
    fprintf('Метод Зейделя не сошелся за %d итераций.\n', max_iter);
end

% 4.3 Метод простой итерации (Richardson)
fprintf('\n--- Метод простой итерации ---\n');
% Для метода простой итерации нужно выбрать параметр tau
% Обычно tau = 2 / (lambda_min + lambda_max)
% Но проще использовать tau = 1 / norm(A, inf) для гарантии сходимости
tau = 1 / norm_A; 
fprintf('Параметр релаксации tau = %.6f\n', tau);
[x_simple, iter_simple] = simple_iteration(A, b, x0, epsilon, max_iter, tau);
if ~isempty(x_simple)
    fprintf('Решение методом простой итерации (итераций: %d):\n', iter_simple);
    disp(x_simple);
    fprintf('Погрешность относительно точного решения: %.2e\n', norm(x_simple - x_exact, inf));
else
    fprintf('Метод простой итерации не сошелся за %d итераций.\n', max_iter);
end

%%  Сравнение результатов
fprintf('\n Сравнение результатов \n');
fprintf('Точное решение (linsolve):\n');
fprintf('  x1 = %.6f, x2 = %.6f, x3 = %.6f, x4 = %.6f\n', x_exact(1), x_exact(2), x_exact(3), x_exact(4));
fprintf('\nИтоговый код доступа (округленное значение): %d %d %d %d\n', round(x_exact(1)), round(x_exact(2)), round(x_exact(3)), round(x_exact(4)));