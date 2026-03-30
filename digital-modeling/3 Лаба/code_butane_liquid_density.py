from math import log
from math import exp
from numpy import mean
import numpy as np
import pandas as pd
from sklearn.model_selection import RepeatedKFold
from keras.models import Sequential
from keras.layers import Dense
from keras import optimizers
from matplotlib import pyplot as plt


def get_dataset():
    # X: samples * inputs
    # y: samples * outputs

    data = pd.read_csv("./data/data_butane_gas_thermal_conductivity.csv")
    # data=data[data["GL"]==0]
    X = data[["Temperature", "Pressure"]].to_numpy()
    y = data[["Cp"]].to_numpy()  # ,"GL"
    return X, y


# get the model
def get_model(n_inputs, n_outputs):
    model = Sequential()
    model.add(Dense(2, input_dim=n_inputs, activation='sigmoid'))
    model.add(Dense(n_outputs, activation='linear'))
    opt1 = optimizers.Adam(learning_rate=0.005)
    model.compile(loss='mae', metrics=['mape'], optimizer=opt1)
    model.summary()
    return model


# evaluate a model using repeated k-fold cross-validation
def evaluate_model(X, y):
    n_inputs, n_outputs = X.shape[1], y.shape[1]
    print("Inputs = ", n_inputs, " Outputs = ", n_outputs)
    # define evaluation procedure
    cv = RepeatedKFold(n_splits=5, n_repeats=1, random_state=22527)
    # enumerate folds
    i = 0
    MAPE = 300
    ##K-fold
    for train_ix, test_ix in cv.split(X):
        # prepare data
        i = i + 1
        ##for K-fold
        X_train, X_test = X[train_ix], X[test_ix]
        y_train, y_test = y[train_ix], y[test_ix]

        # define model
        model = get_model(n_inputs, n_outputs)
        # fit model
        history = model.fit(X_train, y_train, verbose=0, epochs=1000)  # type: ignore
        plt.plot(history.history['loss'])
        plt.title('model loss')
        plt.ylabel('loss')
        plt.xlabel('epoch')
        plt.legend(['train', 'val'], loc='upper left')
        plt.show()  # thx https://stackoverflow.com/a/56807595
        # evaluate model on test set
        [mae_train, mape_train] = model.evaluate(X_train, y_train)
        [mae_test, mape_test] = model.evaluate(X_test, y_test)
        [mae, mape] = model.evaluate(X, y)
        if (mape < MAPE):
            MAPE = mape
            model2 = model
            print("Saving model...")
        # store result
        print('fold: %d' % i)
        print('> MAE train: %.3f' % mae_train)
        print('> MAE test: %.3f' % mae_test)
        print('> MAPE train: %.3f' % mape_train)
        print('> MAPE test: %.3f' % mape_test)
        print('> MAE total: %.3f' % mae)
        print('> MAPE total: %.3f' % mape)
    return mae, mape, model2


def normalize_data(X):
    nX = X.copy();
    minsX = []
    maxsX = []
    for j in range(0, X.shape[1]):
        minsX.append(min(X[:, j]))
        maxsX.append(max(X[:, j]))
        for i in range(0, X.shape[0]):
            nX[i, j] = (X[i, j] - minsX[j]) / (maxsX[j] - minsX[j]) * 0.9 + 0.1
    return nX, minsX, maxsX


def denormalize_data(X, minsX, maxsX):
    dX = X.copy();
    for j in range(0, X.shape[1]):
        for i in range(0, X.shape[0]):
            dX[i, j] = ((X[i, j] - 0.1) / 0.9) * (maxsX[j] - minsX[j]) + minsX[j]
    return dX


