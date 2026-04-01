
from datetime import date
import os

class Logger():
    def __init__(self):
        self.log_file = "myProgram.log"
        self.error_file = "myErrors.log"
        
    def init(self):
        self.clear()
        self.log("Сапунков Александр Андреевич - 18 Вариант")
        self.log(f"Дата запуска: {date.today().isoformat()}")
        self.log("ln(x)/(y – 2)")
        
        self.error("ln(x)/(y – 2)")

    def log(self, message):
        with open(self.log_file, 'a') as f:
            f.write(message + '\n')

    def error(self, message):
        with open(self.error_file, 'a') as f:
            f.write(message + '\n')

    def clear(self):
        with open(self.log_file, 'w') as f:
            f.write("")

        with open(self.error_file, 'w') as f:
            f.write("")
    
    def record_results(self, data):
        if not (os.path.exists("./log") and os.path.isdir("./log")):
            os.mkdir('log')
        files = os.listdir("./log")
        
        if not data or not data[0] or not data[0][0]:
            self.error("Нет данных для записи в файл результатов.")
            return
        
        try:
            counter = 1
            while ("G" + str(counter).zfill(4) + ".dat") in files:
                counter += 1
            with open("./log/G" + str(counter).zfill(4) + ".dat", 'w') as f:
                col_width = 14
                f.write(f"{'y\\x':>{col_width}}") # type: ignore
                for point in data[0]:
                    f.write(f"{point['x']:>{col_width}.6g}")
                for row in data:
                    if not row:
                        continue
                    f.write(f"\n{row[0]['y']:>{col_width}.6g}")
                    for point in row:
                        f.write(f"{point['f']:>{col_width}.6g}")
                f.write("\n")
                
                return ("G" + str(counter).zfill(4) + ".dat")
        except Exception as e:
            self.error(f"Ошибка при записи результатов в файл: {e}")