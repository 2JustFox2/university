<?php
declare(strict_types=1);

final class Database
{
    private \PDO $pdo;

    public function __construct(string $dbFilePath)
    {
        $dir = dirname($dbFilePath);
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }

        $this->pdo = new \PDO('sqlite:' . $dbFilePath, null, null, [
            \PDO::ATTR_ERRMODE => \PDO::ERRMODE_EXCEPTION,
            \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
        ]);

        $this->pdo->exec('PRAGMA foreign_keys = ON;');
        $this->initSchema();
        $this->seedIfEmpty();
    }

    private function initSchema(): void
    {
        $this->pdo->exec(
            'CREATE TABLE IF NOT EXISTS categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE
            );'
        );

        $this->pdo->exec(
            'CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                price REAL NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime(\'now\')),
                FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
            );'
        );
    }

    private function seedIfEmpty(): void
    {
        $count = (int)$this->pdo->query('SELECT COUNT(*) AS c FROM categories')->fetchColumn();
        if ($count > 0) {
            return;
        }

        $this->pdo->beginTransaction();
        try {
            $stmt = $this->pdo->prepare('INSERT INTO categories(name) VALUES (:name)');
            foreach (['Книги', 'Электроника', 'Канцелярия'] as $name) {
                $stmt->execute([':name' => $name]);
            }

            $catId = (int)$this->pdo->query('SELECT id FROM categories WHERE name = \'Книги\'')->fetchColumn();
            $this->addProduct($catId, 'Основы PHP', 499.0);
            $this->addProduct($catId, 'HTML5 и CSS3', 599.0);

            $catId = (int)$this->pdo->query('SELECT id FROM categories WHERE name = \'Электроника\'')->fetchColumn();
            $this->addProduct($catId, 'USB‑накопитель 64GB', 899.0);

            $catId = (int)$this->pdo->query('SELECT id FROM categories WHERE name = \'Канцелярия\'')->fetchColumn();
            $this->addProduct($catId, 'Блокнот A5', 199.0);

            $this->pdo->commit();
        } catch (\Throwable $e) {
            $this->pdo->rollBack();
            throw $e;
        }
    }

    /** @return array<int, array<string, mixed>> */
    public function getProducts(string $sortBy = 'id', string $dir = 'asc'): array
    {
        $allowedSort = [
            'id' => 'p.id',
            'name' => 'p.name',
            'price' => 'p.price',
            'created_at' => 'p.created_at',
            'category' => 'c.name',
        ];

        $sortKey = strtolower(trim($sortBy));
        $dirKey = strtolower(trim($dir));

        $orderBy = $allowedSort[$sortKey] ?? $allowedSort['id'];
        $direction = $dirKey === 'desc' ? 'DESC' : 'ASC';

        $sql = 'SELECT
                    p.id,
                    p.name,
                    p.price,
                    p.created_at,
                    c.name AS category_name
                FROM products p
                INNER JOIN categories c ON c.id = p.category_id
                ORDER BY ' . $orderBy . ' ' . $direction . ', p.id ASC';

        return $this->pdo->query($sql)->fetchAll();
    }

    /** @return array<int, array{id:int,name:string}> */
    public function getCategories(): array
    {
        /** @var array<int, array{id:int,name:string}> $rows */
        $rows = $this->pdo
            ->query('SELECT id, name FROM categories ORDER BY name ASC')
            ->fetchAll();
        return $rows;
    }

    public function addProduct(int $categoryId, string $name, float $price): int
    {
        $name = trim($name);
        if ($name === '') {
            throw new \InvalidArgumentException('Название товара не может быть пустым.');
        }
        if (!is_finite($price) || $price < 0) {
            throw new \InvalidArgumentException('Цена должна быть неотрицательным числом.');
        }

        $stmt = $this->pdo->prepare(
            'INSERT INTO products(category_id, name, price) VALUES (:category_id, :name, :price)'
        );
        $stmt->execute([
            ':category_id' => $categoryId,
            ':name' => $name,
            ':price' => $price,
        ]);

        return (int)$this->pdo->lastInsertId();
    }

    public function deleteProductById(int $id): bool
    {
        $stmt = $this->pdo->prepare('DELETE FROM products WHERE id = :id');
        $stmt->execute([':id' => $id]);
        return $stmt->rowCount() > 0;
    }
}
