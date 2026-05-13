<?php

require_once($_SERVER['DOCUMENT_ROOT'] . '/modules/db.php');

$services = $DataBase->getAll('services');
$news = $DataBase->getAll('news');
$bid = $DataBase->getAll('bid');

$bid_message = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $phone = trim($_POST['phone'] ?? '');

    if ($name === '' || $phone === '') {
        $bid_message = 'Заполните все поля.';
    } else {
        try {
            $DataBase->insert('bid', [
                'name' => $name,
                'phone' => $phone,
            ]);
            $bid_message = 'Спасибо! Заявка отправлена. Мы вам перезвоним.';
        } catch (Exception $e) {
            $bid_message = 'Ошибка: ' . htmlspecialchars($e->getMessage());
        }
    }
}

?>
<!DOCTYPE HTML>
<html lang="ru">
<head>
    <title>Сапунков Александр</title>
    <meta name="description" content="Группа КС-23, контрольная работа">
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
    <div id="main">
        <div class="container">
            <h1>Магазины, маркетплейсы, стартапы</h1>
            <p>Профессиональная команда готова предложить вам решение задачи любой сложности. От готовых модулей до
                разработки специфических интеграций и решений на CS-Cart.</p>
        </div>
    </div>
    <div class="container" id="services">
        <h2>Услуги по разработке и настройке CS-Cart</h2>
        <p>Мы предлагаем пакеты услуг по разным направлениям</p>
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
    <div id="news">
        <div class="container">
            <h2>Новости</h2>
            <p>Пишем статьи на серьезных площадках и публикуем разные интересности</p>
            <ul>
                <?php foreach ($news as $newsItem) { ?>
                    <?php $features = json_decode($newsItem['property'], true); ?>
                    <li>
                        <div>
                            <span><?php echo $newsItem['upload']; ?></span>
                            <h3><?php echo $newsItem['name']; ?></h3>
                            <p><?php echo nl2br(htmlspecialchars($newsItem['description'])); ?></p>
                            <ul>
                                <?php foreach ($features as $feature) { ?>
                                <li><?php echo $feature; ?></li>
                                <?php } ?>
                            </ul>
                            <a class="button" href="index.php">Подробнее</a>
                        </div>
                        <img src="img/<?php echo $newsItem['img']; ?>" alt="" width="50%">
                    </li>
                <?php } ?>
            </ul>
        </div>
    </div>
    <div class="container" id="form">
        <h2>Оставьте заявку</h2>
        <p>Оставьте заявку, и мы вам перезвоним</p>
        <?php if ($bid_message !== '') { ?>
            <div style="margin-bottom: 16px; padding: 12px 14px; background: #f3f7ff; border-radius: 10px;">
                <?php echo htmlspecialchars($bid_message); ?>
            </div>
        <?php } ?>
        <form action="index.php" method="post">
            <input type="text" placeholder="Имя" name="name" required>
            <input type="tel" placeholder="Телефон *" name="phone" required>
            <button type="submit">Отправить</button>
        </form>
        <p>Нажимая на кнопку, вы соглашаетесь с условиями обработки персональных данных и <a href="index.php">политикой
            конфиденциальности</a></p>
    </div>
</main>
<footer>
    <div class="container">
        <div id="label">Контакты:</div>
        <a href="tel:88002009775">8 800 200-97-75</a>
        <a href="mailto:info@makeshop.pro">info@makeshop.pro</a>
        <hr>
        <div id="user">Работу выполнил: Сапунков Александр, группа КС-23</div>
        <div id="copy">© makeshop.pro</div>
    </div>
</footer>
</body>
</html>
