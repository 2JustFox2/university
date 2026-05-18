import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
from scipy.optimize import fsolve

# Данные задачи
# Реакция: C8H18 --k1--> i-C8H18 --k2--> C4H10 + C4H8
# Обозначим:
# A = C8H18 (н-октан)
# B = i-C8H18 (изооктан)
# C = C4H10 (бутан)
# D = C4H8 (бутен)

# Константы скоростей при температуре 620 K
k1 = 0.12   # с⁻¹ для реакции A -> B
k2 = 0.80   # с⁻¹ для реакции B -> C + D

# Энергии активации (кДж/моль)
E1 = 94.2   # для реакции A -> B
E2 = 81.2   # для реакции B -> C + D

R_gas = 8.314  # Дж/(моль·К) - универсальная газовая постоянная

# Температура
T = 620  # K

# Параметры реактора
V = 1.0  # объем реактора, м³
tau = 100  # время пребывания, с
Q = V / tau  # объемный расход, м³/с

# Начальная концентрация A на входе
C_A0_in = 0.0328  # моль/м³

# Система дифференциальных уравнений для реактора идеального смешения (CSTR)
def cstr_equations(y, t, k1, k2, Q, V, C_A_in):
    """
    y = [C_A, C_B, C_C, C_D] - концентрации в реакторе
    Возвращает dC/dt
    """
    C_A, C_B, C_C, C_D = y
    
    # Концентрация на входе
    C_A_in = C_A0_in
    C_B_in = 0
    C_C_in = 0
    C_D_in = 0
    
    # Скорости реакций
    r1 = k1 * C_A          # скорость реакции A -> B
    r2 = k2 * C_B          # скорость реакции B -> C + D
    
    # Материальные балансы для CSTR
    dC_A_dt = (Q/V) * (C_A_in - C_A) - r1
    dC_B_dt = (Q/V) * (C_B_in - C_B) + r1 - r2
    dC_C_dt = (Q/V) * (C_C_in - C_C) + r2
    dC_D_dt = (Q/V) * (C_D_in - C_D) + r2
    
    return [dC_A_dt, dC_B_dt, dC_C_dt, dC_D_dt]

# Функция для нахождения стационарного состояния (решение системы алгебраических уравнений)
def steady_state(y, k1, k2, Q, V, C_A_in):
    """Система уравнений для стационарного состояния"""
    C_A, C_B, C_C, C_D = y
    
    C_A_in = C_A0_in
    C_B_in = 0
    C_C_in = 0
    C_D_in = 0
    
    r1 = k1 * C_A
    r2 = k2 * C_B
    
    eq1 = (Q/V) * (C_A_in - C_A) - r1
    eq2 = (Q/V) * (C_B_in - C_B) + r1 - r2
    eq3 = (Q/V) * (C_C_in - C_C) + r2
    eq4 = (Q/V) * (C_D_in - C_D) + r2
    
    return [eq1, eq2, eq3, eq4]

# Время интегрирования до достижения стационарного состояния
t_max = 500  # максимальное время, с
t = np.linspace(0, t_max, 1000)

# Начальные условия: в начале в реакторе чистые компоненты
y0 = [0, 0, 0, 0]  # начальные концентрации в реакторе

# Решение системы ОДУ
print("Интегрирование системы дифференциальных уравнений...")
solution = odeint(cstr_equations, y0, t, args=(k1, k2, Q, V, C_A0_in))

# Извлечение концентраций
C_A = solution[:, 0]
C_B = solution[:, 1]
C_C = solution[:, 2]
C_D = solution[:, 3]

# Поиск стационарного состояния
print("Поиск стационарного состояния...")
y_guess = [C_A[-1], C_B[-1], C_C[-1], C_D[-1]]  # начальное приближение - последние значения
steady_state_solution = fsolve(steady_state, y_guess, args=(k1, k2, Q, V, C_A0_in))

C_A_ss, C_B_ss, C_C_ss, C_D_ss = steady_state_solution

# Определение времени достижения стационарного состояния (когда изменение < 1%)
tolerance = 0.01  # 1% от стационарного значения
t_steady_state = t_max

# Исправленная часть: проверяем сначала, что стационарные концентрации определены и не равны нулю
for i in range(len(t)):
    # Проверяем условие только для положительных стационарных концентраций
    condition_A = abs(C_A[i] - C_A_ss) / C_A_ss < tolerance if C_A_ss > 0 else True
    condition_B = abs(C_B[i] - C_B_ss) / C_B_ss < tolerance if C_B_ss > 0 else True # type: ignore
    condition_C = abs(C_C[i] - C_C_ss) / C_C_ss < tolerance if C_C_ss > 0 else True
    condition_D = abs(C_D[i] - C_D_ss) / C_D_ss < tolerance if C_D_ss > 0 else True
    
    if condition_A and condition_B and condition_C and condition_D:
        t_steady_state = t[i]
        break

