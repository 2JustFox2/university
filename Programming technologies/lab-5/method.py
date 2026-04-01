import math
from logger import Logger

class Calculate:
    def __init__(self):
        self.logger = Logger()

    def _is_strictly_increasing(self, values):
        return all(values[i] < values[i + 1] for i in range(len(values) - 1))
        

    def __call__(self, data):
        all_results = {}  # Словарь для хранения результатов всех форм
        parsed_forms = {}
        validation_errors = []

        # Валидируем все формы до начала вычислений
        for form_id in data:
            x_raw = data[form_id].get("x", [])
            y_raw = data[form_id].get("y", [])

            if not x_raw or not y_raw:
                validation_errors.append(
                    f"Форма {form_id} не содержит данных для x или y."
                )
                continue

            try:
                x_data = [float(val) for val in x_raw]
                y_data = [float(val) for val in y_raw]
            except ValueError:
                validation_errors.append(
                    f"Форма {form_id} содержит нечисловые значения."
                )
                continue

            if not self._is_strictly_increasing(x_data):
                validation_errors.append(
                    f"Форма {form_id}: значения x должны быть в строго возрастающем порядке."
                )

            if not self._is_strictly_increasing(y_data):
                validation_errors.append(
                    f"Форма {form_id}: значения y должны быть в строго возрастающем порядке."
                )

            parsed_forms[form_id] = {"x": x_data, "y": y_data}

        if validation_errors:
            for error_text in validation_errors:
                self.logger.error(error_text)
            raise ValueError("\n".join(validation_errors))

        for form_id, form_data in parsed_forms.items():
            x_data = form_data["x"]
            y_data = form_data["y"]

            result = [[]]
            row_index = 0
            form_errors = []
            
            for y in y_data:
                result.append([])
                for x in x_data:
                    try:
                        f_value = self.f(x, y)
                        if math.isnan(f_value):
                            form_errors.append(f"Форма {form_id}: x={x} меньше или равен нулю, результат = NaN")
                        result[row_index].append({"x": x, "y": y, "f": f_value})
                    except ZeroDivisionError:
                        form_errors.append(f"Форма {form_id}: деление на ноль при x={x}, y={y} (y не должно быть равно 2).")
                        result[row_index].append({"x": x, "y": y, "f": float('nan')})
                    except OverflowError:
                        form_errors.append(f"Форма {form_id}: переполнение при вычислении f({x}, {y}).")
                        result[row_index].append({"x": x, "y": y, "f": float('nan')})
                    except Exception as e:
                        form_errors.append(f"Форма {form_id}: непредвиденная ошибка при вычислении f({x}, {y}): {e}")
                        result[row_index].append({"x": x, "y": y, "f": float('nan')})
                row_index += 1
            
            file = self.logger.record_results(result)
            self.logger.log(f"\nРезультаты формы {form_id} записаны в файл {file}.")

            if form_errors:
                if file:
                    for error_text in form_errors:
                        self.logger.error(f"{error_text} | Файл результатов: {file}")
                else:
                    for error_text in form_errors:
                        self.logger.error(f"{error_text} | Файл результатов не создан")

            all_results[form_id] = result
        
        return all_results
        
    def f(self, x, y):
        if x <= 0:
            return float('nan')
        if y == 2:
            raise ZeroDivisionError("Деление на ноль")

        result = math.log(x) / (y - 2)
        if not math.isfinite(result):
            raise OverflowError("Результат не является конечным числом")
        return result