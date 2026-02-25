import math

# 4 Вариант
# ln(1-x)   sh(-3/x)    ln(sin(1/(1-x)))    do...while

def f1(x):
    return math.log(1-x)

def f2(x):
    return math.sinh(-3/x)

def f3(x):
    return math.log(1/(1-x))

def f4(x):
    i = 1
    summ = 0
    while True:
        if (x + math.sqrt(i) == 0):
            print(f"Невалидное значение X: ${x}")
        else:
            summ += 1 / (x + math.sqrt(i))
        if i >= 1000000:
            break
    return summ

def f(x):
    return f1(x) + f2(x) + f3(x) + f4(x)

res = []