<?php
$title = "Портфолио - Управление проектами";
$description = "Управление проектами портфолио: добавление, удаление, сортировка.";
require_once 'db/database.php';
$db = new Database();

$orderBy = $_GET['order'] ?? 'created_at';
$direction = $_GET['dir'] ?? 'DESC';
$projects = $db->getProjectsSorted($orderBy, $direction);

// Удаление
if(isset($_GET['delete'])) {
    $id = (int)$_GET['delete'];
    if($db->deleteProject($id)) {
        $message = "Проект успешно удалён";
        $projects = $db->getProjectsSorted($orderBy, $direction);
    } else {
        $error = "Ошибка удаления";
    }
}

if($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_project'])) {
    $title = trim($_POST['title']);
    $desc = trim($_POST['description']);
    // $image = trim($_POST['image']);
    $date = $_POST['created_at'];
    $tech = trim($_POST['technologies']);
    
    if($title && $desc && $date && $tech) {
        if($db->addProject($title, $desc, $image, $date, $tech)) {
            $message = "Проект успешно добавлен";
            $projects = $db->getProjectsSorted($orderBy, $direction);
        } else {
            $error = "Ошибка добавления";
        }
    } else {
        $error = "Заполните обязательные поля (название, описание, дата, технологии)";
    }
}

include 'includes/header.php';
?>

<h1>Управление портфолио</h1>

<?php if(isset($message)): ?>
    <div class="success"><?php echo $message; ?></div>
<?php endif; ?>
<?php if(isset($error)): ?>
    <div class="error"><?php echo $error; ?></div>
<?php endif; ?>

<h2>Добавить новый проект</h2>
<form method="post" class="add-form">
    <div class="form-group">
        <label>Название *</label>
        <input type="text" name="title" required>
    </div>
    <div class="form-group">
        <label>Описание *</label>
        <textarea name="description" rows="3" required></textarea>
    </div>
    <!-- <div class="form-group">
        <label>Изображение (имя файла)</label>
        <input type="text" name="image" placeholder="например: project.jpg">
    </div> -->
    <div class="form-group">
        <label>Дата создания *</label>
        <input type="date" name="created_at" required>
    </div>
    <div class="form-group">
        <label>Технологии (через запятую) *</label>
        <input type="text" name="technologies" placeholder="PHP, MySQL, JS" required>
    </div>
    <button type="submit" name="add_project">Добавить проект</button>
</form>

<h2>Список проектов</h2>
<div class="sort-links">
    <span>Сортировать по:</span>
    <a href="?order=title&dir=ASC">Названию (А-Я)</a> |
    <a href="?order=created_at&dir=DESC">Новые сначала</a> |
    <a href="?order=created_at&dir=ASC">Старые сначала</a>
</div>

<table>
    <thead>
        <tr><th>ID</th><th>Название</th><th>Описание</th><th>Технологии</th><th>Дата</th><th>Действие</th></tr>
    </thead>
    <tbody>
        <?php foreach($projects as $proj): ?>
        <tr>
            <td data-label="ID"><?php echo $proj['id']; ?></td>
            <td data-label="Название"><?php echo htmlspecialchars($proj['title']); ?></td>
            <td data-label="Описание"><?php echo htmlspecialchars(substr($proj['description'], 0, 80)); ?>...</td>
            <td data-label="Технологии"><?php echo htmlspecialchars($proj['technologies']); ?></td>
            <td data-label="Дата"><?php echo $proj['created_at']; ?></td>
            <td data-label="Действие">
                <a href="?delete=<?php echo $proj['id']; ?>" onclick="return confirm('Удалить проект?')" class="btn-delete">Удалить</a>
            </td>
        </tr>
        <?php endforeach; ?>
    </tbody>
</table>

<?php include 'includes/footer.php'; ?>