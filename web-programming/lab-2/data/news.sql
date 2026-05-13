-- phpMyAdmin SQL Dump
-- version 5.1.2
-- https://www.phpmyadmin.net/
--
-- Хост: localhost:3306
-- Время создания: Май 13 2026 г., 17:05
-- Версия сервера: 5.7.24
-- Версия PHP: 8.3.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `web`
--

-- --------------------------------------------------------

--
-- Структура таблицы `news`
--

CREATE TABLE `news` (
  `id` int(10) NOT NULL,
  `name` text NOT NULL,
  `description` text NOT NULL,
  `property` json DEFAULT NULL,
  `upload` text NOT NULL,
  `img` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `news`
--

INSERT INTO `news` (`id`, `name`, `description`, `property`, `upload`, `img`) VALUES
(3, 'Нетрадиционное использование ChatGPT вместо базы данных с API или подбор запчастей «наоборот»', 'Наш клиент, магазин автомобильных аккумуляторов massa.moscow, нуждался в разработке модуля для подбора аккумуляторов по модели автомобиля.\r\n\r\nВ поисках оптимального решения мы пришли к идее симбиоза двух API. Первый мы использовали для доступа к обширной базе...', NULL, '22 января 2024', 'n1.png'),
(4, 'Новый кейс \"Интернет-магазин американских БАДов', 'ады представить вам наш новый кейс по разработке интернет-магазина американских БАДов на CS-Cart. \r\n\r\nИз особенностей проекта:', '[\"- Разработка логотипа, фирменного стиля и дизайна страниц\", \"- Поддержка различных языковых версий\", \"- Разработка модуля валют\"]', '30 ноября 2023', 'n2.png');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `news`
--
ALTER TABLE `news`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `news`
--
ALTER TABLE `news`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
