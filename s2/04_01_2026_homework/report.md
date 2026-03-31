### 1. Секционирование (RANGE, LIST, HASH)

#### 1.1. RANGE секционирование (таблица `logs`)

Создана таблица `logs` с секционированием по диапазону `created_at`. Секции: `logs_2026_03` (март), `logs_2026_04` (апрель). Вставлены три строки.

**Запрос 1 (условие в одной секции):**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE created_at >= '2026-03-01' AND created_at < '2026-04-01';
```
**Вывод:**
```
Seq Scan on logs_2026_03 logs  (cost=0.00..1.03 rows=1 width=44) (actual time=0.012..0.013 rows=2 loops=1)
  Filter: ((created_at >= '2026-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2026-04-01 00:00:00'::timestamp without time zone))
  Buffers: shared hit=1
Planning Time: 0.200 ms
Execution Time: 0.025 ms
```
- **Partition pruning**: да, затронута только секция `logs_2026_03`.
- **Количество секций в плане**: 1.
- **Использование индекса**: Seq Scan (после создания индекса на `created_at` – Index Scan).

**Запрос 2 (условие пересекает две секции):**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE created_at >= '2026-03-15' AND created_at < '2026-04-15';
```
**Вывод:**
```
Append  (cost=0.00..2.05 rows=2 width=44) (actual time=0.023..0.027 rows=3 loops=1)
  Buffers: shared hit=2
  ->  Seq Scan on logs_2026_03 logs_1  (cost=0.00..1.03 rows=1 width=44) (actual time=0.023..0.023 rows=2 loops=1)
        Filter: ((created_at >= '2026-03-15 00:00:00'::timestamp without time zone) AND (created_at < '2026-04-15 00:00:00'::timestamp without time zone))
        Buffers: shared hit=1
  ->  Seq Scan on logs_2026_04 logs_2  (cost=0.00..1.01 rows=1 width=44) (actual time=0.002..0.003 rows=1 loops=1)
        Filter: ((created_at >= '2026-03-15 00:00:00'::timestamp without time zone) AND (created_at < '2026-04-15 00:00:00'::timestamp without time zone))
        Buffers: shared hit=1
Planning Time: 0.322 ms
Execution Time: 0.040 ms
```
- Затронуты две секции, соответствующие диапазону.

**Запрос 3 (условие не по ключу):**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE message LIKE '%Сообщение%';
```
**Вывод:**
```
Append  (cost=0.00..2.05 rows=2 width=44) (actual time=0.014..0.019 rows=3 loops=1)
  Buffers: shared hit=2
  ->  Seq Scan on logs_2026_03 logs_1  (cost=0.00..1.02 rows=1 width=44) (actual time=0.013..0.014 rows=2 loops=1)
        Filter: (message ~~ '%Сообщение%'::text)
        Buffers: shared hit=1
  ->  Seq Scan on logs_2026_04 logs_2  (cost=0.00..1.01 rows=1 width=44) (actual time=0.003..0.003 rows=1 loops=1)
        Filter: (message ~~ '%Сообщение%'::text)
        Buffers: shared hit=1
Planning Time: 0.124 ms
Execution Time: 0.038 ms
```
- Сканируются все секции, так как условие не содержит ключа секционирования.

#### 1.2. LIST секционирование (таблица `cities`)

Создана таблица `cities` с секционированием по списку `region`. Секции: `cities_center`, `cities_north`, `cities_south`. Вставлены три города.

**Запрос по ключу секционирования:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM cities WHERE region = 'Центральный';
```
**Вывод:**
```
Seq Scan on cities_center cities  (cost=0.00..20.62 rows=4 width=68) (actual time=0.012..0.013 rows=1 loops=1)
  Filter: (region = 'Центральный'::text)
  Buffers: shared hit=1
Planning Time: 0.265 ms
Execution Time: 0.026 ms
```
- Partition pruning: затронута только секция `cities_center`.

**Запрос не по ключу:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM cities WHERE name = 'Москва';
```
**Вывод:**
```
Append  (cost=0.00..61.94 rows=12 width=68) (actual time=0.012..0.015 rows=1 loops=1)
  Buffers: shared hit=3
  ->  Seq Scan on cities_north cities_1  (cost=0.00..20.62 rows=4 width=68) (actual time=0.009..0.009 rows=0 loops=1)
        Filter: (name = 'Москва'::text)
        Rows Removed by Filter: 1
        Buffers: shared hit=1
  ->  Seq Scan on cities_center cities_2  (cost=0.00..20.62 rows=4 width=68) (actual time=0.002..0.002 rows=1 loops=1)
        Filter: (name = 'Москва'::text)
        Buffers: shared hit=1
  ->  Seq Scan on cities_south cities_3  (cost=0.00..20.62 rows=4 width=68) (actual time=0.002..0.002 rows=0 loops=1)
        Filter: (name = 'Москва'::text)
        Rows Removed by Filter: 1
        Buffers: shared hit=1
