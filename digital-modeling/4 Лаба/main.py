# Сапунков Александр Андреевич вариант 28
# Метилацетат + вода
# Подбор параметров модели Вильсона и построение диаграмм VLE

from scipy.optimize import minimize, fsolve
import numpy as np
import matplotlib.pyplot as plt
import math

# ДАННЫЕ И КОНСТАНТЫ
T = 298.15  # Температура (K)
R = 8.314   # Газовая постоянная (Дж/(моль·К))

# Экспериментальные данные
x1_exp = np.array([0.100, 0.300, 0.500, 0.700, 0.900])
y1_exp = np.array([0.903, 0.875, 0.923, 0.873, 0.923])
P_exp_bar = np.array([0.2630, 0.2796, 0.2833, 0.2874, 0.2937])  # (бар)

# В расчете используем МПа, чтобы согласовать единицы с P_sat из Антуана
P_exp = P_exp_bar * 0.1  # 1 бар = 0.1 МПа

# Константы Антуана для расчета давления насыщения (ММ РТ СТ)
# Компонент 1: Метилацетат
# Компонент 2: Вода
A = np.array([16.13, 18.30])
B = np.array([2601.92, 3816.44])
C = np.array([-56.15, -46.13])

Tc = np.array([506.80, 647.30])  # Критическая температура (K)
Pc = np.array([46.91, 220.48])    # Критическое давление (бар)
omega = np.array([0.32, 0.34])   # Ацентрическая фактор


# ФУНКЦИЯ РАСЧЕТА ДАВЛЕНИЯ НАСЫЩЕНИЯ 
def antoine(T_K, A, B, C):
    """
    Расчет давления насыщения по уравнению Антуана
    Возвращает давление в МПа
    ln(P[мм.рт.ст]) = A - B/(T + C)
    1 мм.рт.ст = 133.322 Па = 0.000133322 МПа
    """
    ln_P_mmHg = A - B / (T_K + C)
    P_mmHg = np.exp(ln_P_mmHg)
    P_Pa = P_mmHg * 133.322
    P_MPa = P_Pa / 1e6
    return P_MPa

# Расчет давлений насыщения при температуре T
P1_sat = antoine(T, A[0], B[0], C[0])  # Метилацетат
P2_sat = antoine(T, A[1], B[1], C[1])  # Вода

print(f"P1_sat (Метилацетат) = {P1_sat:.6f} МПа = {P1_sat*1e6/133.322:.2f} мм.рт.ст")
print(f"P2_sat (Вода) = {P2_sat:.6f} МПа = {P2_sat*1e6/133.322:.2f} мм.рт.ст")
print()

# РАСЧЕТ КОЭФФИЦИЕНТОВ АКТИВНОСТИ ИЗ ЭКСПЕРИМЕНТАЛЬНЫХ ДАННЫХ
gam1_exp = np.zeros(5)
gam2_exp = np.zeros(5)

for i in range(5):
    # Из уравнения VLE: y1*P = x1*gam1*P1_sat
    gam1_exp[i] = y1_exp[i] * P_exp[i] / (x1_exp[i] * P1_sat)
    # (1-y1)*P = (1-x1)*gam2*P2_sat
    gam2_exp[i] = (1 - y1_exp[i]) * P_exp[i] / ((1 - x1_exp[i]) * P2_sat)

print("Экспериментальные коэффициенты активности:")
print("x1\t\tγ1\t\tγ2")
for i in range(5):
    print(f"{x1_exp[i]:.3f}\t\t{gam1_exp[i]:.6f}\t{gam2_exp[i]:.6f}")
print()

# ============ МОДЕЛЬ ВИЛЬСОНА ============
def wilson_activity_coefficients(x1, Lambda12, Lambda21):
    """
    Расчет коэффициентов активности по модели Вильсона
    x1 - мольная доля компонента 1
    Lambda12, Lambda21 - параметры модели Вильсона
    """
    x2 = 1 - x1
    
    # Защита от деления на ноль и логарифма отрицательного числа
    if x1 == 0:
        return 1.0, np.exp(-Lambda21)
    if x1 == 1:
        return np.exp(-Lambda12), 1.0
    
    # Члены, часто используемые в расчетах
    A = x1 + Lambda12 * x2
    B = x2 + Lambda21 * x1
    
    if A <= 0 or B <= 0:
        return 1.0, 1.0  # Возврат к идеальности при проблемах
    
    # Коэффициент активности компонента 1
    ln_gam1 = -np.log(A) + x2 * (Lambda12/A - Lambda21/B)
    
    # Коэффициент активности компонента 2
    ln_gam2 = -np.log(B) - x1 * (Lambda12/A - Lambda21/B)
    
    gam1 = np.exp(ln_gam1)
    gam2 = np.exp(ln_gam2)
    
    return gam1, gam2

