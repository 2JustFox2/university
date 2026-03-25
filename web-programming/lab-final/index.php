<?php
declare(strict_types=1);

$pageTitle = 'Информационная страница';
require __DIR__ . '/includes/header.php';
?>

<section class="card grid-2">
  <div class="hero">
    <h1>Многостраничный сайт на локальном сервере</h1>
    <p>
      Это шаблон для лабораторной работы: есть минимум две страницы, общий
      шаблон (header/nav/footer), адаптивная верстка, и отдельная страница
      для работы с базой данных.
    </p>
    <div class="pill-row" aria-label="Ключевые пункты">
      <div class="pill"><b>HTML5</b> + UTF‑8 + favicon</div>
      <div class="pill"><b>CSS</b> reset.css + @media</div>
      <div class="pill"><b>БД</b> 2 таблицы + JOIN</div>
    </div>
  </div>

  <div class="media">
    <figure>
      <img src="img/hero.svg" alt="Иллюстрация для информационной страницы" width="1200" height="700">
      <figcaption>Пример изображения (SVG хранится в папке <span class="muted">img</span>).</figcaption>
    </figure>
  </div>
</section>

<section style="margin-top: 18px;" class="card">
  <h2 style="margin: 0 0 10px;">Примеры контента (списки, таблицы, media)</h2>

  <div class="grid-2">
    <div>
      <h3 style="margin: 0 0 8px;">Список требований</h3>
      <ul style="margin: 0; padding-left: 18px;">
        <li>Шапка сайта: логотип + название</li>
        <li>Навигация: ссылки на страницы</li>
        <li>Основной контент в <span class="muted">main</span></li>
        <li>Подвал: копирайт</li>
      </ul>

      <h3 style="margin: 14px 0 8px;">Небольшая таблица</h3>
      <div class="table-wrap">
        <table class="data" aria-label="Таблица примера контента">
          <thead>
            <tr>
              <th>Элемент</th>
              <th>Где хранится</th>
              <th>Зачем нужен</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Изображения</td>
              <td><span class="muted">img/</span></td>
              <td>Медиа‑контент</td>
            </tr>
            <tr>
              <td>Стили</td>
              <td><span class="muted">css/</span></td>
              <td>Единый дизайн и адаптивность</td>
            </tr>
            <tr>
              <td>Шаблон</td>
              <td><span class="muted">includes/</span></td>
              <td>Подключение header/nav/footer на каждой странице</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div>
      <h3 style="margin: 0 0 8px;">Пример HTML5 media</h3>
      <div class="notice">
        <p style="margin: 0 0 10px;">
          Ниже — пример блока <span class="muted">&lt;video&gt;</span>. При желании
          добавьте файл в <span class="muted">img/</span> (или отдельную папку <span class="muted">media/</span>)
          и укажите <span class="muted">src</span>.
        </p>
        <video controls width="480">
          Ваш браузер не поддерживает HTML5 video.
        </video>
      </div>

      <h3 style="margin: 14px 0 8px;">Дальше по заданию</h3>
      <p style="margin: 0;" class="muted">
        Перейдите на страницу <b>«Страница БД»</b>: там вывод данных, сортировка,
        удаление по id и создание новой записи (2 таблицы + JOIN).
      </p>
    </div>
  </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
