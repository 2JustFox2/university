# -*- coding: utf-8 -*-

from matplotlib import pyplot as plt
import numpy as np
from thermo import CEOSGas, CEOSLiquid, ChemicalConstantsPackage, FlashVL, PRMIX
from typing import Optional, Any

COMPONENTS = ["cyclohexane", "methanol"]
T_REF = 298.15
P_REF = 1e5
ZS_REF = [0.5, 0.5]

# Калибруемый параметр для PR (лист BIPJ...xlsx).
KIJ_USER = 0.0347

# Если True, скрипт подберет kij по заданным 11 точкам перебором.
FIT_KIJ = False
KIJ_GRID = np.linspace(-0.10, 0.20, 601)

# 11 экспериментальных точек T-x1-y1 при 1 бар.
# При необходимости замените на ваши 11 точек с vle-calc.com.
EXP_DATA_11 = [
    (337.355, 0.0001, 0.0010),
    (337.306, 0.0010, 0.0030),
    (337.100, 0.0050, 0.0150),
    (336.866, 0.0100, 0.0290),
    (336.450, 0.0200, 0.0550),
    (335.940, 0.0300, 0.0830),
    (335.350, 0.0450, 0.1180),
    (334.678, 0.0600, 0.1540),
    (333.900, 0.0800, 0.1950),
    (333.211, 0.1000, 0.2340),
    (330.435, 0.2000, 0.3800),
]


def build_flasher(kij_value: float) -> FlashVL:
    constants, properties = ChemicalConstantsPackage.from_IDs(COMPONENTS)

    kijs = [[0.0, kij_value], [kij_value, 0.0]]
    eos_kwargs = dict(
        Tcs=constants.Tcs,
        Pcs=constants.Pcs,
        omegas=constants.omegas,
        kijs=kijs,
    )

    gas = CEOSGas(
        PRMIX,
        eos_kwargs=eos_kwargs,
        HeatCapacityGases=properties.HeatCapacityGases,
        T=T_REF,
        P=P_REF,
        zs=ZS_REF,
    )

    liquid = CEOSLiquid(
        PRMIX,
        eos_kwargs=eos_kwargs,
        HeatCapacityGases=properties.HeatCapacityGases,
        T=T_REF,
        P=P_REF,
        zs=ZS_REF,
    )

    return FlashVL(constants, properties, liquid=liquid, gas=gas)


def get_liquid_phase(result) -> Optional[Any]:
    # Пример: в thermo жидкая фаза может быть в liquid0
    return getattr(result, "liquid0", None)


def get_vapor_phase(result) -> Optional[Any]:
    return getattr(result, "gas", None)


def get_x1_from_liquid(result) -> Optional[float]:
    liquid = get_liquid_phase(result)
    if liquid is None:
        return None
    zs = getattr(liquid, "zs", None)
    if zs is None or len(zs) == 0:
        return None
    return float(zs[0])


def get_y1_from_vapor(result) -> Optional[float]:
    vapor = get_vapor_phase(result)
    if vapor is None:
        return None
    zs = getattr(vapor, "zs", None)
    if zs is None or len(zs) == 0:
        return None
    return float(zs[0])


def flash_is_two_phase(result) -> bool:
    liquid_phase = get_liquid_phase(result)
    return result is not None and result.phase_count > 1 and liquid_phase is not None and hasattr(result, "gas") and result.gas


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


