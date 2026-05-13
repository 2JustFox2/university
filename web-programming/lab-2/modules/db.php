<?php

class DataBase {
    private $host = '127.0.0.1';
    private $user = 'root';
    private $pass = '';
    private $db = 'web';
    private $port = 3306;
    private $mysqli = null;
    
    function __construct() {
        // Подключение с правильной передачей порта
        $this->mysqli = new mysqli($this->host, $this->user, $this->pass, $this->db, $this->port);
        
        if ($this->mysqli->connect_error) {
            throw new Exception('Ошибка подключения: ' . $this->mysqli->connect_error);
        }
        
        $this->mysqli->set_charset('utf8mb4');
    }

    public function insert($tableName, array $data) {
        if (!$data) {
            throw new Exception('Нет данных для добавления.');
        }

        $columns = array_keys($data);
        $placeholders = array_fill(0, count($data), '?');
        $types = str_repeat('s', count($data));

        $sql = 'INSERT INTO `' . $tableName . '` (`' . implode('`, `', $columns) . '`) VALUES (' . implode(', ', $placeholders) . ')';
        $stmt = $this->mysqli->prepare($sql);

        if (!$stmt) {
            throw new Exception('Ошибка подготовки запроса: ' . $this->mysqli->error);
        }

        $values = array_values($data);
        $bindValues = [];
        $bindValues[] = $types;

        foreach ($values as $index => $value) {
            $bindValues[] = &$values[$index];
        }

        call_user_func_array([$stmt, 'bind_param'], $bindValues);

        if (!$stmt->execute()) {
            throw new Exception('Ошибка добавления записи: ' . $stmt->error);
        }

        return $stmt->insert_id;
    }
    
    public function getAll($tableName, $search = null) {
        $query = 'SELECT * FROM ' . $tableName;
        
        if ($search) {
            $searchEscaped = $this->mysqli->real_escape_string($search);
            $query .= " WHERE `name` LIKE '%$searchEscaped%'";
        }
        
        $obj = $this->mysqli->query($query);
        
        if (!$obj) {
            throw new Exception('Ошибка запроса: ' . $this->mysqli->error);
        }
        
        $result = [];
        
        while ($row = $obj->fetch_assoc()) {
            $result[$row['id']] = $row;
        }
        
        return $result;
    }
}

$DataBase = new DataBase();