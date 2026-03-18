## 2. Анализ изменения LSN и WAL

### 2.1 Сравнение LSN до и после INSERT (одиночная вставка)

**До INSERT:**
```
0/E753EEC8
```

**После INSERT (одна строка):**
```
0/E75429F8
```

**Разница в байтах:**
```
15152
```
*Вывод:* одиночная вставка сгенерировала около 15 152 байт журнальных записей.

### 2.2 Сравнение WAL до и после COMMIT

**До COMMIT:**
```
0/E7542B00
```

**После INSERT (до COMMIT):**
```
0/E7542BA0
```

**После COMMIT:**
```
0/E7546B78
```

**Разница «после COMMIT» – «после INSERT»:**
```
16344
```

**Общая разница от начала до конца:**
```
16504
```
*Вывод:* сам COMMIT добавляет примерно 16 344 байта, а общий объём WAL за всю транзакцию составил 16 504 байта.

### 2.3 Анализ размера WAL после массовой операции (10 000 строк)

**До массовой вставки:**
```
0/EAB4A240
```

**После массовой вставки:**
```
0/EBD24560
```

**Разница в байтах:**
```
18719520
```

**Перевод в мегабайты:**
```
18719520 / 1024 / 1024 ≈ 17.85 МБ
```

*Вывод:* массовая вставка 10000 строк сгенерировала около 17.85 МБ журнальных записей, что составляет примерно 1.8 КБ на одну строку (с учётом индексов и служебной информации).


## 3. Сделать дамп БД и накатить его на новую чистую БД

Устанавливаем кодировку (необходимо, чтобы избежать проблемы с распознанием русских символов)
```bash
chcp 65001
```

### 3.1 Дамп только структуры базы (без данных)
```bash
docker exec -t db_practice pg_dump -U db_practice_umarrina -d db_store --schema-only > s2\03_18_2026_homework\dump\schema_dump.sql
```

### 3.2 Дамп одной таблицы
```bash
docker exec -t db_practice pg_dump -U db_practice_umarrina -d db_store --table=warehouse.customer > s2\03_18_2026_homework\dump\customer_dump.sql
```

### 3.3 Создать новую чистую БД и накатить дамп
```bash
docker exec -it db_practice psql -U db_practice_umarrina -d postgres -c "CREATE DATABASE db_store_restore;"

docker exec -i db_practice psql -U db_practice_umarrina -d db_store_restore < s2\03_18_2026_homework\dump\schema_dump.sql

docker exec -i db_practice psql -U db_practice_umarrina -d db_store_restore < s2/03_18_2026_homework/dump/customer_dump.sql
```

Проверка:
```bash
docker exec -it db_practice psql -U db_practice_umarrina -d db_store_restore -c "\dt warehouse.*"
```

Вывод:
```
                       List of relations
  Schema   |        Name        | Type  |        Owner
-----------+--------------------+-------+----------------------
 warehouse | customer           | table | db_practice_umarrina
 warehouse | customer_archive   | table | db_practice_umarrina
 warehouse | customer_order     | table | db_practice_umarrina
 warehouse | employee           | table | db_practice_umarrina
 warehouse | log                | table | db_practice_umarrina
 warehouse | manager            | table | db_practice_umarrina
 warehouse | manager_change_log | table | db_practice_umarrina
 warehouse | order_item         | table | db_practice_umarrina
 warehouse | order_log          | table | db_practice_umarrina
 warehouse | payment            | table | db_practice_umarrina
 warehouse | payment_status     | table | db_practice_umarrina
 warehouse | product_catalog    | table | db_practice_umarrina
 warehouse | product_category   | table | db_practice_umarrina
 warehouse | product_inventory  | table | db_practice_umarrina
 warehouse | supplier           | table | db_practice_umarrina
 warehouse | warehouse          | table | db_practice_umarrina
(16 rows)
```

## 4️. Создать несколько seed

Использовала файл seed_data.sql из первой домашки

Применение seed:

```bash
docker cp "s2\02_18_2026_homework\seed_data.sql" db_practice:/tmp/seed.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/seed.sql
```

Проверка идемпотентности (запуск второй раз):

```bash
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/seed.sql
```

Вывод:
```
INSERT 0 0
INSERT 0 0
INSERT 0 0
INSERT 0 0
INSERT 0 0
INSERT 0 0
INSERT 0 250000
INSERT 0 250000
INSERT 0 250000
INSERT 0 999986
INSERT 0 1250000
```

Первые 6 строк – вставка в справочники (product_category, payment_status и др.) – дают 0, потому что записи с такими id уже существуют (использован ON CONFLICT (id) DO NOTHING). Это идемпотентность.

Далее идут массовые вставки в основные таблицы (customer, product_catalog, customer_order, order_item, payment). Они генерируют новые id через последовательности, поэтому при повторном запуске добавляются новые строки (что видно по ненулевым значениям). Это особенность тестовых данных – они предназначены для наполнения большими объёмами, и идемпотентность здесь не требуется (seed обычно выполняется один раз при инициализации).

**Создадим второй seed: "seed_data_2.sql"**

Применение seed:

```bash
docker cp "s2\03_18_2026_homework\seed_data_2.sql" db_practice:/tmp/seed_data_2.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/seed_data_2.sql
```

Проверка идемпотентности (запуск второй раз):

```bash
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/seed_data_2.sql
```

Вывод:
```
INSERT 0 0
INSERT 0 0
```

Вывод:
- Категории не вставились повторно – сработал ON CONFLICT (id).
- Товары не вставились повторно. Перед проведением скрипта выяснила, что кол-во строк 2250004. Первый запуск вставил данные, последующие запуски - нет