<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $title ?? 'Портфолио'; ?></title>
    <meta name="description" content="<?php echo $description ?? 'Портфолио студента университета'; ?>">
    <link rel="icon" href="img/favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="css/reset.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <div class="wrapper">
        <header class="header">
            <div class="header-inner">
                <div class="logo">
                    <img src="img/logo.png" alt="Логотип" class="logo-img">
                    <span class="logo-text">Студенческое портфолио</span>
                </div>
            </div>
        </header>
        <nav class="nav">
            <ul class="nav-list">
                <li><a href="index.php">Главная</a></li>
                <li><a href="portfolio.php">Портфолио</a></li>
            </ul>
        </nav>
        <main class="main">