def collect_yx_curve(flasher: FlashVL, temperature: float, grid: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    x_vals = []
    y_vals = []
    for x1 in grid:
        try:
            res = flasher.flash(T=temperature, zs=[x1, 1.0 - x1], VF=0)
        except Exception:
            continue
        if flash_is_two_phase(res):
            x1_liq = get_x1_from_liquid(res)
            y1_vap = get_y1_from_vapor(res)
            if x1_liq is not None and y1_vap is not None:
                x_vals.append(x1_liq)
                y_vals.append(y1_vap)
    return np.asarray(x_vals), np.asarray(y_vals)


def collect_pxy_curves(flasher: FlashVL, temperature: float, grid: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    x_bub = []
    p_bub = []
    y_dew = []
    p_dew = []

    for z1 in grid:
        try:
            r_bub = flasher.flash(T=temperature, zs=[z1, 1.0 - z1], VF=0)
            if flash_is_two_phase(r_bub):
                x1_liq = get_x1_from_liquid(r_bub)
                if x1_liq is not None:
                    x_bub.append(x1_liq)
                    p_bub.append(r_bub.P)
        except Exception:
            pass

        try:
            r_dew = flasher.flash(T=temperature, zs=[z1, 1.0 - z1], VF=1)
            if flash_is_two_phase(r_dew):
                y1_vap = get_y1_from_vapor(r_dew)
                if y1_vap is not None:
                    y_dew.append(y1_vap)
                    p_dew.append(r_dew.P)
        except Exception:
            pass

    return np.asarray(x_bub), np.asarray(p_bub), np.asarray(y_dew), np.asarray(p_dew)


def collect_txy_curves(flasher: FlashVL, pressure: float, grid: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    x_bub = []
    t_bub = []
    y_dew = []
    t_dew = []

    for z1 in grid:
        try:
            r_bub = flasher.flash(P=pressure, zs=[z1, 1.0 - z1], VF=0)
            if flash_is_two_phase(r_bub):
                x1_liq = get_x1_from_liquid(r_bub)
                if x1_liq is not None:
                    x_bub.append(x1_liq)
                    t_bub.append(r_bub.T)
        except Exception:
            pass

        try:
            r_dew = flasher.flash(P=pressure, zs=[z1, 1.0 - z1], VF=1)
            if flash_is_two_phase(r_dew):
                y1_vap = get_y1_from_vapor(r_dew)
                if y1_vap is not None:
                    y_dew.append(y1_vap)
                    t_dew.append(r_dew.T)
        except Exception:
            pass

    return np.asarray(x_bub), np.asarray(t_bub), np.asarray(y_dew), np.asarray(t_dew)


def classify_txy(bubble_x: np.ndarray, bubble_t: np.ndarray) -> str:
    if bubble_x.size < 3:
        return "Диаграмма кипения; данных недостаточно для классификации"
    idx = int(np.argmin(bubble_t))
    if 0 < idx < bubble_t.size - 1:
        return (
            "Диаграмма кипения с минимумом температуры "
            f", x_аз={bubble_x[idx]:.3f}, T_аз={bubble_t[idx]:.2f} K"
        )
    return "Диаграмма кипения без внутреннего минимума"


def evaluate_point(flasher: FlashVL, t_exp: float, x_exp: float, y_exp: float) -> dict:
    z0 = 0.5 * (x_exp + y_exp)
    result = flasher.flash(T=t_exp, P=P_REF, zs=[z0, 1.0 - z0])
    x1_liq = get_x1_from_liquid(result)
    y1_vap = get_y1_from_vapor(result)

    if flash_is_two_phase(result):
        x_calc = x1_liq if x1_liq is not None else 0.0
        y_calc = y1_vap if y1_vap is not None else 0.0
        phase_state = "2 фазы"
    elif y1_vap is not None:
        x_calc = 0.0
        y_calc = y1_vap
        phase_state = "1 фаза (газ)"
    elif x1_liq is not None:
        x_calc = x1_liq
        y_calc = 0.0
        phase_state = "1 фаза (жидкость)"
    else:
        x_calc = 0.0
        y_calc = 0.0
        phase_state = "неопределено"

    err_x = abs(x_calc - x_exp)
    err_y = abs(y_calc - y_exp)
    return {
        "z": z0,
        "phase_state": phase_state,
        "x_calc": x_calc,
        "y_calc": y_calc,
        "err_x": err_x,
        "err_y": err_y,
    }


def compute_mae_for_dataset(kij_value: float, data: list[tuple[float, float, float]]) -> tuple[float, float]:
    flasher = build_flasher(kij_value)
    errs_x = []
    errs_y = []
    for t_exp, x_exp, y_exp in data:
        try:
            point = evaluate_point(flasher, t_exp, x_exp, y_exp)
            errs_x.append(point["err_x"])
            errs_y.append(point["err_y"])
        except Exception:
            errs_x.append(abs(x_exp))
            errs_y.append(abs(y_exp))
    return float(np.mean(errs_x)), float(np.mean(errs_y))


def fit_kij(data: list[tuple[float, float, float]]) -> tuple[float, float, float]:
    best_kij: float = KIJ_USER
    best_mae_x: float = float("inf")
    best_mae_y: float = float("inf")
    best_score: float = float("inf")
    found: bool = False

    for kij in KIJ_GRID:
        mae_x, mae_y = compute_mae_for_dataset(float(kij), data)
        score = mae_x + mae_y
        if score < best_score:
            best_score = score
            best_kij = float(kij)
            best_mae_x = float(mae_x)
            best_mae_y = float(mae_y)
            found = True

    if not found:
        raise RuntimeError("fit_kij: не удалось получить валидные двухфазные точки для подбора kij")

    return best_kij, best_mae_x, best_mae_y


def run_workflow(kij_value: float, data: list[tuple[float, float, float]]) -> None:
    flasher = build_flasher(kij_value)
    component_1 = COMPONENTS[0]
    component_2 = COMPONENTS[1]

    print(f"Используемый kij = {kij_value:.6f}")

    # 1) y-x диаграмма
    grid = np.linspace(0.0, 1.0, 101)
    x_y, y_y = collect_yx_curve(flasher, T_REF, grid)

    fig_xy, ax_xy = plt.subplots(figsize=(7.4, 5.6))
    ax_xy.plot([0, 1], [0, 1], "k--", linewidth=1.0, alpha=0.6, label="y = x")
    ax_xy.plot(x_y, y_y, color="#0B5CAD", linewidth=2.2, label="Равновесная кривая")
    ax_xy.scatter([0.0, 1.0], [0.0, 1.0], color="black", s=18, zorder=5)
    ax_xy.annotate(component_2, (0.0, 0.0), textcoords="offset points", xytext=(6, 5), fontsize=9)
    ax_xy.annotate(component_1, (1.0, 1.0), textcoords="offset points", xytext=(-6, -12), ha="right", fontsize=9)
    ax_xy.set_xlabel(f"x1 ({component_1})")
    ax_xy.set_ylabel(f"y1 ({component_1})")
    ax_xy.set_title(f"1) y-x диаграмма при T = {T_REF:.2f} K")
    ax_xy.set_xlim(0, 1)
    ax_xy.set_ylim(0, 1)
    ax_xy.grid(True, alpha=0.3)
    ax_xy.legend(loc="best")
    plt.tight_layout()

    # 2) P-x-y диаграмма
    x_bub, p_bub, y_dew, p_dew = collect_pxy_curves(flasher, T_REF, grid)

    fig_px, ax_px = plt.subplots(figsize=(7.4, 5.6))
    ax_px.plot(x_bub, p_bub / 1e5, color="#1F77B4", linewidth=2.2, label="Кривая кипения")
    ax_px.plot(y_dew, p_dew / 1e5, color="#D62728", linewidth=2.2, label="Кривая конденсации")
    put_phase_labels_pxy(ax_px, x_bub, p_bub / 1e5, y_dew, p_dew / 1e5)
    ax_px.scatter([0.0, 1.0], [p_bub[0] / 1e5, p_bub[-1] / 1e5], color="black", s=20, zorder=5)
    ax_px.annotate(component_2, (0.0, p_bub[0] / 1e5), textcoords="offset points", xytext=(6, 5), fontsize=9)
    ax_px.annotate(component_1, (1.0, p_bub[-1] / 1e5), textcoords="offset points", xytext=(-6, -12), ha="right", fontsize=9)
    ax_px.set_xlabel(f"x1/y1 ({component_1})")
    ax_px.set_ylabel("P, бар")
    ax_px.set_title(f"2) P-x-y диаграмма при T = {T_REF:.2f} K")
    ax_px.set_xlim(0, 1)
    ax_px.grid(True, alpha=0.3)
    ax_px.legend(loc="best")
    plt.tight_layout()

    # 3) T-x-y диаграмма
    x_bub_t, t_bub, y_dew_t, t_dew = collect_txy_curves(flasher, P_REF, grid)
    diagram_type = classify_txy(x_bub_t, t_bub)

    fig_tx, ax_tx = plt.subplots(figsize=(7.4, 5.6))
    ax_tx.plot(x_bub_t, t_bub, color="#1F77B4", linewidth=2.2, label="Кривая кипения")
    ax_tx.plot(y_dew_t, t_dew, color="#D62728", linewidth=2.2, label="Кривая конденсации")
    put_phase_labels_txy(ax_tx, x_bub_t, t_bub, y_dew_t, t_dew)
    ax_tx.scatter([0.0, 1.0], [t_bub[0], t_bub[-1]], color="black", s=20, zorder=5)
    ax_tx.annotate(component_2, (0.0, t_bub[0]), textcoords="offset points", xytext=(6, 5), fontsize=9)
    ax_tx.annotate(component_1, (1.0, t_bub[-1]), textcoords="offset points", xytext=(-6, -12), ha="right", fontsize=9)
    ax_tx.text(0.02, 0.02, diagram_type, transform=ax_tx.transAxes, fontsize=9,
            bbox=dict(boxstyle="round,pad=0.25", facecolor="white", alpha=0.85))
    ax_tx.set_xlabel(f"x1/y1 ({component_1})")
    ax_tx.set_ylabel("T, K")
    ax_tx.set_title(f"3) T-x-y диаграмма при P = {P_REF/1e5:.0f} бар")
    ax_tx.set_xlim(0, 1)
    ax_tx.grid(True, alpha=0.3)
    ax_tx.legend(loc="best")
    plt.tight_layout()

    # 4) Точка D как середина по T между bubble/dew при z=0.5
    z_d = [0.5, 0.5]
    try:
        t_bubble_d = flasher.flash(P=P_REF, zs=z_d, VF=0).T
        t_dew_d = flasher.flash(P=P_REF, zs=z_d, VF=1).T
        t_d = 0.5 * (t_bubble_d + t_dew_d)
        res_d = flasher.flash(T=t_d, P=P_REF, zs=z_d)

        if flash_is_two_phase(res_d):
            x_d = get_x1_from_liquid(res_d)
            y_d = get_y1_from_vapor(res_d)
            if x_d is None or y_d is None:
                raise RuntimeError("Не удалось извлечь x/y для точки D")
            v_frac = res_d.VF
            l_frac = 1.0 - v_frac

            print("\n4) Точка D (середина по температуре):")
            print(f"T_bubble = {t_bubble_d:.3f} K")
            print(f"T_dew    = {t_dew_d:.3f} K")
            print(f"T_D      = {t_d:.3f} K")
            print(f"x1       = {x_d:.5f}")
            print(f"y1       = {y_d:.5f}")
            print(f"L        = {l_frac:.4f}")
            print(f"V        = {v_frac:.4f}")

            ax_tx.plot([x_d, 0.5, y_d], [t_d, t_d, t_d], "k--", linewidth=1.2, label="Правило рычага")
            ax_tx.scatter([x_d, 0.5, y_d], [t_d, t_d, t_d], color=["#1F77B4", "#2CA02C", "#D62728"], zorder=6)
            ax_tx.annotate("x", (x_d, t_d), textcoords="offset points", xytext=(-8, 8), fontsize=9)
            ax_tx.annotate("D", (0.5, t_d), textcoords="offset points", xytext=(4, 8), fontsize=9)
            ax_tx.annotate("y", (y_d, t_d), textcoords="offset points", xytext=(4, 8), fontsize=9)
        else:
            print("\n4) Точка D не попала в двухфазную область")
    except Exception as exc:
        print(f"\n4) Ошибка расчета точки D: {exc}")

    # 5) MAE по всем 11 точкам
    abs_err_x = []
    abs_err_y = []

    print("\n5) Ошибки по всем экспериментальным точкам:")
    for idx, (t_exp, x_exp, y_exp) in enumerate(data, start=1):
        try:
            point = evaluate_point(flasher, t_exp, x_exp, y_exp)
        except Exception as exc:
            point = {
                "z": 0.5 * (x_exp + y_exp),
                "phase_state": f"flash error: {exc}",
                "x_calc": 0.0,
                "y_calc": 0.0,
                "err_x": abs(x_exp),
                "err_y": abs(y_exp),
            }

        abs_err_x.append(point["err_x"])
        abs_err_y.append(point["err_y"])

        print(
            f"Точка {idx:02d}: T={t_exp:.3f} K, z={point['z']:.5f}, {point['phase_state']}, "
            f"x_calc={point['x_calc']:.5f}, y_calc={point['y_calc']:.5f}, "
            f"|dx|={point['err_x']:.5f}, |dy|={point['err_y']:.5f}"
        )

    print("\nСредняя абсолютная ошибка по 11 точкам:")
    print(f"MAE_x = {np.mean(abs_err_x):.6f}")
    print(f"MAE_y = {np.mean(abs_err_y):.6f}")

    print("\nИтог:")
    print("1) y-x пересчитана")
    print("2) P-x-y пересчитана")
    print("3) T-x-y пересчитана")
    print("4) Точка D пересчитана")
    print("5) MAE по 11 точкам пересчитана")

    plt.show()


if __name__ == "__main__":
    if FIT_KIJ:
        kij_opt, mae_x_opt, mae_y_opt = fit_kij(EXP_DATA_11)
        print("Подбор kij завершен")
        print(f"kij_opt = {kij_opt:.6f}")
        print(f"MAE_x   = {mae_x_opt:.6f}")
        print(f"MAE_y   = {mae_y_opt:.6f}")
        run_workflow(kij_opt, EXP_DATA_11)
    else:
        run_workflow(KIJ_USER, EXP_DATA_11)