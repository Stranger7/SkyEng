Задача №4
=========
Исходя из условий задачи предполагаемый размер файла:
```
line_count = (250 000 users * 100 visits + 750 000 users) * 365 days * 5 years = 46 993 750 000
line_size = strlen("1234567890 2013-03-08 12:26:09\n") = 31 bytes
file_size = line_count * line_size = 1 456 806 250 000 bytes
```
То есть файл размером в полтора терабайта при условии, что 250 тысяч активных пользователей
ежедневно посещают сайт.

Очевидно, что для обработки такого объема данных необходимо использовать СУБД с
возможностью партиционирования таблиц.

1. Создание таблицы
-------------------
Партиционировать предлагаю помесячно.
Таблица должна содержать два поля:
+ user_id INT
+ timestamp INT

Если использовать MySQL, то примерный скрипт создания таблицы выглядит следующим образом:
```
 CREATE TABLE log (
     `user_id` INT UNSIGNED,
     `timestamp` INT UNSIGNED,
 ) ENGINE = MYISAM
 PARTITION BY RANGE (`timestamp`) (
     PARTITION p_2010_01 VALUES LESS THAN(unix-timestamp для 2010/01/01 00:00:00),
     PARTITION p_2010_02 VALUES LESS THAN(unix-timestamp для 2010/02/01 00:00:00),
     ...
     PARTITION p_2015_07 VALUES LESS THAN(MAXVALUE)
 );
 CREATE INDEX idx1 ON log (`user_id`, `timestamp`);
```
*_Примечание:_* Вычислить unix-timestamp можно с помощью функции mktime

2. Загрузка данных
------------------
Загрузку данных осуществлять транзакциями, например, по миллиону записей в зависимости
от производительности сервера.
В момент загрузки преобразовывать идентификаторы пользователей и время записи к числовому типу
с целью уменьшения объема данных и ускорения последующей выборки.
Схематично скрипт может выглядеть так:
```
DEFINE('MAX_INSERTS', 1000000);
$source = fopen($filename, 'rt');
$insert_count = 0;
while (($buffer = fgets($source)) !== false)
{
    list($user_id, $timestamp) = explode(' ', $buffer); 
    if ($insert_count == 0)
    {
        $db->query('BEGIN');
    }
    $sql = 'INSERT INTO log (user_id, timestamp) VALUES (' . (int) $user_id ', ' . strtotime($timestamp) . ')';
    $db->query($sql);
    $insert_count++;
    if ($insert_count == MAX_INSERTS)
    {
        $db->query('COMMIT');
        $insert_count = 0;
    }
}
```

3. Формирование результирующего файла
-------------------------------------
Выгрузку осуществлять по циклу подиапазонно по user_id для ограничения объема возвращаемых данных
(весь результат выборки не должен превышать размер кеша).

Алгоритм выгрузки выглядит следующим образом:
```
$min_user_id = $db->query('SELECT MIN(user_id) AS min_user_id')->run()->row()->min_user_id;
$max_user_id = $db->query('SELECT MAX(user_id) AS max_user_id')->run()->row()->max_user_id;
// Выборку делать для диапазона, например, в 50 тысяч.
$step = 50000; 
// Количество выборок
$range_count = (int) ceil(($max_user_id - $min_user_id) / $step);
for ($i = 0; $i < $range_count; $i++)
{
   $curr_min_user_id = $min_user_id + $i * $step;
   $curr_max_user_id = $min_user_id + ($i + 1) * $step - 1;
   $sql = "SELECT * FROM log "
        . "WHERE user_id BETWEEN $curr_min_user_id AND $curr_max_user_id "
        . "ORDER BY user_id, timestamp"
   foreach($db->query()->result($sql) as $row)
   {
       fputs($file, $row->user_id . ' ' . date('d/m/Y h:i:s', (int) $row->timestamp ));
   }
}
```
