clear; clc; close all;

% Экспериментальные данные из main.m
x = [0.0 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7];
y = [17.373 22.50 24.65 27.24 30.34 34.01 38.33 41.28 49.39];
p = [0.8 0.7 0.5 0.9 1.0 0.7 0.5 0.8 0.3];

x = x(:);
y = y(:);
p = p(:);

n = length(x);

fprintf('Количество узловых точек: %d\n\n', n);

%% Определение степени полинома по конечным разностям

disp('Метод конечных разностей');

dy = y;
diff_table = cell(1, n-1);

for k = 1:n-1
    dy = diff(dy);
    diff_table{k} = dy;

    fprintf('Разности порядка %d:\n', k);
    disp(dy);
end

deg = 3;
fprintf('Выбранная степень по конечным разностям: %d \n\n', deg);

%% Полином без весов через polyfit (МНК)

disp('Полином без весов через polyfit');

coef_polyfit = polyfit(x, y, deg);

V_poly = vander(x);
V_poly = V_poly(:, end-deg:end);

A_poly = V_poly' * V_poly;

det_poly = det(A_poly);
cond_poly = cond(A_poly);

fprintf('Детерминант polyfit: %.6e\n', det_poly);
fprintf('Обусловленность polyfit: %.6e\n', cond_poly);

disp('Коэффициенты:');
disp(coef_polyfit);

y_polyfit = polyval(coef_polyfit, x);

Q1 = sum((y - y_polyfit).^2);
fprintf('Сумма квадратов ошибок: %.8f\n\n', Q1);

%% Полином без весов через матрицу Вандермонда

disp('Полином без весов через матрицу Вандермонда');

V_full = vander(x);
V = V_full(:, end-deg:end);

A = V' * V;
b = V' * y;

detA = det(A);
condA = cond(A);

fprintf('Детерминант матрицы V^T V: %.6e\n', detA);
fprintf('Обусловленность V^T V: %.6e\n', condA);

coef_vand = A \ b;

disp('Коэффициенты:');
disp(coef_vand');

y_vand = polyval(coef_vand', x);

Q2 = sum((y - y_vand).^2);
fprintf('Сумма квадратов ошибок: %.8f\n\n', Q2);

%% Полином с весами через spap2

disp('Полином с весами через spap2');

sp = spap2(1, 4, x, y, p);

y_sp = fnval(sp, x);

Q3 = sum(p .* (y - y_sp).^2);

fprintf('Взвешенная сумма квадратов ошибок: %.8f\n\n', Q3);

%% Полином с весами через fminsearch

disp('Полином с весами через fminsearch');

a0 = coef_polyfit;

fun = @(a) sum(p .* (y - polyval(a, x)).^2);

coef_fmin = fminsearch(fun, a0);

disp('Коэффициенты:');
disp(coef_fmin);

y_fmin = polyval(coef_fmin, x);

Q4 = sum(p .* (y - y_fmin).^2);

fprintf('Взвешенная сумма квадратов ошибок: %.8f\n\n', Q4);

%% Неполиномиальная функция через fminsearch

disp('Экспоненциальная модель через fminsearch');

model = @(k,xx) k(1)*exp(k(2)*xx) + k(3);

fun_exp = @(k) sum(p .* (y - model(k,x)).^2);

c0 = min(y) - 1;
y_shift = y - c0;
y_shift(y_shift <= 0) = eps;
lin_coef = polyfit(x, log(y_shift), 1);
k0 = [exp(lin_coef(2)) lin_coef(1) c0];

options = optimset('Display','off', ...
    'MaxFunEvals',5000, ...
    'MaxIter',5000);

coef_exp = fminsearch(fun_exp, k0, options);

disp('Параметры модели [a b c]:');
disp(coef_exp);

y_exp = model(coef_exp, x);

Q5 = sum(p .* (y - y_exp).^2);

fprintf('Ошибка модели: %.8f\n\n', Q5);

%% Полином Чебышева

disp('Полином Чебышева');

xt = 2*(x - min(x))/(max(x)-min(x)) - 1;

T = zeros(n, deg+1);
T(:,1) = 1;
T(:,2) = xt;

for k = 3:deg+1
    T(:,k) = 2*xt.*T(:,k-1) - T(:,k-2);
end

W = diag(p);

A_cheb = T' * W * T;

det_cheb = det(A_cheb);
cond_cheb = cond(A_cheb);

fprintf('Детерминант Чебышёв: %.6e\n', det_cheb);
fprintf('Обусловленность Чебышёв: %.6e\n', cond_cheb);

c_cheb = A_cheb \ (T' * W * y);

y_cheb = T * c_cheb;

Q6 = sum(p .* (y - y_cheb).^2);

fprintf('Ошибка Чебышёва: %.8f\n\n', Q6);

%% Оценка точности лучшего решения

disp('Оценка точности');

fprintf('Максимальная ошибка (fminsearch): %.8f\n', max(abs(y - y_fmin)));
fprintf('СКО (fminsearch): %.8f\n\n', sqrt(Q4/sum(p)));

%% Значения в заданных точках

xq = [0.25 0.35];
yq = polyval(coef_fmin, xq);

fprintf('При x = %.2f  y = %.6f\n', xq(1), yq(1));
fprintf('При x = %.2f  y = %.6f\n\n', xq(2), yq(2));

errors = [Q1 Q2 Q3 Q4 Q5 Q6];
names = {'polyfit','vandermonde','spap2','fminsearch','exp_model','chebyshev'};
[min_error, ~] = min(errors);

%% Построение общего графика

xx = linspace(min(x), max(x), 500);

figure('Color','w','Position',[100 100 1300 750]);

plot(x, y, 'k*', ...
    'MarkerSize',10, ...
    'LineWidth',1.6, ...
    'DisplayName','Узловые точки');

hold on;

plot(xx, polyval(coef_polyfit,xx), 'b--', ...
    'LineWidth',2, ...
    'DisplayName','polyfit');

plot(xx, polyval(coef_vand',xx), 'g:', ...
    'LineWidth',2.2, ...
    'DisplayName','Вандермонд');

plot(xx, polyval(coef_fmin,xx), 'r-', ...
    'LineWidth',2.5, ...
    'DisplayName','fminsearch');

xt_q = 2*(xx - min(x))/(max(x)-min(x)) - 1;

Tq = zeros(length(xx), deg+1);
Tq(:,1) = 1;
Tq(:,2) = xt_q(:);

for k = 3:deg+1
    Tq(:,k) = 2*xt_q(:).*Tq(:,k-1) - Tq(:,k-2);
end

y_cheb_plot = Tq * c_cheb;

plot(xx, y_cheb_plot, 'k-.', ...
    'LineWidth',2.2, ...
    'DisplayName','Чебышёв');

if all(~isnan(y_sp))
    plot(xx, fnval(sp,xx), 'm-.', ...
        'LineWidth',2, ...
        'DisplayName','spap2');
end

plot(xx, model(coef_exp,xx), 'c-', ...
    'LineWidth',2, ...
    'DisplayName','Экспонента');

grid on;
box on;

xlabel('x','FontSize',12);
ylabel('y','FontSize',12);

title('Аппроксимация экспериментальных данных');

legend('Location','best');

xlim([min(x) max(x)]);
ylim([min(y)-2 max(y)+2]);

hold off;