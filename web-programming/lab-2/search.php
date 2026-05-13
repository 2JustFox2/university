<?php

require_once($_SERVER['DOCUMENT_ROOT'] . '/modules/db.php');

$services = $DataBase->getAll('services', $_GET['search']);

?>
<!DOCTYPE HTML>
<html lang="ru">
<head>
    <title>Результаты поиска</title>
    <meta name="description" content="Результаты поиска">
    <meta charset="utf-8">
    <link href="img/favicon.svg" rel="shortcut icon">
    <link rel="stylesheet" href="css/main.css">
</head>
<body>
<header>
    <div class="container">
        <a id="logo" href="index.php">
            <img src="img/logo.png">
        </a>
        <form action="search.php" method="get">
            <input type="text" placeholder="Введите поисковый запрос" name="search">
            <button type="submit"></button>
        </form>
        <a class="icon" href="index.php">
            <img src="img/cart.png">
        </a>
        <a class="icon" href="index.php">
            <img src="img/user.png">
        </a>
    </div>
</header>
<main>
    <div class="container" id="services">
        <h2>Результаты поиска услуг</h2>
        <ul>
            <?php foreach ($services as $service) { ?>
            <li>
                <img src="img/<?php echo $service['image']; ?>">
                <div>
                    <h3><?php echo $service['name']; ?></h3>
                    <p><?php echo $service['description']; ?></p>
                </div>
            </li>
            <?php } ?>
        </ul>
    </div>
</main>
<footer>
    <div class="container">
        <div id="label">Контакты:</div>
        <a href="tel:88002009775">8 800 200-97-75</a>
        <a href="mailto:info@makeshop.pro">info@makeshop.pro</a>
        <hr>
        <div id="user">Работу выполнил: Фамилия Имя, группа КС-2Х</div>
        <div id="copy">© makeshop.pro</div>
    </div>
</footer>
</body>
</html>