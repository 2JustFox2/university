<?php
class Database {
    private $host = '127.0.0.1';
    private $dbname = 'portfolio_db';
    private $user = 'root';
    private $pass = '';
    private $port = 3306;
    private $pdo;

    public function __construct() {
        try {
            $this->pdo = new PDO("mysql:host={$this->host};port={$this->port};dbname={$this->dbname};charset=utf8", $this->user, $this->pass);
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $e) {
            die("Ошибка подключения: " . $e->getMessage());
        }
    }

    // Получить все проекты с технологиями (JOIN)
    public function getAllProjectsWithTech() {
        $sql = "SELECT p.*, GROUP_CONCAT(t.tech_name SEPARATOR ', ') AS technologies 
                FROM projects p 
                LEFT JOIN technologies t ON p.id = t.project_id 
                GROUP BY p.id ORDER BY p.created_at DESC";
        $stmt = $this->pdo->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Сортировка по полю
    public function getProjectsSorted($orderBy, $direction = 'ASC') {
        $allowed = ['id', 'title', 'created_at'];
        if (!in_array($orderBy, $allowed)) $orderBy = 'created_at';
        $direction = strtoupper($direction) === 'DESC' ? 'DESC' : 'ASC';
        
        $sql = "SELECT p.*, GROUP_CONCAT(t.tech_name SEPARATOR ', ') AS technologies 
                FROM projects p 
                LEFT JOIN technologies t ON p.id = t.project_id 
                GROUP BY p.id ORDER BY $orderBy $direction";
        $stmt = $this->pdo->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Удалить проект по id
    public function deleteProject($id) {
        $sql = "DELETE FROM projects WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$id]);
    }

    // Создать новый проект
    public function addProject($title, $description, $image, $created_at, $technologies) {
        try {
            $this->pdo->beginTransaction();
            
            $sql = "INSERT INTO projects (title, description, image, created_at) VALUES (?, ?, ?, ?)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$title, $description, $image, $created_at]);
            $projectId = $this->pdo->lastInsertId();
            
            // Добавляем технологии
            $techArray = array_map('trim', explode(',', $technologies));
            $sqlTech = "INSERT INTO technologies (project_id, tech_name) VALUES (?, ?)";
            $stmtTech = $this->pdo->prepare($sqlTech);
            foreach($techArray as $tech) {
                if(!empty($tech)) $stmtTech->execute([$projectId, $tech]);
            }
            
            $this->pdo->commit();
            return true;
        } catch(Exception $e) {
            $this->pdo->rollBack();
            return false;
        }
    }
}
?>