# ============ ПОДБОР ПАРАМЕТРОВ МОДЕЛИ ВИЛЬСОНА ============
def objective_function(params, x1, gam1_exp, gam2_exp):
    """
    Целевая функция для минимизации (взвешенная среднеквадратичная ошибка)
    params = [Lambda12, Lambda21]
    """
    Lambda12, Lambda21 = params
    
    error = 0.0
    for i in range(len(x1)):
        try:
            gam1, gam2 = wilson_activity_coefficients(x1[i], Lambda12, Lambda21)
            
            # Проверка на валидные значения
            if np.isnan(gam1) or np.isnan(gam2) or np.isinf(gam1) or np.isinf(gam2) or gam1 < 0 or gam2 < 0:
                return 1e10
            
            # Взвешенная ошибка (относительная ошибка)
            error += ((gam1 - gam1_exp[i])/gam1_exp[i])**2 + ((gam2 - gam2_exp[i])/gam2_exp[i])**2
        except:
            return 1e10
    
    return error

# Пробуем разные начальные приближения с более гибкими ограничениями
best_result = None
best_error = float('inf')

initial_guesses = [
    [0.2, 0.3],
    [0.5, 0.5],
    [1.0, 1.0],
    [0.8, 0.6],
    [1.5, 0.4],
    [0.4, 1.5],
]

# Используем региональное ограничение (региональное ограничение находит глобальный минимум)
from scipy.optimize import differential_evolution

bounds_de = [(0.01, 3.0), (0.01, 3.0)]  # Lambda > 0.01

try:
    result = differential_evolution(objective_function, bounds_de, 
                                args=(x1_exp, gam1_exp, gam2_exp),
                                seed=42, maxiter=1000, atol=1e-8, tol=1e-8) # pyright: ignore[reportCallIssue]
    Lambda12_fit = result.x[0]
    Lambda21_fit = result.x[1]
    best_error = result.fun
    print(f"Подобранные параметры модели Вильсона (дифференциальная эволюция):")
except:
    # Если differential_evolution не работает, используем множественные стартовые точки с L-BFGS-B
    for x0 in initial_guesses:
        bounds = [(0.01, 3.0), (0.01, 3.0)]
        result = minimize(objective_function, x0, args=(x1_exp, gam1_exp, gam2_exp), 
                        method='L-BFGS-B', bounds=bounds, options={'maxiter': 10000})
        
        if result.fun < best_error:
            best_error = result.fun
            best_result = result
    
    Lambda12_fit = best_result.x[0] # type: ignore
    Lambda21_fit = best_result.x[1] # type: ignore
    print(f"Подобранные параметры модели Вильсона (L-BFGS-B):")

print(f"Λ12 = {Lambda12_fit:.6f}")
print(f"Λ21 = {Lambda21_fit:.6f}")
print(f"Взвешенная ошибка оптимизации = {best_error:.6f}")
print()

# Проверка качества подбора
print("Проверка качества подбора параметров:")
print("x1\t\tγ1(exp)\t\tγ1(Wilson)\tγ2(exp)\t\tγ2(Wilson)")
for i in range(5):
    gam1_w, gam2_w = wilson_activity_coefficients(x1_exp[i], Lambda12_fit, Lambda21_fit)
    print(f"{x1_exp[i]:.3f}\t\t{gam1_exp[i]:.6f}\t{gam1_w:.6f}\t{gam2_exp[i]:.6f}\t{gam2_w:.6f}")
print()

# ПОСТРОЕНИЕ ДИАГРАММ
# Создаем массив x1 для построения диаграмм
x1_plot = np.linspace(0, 1, 100)

# Расчет y1 и P для всего диапазона x1
y1_plot = np.zeros(100)
P_plot = np.zeros(100)

for i in range(100):
    if x1_plot[i] == 0 or x1_plot[i] == 1:
        # На границах чистые компоненты
        if x1_plot[i] == 0:
            y1_plot[i] = 0
            P_plot[i] = P2_sat
        else:
            y1_plot[i] = 1
            P_plot[i] = P1_sat
    else:
        # Из уравнения VLE: y1*P = x1*gam1*P1_sat
        gam1, gam2 = wilson_activity_coefficients(x1_plot[i], Lambda12_fit, Lambda21_fit)
        
        # Используем условие равновесия:
        # y1*P = x1*gam1*P1_sat
        # (1-y1)*P = (1-x1)*gam2*P2_sat
        # Суммируя: P = x1*gam1*P1_sat + (1-x1)*gam2*P2_sat
        P_plot[i] = x1_plot[i] * gam1 * P1_sat + (1 - x1_plot[i]) * gam2 * P2_sat
        
        # Из первого уравнения:
        if P_plot[i] > 0:
            y1_plot[i] = x1_plot[i] * gam1 * P1_sat / P_plot[i]
        else:
            y1_plot[i] = x1_plot[i]

