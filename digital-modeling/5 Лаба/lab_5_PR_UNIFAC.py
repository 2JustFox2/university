# -*- coding: utf-8 -*-
#############
# UNIFAC
#############

from thermo import *
from thermo.unifac import DOUFSG, DOUFIP2016
import numpy as np

constants, properties = ChemicalConstantsPackage.from_IDs(
    ['cyclohexane', 'methanol']
)

T = 298.15
P = 1e5
zs = [0.5, 0.5]

# Peng-Robinson для газа
eos_kwargs = dict(
    Tcs=constants.Tcs,
    Pcs=constants.Pcs,
    omegas=constants.omegas
)

gas = CEOSGas(
    PRMIX,
    HeatCapacityGases=properties.HeatCapacityGases,
    eos_kwargs=eos_kwargs
)

# UNIFAC Dortmund для жидкости
GE = UNIFAC.from_subgroups(
    chemgroups=constants.UNIFAC_Dortmund_groups,
    version=1,
    T=T,
    xs=zs,
    interaction_data=DOUFIP2016,
    subgroups=DOUFSG
)

liquid = GibbsExcessLiquid(
    VaporPressures=properties.VaporPressures,
    HeatCapacityGases=properties.HeatCapacityGases,
    VolumeLiquids=properties.VolumeLiquids,
    GibbsExcessModel=GE,
    equilibrium_basis='Psat',
    caloric_basis='Psat',
    T=T,
    P=P,
    zs=zs
)

flasher = FlashVL(constants, properties, liquid=liquid, gas=gas)




# 4 Точка D 
z1 = 0.5
z_D = [z1, 1 - z1]

try:
    # температуры bubble) dew
    T_bubble = flasher.flash(P=P, zs=z_D, VF=0).T
    T_dew = flasher.flash(P=P, zs=z_D, VF=1).T
    
    T_D = (T_bubble + T_dew) / 2
    res = flasher.flash(T=T_D, P=P, zs=z_D)

    print(f"Границы кипения для z=0.5: {T_bubble:.2f} K ... {T_dew:.2f} K")
    print(f"Выбранная точка D: T = {T_D:.2f} K")

    if res.phase_count > 1:
        x1 = res.liquid0.zs[0] if hasattr(res, 'liquid0') else res.liquid.zs[0]
        y1 = res.gas.zs[0]

        V_frac = res.VF
        L_frac = 1 - V_frac

        print(f"Состав жидкости x1: {x1:.4f}")
        print(f"Состав пара     y1: {y1:.4f}")
        print(f"Доля жидкости (L): {L_frac:.4f} ({L_frac*100:.1f}%)")
        print(f"Доля пара     (V): {V_frac:.4f} ({V_frac*100:.1f}%)")
    else:
        print("Точка D все еще вне двухфазной области (проверь модель)")

except Exception as e:
    print(f"Ошибка при расчете точки D: {e}")



#5 Средняя абсолютная ошибка

T_exp = np.array([337.355, 337.306, 336.866, 335.94, 334.678])
x_exp = np.array([0.0001, 0.001, 0.01, 0.03, 0.06])
y_exp = np.array([0.001, 0.003, 0.029, 0.083, 0.154])

abs_err_x = []
abs_err_y = []
valid_points = 0
skipped_points = []
vf_grid = np.linspace(0.05, 0.95, 19)

for i in range(5):

    res = None
    z = None
    vf_used = None

    for vf_try in vf_grid:
        z_try = x_exp[i]*(1 - vf_try) + y_exp[i]*vf_try
        try:
            res_try = flasher.flash(
                T=T_exp[i],
                P=P,
                zs=[z_try, 1-z_try]
            )
        except Exception:
            continue

        if (
            res_try.phase_count > 1
            and hasattr(res_try, 'liquid0') and res_try.liquid0
            and hasattr(res_try, 'gas') and res_try.gas
        ):
            res = res_try
            z = z_try
            vf_used = vf_try
            break

    if res is None:
        skipped_points.append(i)
        z_mid = 0.5*(x_exp[i] + y_exp[i])
        print(
            f"Точка {i+1}: T={T_exp[i]:.3f} K, "
            f"не найдена двухфазная точка по правилу рычага (z~{z_mid:.5f}), пропуск в MAE"
        )
        continue

    if hasattr(res, 'liquid0') and res.liquid0:
        x_calc = res.liquid0.zs[0]
    else:
        skipped_points.append(i)
        print(f"Точка {i+1}: нет жидкой фазы, пропуск в MAE")
        continue

    if hasattr(res, 'gas') and res.gas:
        y_calc = res.gas.zs[0]
    else:
        skipped_points.append(i)
        print(f"Точка {i+1}: нет паровой фазы, пропуск в MAE")
        continue

    err_x = abs(x_calc - x_exp[i])
    err_y = abs(y_calc - y_exp[i])
    abs_err_x.append(err_x)
    abs_err_y.append(err_y)
    valid_points += 1
    print(
        f"Точка {i+1}: T={T_exp[i]:.3f} K, z={z:.5f}, V={vf_used:.2f}, "
        f"x_calc={x_calc:.5f}, y_calc={y_calc:.5f}, "
        f"|dx|={err_x:.5f}, |dy|={err_y:.5f}"
    )

print("\nСредняя абсолютная ошибка (Часть I):")
if valid_points > 0:
    print(f"По x (жидкость): {np.mean(abs_err_x):.6f}")
    print(f"По y (пар):      {np.mean(abs_err_y):.6f}")
    print(f"Использовано точек: {valid_points}, пропущено: {len(skipped_points)}")
else:
    print("Недостаточно двухфазных точек для расчета MAE.")
# 1–3 Диаграммы
_ = flasher.plot_xy(T=T, pts=200)      # y-x
_ = flasher.plot_Pxy(T=T, pts=200)     # P-x
_ = flasher.plot_Txy(P=P, pts=200)     # T-x