# Функция для предсказания и построения графиков
def predict_and_plot(model, X, y, minsX, maxsX, minsy, maxsy):
    # Предсказание для всех точек
    new_y = model.predict(X)
    dnX = denormalize_data(X, minsX, maxsX)
    dny = denormalize_data(y, minsy, maxsy)
    new_y = denormalize_data(new_y, minsy, maxsy)

    # Предсказание для T=430K, P=1 бар
    T_target = 430  # K
    P_target = 1  # бар

    # Создание графиков
    fig, axes = plt.subplots(2, 1, figsize=(10, 14))
    fig.suptitle('Теплопроводность бутана (газ)', fontsize=16)

    # Получаем уникальные давления из данных
    unique_pressures = np.sort(np.unique(dnX[:, 1]))

    # Линейная интерполяция по давлению для строгого расчета при P_target
    def predict_at_pressure(temp_values, pressure_target):
        lower_candidates = unique_pressures[unique_pressures <= pressure_target]
        upper_candidates = unique_pressures[unique_pressures >= pressure_target]

        p_low = lower_candidates[-1] if lower_candidates.size > 0 else unique_pressures[0]
        p_high = upper_candidates[0] if upper_candidates.size > 0 else unique_pressures[-1]

        # Если точное давление есть в данных, интерполяция не нужна
        if np.isclose(p_low, p_high):
            X_eval = np.column_stack([temp_values, np.full_like(temp_values, p_low, dtype=float)])
            X_eval_norm = X_eval.copy()
            for j in range(X_eval.shape[1]):
                X_eval_norm[:, j] = (X_eval[:, j] - minsX[j]) / (maxsX[j] - minsX[j]) * 0.9 + 0.1
            y_eval_norm = model.predict(X_eval_norm, verbose=0)
            y_eval = denormalize_data(y_eval_norm, minsy, maxsy)
            return y_eval[:, 0], p_low, p_high

        X_low = np.column_stack([temp_values, np.full_like(temp_values, p_low, dtype=float)])
        X_high = np.column_stack([temp_values, np.full_like(temp_values, p_high, dtype=float)])

        X_low_norm = X_low.copy()
        X_high_norm = X_high.copy()
        for j in range(X_low.shape[1]):
            X_low_norm[:, j] = (X_low[:, j] - minsX[j]) / (maxsX[j] - minsX[j]) * 0.9 + 0.1
            X_high_norm[:, j] = (X_high[:, j] - minsX[j]) / (maxsX[j] - minsX[j]) * 0.9 + 0.1

        y_low = denormalize_data(model.predict(X_low_norm, verbose=0), minsy, maxsy)[:, 0]
        y_high = denormalize_data(model.predict(X_high_norm, verbose=0), minsy, maxsy)[:, 0]

        w = (pressure_target - p_low) / (p_high - p_low)
        y_interp = y_low + w * (y_high - y_low)
        return y_interp, p_low, p_high

    # Строгое предсказание при P=1 бар через интерполяцию
    y_target_arr, p_low, p_high = predict_at_pressure(np.array([T_target], dtype=float), P_target)
    y_target = y_target_arr[0]

    print(
        f"\nПредсказанное значение теплопроводности при T={T_target}K, P={P_target} бар: {y_target:.3f} мВт/м·K")
    if not np.isclose(p_low, p_high):
        print(f"Интерполяция выполнена между линиями P={p_low:.3f} и P={p_high:.3f} бар.")

    # График 1: Зависимость от температуры при разных давлениях
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0, 1, len(unique_pressures)))

    for pressure, color in zip(unique_pressures, colors):
        # Фильтруем данные для данного давления
        mask = dnX[:, 1] == pressure
        if np.sum(mask) > 1:  # Нужно минимум 2 точки для построения линии
            # Сортируем по температуре
            temp_exp = dnX[mask, 0]
            cp_points = dny[mask, 0]
            sort_idx = np.argsort(temp_exp)
            temp_exp = temp_exp[sort_idx]
            cp_points = cp_points[sort_idx]

            temp_model = temp_exp

            # Предсказания модели для этих точек
            X_plot = np.column_stack([temp_model, np.full_like(temp_model, pressure)])
            X_plot_norm = X_plot.copy()
            for j in range(X_plot.shape[1]):
                X_plot_norm[:, j] = (X_plot[:, j] - minsX[j]) / (maxsX[j] - minsX[j]) * 0.9 + 0.1
            y_plot_norm = model.predict(X_plot_norm, verbose=0)
            y_plot = denormalize_data(y_plot_norm, minsy, maxsy)

            # Экспериментальные точки
            ax1.plot(temp_exp, cp_points, 'o', color=color, markersize=6,
                    label=f'P={pressure:.1f} бар (эксп)', alpha=0.7)
            # Линия предсказания
            ax1.plot(temp_model, y_plot, '-', color=color, linewidth=2,
                    label=f'P={pressure:.1f} бар (модель)', alpha=0.8)

    # Интерполированная линия строго для P_target
    temp_interp = np.sort(np.unique(np.append(dnX[:, 0], T_target)))
    y_interp_line, _, _ = predict_at_pressure(temp_interp.astype(float), P_target)
    ax1.plot(temp_interp, y_interp_line, 'k--', linewidth=2.5,
             label=f'P={P_target:.1f} бар (интерполяция)')

    # Точка предсказания лежит на интерполированной линии
    ax1.plot(T_target, y_target, '*', color='red', markersize=15,
             label=f'Предсказание: {T_target}K, {P_target:.1f}бар', markeredgecolor='black', markeredgewidth=1)

    ax1.set_xlabel('Температура [K]', fontsize=12)
    ax1.set_ylabel('Теплопроводность [мВт/м·K]', fontsize=12)
    ax1.set_title('Зависимость теплопроводности от температуры', fontsize=12)
    ax1.legend(bbox_to_anchor=(1.05, 1), loc='upper left', fontsize=8)
    ax1.grid(True, alpha=0.3)

    # График 2: Сравнение экспериментальных и предсказанных значений
    ax2 = axes[1]
    ax2.plot(dny[:, 0], new_y[:, 0], '.', alpha=0.5, markersize=8)
    ax2.axline((0, 0), slope=1, color='r', linestyle='--', linewidth=2, label='Идеальное совпадение')

    mae_value = np.mean(np.abs(dny[:, 0] - new_y[:, 0]))
    ax2.text(0.05, 0.95, f'MAE = {mae_value:.3f}', transform=ax2.transAxes,
             fontsize=12, verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax2.set_xlabel('Экспериментальные значения [мВт/м·K]', fontsize=12)
    ax2.set_ylabel('Предсказанные значения [мВт/м·K]', fontsize=12)
    ax2.set_title('Сравнение экспериментальных и предсказанных значений', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.show()

    return y_target


# load dataset
X, y = get_dataset()
X, minsX, maxsX = normalize_data(X)
y, minsy, maxsy = normalize_data(y)

# evaluate model
mae_score, mape, model = evaluate_model(X, y)
model.save('./content/Lab2_ML_Butane.keras')
print('MAE: %.3f MAPE: %.3f' % (mae_score, mape))

# Предсказание и построение графиков
predicted_value = predict_and_plot(model, X, y, minsX, maxsX, minsy, maxsy)

# Дополнительный вывод результатов
print("\n" + "=" * 50)
print("РЕЗУЛЬТАТЫ ПРЕДСКАЗАНИЯ")
print("=" * 50)
print(f"Температура: 430 K")
print(f"Давление: 1 бар")
print(f"Предсказанная теплопроводность: {predicted_value:.3f} мВт/м·K")
print("=" * 50)