# Вывод результатов
print("\n" + "="*70)
print("РЕЗУЛЬТАТЫ МОДЕЛИРОВАНИЯ РЕАКТОРА ИДЕАЛЬНОГО СМЕШЕНИЯ (CSTR)")
print("="*70)
print(f"\nПараметры реактора:")
print(f"  Объем реактора V = {V} м³")
print(f"  Расход Q = {Q:.4f} м³/с")
print(f"  Время пребывания τ = {tau} с")
print(f"  Температура T = {T} K")
print(f"\nКинетические параметры:")
print(f"  k1 = {k1:.4f} с⁻¹ (C8H18 -> i-C8H18)")
print(f"  k2 = {k2:.4f} с⁻¹ (i-C8H18 -> C4H10 + C4H8)")
print(f"\nСтационарные концентрации:")
print(f"  C_A (C8H18)  = {C_A_ss:.6f} моль/м³")
print(f"  C_B (i-C8H18)= {C_B_ss:.6f} моль/м³")
print(f"  C_C (C4H10)  = {C_C_ss:.6f} моль/м³")
print(f"  C_D (C4H8)   = {C_D_ss:.6f} моль/м³")
print(f"\nВремя достижения стационарного состояния: ~{t_steady_state:.1f} с")
if C_A0_in > 0:
    print(f"Конверсия A в стационарном состоянии: {(C_A0_in - C_A_ss)/C_A0_in*100:.2f}%")
print("="*70)

# Визуализация
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Кинетика реакции в реакторе идеального смешения (CSTR)', fontsize=16)

# График 1: Концентрации всех компонентов
ax1 = axes[0, 0]
ax1.plot(t, C_A, 'b-', linewidth=2, label='C8H18 (A)')
ax1.plot(t, C_B, 'r-', linewidth=2, label='i-C8H18 (B)')
ax1.plot(t, C_C, 'g-', linewidth=2, label='C4H10 (C)')
ax1.plot(t, C_D, 'm-', linewidth=2, label='C4H8 (D)')
ax1.axhline(y=C_A_ss, color='b', linestyle='--', alpha=0.5, label=f'C_A стац. = {C_A_ss:.4f}')
ax1.axhline(y=C_B_ss, color='r', linestyle='--', alpha=0.5, label=f'C_B стац. = {C_B_ss:.4f}')
ax1.set_xlabel('Время, с', fontsize=12)
ax1.set_ylabel('Концентрация, моль/м³', fontsize=12)
ax1.set_title('Изменение концентраций компонентов', fontsize=14)
ax1.legend(loc='best', fontsize=10)
ax1.grid(True, alpha=0.3)

# График 2: Увеличенный вид для малых концентраций (логарифмический)
ax2 = axes[0, 1]
# Добавляем небольшое смещение для избежания log(0)
eps = 1e-10
ax2.semilogy(t, C_A + eps, 'b-', linewidth=2, label='C8H18')
ax2.semilogy(t, C_B + eps, 'r-', linewidth=2, label='i-C8H18')
ax2.semilogy(t, C_C + eps, 'g-', linewidth=2, label='C4H10')
ax2.semilogy(t, C_D + eps, 'm-', linewidth=2, label='C4H8')
ax2.set_xlabel('Время, с', fontsize=12)
ax2.set_ylabel('Концентрация (логарифм), моль/м³', fontsize=12)
ax2.set_title('Изменение концентраций (логарифмический масштаб)', fontsize=14)
ax2.legend(loc='best', fontsize=10)
ax2.grid(True, alpha=0.3)

# График 3: Относительные концентрации (нормированные на входную)
ax3 = axes[1, 0]
if C_A0_in > 0:
    ax3.plot(t, C_A/C_A0_in, 'b-', linewidth=2, label='C8H18/C0')
    ax3.plot(t, C_B/C_A0_in, 'r-', linewidth=2, label='i-C8H18/C0')
    ax3.plot(t, C_C/C_A0_in, 'g-', linewidth=2, label='C4H10/C0')
    ax3.plot(t, C_D/C_A0_in, 'm-', linewidth=2, label='C4H8/C0')
else:
    ax3.plot(t, C_A, 'b-', linewidth=2, label='C8H18')
    ax3.plot(t, C_B, 'r-', linewidth=2, label='i-C8H18')
    ax3.plot(t, C_C, 'g-', linewidth=2, label='C4H10')
    ax3.plot(t, C_D, 'm-', linewidth=2, label='C4H8')
ax3.set_xlabel('Время, с', fontsize=12)
ax3.set_ylabel('Относительная концентрация (C/C0)', fontsize=12)
ax3.set_title('Нормированные концентрации', fontsize=14)
ax3.legend(loc='best', fontsize=10)
ax3.grid(True, alpha=0.3)

