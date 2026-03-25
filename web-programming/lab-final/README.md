# Web Programming — шаблон (PHP + БД)

## Как запустить локально

Вариант 1 (проще всего): встроенный сервер PHP.

```bash
cd web-programming
php -S localhost:8000
```

Откройте в браузере `http://localhost:8000/index  .php`.

## Что реализовано по требованиям

- **Минимум 2 страницы**: `index.php` (информационная), `catalog.php` (работа с БД).
- **Шаблон**: общий `header + nav` в `includes/header.php`, общий `footer` в `includes/footer.php`.
- **HTML5 / UTF‑8 / favicon**: подключено в `includes/header.php`, favicon — `favicon.svg`.
- **Логотип**: `img/logo.svg` (в шапке сайта).
- **CSS**: `css/reset.css` + `css/styles.css` с адаптивностью через `@media`.
- **База данных**: `db/app.sqlite` (SQLite), 2 таблицы `categories` и `products`.
- **JOIN**: вывод товаров на `catalog.php` делается запросом `products JOIN categories`.
- **Функции БД в классе**: `src/Database.php`.
- **Функции страницы БД**:
  - вывод данных из таблиц;
  - сортировка по столбцам;
  - удаление записи по `id`;
  - создание новой записи.