# ПОСТРОЕНИЕ ГРАФИКОВ
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# График 1: y-x диаграмма
ax1 = axes[0]
ax1.plot(x1_plot, y1_plot, 'b-', linewidth=2, label='Модель Вильсона')
ax1.plot(x1_plot, x1_plot, 'k--', linewidth=1, alpha=0.5, label='y=x (идеальный раствор)')
ax1.scatter(x1_exp, y1_exp, color='red', s=100, zorder=5, label='Экспериментальные данные')
ax1.set_xlabel('x₁ (мольная доля метилацетата)', fontsize=12)
ax1.set_ylabel('y₁ (мольная доля метилацетата в паре)', fontsize=12)
ax1.set_title('y-x диаграмма (Т = 298.15 К)', fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.legend(fontsize=10)
ax1.set_xlim(0, 1)
ax1.set_ylim(0, 1)

# График 2: P-x-y диаграмма
ax2 = axes[1]
ax2.plot(x1_plot, P_plot * 1e3, 'b-', linewidth=2.5, label='закипание (boiling)', marker='')
ax2.scatter(x1_exp, P_exp * 1e3, color='red', s=100, zorder=5, label='Экспериментальные данные')

# Дополнительно: верхняя кривая (роса)
y1_dew = np.zeros(100)
for i in range(100):
    if y1_plot[i] == 0 or y1_plot[i] == 1:
        if y1_plot[i] == 0:
            y1_dew[i] = 0
        else:
            y1_dew[i] = 1
    else:
        # Найти x1 для данного y1
        gam1, gam2 = wilson_activity_coefficients(x1_plot[i], Lambda12_fit, Lambda21_fit)
        P_calc = x1_plot[i] * gam1 * P1_sat + (1 - x1_plot[i]) * gam2 * P2_sat
        y1_dew[i] = y1_plot[i]

ax2.set_xlabel('x₁, y₁ (мольная доля метилацетата)', fontsize=12)
ax2.set_ylabel('Давление P (кПа)', fontsize=12)
ax2.set_title('P-x-y диаграмма (Т = 298.15 К)', fontsize=13, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.legend(fontsize=10)

plt.tight_layout()
plt.savefig('VLE_diagrams.png', dpi=150, bbox_inches='tight')
print("Графики сохранены в файл 'VLE_diagrams.png'")
plt.show()

print("\n" + "="*70)
print("\n" + "="*70)
print("ИТОГОВЫЕ РЕЗУЛЬТАТЫ И АНАЛИЗ")
print("="*70)

print(f"\nПараметры модели Вильсона:")
print(f"  Λ₁₂ = {Lambda12_fit:.6f}")
print(f"  Λ₂₁ = {Lambda21_fit:.6f}")
print(f"  Взвешенная относительная ошибка = {best_error:.6f}")

print(f"\nДавления насыщения при T = {T} K:")
print(f"  P₁⁰ (Метилацетат) = {P1_sat*1e6/133.322:.2f} мм.рт.ст ({P1_sat*1e3:.4f} кПа)")
print(f"  P₂⁰ (Вода)        = {P2_sat*1e6/133.322:.2f} мм.рт.ст ({P2_sat*1e3:.4f} кПа)")

# АНАЛИЗ КАЧЕСТВА ПОДБОРА
print("\n" + "-"*70)
print("АНАЛИЗ КАЧЕСТВА ПОДБОРА МОДЕЛИ ВИЛЬСОНА")
print("-"*70)

# Расчет среднеквадратичных ошибок для каждого компонента
rmse_gam1 = 0
rmse_gam2 = 0
mae_gam1 = 0
mae_gam2 = 0

print("\nИндивидуальные ошибки:")
print("x1\tγ1(exp)\t\tγ1(calc)\tОшибка γ1\tγ2(exp)\t\tγ2(calc)\tОшибка γ2")

for i in range(5):
    gam1_w, gam2_w = wilson_activity_coefficients(x1_exp[i], Lambda12_fit, Lambda21_fit)
    err_gam1 = abs(gam1_exp[i] - gam1_w) / gam1_exp[i] * 100
    err_gam2 = abs(gam2_exp[i] - gam2_w) / gam2_exp[i] * 100
    
    rmse_gam1 += (gam1_exp[i] - gam1_w)**2
    rmse_gam2 += (gam2_exp[i] - gam2_w)**2
    mae_gam1 += abs(gam1_exp[i] - gam1_w)
    mae_gam2 += abs(gam2_exp[i] - gam2_w)
    
    print(f"{x1_exp[i]:.3f}\t{gam1_exp[i]:.6f}\t{gam1_w:.6f}\t{err_gam1:7.2f}%\t{gam2_exp[i]:.6f}\t{gam2_w:.6f}\t{err_gam2:7.2f}%")

rmse_gam1 = np.sqrt(rmse_gam1 / 5)
rmse_gam2 = np.sqrt(rmse_gam2 / 5)
mae_gam1 = mae_gam1 / 5
mae_gam2 = mae_gam2 / 5

print(f"\nСредняя квадратичная ошибка (RMSE):")
print(f"  RMSE(γ₁) = {rmse_gam1:.6f}")
print(f"  RMSE(γ₂) = {rmse_gam2:.6f}")
print(f"\nСредняя абсолютная ошибка (MAE):")
print(f"  MAE(γ₁) = {mae_gam1:.6f}")
print(f"  MAE(γ₂) = {mae_gam2:.6f}")
