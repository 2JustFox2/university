# -*- coding: utf-8 -*-

from matplotlib import pyplot as plt
import numpy as np
from thermo import ChemicalConstantsPackage, CEOSGas, FlashVL, GibbsExcessLiquid, PRMIX, UNIFAC
from thermo.unifac import DOUFSG, DOUFIP2016


COMPONENTS = ["cyclohexane", "methanol"]
T_REF = 298.15
P_REF = 1e5
XS0 = [0.5, 0.5]


def build_flasher() -> tuple[FlashVL, ChemicalConstantsPackage, object]:
    constants, properties = ChemicalConstantsPackage.from_IDs(COMPONENTS)

    gas = CEOSGas(
        PRMIX,
        HeatCapacityGases=properties.HeatCapacityGases,
        eos_kwargs=dict(Tcs=constants.Tcs, Pcs=constants.Pcs, omegas=constants.omegas),
    )

    liquid_model = UNIFAC.from_subgroups(
        chemgroups=constants.UNIFAC_Dortmund_groups,
        version=1,
        T=T_REF,
        xs=XS0,
        interaction_data=DOUFIP2016,
        subgroups=DOUFSG,
    )

    liquid = GibbsExcessLiquid(
        VaporPressures=properties.VaporPressures,
        HeatCapacityGases=properties.HeatCapacityGases,
        VolumeLiquids=properties.VolumeLiquids,
        GibbsExcessModel=liquid_model,
        equilibrium_basis="Psat",
        caloric_basis="Psat",
        T=T_REF,
        P=P_REF,
        zs=XS0,
    )

    return FlashVL(constants, properties, liquid=liquid, gas=gas), constants, properties


def flash_is_two_phase(result) -> bool:
    return (
        result is not None
        and result.phase_count > 1
        and hasattr(result, "liquid0")
        and result.liquid0
        and hasattr(result, "gas")
        and result.gas
    )