Planning Time: 0.143 ms
Execution Time: 0.029 ms
```
- Сканируются все три секции.

#### 1.3. HASH секционирование (таблица `users`)

Создана таблица `users` с секционированием по хешу от `id` на 2 секции. Вставлены 4 строки.

**Запрос с условием по ключу:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id = 3;
```
**Вывод:**
```
Index Scan using users_p1_pkey on users_p1 users  (cost=0.15..8.17 rows=1 width=36) (actual time=0.012..0.013 rows=1 loops=1)
  Index Cond: (id = 3)
  Buffers: shared hit=2
Planning Time: 0.213 ms
Execution Time: 0.042 ms
```
- Partition pruning: затронута только секция `users_p1`.
- Используется индекс первичного ключа.

**Запрос без фильтра:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users;
```
**Вывод:**
```
Append  (cost=0.00..58.10 rows=2540 width=36) (actual time=0.006..0.010 rows=4 loops=1)
  Buffers: shared hit=2
  ->  Seq Scan on users_p0 users_1  (cost=0.00..22.70 rows=1270 width=36) (actual time=0.005..0.006 rows=2 loops=1)
        Buffers: shared hit=1
  ->  Seq Scan on users_p1 users_2  (cost=0.00..22.70 rows=1270 width=36) (actual time=0.002..0.002 rows=2 loops=1)
        Buffers: shared hit=1
Planning Time: 0.070 ms
Execution Time: 0.072 ms
```
- Сканируются обе секции.

### 2. Физическая репликация

После настройки физической репликации проверено, что секционированные таблицы присутствуют на реплике (контейнер `replica1`):

```sql
-- на мастере
SELECT * FROM partitioning_demo.logs;
```
Вывод:
```
 id |     created_at      |   message
----+---------------------+-------------
  1 | 2026-03-15 10:00:00 | Сообщение 1
  2 | 2026-03-20 12:00:00 | Сообщение 2
  3 | 2026-04-05 15:00:00 | Сообщение 3
```
Аналогичный вывод на реплике подтверждает синхронизацию.

**Вывод:** физическая репликация копирует структуру и данные секционированных таблиц как обычных таблиц. Репликация «не знает» о логике секционирования – она воспроизводит изменения на уровне страниц (WAL).

### 3. Логическая репликация

#### 3.1. publish_via_partition_root = off

На мастере создана публикация `pub_logs_off` для таблицы `logs`. На подписчике (контейнер `logical_subscriber`) создана идентичная секционированная таблица. Подписка `sub_logs_off` скопировала данные.

**Вставка новой строки на мастере:**
```sql
INSERT INTO partitioning_demo.logs (created_at, message) VALUES ('2026-03-25 12:00:00', 'test off');
```
На подписчике строка попала в секцию `logs_2026_03`.

#### 3.2. publish_via_partition_root = on

На мастере создана публикация `pub_logs_on` с опцией `publish_via_partition_root = on`. На подписчике создана обычная несекционированная таблица `logs_flat`. Подписка `sub_logs_on` скопировала все данные в эту таблицу.

**Вставка новой строки на мастере:**
```sql
INSERT INTO partitioning_demo.logs (created_at, message) VALUES ('2026-04-10 12:00:00', 'test on');
```
На подписчике строка попала в `logs_flat` без разделения на секции.

**Вывод:** при `off` изменения направляются в конкретные секции, требуя идентичной структуры на подписчике; при `on` изменения направляются в родительскую таблицу, позволяя подписчику иметь другую структуру.

### 4. Шардирование через postgres_fdw

Созданы базы `shard1`, `shard2`, `router`. В шардах размещены записи:

- `shard1.users`: (1, 'Alice'), (3, 'Charlie')
- `shard2.users`: (2, 'Bob'), (4, 'David')

В базе `router` настроены внешние серверы, внешние таблицы и представление `all_users`.

**Запрос на все данные:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM all_users;
```
```
Append  (cost=100.00..834.25 rows=2730 width=36) (actual time=1.981..4.347 rows=4 loops=1)
  ->  Foreign Scan on users_shard1  (cost=100.00..410.30 rows=1365 width=36) (actual time=1.979..1.980 rows=2 loops=1)
  ->  Foreign Scan on users_shard2  (cost=100.00..410.30 rows=1365 width=36) (actual time=2.360..2.361 rows=2 loops=1)
Planning Time: 0.350 ms
Execution Time: 21.388 ms
```
- Сканируются оба шарда.

**Запрос к одному шарду:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users_shard1 WHERE id = 1;
```
```
Foreign Scan on users_shard1  (cost=100.00..128.53 rows=7 width=36) (actual time=1.399..1.401 rows=1 loops=1)
Planning Time: 0.255 ms
Execution Time: 2.164 ms
```
- Затронут только нужный шард.

**Запрос с фильтром через представление:**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM all_users WHERE id = 1;
```
```
Append  (cost=100.00..257.13 rows=14 width=36) (actual time=0.819..3.644 rows=1 loops=1)
  ->  Foreign Scan on users_shard1  (cost=100.00..128.53 rows=7 width=36) (actual time=0.818..0.820 rows=1 loops=1)
  ->  Foreign Scan on users_shard2  (cost=100.00..128.53 rows=7 width=36) (actual time=2.820..2.820 rows=0 loops=1)
Planning Time: 0.246 ms
Execution Time: 4.890 ms
```
- Фильтр `id = 1` не проталкивается через `UNION ALL`, поэтому сканируются оба шарда, несмотря на наличие данных только в одном.