# График 4: Селективность и конверсия
ax4 = axes[1, 1]
if C_A0_in > 0:
    conversion = (C_A0_in - C_A) / C_A0_in * 100
    # Избегаем деления на ноль
    denominator = (C_A0_in - C_A)
    denominator[denominator < 1e-10] = 1e-10
    selectivity_to_C = C_C / denominator * 100
    yield_of_C = C_C / C_A0_in * 100
    
    ax4.plot(t, conversion, 'b-', linewidth=2, label='Конверсия A, %')
    ax4.plot(t, selectivity_to_C, 'g-', linewidth=2, label='Селективность по C4H10, %')
    ax4.plot(t, yield_of_C, 'r-', linewidth=2, label='Выход C4H10, %')
    ax4.set_ylabel('Проценты, %', fontsize=12)
    ax4.legend(loc='best', fontsize=10)
else:
    ax4.text(0.5, 0.5, 'Невозможно рассчитать\nконверсию (C_A0_in = 0)', 
             ha='center', va='center', transform=ax4.transAxes)
ax4.set_xlabel('Время, с', fontsize=12)
ax4.set_title('Конверсия, селективность и выход', fontsize=14)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# Дополнительный анализ: влияние времени пребывания
print("\n" + "="*70)
print("АНАЛИЗ ВЛИЯНИЯ ВРЕМЕНИ ПРЕБЫВАНИЯ НА СТАЦИОНАРНЫЕ КОНЦЕНТРАЦИИ")
print("="*70)

tau_values = np.linspace(1, 200, 50)
C_A_ss_tau = []
C_B_ss_tau = []
C_C_ss_tau = []
C_D_ss_tau = []

for tau_val in tau_values:
    Q_val = V / tau_val
    # Решение стационарного состояния для каждого tau
    try:
        # Начальное приближение: предполагаем, что концентрации положительные
        initial_guess = [C_A0_in/2, C_A0_in/2, C_A0_in/4, C_A0_in/4]
        ss = fsolve(steady_state, initial_guess, args=(k1, k2, Q_val, V, C_A0_in))
        # Проверяем, что концентрации неотрицательные
        ss = np.maximum(ss, 0) # type: ignore
        C_A_ss_tau.append(ss[0])
        C_B_ss_tau.append(ss[1])
        C_C_ss_tau.append(ss[2])
        C_D_ss_tau.append(ss[3])
    except Exception as e:
        print(f"Предупреждение: не удалось найти решение для τ = {tau_val:.1f} с")
        C_A_ss_tau.append(np.nan)
        C_B_ss_tau.append(np.nan)
        C_C_ss_tau.append(np.nan)
        C_D_ss_tau.append(np.nan)

# График влияния времени пребывания
fig2, ax = plt.subplots(figsize=(10, 6))
# Убираем точки с nan для корректного построения
mask = ~np.isnan(C_A_ss_tau)
if np.any(mask):
    ax.plot(tau_values[mask], np.array(C_A_ss_tau)[mask], 'b-', linewidth=2, label='C8H18')
    ax.plot(tau_values[mask], np.array(C_B_ss_tau)[mask], 'r-', linewidth=2, label='i-C8H18')
    ax.plot(tau_values[mask], np.array(C_C_ss_tau)[mask], 'g-', linewidth=2, label='C4H10')
    ax.plot(tau_values[mask], np.array(C_D_ss_tau)[mask], 'm-', linewidth=2, label='C4H8')
    ax.axvline(x=tau, color='k', linestyle='--', alpha=0.5, label=f'τ = {tau} с (исходный)')
else:
    ax.text(0.5, 0.5, 'Не удалось рассчитать\nзависимость от τ', 
            ha='center', va='center', transform=ax.transAxes)
ax.set_xlabel('Время пребывания τ, с', fontsize=12)
ax.set_ylabel('Стационарная концентрация, моль/м³', fontsize=12)
ax.set_title('Влияние времени пребывания на стационарные концентрации', fontsize=14)
ax.legend(loc='best', fontsize=10)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

print("\nПрограмма завершена успешно!")

# Дополнительная информация о достижении стационарного состояния
print("\n")
print("ДОПОЛНИТЕЛЬНАЯ ИНФОРМАЦИЯ О КИНЕТИКЕ")
print(f"Максимальная концентрация промежуточного продукта B: {np.max(C_B):.6f} моль/м³")
print(f"Время достижения максимума B: {t[np.argmax(C_B)]:.1f} с")
print(f"Конечная концентрация C4H10: {C_C[-1]:.6f} моль/м³")
print(f"Конечная концентрация C4H8: {C_D[-1]:.6f} моль/м³")