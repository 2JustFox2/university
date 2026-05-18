import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# Исходные данные
T = 835  # K
t = np.array([0, 80, 160, 240, 420, 500, 600])  # s
p_total = np.array([43.2, 53.0, 61.6, 69.3, 83.6, 88.8, 94.5])  # kPa
t1 = 500  # s

# Определение стехиометрического коэффициента m
# Исходим из того, что при t → ∞ давление стремится к m*P0
P0 = p_total[0]
m_candidates = [2, 3, 4]

for m in m_candidates:
    pA_final = (m * P0 - p_total[-1]) / (m - 1) if m != 1 else p_total[-1] - p_total[-1]
    if pA_final >= 0:
        m_final = m
        break

print(f"Стехиометрический коэффициент m = {m_final}")

# Расчёт парциального давления реагента A
pA = (m_final * P0 - p_total) / (m_final - 1)

# Пересчёт давления в концентрацию (моль/л)
R = 8.314  # Дж/(моль·К)
RT_kPa_L_mol = R * T / 1000  # кПа·л/моль
C_A = pA / RT_kPa_L_mol

print("\nПарциальное давление A в разные моменты времени:")
print("t, с\tp_total, кПа\tpA, кПа\tC_A, моль/л")
for i in range(len(t)):
    print(f"{t[i]}\t\t{p_total[i]:.1f}\t\t\t{pA[i]:.2f}\t{C_A[i]:.3f}")

# Проверка кинетических моделей
ln_pA = np.log(pA)
inv_pA = 1 / pA

# Линейная регрессия для 1-го порядка
slope1, intercept1, r1, _, _ = stats.linregress(t, ln_pA)

# Линейная регрессия для 2-го порядка
slope2, intercept2, r2, _, _ = stats.linregress(t, inv_pA)

# Выбор порядка реакции по коэффициенту корреляции
if abs(r1) > abs(r2): # pyright: ignore[reportArgumentType]
    order = 1
    k = -slope1  # pyright: ignore[reportOperatorIssue] # для 1-го порядка k = -slope
    print(f"\nПорядок реакции: 1 (R^2 = {r1**2:.4f})") # pyright: ignore[reportOperatorIssue]
    print(f"Константа скорости k = {k:.4e} с⁻¹")
    # Время полупревращения для 1-го порядка
    t_half = np.log(2) / k
else:
    order = 2
    k = slope2  # для 2-го порядка k = slope
    print(f"\nПорядок реакции: 2 (R^2 = {r2**2:.4f})") # pyright: ignore[reportOperatorIssue]
    print(f"Константа скорости k = {k:.4e} кПа⁻¹·с⁻¹")
    # Время полупревращения для 2-го порядка
    t_half = 1 / (k * P0)

print(f"Время полупревращения t1/2 = {t_half:.1f} с")

# Расчёт концентрации и степени превращения в момент t1
if t1 in t:
    idx = np.where(t == t1)[0][0]
    pA_t1 = pA[idx]
else:
    # Интерполяция, если t1 нет в массиве
    pA_t1 = np.interp(t1, t, pA)

alpha_t1 = (P0 - pA_t1) / P0

print(f"\nВ момент времени t1 = {t1} с:")
print(f"Парциальное давление A: {pA_t1:.2f} кПа")
print(f"Степень превращения a = {alpha_t1:.4f} ({alpha_t1*100:.2f}%)")

# Расчёт концентрации в моль/л
C0 = P0 / RT_kPa_L_mol
C_t1 = pA_t1 / RT_kPa_L_mol

print(f"Начальная концентрация C0 = {C0:.3f} моль/л")
print(f"Концентрация в момент t1 = {C_t1:.3f} моль/л")

# Построение графиков
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# 1. Кинетическая кривая: C_A(t)
axes[0, 0].plot(t, C_A, 'bo-', linewidth=2, markersize=8)
axes[0, 0].set_xlabel('Время, с', fontsize=12)
axes[0, 0].set_ylabel('Концентрация A, моль/л', fontsize=12)
axes[0, 0].set_title('Кинетическая кривая C_A(t)', fontsize=14)
axes[0, 0].grid(True, alpha=0.3)
axes[0, 0].axhline(y=C0, color='gray', linestyle='--', alpha=0.5, label=f'C0 = {C0:.3f} моль/л')
axes[0, 0].legend()

# 2. Проверка 1-го порядка: ln(pA) vs t
axes[0, 1].plot(t, ln_pA, 'ro-', linewidth=2, markersize=8)
axes[0, 1].plot(t, intercept1 + slope1 * t, 'b--', alpha=0.7, 
                label=f'Линейная регрессия: R² = {r1**2:.4f}') # pyright: ignore[reportOperatorIssue]
axes[0, 1].set_xlabel('Время, с', fontsize=12)
axes[0, 1].set_ylabel('ln(pA)', fontsize=12)
axes[0, 1].set_title('Проверка 1-го порядка реакции', fontsize=14)
axes[0, 1].grid(True, alpha=0.3)
axes[0, 1].legend()

# 3. Проверка 2-го порядка: 1/pA vs t
axes[1, 0].plot(t, inv_pA, 'go-', linewidth=2, markersize=8)
axes[1, 0].plot(t, intercept2 + slope2 * t, 'b--', alpha=0.7,
                label=f'Линейная регрессия: R^2 = {r2**2:.4f}') # type: ignore
axes[1, 0].set_xlabel('Время, с', fontsize=12)
axes[1, 0].set_ylabel('1/pA, кПа^(-1)', fontsize=12)
axes[1, 0].set_title('Проверка 2-го порядка реакции', fontsize=14)
axes[1, 0].grid(True, alpha=0.3)
axes[1, 0].legend()

# 4. Общее давление и степень превращения
alpha_all = (P0 - pA) / P0
axes[1, 1].plot(t, p_total, 'purple', 'o-', linewidth=2, markersize=8, label='Общее давление')
axes[1, 1].plot(t, alpha_all * 100, 'orange', 's-', linewidth=2, markersize=8, label='Степень превращения, %')
axes[1, 1].set_xlabel('Время, с', fontsize=12)
axes[1, 1].set_ylabel('Давление (кПа) / Степень превращения (%)', fontsize=12)
axes[1, 1].set_title('Изменение общего давления и степени превращения', fontsize=14)
axes[1, 1].grid(True, alpha=0.3)
axes[1, 1].legend()

plt.tight_layout()
plt.show()

# Дополнительный вывод результатов регрессии
print("\n")
print("РЕЗУЛЬТАТЫ РЕГРЕССИОННОГО АНАЛИЗА:")
print(f"Для 1-го порядка: ln(pA) = {intercept1:.4f} + ({slope1:.4f})·t")
print(f"Коэффициент корреляции R = {r1:.6f}, R^2 = {r1**2:.6f}") # pyright: ignore[reportOperatorIssue]
print(f"\nДля 2-го порядка: 1/pA = {intercept2:.4f} + ({slope2:.4f})·t")
print(f"Коэффициент корреляции R = {r2:.6f}, R^2 = {r2**2:.6f}") # pyright: ignore[reportOperatorIssue]

if order == 2:
    print("\nВывод: реакция имеет ВТОРОЙ порядок (лучшая линейность 1/pA от t)")
else:
    print("\nВывод: реакция имеет ПЕРВЫЙ порядок (лучшая линейность ln(pA) от t)")