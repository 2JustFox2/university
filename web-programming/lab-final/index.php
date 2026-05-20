<?php
$title = "Главная - Портфолио студента";
$description = "Добро пожаловать в портфолио студента университета. Проекты, технологии, достижения.";
require_once 'db/database.php';
$db = new Database();
$projects = $db->getAllProjectsWithTech();
include 'includes/header.php';
?>

<h1>Моё портфолио</h1>
<p>Привет! Я студент университета. Здесь представлены мои лучшие проекты.</p>

<h2>Последние проекты</h2>
<div class="projects-grid">
    <?php foreach(array_slice($projects, 0, 3) as $project): ?>
        <div class="project-card">
            <h3><?php echo htmlspecialchars($project['title']); ?></h3>
            <p><?php echo htmlspecialchars($project['description']); ?></p>
            <small>Технологии: <?php echo htmlspecialchars($project['technologies']); ?></small>
        </div>
    <?php endforeach; ?>
</div>

<style>
.projects-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
    margin-top: 20px;
}
.project-card {
    background: white;
    padding: 15px;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}
</style>

<?php include 'includes/footer.php'; ?>