CREATE DATABASE IF NOT EXISTS `portfolio_db`;
USE `portfolio_db`;

CREATE TABLE `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `technologies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `tech_name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE
);

INSERT INTO `projects` (`title`, `description`, `image`, `created_at`) VALUES
('Сайт университета', 'Адаптивный сайт для приёмной комиссии', 'uni.jpg', '2024-05-10'),
('Личное портфолио', 'Современное портфолио с анимациями', 'portfolio.jpg', '2025-01-20');

INSERT INTO `technologies` (`project_id`, `tech_name`) VALUES
(1, 'PHP'), (1, 'MySQL'), (1, 'HTML5/CSS3'),
(2, 'JavaScript'), (2, 'jQuery'), (2, 'Bootstrap');