def collect_yx_curve(flasher: FlashVL, temperature: float, x_grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    x_values = []
    y_values = []
    for x1 in x_grid:
        try:
            result = flasher.flash(T=temperature, zs=[x1, 1.0 - x1], VF=0)
        except Exception:
            continue
        if flash_is_two_phase(result):
            x_values.append(result.liquid0.zs[0])
            y_values.append(result.gas.zs[0])
    return np.asarray(x_values), np.asarray(y_values)


def collect_Pxy_bubble(flasher: FlashVL, temperature: float, x_grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    x_values = []
    pressures = []
    for x1 in x_grid:
        try:
            result = flasher.flash(T=temperature, zs=[x1, 1.0 - x1], VF=0)
        except Exception:
            continue
        if flash_is_two_phase(result):
            x_values.append(result.liquid0.zs[0])
            pressures.append(result.P)
    return np.asarray(x_values), np.asarray(pressures)


def collect_Pxy_dew(flasher: FlashVL, temperature: float, y_grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    y_values = []
    pressures = []
    for y1 in y_grid:
        try:
            result = flasher.flash(T=temperature, zs=[y1, 1.0 - y1], VF=1)
        except Exception:
            continue
        if flash_is_two_phase(result):
            y_values.append(result.gas.zs[0])
            pressures.append(result.P)
    return np.asarray(y_values), np.asarray(pressures)


def collect_Txy_bubble(flasher: FlashVL, pressure: float, x_grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    x_values = []
    temperatures = []
    for x1 in x_grid:
        try:
            result = flasher.flash(P=pressure, zs=[x1, 1.0 - x1], VF=0)
        except Exception:
            continue
        if flash_is_two_phase(result):
            x_values.append(result.liquid0.zs[0])
            temperatures.append(result.T)
    return np.asarray(x_values), np.asarray(temperatures)


def collect_Txy_dew(flasher: FlashVL, pressure: float, y_grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    y_values = []
    temperatures = []
    for y1 in y_grid:
        try:
            result = flasher.flash(P=pressure, zs=[y1, 1.0 - y1], VF=1)
        except Exception:
            continue
        if flash_is_two_phase(result):
            y_values.append(result.gas.zs[0])
            temperatures.append(result.T)
    return np.asarray(y_values), np.asarray(temperatures)


def annotate_pure_components(ax, left_label: str, right_label: str, left_xy: tuple[float, float], right_xy: tuple[float, float]) -> None:
    ax.scatter([left_xy[0], right_xy[0]], [left_xy[1], right_xy[1]], color="black", s=22, zorder=5)
    ax.annotate(left_label, xy=left_xy, xytext=(left_xy[0] + 0.04, left_xy[1]), fontsize=9)
    ax.annotate(right_label, xy=right_xy, xytext=(right_xy[0] - 0.20, right_xy[1]), fontsize=9, ha="right")


def put_phase_labels_pxy(ax, bubble_x: np.ndarray, bubble_p_bar: np.ndarray, dew_y: np.ndarray, dew_p_bar: np.ndarray) -> None:
    if bubble_x.size < 2 or dew_y.size < 2:
        return
    x_mid = 0.5
    p_bubble = float(np.interp(x_mid, bubble_x, bubble_p_bar))
    p_dew = float(np.interp(x_mid, dew_y, dew_p_bar))
    p_high = max(np.max(bubble_p_bar), np.max(dew_p_bar))
    p_low = min(np.min(bubble_p_bar), np.min(dew_p_bar))
    p_span = max(p_high - p_low, 1e-6)

    p_l = min(p_high - 0.08 * p_span, p_bubble + 0.20 * p_span)
    p_lv = 0.5 * (p_bubble + p_dew)
    p_v = max(p_low + 0.08 * p_span, p_dew - 0.20 * p_span)

    style = dict(boxstyle="round,pad=0.2", facecolor="white", alpha=0.8)
    ax.text(x_mid, p_l, "L", fontsize=12, bbox=style, ha="center")
    ax.text(x_mid, p_lv, "L+V", fontsize=11, bbox=style, ha="center")
    ax.text(x_mid, p_v, "V", fontsize=12, bbox=style, ha="center")


def put_phase_labels_txy(ax, bubble_x: np.ndarray, bubble_t: np.ndarray, dew_y: np.ndarray, dew_t: np.ndarray) -> None:
    if bubble_x.size < 2 or dew_y.size < 2:
        return
    x_mid = 0.5
    t_bubble = float(np.interp(x_mid, bubble_x, bubble_t))
    t_dew = float(np.interp(x_mid, dew_y, dew_t))
    t_high = max(np.max(bubble_t), np.max(dew_t))
    t_low = min(np.min(bubble_t), np.min(dew_t))
    t_span = max(t_high - t_low, 1e-6)

    t_l = max(t_low + 0.08 * t_span, t_bubble - 0.20 * t_span)
    t_lv = 0.5 * (t_bubble + t_dew)
    t_v = min(t_high - 0.08 * t_span, t_dew + 0.20 * t_span)

    style = dict(boxstyle="round,pad=0.2", facecolor="white", alpha=0.8)
    ax.text(x_mid, t_l, "L", fontsize=12, bbox=style, ha="center")
    ax.text(x_mid, t_lv, "L+V", fontsize=11, bbox=style, ha="center")
    ax.text(x_mid, t_v, "V", fontsize=12, bbox=style, ha="center")


def classify_txy(bubble_x: np.ndarray, bubble_t: np.ndarray) -> str:
    if bubble_x.size < 3 or bubble_t.size < 3:
        return "Диаграмма кипения; данных недостаточно для уверенной классификации азеотропа"
    min_idx = int(np.argmin(bubble_t))
    if 0 < min_idx < bubble_t.size - 1:
        return (
            f"Диаграмма кипения с минимумом температуры, "
            f"x_аз = {bubble_x[min_idx]:.3f}, T_аз = {bubble_t[min_idx]:.2f} K"
        )
    return "Диаграмма кипения без внутреннего минимума"


flasher, constants, properties = build_flasher()
component_1 = COMPONENTS[0]
component_2 = COMPONENTS[1]


# 1) y-x diagram at T = 298.15 K
xy_grid = np.linspace(0.0, 1.0, 101)
yx_x, yx_y = collect_yx_curve(flasher, T_REF, xy_grid)

fig_xy, ax_xy = plt.subplots(figsize=(7.5, 6))
ax_xy.plot([0, 1], [0, 1], "k--", linewidth=1, alpha=0.6, label="y = x")
ax_xy.plot(yx_x, yx_y, color="#0B5CAD", linewidth=2.2, label="Равновесная кривая")
ax_xy.scatter([0, 1], [0, 1], color="black", s=18, zorder=5)
annotate_pure_components(
    ax_xy,
    component_2,
    component_1,
    (0.0, 0.0),
    (1.0, 1.0),
)
ax_xy.text(0.05, 0.90, "L+V", transform=ax_xy.transAxes, fontsize=11, bbox=dict(boxstyle="round,pad=0.2", facecolor="white", alpha=0.8))
ax_xy.text(0.78, 0.12, "L / V", transform=ax_xy.transAxes, fontsize=10, bbox=dict(boxstyle="round,pad=0.2", facecolor="white", alpha=0.8))
ax_xy.set_xlabel(f"x1, y1 для {component_1}")
ax_xy.set_ylabel(f"x1, y1 для {component_1}")
ax_xy.set_title(f"y-x диаграмма при T = {T_REF:.2f} K")
ax_xy.set_xlim(0, 1)
ax_xy.set_ylim(0, 1)
ax_xy.grid(True, alpha=0.3)
ax_xy.legend(loc="best")
plt.tight_layout()


# 2) P-x diagram at T = 298.15 K
px_x = np.linspace(0.0, 1.0, 101)
px_bubble_x, px_bubble_p = collect_Pxy_bubble(flasher, T_REF, px_x)
px_dew_y, px_dew_p = collect_Pxy_dew(flasher, T_REF, px_x)

fig_px, ax_px = plt.subplots(figsize=(7.5, 6))
ax_px.plot(px_bubble_x, px_bubble_p / 1e5, color="#1F77B4", linewidth=2.2, label="Кривая кипения")
ax_px.plot(px_dew_y, px_dew_p / 1e5, color="#D62728", linewidth=2.2, label="Кривая конденсации")
put_phase_labels_pxy(ax_px, px_bubble_x, px_bubble_p / 1e5, px_dew_y, px_dew_p / 1e5)
if px_bubble_x.size and px_dew_y.size:
    annotate_pure_components(
        ax_px,
        component_2,
        component_1,
        (px_bubble_x[0], px_bubble_p[0] / 1e5),
        (px_bubble_x[-1], px_bubble_p[-1] / 1e5),
    )
ax_px.set_xlabel(f"Мольная доля {component_1} в жидкости x1 / в паре y1")
ax_px.set_ylabel("P, бар")
ax_px.set_title(f"P-x-y диаграмма при T = {T_REF:.2f} K")
ax_px.set_xlim(0, 1)
ax_px.grid(True, alpha=0.3)
ax_px.legend(loc="best")
plt.tight_layout()


# 3) T-x diagram at P = 1 bar
tx_x = np.linspace(0.0, 1.0, 101)
tx_bubble_x, tx_bubble_t = collect_Txy_bubble(flasher, P_REF, tx_x)
tx_dew_y, tx_dew_t = collect_Txy_dew(flasher, P_REF, tx_x)
diagram_type = classify_txy(tx_bubble_x, tx_bubble_t)

fig_tx, ax_tx = plt.subplots(figsize=(7.5, 6))
ax_tx.plot(tx_bubble_x, tx_bubble_t, color="#1F77B4", linewidth=2.2, label="Кривая кипения")
ax_tx.plot(tx_dew_y, tx_dew_t, color="#D62728", linewidth=2.2, label="Кривая конденсации")
put_phase_labels_txy(ax_tx, tx_bubble_x, tx_bubble_t, tx_dew_y, tx_dew_t)
if tx_bubble_x.size and tx_dew_y.size:
    annotate_pure_components(
        ax_tx,
        component_2,
        component_1,
        (tx_bubble_x[0], tx_bubble_t[0]),
        (tx_bubble_x[-1], tx_bubble_t[-1]),
    )
ax_tx.set_xlabel(f"Мольная доля {component_1} в жидкости x1 / в паре y1")
ax_tx.set_ylabel("T, K")
ax_tx.set_title(f"T-x-y диаграмма при P = {P_REF/1e5:.0f} бар")
ax_tx.text(
    0.02,
    0.02,
    diagram_type,
    transform=ax_tx.transAxes,
    fontsize=9,
    va="bottom",
    bbox=dict(boxstyle="round,pad=0.25", facecolor="white", alpha=0.85),
)
ax_tx.set_xlim(0, 1)
ax_tx.grid(True, alpha=0.3)
ax_tx.legend(loc="best")
plt.tight_layout()


# 4) Point D on T-x diagram from midpoint temperature between bubble and dew
z_D = [0.5, 0.5]
try:
    T_bubble_D = flasher.flash(P=P_REF, zs=z_D, VF=0).T
    T_dew_D = flasher.flash(P=P_REF, zs=z_D, VF=1).T
    T_D = 0.5 * (T_bubble_D + T_dew_D)
    res_D = flasher.flash(T=T_D, P=P_REF, zs=z_D)
    if flash_is_two_phase(res_D):
        x_D = res_D.liquid0.zs[0]
        y_D = res_D.gas.zs[0]
        T_D = res_D.T
        V_frac = res_D.VF
        L_frac = 1.0 - V_frac

        print(f"Точка D для z = 0.5 в середине по температуре:")
        print(f"  T_bubble = {T_bubble_D:.3f} K")
        print(f"  T_dew    = {T_dew_D:.3f} K")
        print(f"  T = {T_D:.3f} K")
        print(f"  x1 = {x_D:.5f}")
        print(f"  y1 = {y_D:.5f}")
        print(f"  L = {L_frac:.4f}")
        print(f"  V = {V_frac:.4f}")

        ax_tx.plot([x_D, 0.5, y_D], [T_D, T_D, T_D], "k--", linewidth=1.2, label="Правило рычага")
        ax_tx.scatter([x_D, 0.5, y_D], [T_D, T_D, T_D], color=["#1F77B4", "#2CA02C", "#D62728"], zorder=6)
        ax_tx.annotate("x", (x_D, T_D), textcoords="offset points", xytext=(-8, 8), fontsize=9)
        ax_tx.annotate("D", (0.5, T_D), textcoords="offset points", xytext=(4, 8), fontsize=9)
        ax_tx.annotate("y", (y_D, T_D), textcoords="offset points", xytext=(4, 8), fontsize=9)
    else:
        print("Точка D не попала в двухфазную область при VF = 0.5")
except Exception as exc:
    print(f"Ошибка расчета точки D: {exc}")


# 5) Mean absolute error against vle-calc.com
T_exp = np.array([337.355, 337.306, 336.866, 335.940, 334.678])
x_exp = np.array([0.0001, 0.0010, 0.0100, 0.0300, 0.0600])
y_exp = np.array([0.0010, 0.0030, 0.0290, 0.0830, 0.1540])

abs_err_x = []
abs_err_y = []

for index, (temperature, x_ref, y_ref) in enumerate(zip(T_exp, x_exp, y_exp), start=1):
    z0 = 0.5 * (x_ref + y_ref)
    try:
        result = flasher.flash(T=temperature, P=P_REF, zs=[z0, 1.0 - z0])
    except Exception as exc:
        print(f"Точка {index}: T={temperature:.3f} K, ошибка flash: {exc}")
        abs_err_x.append(abs(0.0 - x_ref))
        abs_err_y.append(abs(0.0 - y_ref))
        continue

    if flash_is_two_phase(result):
        x_calc = result.liquid0.zs[0]
        y_calc = result.gas.zs[0]
    elif hasattr(result, "gas") and result.gas:
        x_calc = 0.0
        y_calc = result.gas.zs[0]
    elif hasattr(result, "liquid0") and result.liquid0:
        x_calc = result.liquid0.zs[0]
        y_calc = 0.0
    else:
        x_calc = 0.0
        y_calc = 0.0

    err_x = abs(x_calc - x_ref)
    err_y = abs(y_calc - y_ref)
    abs_err_x.append(err_x)
    abs_err_y.append(err_y)

    phase_state = "2 фазы" if flash_is_two_phase(result) else "1 фаза"
    print(
        f"Точка {index}: T={temperature:.3f} K, z={z0:.5f}, {phase_state}, "
        f"x_calc={x_calc:.5f}, y_calc={y_calc:.5f}, |dx|={err_x:.5f}, |dy|={err_y:.5f}"
    )

print("\nСредняя абсолютная ошибка:")
print(f"По x (жидкость): {np.mean(abs_err_x):.6f}")
print(f"По y (пар):      {np.mean(abs_err_y):.6f}")


print("\nИтог по диаграммам:")
print(f"1) y-x диаграмма построена для {component_1} при T = {T_REF:.2f} K.")
print(f"2) P-x диаграмма построена при T = {T_REF:.2f} K.")
print(f"3) T-x диаграмма построена при P = {P_REF/1e5:.0f} бар.")
print(f"   {diagram_type}.")
print("4) Точка D рассчитана в двухфазной области для z = 50:50 в середине по температуре между bubble и dew.")
print("5) MAE посчитана по пяти точкам с учётом однофазных результатов как нулевой второй фазы.")

plt.show()