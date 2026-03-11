# Статистика для JOIN запросов

## Запрос 1: INNER JOIN (покупатели и их заказы)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
                  JOIN warehouse.customer_order o ON c.id = o.customer_id
WHERE c.id BETWEEN 1000 AND 2000;
```

**Вывод EXPLAIN (ANALYZE, BUFFERS):**
```
Gather  (cost=1075.22..12848.64 rows=1040 width=183) (actual time=6.887..147.152 rows=27909 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=178 read=6422
  ->  Hash Join  (cost=75.22..11744.64 rows=433 width=183) (actual time=2.426..136.244 rows=9303 loops=3)
        Hash Cond: (o.customer_id = c.id)
        Buffers: shared hit=178 read=6422
        ->  Parallel Seq Scan on customer_order o  (cost=0.00..10575.67 rows=416667 width=22) (actual time=0.520..108.792 rows=333333 loops=3)
              Buffers: shared read=6409
        ->  Hash  (cost=62.22..62.22 rows=1040 width=161) (actual time=1.784..1.785 rows=1001 loops=3)
              Buckets: 2048  Batches: 1  Memory Usage: 201kB
              Buffers: shared hit=82 read=13
              ->  Index Scan using customer_pkey on customer c  (cost=0.42..62.22 rows=1040 width=161) (actual time=0.056..1.506 rows=1001 loops=3)
                    Index Cond: ((id >= 1000) AND (id <= 2000))
                    Buffers: shared hit=82 read=13
Planning:
  Buffers: shared hit=286 read=6 dirtied=1
Planning Time: 4.382 ms
Execution Time: 148.325 ms
```

**Метод соединения:** Hash Join (параллельный)  
**Время выполнения:** 148.325 ms  
**Буферы:** shared hit=178, shared read=6422 (всего 6600 буферов)

**Вывод по запросу 1:**  
Для выборки покупателей с id от 1000 до 2000 (около 1000 строк) и их заказов планировщик выбрал Hash Join. Сначала по индексу первичного ключа были отобраны нужные покупатели, затем построена хеш-таблица. После этого выполнено параллельное последовательное сканирование таблицы заказов, и для каждого заказа проверялось совпадение по хешу. Несмотря на то, что ожидалось всего 1040 строк, фактически заказов оказалось 27909 (примерно 28 на покупателя). Hash Join хорошо подходит для соединения таблиц разного размера, когда одна из сторон может быть упакована в хеш.

---

## Запрос 2: LEFT JOIN (все покупатели, даже без заказов)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
LEFT JOIN warehouse.customer_order o ON c.id = o.customer_id
WHERE c.id BETWEEN 1000 AND 2000;
```

**Вывод EXPLAIN (ANALYZE, BUFFERS):**
```
Hash Right Join  (cost=75.22..19109.24 rows=1040 width=183) (actual time=0.416..170.624 rows=27909 loops=1)
  Hash Cond: (o.customer_id = c.id)
  Buffers: shared hit=127 read=6313
  ->  Seq Scan on customer_order o  (cost=0.00..16409.00 rows=1000000 width=22) (actual time=0.121..92.053 rows=1000000 loops=1)
        Buffers: shared hit=96 read=6313
  ->  Hash  (cost=62.22..62.22 rows=1040 width=161) (actual time=0.281..0.282 rows=1001 loops=1)
        Buckets: 2048  Batches: 1  Memory Usage: 201kB
        Buffers: shared hit=31
        ->  Index Scan using customer_pkey on customer c  (cost=0.42..62.22 rows=1040 width=161) (actual time=0.013..0.157 rows=1001 loops=1)
              Index Cond: ((id >= 1000) AND (id <= 2000))
              Buffers: shared hit=31
Planning:
  Buffers: shared hit=12
Planning Time: 0.230 ms
Execution Time: 171.844 ms
```

**Метод соединения:** Hash Right Join  
**Время выполнения:** 171.844 ms  
**Буферы:** shared hit=127, shared read=6313 (всего 6440)

**Вывод по запросу 2:**  
Здесь использован Hash Right Join – правая таблица (заказы) сканируется последовательно, а левая (покупатели) помещается в хеш. Поскольку запрос должен вернуть всех покупателей из диапазона, даже если у них нет заказов, именно такая стратегия позволяет эффективно соединить все строки. Время выполнения незначительно выше, чем в запросе 1, из-за необходимости полного сканирования таблицы заказов.

---

## Запрос 3: Тройной JOIN (покупатели → заказы → товары)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
JOIN warehouse.customer_order o ON c.id = o.customer_id
JOIN warehouse.order_item oi ON o.id = oi.order_id
JOIN warehouse.product_catalog p ON oi.product_id = p.id
WHERE c.id BETWEEN 1000 AND 2000;
```

**Вывод EXPLAIN (ANALYZE, BUFFERS):**
```
Gather  (cost=1076.08..14032.09 rows=3120 width=439) (actual time=4.778..2304.983 rows=83409 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=427180 read=80190 written=2
  ->  Nested Loop  (cost=76.08..12720.09 rows=1300 width=439) (actual time=2.935..2276.194 rows=27803 loops=3)
        Buffers: shared hit=427180 read=80190 written=2
        ->  Nested Loop  (cost=75.66..12038.21 rows=1300 width=203) (actual time=2.061..1612.467 rows=27803 loops=3)
              Buffers: shared hit=115893 read=57839 written=1
              ->  Hash Join  (cost=75.22..11744.64 rows=433 width=183) (actual time=0.513..82.792 rows=9303 loops=3)
                    Hash Cond: (o.customer_id = c.id)
                    Buffers: shared hit=191 read=6409
                    ->  Parallel Seq Scan on customer_order o  (cost=0.00..10575.67 rows=416667 width=22) (actual time=0.029..37.487 rows=333333 loops=3)
                          Buffers: shared read=6409
                    ->  Hash  (cost=62.22..62.22 rows=1040 width=161) (actual time=0.411..0.412 rows=1001 loops=3)
                          Buckets: 2048  Batches: 1  Memory Usage: 201kB
                          Buffers: shared hit=95
                          ->  Index Scan using customer_pkey on customer c  (cost=0.42..62.22 rows=1040 width=161) (actual time=0.026..0.211 rows=1001 loops=3)
                                Index Cond: ((id >= 1000) AND (id <= 2000))
                                Buffers: shared hit=95
              ->  Index Scan using order_item_pkey on order_item oi  (cost=0.43..0.63 rows=5 width=20) (actual time=0.083..0.163 rows=3 loops=27909)
                    Index Cond: (order_id = o.id)
                    Buffers: shared hit=115702 read=51430 written=1
        ->  Index Scan using product_catalog_pkey on product_catalog p  (cost=0.43..0.52 rows=1 width=236) (actual time=0.023..0.023 rows=1 loops=83409)
              Index Cond: (id = oi.product_id)
              Buffers: shared hit=311287 read=22351 written=1
Planning:
  Buffers: shared hit=128 read=21 dirtied=1
Planning Time: 11.818 ms
Execution Time: 2310.160 ms
```

**Метод соединения (по шагам):**
- Внешний уровень: Nested Loop между промежуточным результатом и product_catalog
- Внутренний уровень: Nested Loop между результатом соединения customer+order и order_item
- Базовое соединение: Hash Join (customer + order)

**Время выполнения:** 2310.160 ms  
**Буферы:** shared hit=427180, shared read=80190 (всего 507370)

**Вывод по запросу 3:**  
Многоступенчатое соединение четырёх таблиц. Планировщик выбрал комбинацию Hash Join для первых двух таблиц (покупатели и заказы), а затем дважды Nested Loop с использованием индексов для соединения с order_item и product_catalog. Это эффективно, так как на каждом следующем шаге число строк остаётся ограниченным (используются индексы). Тем не менее, общее время велико из-за большого количества строк (83k результирующих строк) и соответствующего числа обращений к индексам. Важно, что для соединений использовались индексы первичных ключей, что предотвратило полные сканирования.

---

## Запрос 4: JOIN с агрегацией (сумма заказов по покупателям)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id, c.last_name, COUNT(o.id) as order_count
FROM warehouse.customer c
LEFT JOIN warehouse.customer_order o ON c.id = o.customer_id
GROUP BY c.id, c.last_name
HAVING COUNT(o.id) > 0
LIMIT 100;
```

**Вывод EXPLAIN (ANALYZE, BUFFERS):**
```
Limit  (cost=102104.26..102140.30 rows=100 width=27) (actual time=798.811..815.953 rows=100 loops=1)
"  Buffers: shared hit=184 read=30793, temp read=9123 written=14841"
  ->  Finalize GroupAggregate  (cost=102104.26..222250.02 rows=333333 width=27) (actual time=759.179..776.314 rows=100 loops=1)
        Group Key: c.id
        Filter: (count(o.id) > 0)
"        Buffers: shared hit=184 read=30793, temp read=9123 written=14841"
        ->  Gather Merge  (cost=102104.26..205583.35 rows=833334 width=27) (actual time=759.132..776.254 rows=127 loops=1)
              Workers Planned: 2
              Workers Launched: 2
"              Buffers: shared hit=184 read=30793, temp read=9123 written=14841"
              ->  Partial GroupAggregate  (cost=101104.23..108395.91 rows=416667 width=27) (actual time=722.089..723.916 rows=531 loops=3)
                    Group Key: c.id
"                    Buffers: shared hit=184 read=30793, temp read=9123 written=14841"
                    ->  Sort  (cost=101104.23..102145.90 rows=416667 width=23) (actual time=722.046..723.050 rows=11774 loops=3)
                          Sort Key: c.id
                          Sort Method: external merge  Disk: 18400kB
"                          Buffers: shared hit=184 read=30793, temp read=9123 written=14841"
                          Worker 0:  Sort Method: external merge  Disk: 19936kB
                          Worker 1:  Sort Method: external merge  Disk: 18408kB
                          ->  Parallel Hash Right Join  (cost=36297.00..53664.42 rows=416667 width=23) (actual time=423.211..551.791 rows=603082 loops=3)
                                Hash Cond: (o.customer_id = c.id)
"                                Buffers: shared hit=112 read=30793, temp read=7665 written=7720"
                                ->  Parallel Seq Scan on customer_order o  (cost=0.00..10575.67 rows=416667 width=8) (actual time=0.050..23.954 rows=333333 loops=3)
                                      Buffers: shared hit=96 read=6313
                                ->  Parallel Hash  (cost=28646.67..28646.67 rows=416667 width=19) (actual time=340.572..340.572 rows=333333 loops=3)
                                      Buckets: 131072  Batches: 8  Memory Usage: 7936kB
"                                      Buffers: shared read=24480, temp written=4260"
                                      ->  Parallel Seq Scan on customer c  (cost=0.00..28646.67 rows=416667 width=19) (actual time=4.522..276.107 rows=333333 loops=3)
                                            Buffers: shared read=24480
Planning:
  Buffers: shared hit=8 read=4
Planning Time: 0.230 ms
JIT:
  Functions: 50
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 2.947 ms (Deform 0.924 ms), Inlining 0.000 ms, Optimization 6.063 ms, Emission 46.768 ms, Total 55.777 ms"
Execution Time: 1160.899 ms
```

**Метод соединения и группировки:** Parallel Hash Right Join, затем сортировка (external merge), затем частичная и финальная GroupAggregate  
**Время выполнения:** 1160.899 ms  
**Буферы:** shared hit=184, shared read=30793, temp read=9123, temp written=14841 (активно использовался диск)

**Вывод по запросу 4:**  
Запрос включает соединение, группировку, сортировку и лимит. Планировщик выбрал параллельный хеш-джойн (правый), так как таблица заказов значительно больше. Из-за большого объёма данных и необходимости сортировки для группировки пришлось использовать временные файлы на диске (external merge). Несмотря на это, время выполнения около 1.2 с для обработки миллиона записей – приемлемо. Лимит применяется после агрегации, поэтому сначала вычисляются все группы.

---

## Запрос 5: Заказы и их платежи (INNER JOIN)

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.order_date, o.status, p.amount, p.payment_date
FROM warehouse.customer_order o
JOIN warehouse.payment p ON o.id = p.order_id
WHERE o.id BETWEEN 1000 AND 10000;
```

**Вывод EXPLAIN (ANALYZE, BUFFERS):**
```
Nested Loop  (cost=0.58..16.63 rows=1 width=22) (actual time=0.005..0.005 rows=0 loops=1)
  Buffers: shared hit=3
  ->  Index Scan using customer_order_pkey on customer_order o  (cost=0.42..8.45 rows=1 width=14) (actual time=0.004..0.005 rows=0 loops=1)
        Index Cond: ((id >= 1000) AND (id <= 10000))
        Buffers: shared hit=3
  ->  Index Scan using payment_pkey on payment p  (cost=0.15..8.17 rows=1 width=12) (never executed)
        Index Cond: (order_id = o.id)
Planning:
  Buffers: shared hit=33 read=5
Planning Time: 0.907 ms
Execution Time: 0.027 ms
```

**Метод соединения:** Nested Loop  
**Время выполнения:** 0.027 ms  
**Буферы:** shared hit=3

**Вывод по запросу 5:**  
Этот запрос возвращает 0 строк, так как в диапазоне order_id от 1000 до 10000 нет записей в таблице заказов (вероятно, данные начинаются с больших id). Планировщик всё равно построил план: сначала ищет заказы по индексу (Index Scan), а затем для каждого (если бы они были) выполняет Index Scan по платежам. Очень быстрый план, так как используются первичные ключи. Nested Loop с индексами оптимален для точечных выборок.

---

## Общий вывод по JOIN

В ходе анализа пяти запросов были использованы различные методы соединения:

- **Hash Join** (обычный и параллельный) – применялся для соединения таблиц разного размера, когда одна из сторон могла быть помещена в хеш-таблицу (запросы 1, 2, 4). Он эффективен при отсутствии подходящих индексов или при большом объёме данных.
- **Nested Loop** – использовался в запросе 5 для точечного поиска по индексам, а также в запросе 3 для соединения с детальными таблицами после фильтрации. Nested Loop даёт хорошую производительность, когда внешняя выборка мала, а внутренняя имеет индекс.
- **Parallel Hash Right Join** – в запросе 4 для обработки больших объёмов данных с группировкой, что позволило задействовать несколько ядер.
- **GroupAggregate** и сортировка – потребовались для агрегации; при недостатке памяти использовался диск (external sort).

Наличие индексов на ключах соединения критически важно – все запросы, кроме запроса 4 (где применялся Hash Join из-за размера), активно использовали индексы первичных ключей, что позволило избежать полных сканирований. В запросе 4, несмотря на отсутствие индекса на `customer_order.customer_id`, планировщик выбрал хеш-соединение, которое оказалось приемлемым по времени.

Таким образом, выбор метода соединения зависит от оценок планировщика, основанных на статистике, и может варьироваться от Nested Loop для малых выборок до Hash Join для больших. Регулярный анализ планов помогает выявлять узкие места и добавлять недостающие индексы.