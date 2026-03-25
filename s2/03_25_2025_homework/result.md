## Отчёт по домашнему заданию «Репликация»

### Используемые файлы
- `docker-compose-repl.yaml` – описание всех контейнеров (master, replica1, replica2, logical_subscriber).

### 1. Подготовка физической репликации

#### 1.1. Запуск мастера и создание пользователя репликации
```powershell
docker-compose -f docker-compose-repl.yaml up -d master
Start-Sleep -Seconds 5

docker exec -it master psql -U db_practice_umarrina -d db_store -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'rep_pass';"
docker exec -it master psql -U db_practice_umarrina -d db_store -c "SELECT pg_create_physical_replication_slot('replica1_slot');"
docker exec -it master psql -U db_practice_umarrina -d db_store -c "SELECT pg_create_physical_replication_slot('replica2_slot');"
```

#### 1.2. Настройка pg_hba.conf
```powershell
docker exec -it master bash -c "echo 'host replication replicator 0.0.0.0/0 md5' >> /var/lib/postgresql/data/pg_hba.conf"
docker exec -it master psql -U db_practice_umarrina -d db_store -c "SELECT pg_reload_conf();"
```

#### 1.3. Копирование данных для реплик
```powershell
docker exec -it master pg_basebackup -h localhost -U replicator -D /tmp/backup -Fp -Xs -P -R
docker cp master:/tmp/backup/. ./replica1_data/
docker cp master:/tmp/backup/. ./replica2_data/
```

#### 1.4. Запуск всех сервисов
```powershell
docker-compose -f docker-compose-repl.yaml stop master
docker-compose -f docker-compose-repl.yaml up -d
```

### 2. Проверка физической репликации

#### 2.1. Статус репликации на мастере
```sql
SELECT application_name, state FROM pg_stat_replication;
```
```
 application_name |   state   
------------------+-----------
 walreceiver      | streaming
 walreceiver      | streaming
```

#### 2.2. Создание тестовой таблицы и вставка данных на мастере
```sql
CREATE TABLE test_phys (id int PRIMARY KEY, data text);
INSERT INTO test_phys VALUES (1, 'master data');
```

#### 2.3. Проверка данных на реплике1
```sql
SELECT * FROM test_phys;
```
```
 id |    data     
----+-------------
  1 | master data
```

#### 2.4. Попытка записи на реплике (запрещена)
```sql
INSERT INTO test_phys VALUES (2, 'replica write');
```
```
ERROR:  cannot execute INSERT in a read-only transaction
```

#### 2.5. Измерение задержки репликации (replication lag)
Нагрузка на мастере:
```sql
INSERT INTO test_phys SELECT generate_series(2,100000), 'load';
```
Во время выполнения нагрузочного запроса:
```sql
SELECT application_name, replay_lag FROM pg_stat_replication;
```
```
 application_name |   replay_lag    
------------------+-----------------
 walreceiver      | 00:00:00.004271
 walreceiver      | 00:00:00.003956
```

### 3. Логическая репликация

#### 3.1. Создание таблиц на мастере
```sql
CREATE TABLE test_logical (id int PRIMARY KEY, val text);
INSERT INTO test_logical VALUES (1, 'logical data'), (2, 'new row');

CREATE TABLE no_pk (id int, val text);
INSERT INTO no_pk VALUES (1, 'initial');
```

#### 3.2. Создание публикации
```sql
CREATE PUBLICATION mypub FOR TABLE test_logical, no_pk;
```

#### 3.3. Создание таблиц на подписчике (DDL не реплицируется)
```sql
CREATE TABLE test_logical (id int PRIMARY KEY, val text);
CREATE TABLE no_pk (id int, val text);
```

#### 3.4. Создание подписки
```sql
CREATE SUBSCRIPTION mysub
CONNECTION 'host=master port=5432 user=db_practice_umarrina password=f73aml4k9 dbname=db_store'
PUBLICATION mypub;
```

#### 3.5. Проверка репликации существующих данных
На подписчике:
```sql
SELECT * FROM test_logical;
```
```
 id |     val      
----+--------------
  1 | logical data
  2 | new row
```

#### 3.6. Репликация новых вставок
На мастере:
```sql
INSERT INTO test_logical VALUES (3, 'new after subscription');
```
На подписчике:
```sql
SELECT * FROM test_logical WHERE id = 3;
```
```
 id |          val           
----+------------------------
  3 | new after subscription
```

#### 3.7. DDL не реплицируется
На мастере:
```sql
ALTER TABLE test_logical ADD COLUMN new_col text;
```
На подписчике:
```sql
\d test_logical
```
```
            Table "public.test_logical"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           | not null |
 val    | text    |           |          |
```

#### 3.8. Таблица без первичного ключа и `REPLICA IDENTITY FULL`
На мастере (без `REPLICA IDENTITY`):
```sql
UPDATE no_pk SET val = 'updated' WHERE id = 1;
```
На подписчике значение не изменилось (строка осталась 'initial').

Установка `REPLICA IDENTITY FULL`:
```sql
ALTER TABLE no_pk REPLICA IDENTITY FULL;
UPDATE no_pk SET val = 'updated2' WHERE id = 1;
```
На подписчике:
```sql
SELECT * FROM no_pk;
```
```
 id |   val   
----+---------
  1 | updated2
```

#### 3.9. Статус логической репликации
На мастере:
```sql
SELECT slot_name, active, confirmed_flush_lsn FROM pg_replication_slots;
```
```
 slot_name | active | confirmed_flush_lsn 
-----------+--------+---------------------
 mysub     | t      | 0/50307B8
```

На подписчике:
```sql
SELECT subname, pid, received_lsn, latest_end_lsn FROM pg_stat_subscription;
```
```
 subname | pid | received_lsn | latest_end_lsn 
---------+-----+--------------+----------------
 mysub   | 123 | 0/50307B8    | 0/50307B8
```

### 4. Выводы
- Физическая репликация настроена и работает: реплики синхронизируются, запись на них запрещена, задержка репликации минимальна (единицы миллисекунд).
- Логическая репликация позволяет выборочно реплицировать таблицы. DDL не реплицируется. Для таблиц без первичного ключа необходимо явно указать `REPLICA IDENTITY FULL`, чтобы изменения передавались на подписчика.
- Все пункты домашнего задания выполнены.