import numpy as np


def check(starting_materials, result_materials):
    starting_materials = _normalize_side(starting_materials)
    result_materials = _normalize_side(result_materials)

    compounds = []

    for item in starting_materials:
        coef, composition = _parse_substance(item)
        compounds.append({"side": 1, "coef": coef, "composition": composition, "name": item})

    for item in result_materials:
        coef, composition = _parse_substance(item)
        compounds.append({"side": -1, "coef": coef, "composition": composition, "name": item})

    elements = []
    for compound in compounds:
        for element in compound["composition"]:
            if element not in elements:
                elements.append(element)

    # A: матрица (вектор-столбец) структурных видов - подписанные коэффициенты веществ.
    a_values = [compound["side"] * compound["coef"] for compound in compounds]
    matrix_a = np.array(a_values, dtype=int).reshape(-1, 1)

    # B: стехиометрическая матрица атомного состава (элементы x вещества).
    matrix_b = np.zeros((len(elements), len(compounds)), dtype=int)
    for i, element in enumerate(elements):
        for j, compound in enumerate(compounds):
            matrix_b[i, j] = compound["composition"].get(element, 0)

    product = matrix_b @ matrix_a
    is_balanced = np.all(product == 0)

    print("Вещества:", [compound["name"] for compound in compounds])
    print("Элементы:", elements)
    print("A =")
    print(matrix_a)
    print("B =")
    print(matrix_b)
    print("B*A =")
    print(product)

    return bool(is_balanced)


def _normalize_side(side):
    if isinstance(side, str):
        return [item.strip() for item in side.split("+") if item.strip()]

    normalized = []
    for item in side:
        cleaned = str(item).strip()
        if cleaned:
            normalized.append(cleaned)
    return normalized


def _parse_substance(substance):
    index = 0
    coefficient = 0

    while index < len(substance) and substance[index].isdigit():
        coefficient = coefficient * 10 + int(substance[index])
        index += 1

    if coefficient == 0:
        coefficient = 1

    formula = substance[index:]
    composition = _parse_formula_with_parentheses(formula, substance)

    return coefficient, composition


def _parse_formula_with_parentheses(formula, full_substance):
    stack = [{}]
    i = 0

    while i < len(formula):
        char = formula[i]

        if char == '(':
            stack.append({})
            i += 1
            continue

        if char == ')':
            if len(stack) == 1:
                raise ValueError(f"Лишняя закрывающая скобка в формуле: {full_substance}")

            group = stack.pop()
            i += 1

            multiplier = 0
            while i < len(formula) and formula[i].isdigit():
                multiplier = multiplier * 10 + int(formula[i])
                i += 1
            if multiplier == 0:
                multiplier = 1

            for element, amount in group.items():
                stack[-1][element] = stack[-1].get(element, 0) + amount * multiplier
            continue

        if char.isupper():
            symbol = char
            i += 1

            while i < len(formula) and formula[i].islower():
                symbol += formula[i]
                i += 1

            amount = 0
            while i < len(formula) and formula[i].isdigit():
                amount = amount * 10 + int(formula[i])
                i += 1
            if amount == 0:
                amount = 1

            stack[-1][symbol] = stack[-1].get(symbol, 0) + amount
            continue

        raise ValueError(f"Некорректный символ '{char}' в формуле: {full_substance}")

    if len(stack) != 1:
        raise ValueError(f"Не закрыты скобки в формуле: {full_substance}")

    return stack[0]


print(check(["2H2", "O2"], ["2H2O"]))
print(check(["Ca(OH)2", "SO3"], ["CaSO4", "H2O"]))