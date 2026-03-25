<?php
declare(strict_types=1);

$pageTitle = $pageTitle ?? 'Лабораторная: Многостраничный сайт';
$current = basename($_SERVER['SCRIPT_NAME'] ?? '');

function navCurrent(string $href, string $current): string
{
    return $href === $current ? ' aria-current="page"' : '';
}
?>
<!doctype html>
<html lang="ru">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= htmlspecialchars((string)$pageTitle, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></title>
    <link rel="icon" href="favicon.svg" type="image/svg+xml">
    <link rel="stylesheet" href="css/reset.css">
    <link rel="stylesheet" href="css/styles.css">
  </head>
  <body>
    <header class="site-header">
      <div class="container header-inner">
        <a class="brand" href="index.php">
          <img src="img/logo.svg" alt="Логотип сайта" width="44" height="44">
          <div class="brand-title">
            <strong>Web Programming</strong>
            <span class="muted">Шаблон многостраничного сайта (PHP + БД)</span>
          </div>
        </a>
        <nav class="nav" aria-label="Навигация по сайту">
          <a href="index.php"<?= navCurrent('index.php', $current) ?>>Инфо-страница</a>
          <a href="catalog.php"<?= navCurrent('catalog.php', $current) ?>>Страница БД</a>
        </nav>
      </div>
    </header>
    <main>
      <div class="container">
