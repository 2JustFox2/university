# Сапунков Александр Андреевич вариант 28
# Метилацетат + вода
# Подбор параметров модели Вильсона и построение диаграмм VLE

from scipy.optimize import minimize
import numpy as np
import matplotlib.pyplot as plt

T = 298.15  # Температура (K)
R = 8.314   # Газовая постоянная (Дж/(моль·К))

# Экспериментальные данные
x1_exp = np.array([0.100, 0.300, 0.500, 0.700, 0.900])
y1_exp = np.array([0.903, 0.875, 0.923, 0.873, 0.923])
P_exp = np.array([0.2630, 0.2796, 0.2833, 0.2874, 0.2937])  # (бар)
# P_exp = P_exp_bar * 0.1  # 1 бар = 0.1 МПа

# Константы Антуана для расчета давления насыщения (ММ РТ СТ)
A1, B1, C1 = 16.13, 2601.92, -56.15 #Метилацетат
A2, B2, C2 = 18.30, 3816.44, -46.13 #вода


mmHg_to_bar = 750.06168

def antoine_P0(A, B, C, T):
    return np.exp(A - B / (T + C)) / mmHg_to_bar

P1_0 = antoine_P0(A1, B1, C1, T)
P2_0 = antoine_P0(A2, B2, C2, T)

x2_exp = 1 - x1_exp
y2_exp = 1 - y1_exp
gamma1_exp = y1_exp * P_exp / (P1_0 * x1_exp)
gamma2_exp = y2_exp * P_exp / (P2_0 * x2_exp)

gE_exp_RT = x1_exp * np.log(gamma1_exp) + x2_exp * np.log(gamma2_exp)

def gE_Wilson_RT(x1, L12, L21):
    x2 = 1 - x1
    return -x1*np.log(x1 + L12*x2) - x2*np.log(x2 + L21*x1)

def objective(params):
    L12, L21 = params
    gE_model = np.array([gE_Wilson_RT(x, L12, L21) for x in x1_exp])
    return np.sum(np.abs(gE_model - gE_exp_RT))

res = minimize(objective, [0.1, 0.1], method='Nelder-Mead')
L12_opt, L21_opt = res.x

print("Метилацетат (1) + Вода (2)")
print(f"T = {T} K")
print(f"P1_sat = {P1_0:.4f} bar")
print(f"P2_sat = {P2_0:.4f} bar")
print(f"A12 = {L12_opt:.6f}")
print(f"A21 = {L21_opt:.6f}")

def wilson_gamma(x1, L12, L21):
    x2 = 1 - x1
    ln_g1 = -np.log(x1 + L12*x2) + x2*(L12/(x1+L12*x2) - L21/(x2+L21*x1))
    ln_g2 = -np.log(x2 + L21*x1) - x1*(L12/(x1+L12*x2) - L21/(x2+L21*x1))
    return np.exp(ln_g1), np.exp(ln_g2)

x1_grid = np.linspace(0.001, 0.999, 200)
g1, g2 = wilson_gamma(x1_grid, L12_opt, L21_opt)
x2_grid = 1 - x1_grid
P_grid = x1_grid*g1*P1_0 + x2_grid*g2*P2_0
y1_grid = x1_grid*g1*P1_0 / P_grid

# Точка перехода (приближение азеотропной точки): x1 ~= y1
idx_transition = np.argmin(np.abs(y1_grid - x1_grid))
x1_transition = x1_grid[idx_transition]
y1_transition = y1_grid[idx_transition]
P_transition = P_grid[idx_transition]

print(f"Точка перехода (x1≈y1): x1={x1_transition:.4f}, y1={y1_transition:.4f}, P={P_transition:.4f} bar")


plt.figure(figsize=(8,6))
plt.plot(x1_grid, y1_grid, 'b-', label='Модель Вильсона')
plt.plot(x1_exp, y1_exp, 'ro', label='Эксперимент')
plt.plot([0,1],[0,1],'k--', label='y=x')
plt.plot(x1_transition, y1_transition, 'ks', ms=7, label='Точка перехода (x≈y)')
plt.annotate(
    f'x={x1_transition:.3f}, y={y1_transition:.3f}',
    (x1_transition, y1_transition),
    xytext=(10, -15),
    textcoords='offset points'
)
plt.xlabel('x1 мольная доля метилацетата в жидкой фазе')
plt.ylabel('y1 мольная доля метилацетата в паре')
plt.title('y–x диаграмма')
plt.legend(); plt.grid()


plt.figure(figsize=(8,6))
plt.plot(x1_grid, P_grid, 'b-', label='P(x) - линия кипения')
plt.plot(y1_grid, P_grid, 'r-', label='P(y) - линия росы')
plt.plot(x1_exp, P_exp, 'bo', label='Эксп. точки (x)')
plt.plot(y1_exp, P_exp, 'ro', label='Эксп. точки (y)')
plt.plot(x1_transition, P_transition, 'ks', ms=7, label='Точка перехода')
plt.annotate(
    f'x={x1_transition:.3f}, P={P_transition:.3f} bar',
    (x1_transition, P_transition),
    xytext=(10, -15),
    textcoords='offset points'
)
plt.xlabel('Мольная доля метилацетата')
plt.ylabel('Давление P, бар')
plt.title('P–x–y диаграмма')
plt.legend(); plt.grid()

plt.show()