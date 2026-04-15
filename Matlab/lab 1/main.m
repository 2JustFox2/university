%% 1
disp('1. Выполните несколько арифметических операций c произвольными числами.');
a = 21;
b = 3;
sum_ab = a + b
diff_ab = a - b
prod_ab = a * b
div_ab = a / b
power_ab = a^b

%% 3
disp('3. Выполните команды, приведённые в презентации');
X = 213.23
Sin = sin(X)
Sinh = sinh(X)
Asin = asin(X)

%% 4
disp('4. Создайте массивы размерности 2х3 и 3х2, задав значения их элементов.  ');
disp('Перемножьте массивы. Выполните различные математические операции с этими массивами. Изучите содержимое окон на рабочем столе.');
A = [1 2 3; 4 5 6]
B = [7 8; 9 10; 11 12]


C = A * B

A1 = [1 2 3; 4 5 6];
B1 = [7 8 9; 10 11 12];

sum_elem = A1 + B1
prod_elem = A1 .* B1
div_elem = A1 ./ B1


%% 5
disp('5. Постройте элементарные матрицы:');
zeros_mat = zeros(2,3)
ones_mat = ones(3,2)
rand_mat = rand(2,4)
eye_square = eye(3)
eye_rect = eye(2,4)
magic_mat = magic(3)

%% 6
disp('6. Выполните примеры с символьными переменными');
syms x y

expr1 = (x-y)*(x-y)^2
simplified = simplify(expr1)

expr2 = (x^3 - y^3)/(x - y)
simplified2 = simplify(expr2)

cos1 = cos(pi/2) 
cos2 = cos(sym(pi/2))

sym_sum = sym('1/2') + sym('1/3')

%% 7
disp('Постройте графики следующих функций, использую команды plot  и ezplot');

figure(1);
x_a = linspace(-4, 4, 200);
y_a = x_a.^3 - x_a;             
plot(x_a, y_a, 'b-', 'LineWidth', 1.5);
title('a) y = x^3 - x');
xlabel('x'); ylabel('y');
grid on;

figure(2);
x_b = linspace(-2, 2, 1000);
y_b = sin(1./(x_b.^2));
plot(x_b, y_b, 'r-');
title('b) y = sin(1/x^2)');
xlabel('x'); ylabel('y');
grid on;

figure(3);
ezplot('sin(1/x^2)', [-2, 2]);
title('b) ezplot: y = sin(1/x^2)');

figure(4);
x_c = linspace(-pi, pi, 500);
y_c = tan(x_c/2);
plot(x_c, y_c, 'm-');
title('c) y = tan(x/2)');
xlabel('x'); ylabel('y');
axis([-pi, pi, -10, 10]);
grid on;

figure(5);
ezplot('tan(x/2)', [-pi, pi]);
axis([-pi, pi, -10, 10]);
title('c) ezplot: y = tan(x/2)');

figure(6);
x_d = linspace(-1.5, 1.5, 200);
y1_d = exp(-x_d.^2 / 2);
y2_d = x_d.^4 - x_d.^2;
plot(x_d, y1_d, 'b-', 'LineWidth', 1.5); hold on;
plot(x_d, y2_d, 'r--', 'LineWidth', 1.5);
title('d) Две функции на одном графике');
xlabel('x'); ylabel('y');
legend('e^{-x^2/2}', 'x^4 - x^2');
grid on;
hold off;