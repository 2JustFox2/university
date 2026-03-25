<?php
declare(strict_types=1);

require __DIR__ . '/src/Database.php';

$db = new Database(__DIR__ . '/db/app.sqlite');

$pageTitle = 'Страница работы с БД';

$notice = (string)($_GET['notice'] ?? '');
$error = (string)($_GET['error'] ?? '');

$sort = (string)($_GET['sort'] ?? 'id');
$dir = (string)($_GET['dir'] ?? 'asc');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = (string)($_POST['action'] ?? '');

    try {
        if ($action === 'create') {
            $categoryId = (int)($_POST['category_id'] ?? 0);
            $name = (string)($_POST['name'] ?? '');
            $price = (float)($_POST['price'] ?? 0);

            $newId = $db->addProduct($categoryId, $name, $price);
            header('Location: catalog.php?notice=' . rawurlencode('Запись создана. ID: ' . $newId));
            exit;
        }

        if ($action === 'delete') {
            $id = (int)($_POST['id'] ?? 0);
            $ok = $db->deleteProductById($id);
            $msg = $ok ? 'Запись удалена.' : 'Запись с таким ID не найдена.';
            header('Location: catalog.php?notice=' . rawurlencode($msg));
            exit;
        }

        header('Location: catalog.php?error=' . rawurlencode('Неизвестное действие.'));
        exit;
    } catch (Throwable $e) {
        header('Location: catalog.php?error=' . rawurlencode($e->getMessage()));
        exit;
    }
}

$categories = $db->getCategories();
$products = $db->getProducts($sort, $dir);

function nextDir(string $currentSort, string $requestedSort, string $currentDir): string
{
    if ($currentSort !== $requestedSort) {
        return 'asc';
    }
    return strtolower($currentDir) === 'asc' ? 'desc' : 'asc';
}

function sortLink(string $label, string $key, string $currentSort, string $currentDir): string
{
    $dir = nextDir($currentSort, $key, $currentDir);
    $href = 'catalog.php?sort=' . rawurlencode($key) . '&dir=' . rawurlencode($dir);
    $suffix = ($currentSort === $key) ? (' ' . (strtolower($currentDir) === 'asc' ? '▲' : '▼')) : '';
    return '<a href="' . htmlspecialchars($href, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') . '">' .
        htmlspecialchars($label . $suffix, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') .
        '</a>';
}

require __DIR__ . '/includes/header.php';
?>

<section class="card">
  <h1 style="margin: 0 0 8px;">Работа с базой данных</h1>
  <p class="muted" style="margin: 0;">
    База данных: SQLite (файл <span class="muted">db/app.sqlite</span>).
    Две таблицы: <span class="muted">categories</span> и <span class="muted">products</span>.
    Вывод делается одним запросом с <b>JOIN</b>.
  </p>
</section>

<?php if ($notice !== ''): ?>
  <section style="margin-top: 14px;" class="notice"><?= htmlspecialchars($notice, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></section>
<?php endif; ?>
<?php if ($error !== ''): ?>
  <section style="margin-top: 14px;" class="error"><?= htmlspecialchars($error, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></section>
<?php endif; ?>

<section style="margin-top: 18px;" class="card">
  <h2 style="margin: 0 0 10px;">Создать новую запись (products)</h2>
  <form method="post" class="grid" action="catalog.php">
    <input type="hidden" name="action" value="create">
    <label class="field">
      Категория
      <select name="category_id" required>
        <?php foreach ($categories as $c): ?>
          <option value="<?= (int)$c['id'] ?>"><?= htmlspecialchars((string)$c['name'], ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label class="field">
      Название
      <input type="text" name="name" required maxlength="200" placeholder="Например: Учебник по SQL">
    </label>
    <label class="field">
      Цена
      <input type="number" name="price" required min="0" step="0.01" placeholder="0.00">
    </label>
    <div class="actions" style="align-items: end;">
      <button class="btn btn-primary" type="submit">Добавить</button>
    </div>
  </form>
</section>

<section style="margin-top: 18px;" class="card">
  <h2 style="margin: 0 0 10px;">Данные из БД (JOIN + сортировка)</h2>
  <div class="table-wrap">
    <table class="data" aria-label="Таблица товаров из БД">
      <thead>
        <tr class="sort">
          <th><?= sortLink('ID', 'id', $sort, $dir) ?></th>
          <th><?= sortLink('Название', 'name', $sort, $dir) ?></th>
          <th><?= sortLink('Категория (JOIN)', 'category', $sort, $dir) ?></th>
          <th><?= sortLink('Цена', 'price', $sort, $dir) ?></th>
          <th><?= sortLink('Создано', 'created_at', $sort, $dir) ?></th>
          <th>Удаление по id</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($products as $p): ?>
          <tr>
            <td><?= (int)$p['id'] ?></td>
            <td><?= htmlspecialchars((string)$p['name'], ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></td>
            <td><?= htmlspecialchars((string)$p['category_name'], ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></td>
            <td><?= number_format((float)$p['price'], 2, '.', ' ') ?></td>
            <td><?= htmlspecialchars((string)$p['created_at'], ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8') ?></td>
            <td>
              <form method="post" action="catalog.php" onsubmit="return confirm('Удалить запись ID <?= (int)$p['id'] ?>?');">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<?= (int)$p['id'] ?>">
                <button class="btn btn-danger" type="submit">Удалить</button>
              </form>
            </td>
          </tr>
        <?php endforeach; ?>
        <?php if (count($products) === 0): ?>
          <tr><td colspan="6" class="muted">Нет данных. Добавьте запись выше.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
