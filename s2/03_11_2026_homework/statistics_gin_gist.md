# Статистика для GIN и GiST индексов

## GIN запросы

### Запрос 1: `preferences ? 'newsletter'`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences ? 'newsletter';
```
**Вывод:**
```
Seq Scan on customer  (cost=0.00..36980.00 rows=1000000 width=161) (actual time=1.284..496.562 rows=1000000 loops=1)
  Filter: (preferences ? 'newsletter'::text)
  Buffers: shared read=24480
Planning:
  Buffers: shared hit=68 read=4
Planning Time: 3.505 ms
Execution Time: 534.484 ms
```

#### После создания GIN индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences ? 'newsletter';
```
**Вывод:**
```
Seq Scan on customer  (cost=0.00..36980.00 rows=1000000 width=161) (actual time=0.010..411.302 rows=1000000 loops=1)
  Filter: (preferences ? 'newsletter'::text)
  Buffers: shared hit=221 read=24259
Planning:
  Buffers: shared hit=1
Planning Time: 0.067 ms
Execution Time: 446.992 ms
```

**Вывод по запросу 1:**  
Все строки таблицы customer содержат ключ 'newsletter' в поле preferences, поэтому условие неселективно. В обоих случаях используется последовательное сканирование, и индекс не применяется.
---

### Запрос 2: `preferences @> '{"theme": "dark"}'`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences @> '{"theme": "dark"}';
```
**Вывод:**
```
Seq Scan on customer  (cost=0.00..36980.00 rows=502067 width=161) (actual time=0.107..282.117 rows=499335 loops=1)
"  Filter: (preferences @> '{""theme"": ""dark""}'::jsonb)"
  Rows Removed by Filter: 500665
  Buffers: shared hit=32 read=24448
Planning Time: 0.103 ms
Execution Time: 300.612 ms
```

#### После создания GIN индекса
**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences @> '{"theme": "dark"}';
```
**Вывод:**
```
Bitmap Heap Scan on customer  (cost=3403.64..34159.47 rows=502067 width=161) (actual time=82.646..430.038 rows=499335 loops=1)
"  Recheck Cond: (preferences @> '{""theme"": ""dark""}'::jsonb)"
  Heap Blocks: exact=24480
  Buffers: shared hit=311 read=24451
  ->  Bitmap Index Scan on idx_customer_preferences_gin  (cost=0.00..3278.12 rows=502067 width=0) (actual time=79.131..79.131 rows=499335 loops=1)
"        Index Cond: (preferences @> '{""theme"": ""dark""}'::jsonb)"
        Buffers: shared hit=282
Planning:
  Buffers: shared hit=4
Planning Time: 0.177 ms
Execution Time: 449.926 ms
```

**Вывод по запросу 2:**  
Условие выбирает около половины таблицы (499k из 1M). Несмотря на использование GIN индекса (Bitmap Index Scan), время выполнения не уменьшилось, а даже немного выросло (с 301 мс до 450 мс). Это связано с тем, что для большого числа подходящих строк стоимость чтения индекса и последующего доступа к таблице (Bitmap Heap Scan) может быть выше простого последовательного сканирования. Индекс применился, но не дал выигрыша из-за низкой селективности.

---

### Запрос 3: `tags && ARRAY['vip']`

#### До создания индекса
**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE tags && ARRAY['vip'];
```
**Вывод:**
```
Seq Scan on customer  (cost=0.00..36980.00 rows=301500 width=161) (actual time=0.086..239.035 rows=299556 loops=1)
  Filter: (tags && '{vip}'::text[])
  Rows Removed by Filter: 700444
  Buffers: shared hit=71 read=24416
Planning:
  Buffers: shared hit=52
Planning Time: 0.175 ms
Execution Time: 250.535 ms
```

#### После создания GIN индекса
**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE tags && ARRAY['vip'];
```
**Вывод:**
```
Bitmap Heap Scan on customer  (cost=2045.13..30293.88 rows=301500 width=161) (actual time=39.234..164.755 rows=299556 loops=1)
  Recheck Cond: (tags && '{vip}'::text[])
  Heap Blocks: exact=24480
  Buffers: shared hit=74 read=24451 written=247
  ->  Bitmap Index Scan on idx_customer_tags_gin  (cost=0.00..1969.76 rows=301500 width=0) (actual time=30.131..30.132 rows=299556 loops=1)
        Index Cond: (tags && '{vip}'::text[])
        Buffers: shared hit=45
Planning:
  Buffers: shared hit=6 read=1
Planning Time: 2.231 ms
Execution Time: 177.893 ms
```

**Вывод по запросу 3:**  
Индекс на массиве позволил сократить время выполнения с 251 мс до 178 мс (примерно на 30%). Хотя выборка остаётся большой (300k строк), использование GIN индекса даёт заметное ускорение за счёт быстрого поиска в инвертированном индексе.

---

### Запрос 4: `attributes @> '{"color": "red"}'`

#### До создания индекса
**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes @> '{"color": "red"}';
```
**Вывод:**
```
Seq Scan on product_catalog  (cost=0.00..76716.54 rows=578940 width=236) (actual time=1.841..944.265 rows=576468 loops=1)
"  Filter: (attributes @> '{""color"": ""red""}'::jsonb)"
  Rows Removed by Filter: 1173532
  Buffers: shared read=54842
Planning:
  Buffers: shared hit=44 read=4 dirtied=5
Planning Time: 2.959 ms
Execution Time: 965.455 ms
```

#### После создания GIN индекса
**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes @> '{"color": "red"}';
```
**Вывод:**
```
Bitmap Heap Scan on product_catalog  (cost=3926.98..66005.88 rows=578952 width=236) (actual time=92.329..442.103 rows=576468 loops=1)
"  Recheck Cond: (attributes @> '{""color"": ""red""}'::jsonb)"
  Heap Blocks: exact=54842
  Buffers: shared hit=199 read=55131
  ->  Bitmap Index Scan on idx_product_attributes_gin  (cost=0.00..3782.24 rows=578952 width=0) (actual time=83.382..83.382 rows=576468 loops=1)
"        Index Cond: (attributes @> '{""color"": ""red""}'::jsonb)"
        Buffers: shared hit=167 read=321
Planning:
  Buffers: shared read=1
Planning Time: 0.157 ms
Execution Time: 463.217 ms
```

**Вывод по запросу 4:**  
Несмотря на то что условие отбирает более 576k строк (около трети таблицы), GIN индекс значительно ускоряет запрос: время выполнения снижается с 965 мс до 463 мс (более чем в два раза). Это демонстрирует эффективность индекса при работе с jsonb даже при умеренной селективности.

---

### Запрос 5: `attributes ? 'color'`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes ? 'color';
```
**Вывод:**
```
Seq Scan on product_catalog  (cost=0.00..76716.54 rows=1749798 width=236) (actual time=0.085..453.734 rows=1750000 loops=1)
  Filter: (attributes ? 'color'::text)
  Buffers: shared hit=32 read=54810
Planning Time: 0.131 ms
Execution Time: 517.754 ms
```

#### После создания GIN индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes ? 'color';
```
**Вывод:**
```
Seq Scan on product_catalog  (cost=0.00..76717.00 rows=1749835 width=236) (actual time=0.020..397.291 rows=1750000 loops=1)
  Filter: (attributes ? 'color'::text)
  Buffers: shared hit=16108 read=38734
Planning:
  Buffers: shared read=1
Planning Time: 0.135 ms
Execution Time: 465.767 ms
```

**Вывод по запросу 5:**  
Ключ 'color' присутствует во всех записях таблицы product_catalog, поэтому условие абсолютно неселективно. Как и в запросе 1, индекс не используется – оба раза выполняется последовательное сканирование. Время выполнения с индексом даже немного меньше (466 мс против 518 мс), но это объясняется кешированием, а не работой индекса.

---

## GiST запросы

### Запрос 1: `ORDER BY location <-> point(55.75,37.62) LIMIT 5`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer ORDER BY location <-> point(55.75, 37.62) LIMIT 5;
```
**Вывод:**
```
Limit  (cost=37609.05..37609.63 rows=5 width=169) (actual time=380.145..381.757 rows=5 loops=1)
  Buffers: shared hit=74 read=24480
  ->  Gather Merge  (cost=37609.05..134838.14 rows=833334 width=169) (actual time=380.143..381.753 rows=5 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=74 read=24480
        ->  Sort  (cost=36609.02..37650.69 rows=416667 width=169) (actual time=375.005..375.007 rows=4 loops=3)
"              Sort Key: ((location <-> '(55.75,37.62)'::point))"
              Sort Method: top-N heapsort  Memory: 27kB
              Buffers: shared hit=74 read=24480
              Worker 0:  Sort Method: top-N heapsort  Memory: 27kB
              Worker 1:  Sort Method: top-N heapsort  Memory: 27kB
              ->  Parallel Seq Scan on customer  (cost=0.00..29688.33 rows=416667 width=169) (actual time=0.320..294.364 rows=333333 loops=3)
                    Buffers: shared read=24480
Planning:
  Buffers: shared hit=10 read=1
Planning Time: 0.641 ms
Execution Time: 381.791 ms
```

#### После создания GiST индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer ORDER BY location <-> point(55.75, 37.62) LIMIT 5;
```
**Вывод:**
```
Limit  (cost=0.29..1.04 rows=5 width=169) (actual time=0.290..0.410 rows=5 loops=1)
  Buffers: shared read=11
  ->  Index Scan using idx_customer_location_gist on customer  (cost=0.29..150536.29 rows=1000000 width=169) (actual time=0.288..0.406 rows=5 loops=1)
"        Order By: (location <-> '(55.75,37.62)'::point)"
        Buffers: shared read=11
Planning:
  Buffers: shared hit=19
Planning Time: 0.343 ms
Execution Time: 0.446 ms
```

**Вывод по запросу 1:**  
Для поиска ближайших соседей GiST индекс обеспечивает колоссальное ускорение: время выполнения падает с 382 мс до 0.45 мс. Без индекса требуется полное сканирование и сортировка, с индексом – мгновенный поиск по дереву.

---

### Запрос 2: `dimensions && int4range(0,20)`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions && int4range(0, 20);
```
**Вывод:**
```
Seq Scan on product_catalog  (cost=0.00..76717.00 rows=350000 width=236) (actual time=0.059..436.383 rows=340336 loops=1)
"  Filter: (dimensions && '[0,20)'::int4range)"
  Rows Removed by Filter: 1409664
  Buffers: shared hit=15913 read=38929
Planning:
  Buffers: shared hit=5
Planning Time: 0.111 ms
Execution Time: 450.963 ms
```

#### После создания GiST индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions && int4range(0, 20);
```
**Вывод:**
```
Bitmap Heap Scan on product_catalog  (cost=13368.91..72585.91 rows=350000 width=236) (actual time=300.457..704.972 rows=340336 loops=1)
"  Recheck Cond: (dimensions && '[0,20)'::int4range)"
  Heap Blocks: exact=54776
  Buffers: shared hit=13336 read=54712 written=5416
  ->  Bitmap Index Scan on idx_product_dimensions_gist  (cost=0.00..13281.41 rows=350000 width=0) (actual time=291.775..291.776 rows=340336 loops=1)
"        Index Cond: (dimensions && '[0,20)'::int4range)"
        Buffers: shared hit=13272
Planning Time: 0.087 ms
Execution Time: 719.988 ms
```

**Вывод по запросу 2:**  
Условие с диапазоном [0,20) выбирает около 340k строк (почти 20% таблицы). Несмотря на использование GiST индекса, время выполнения увеличилось с 451 мс до 720 мс. Это классический случай, когда для большого числа подходящих строк индекс не даёт выигрыша, а создаёт дополнительный оверхэд.

---

### Запрос 3: `dimensions @> 260`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions @> 260;
```
**Вывод:**
```
Seq Scan on product_catalog  (cost=0.00..76717.00 rows=341250 width=236) (actual time=0.200..393.953 rows=345168 loops=1)
  Filter: (dimensions @> 260)
  Rows Removed by Filter: 1404832
  Buffers: shared hit=15917 read=38925
Planning:
  Buffers: shared hit=5
Planning Time: 0.174 ms
Execution Time: 408.841 ms
```

#### После создания GiST индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions @> 260;
```
**Вывод:**
```
Bitmap Heap Scan on product_catalog  (cost=13049.10..72156.73 rows=341250 width=236) (actual time=274.636..501.575 rows=345168 loops=1)
  Recheck Cond: (dimensions @> 260)
  Heap Blocks: exact=54783
  Buffers: shared hit=64 read=66587
  ->  Bitmap Index Scan on idx_product_dimensions_gist  (cost=0.00..12963.79 rows=341250 width=0) (actual time=263.557..263.557 rows=345168 loops=1)
        Index Cond: (dimensions @> 260)
        Buffers: shared read=11868
Planning Time: 0.080 ms
Execution Time: 523.273 ms
```

**Вывод по запросу 3:**  
Аналогично предыдущему запросу, условие `@> 260` выбирает около 345k строк. GiST индекс применяется, но время выполнения увеличивается (409 мс → 523 мс). Для таких больших выборок последовательное сканирование оказывается эффективнее.

---

### Запрос 4: `dimensions -|- int4range(50,100)`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions -|- int4range(50, 100);
```
**Вывод:**
```
Gather  (cost=1000.00..66706.58 rows=17500 width=236) (actual time=0.358..551.759 rows=8603 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=16038 read=38854
  ->  Parallel Seq Scan on product_catalog  (cost=0.00..63956.58 rows=7292 width=236) (actual time=2.811..543.124 rows=2868 loops=3)
"        Filter: (dimensions -|- '[50,100)'::int4range)"
        Rows Removed by Filter: 580466
        Buffers: shared hit=16038 read=38854
Planning Time: 0.065 ms
Execution Time: 552.482 ms
```

#### После создания GiST индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions -|- int4range(50, 100);
```
**Вывод:**
```
Bitmap Heap Scan on product_catalog  (cost=672.04..37509.27 rows=17500 width=236) (actual time=213.412..356.911 rows=8603 loops=1)
"  Recheck Cond: (dimensions -|- '[50,100)'::int4range)"
  Heap Blocks: exact=7971
  Buffers: shared hit=13333 read=7957 written=3738
  ->  Bitmap Index Scan on idx_product_dimensions_gist  (cost=0.00..667.66 rows=17500 width=0) (actual time=212.344..212.346 rows=8603 loops=1)
"        Index Cond: (dimensions -|- '[50,100)'::int4range)"
        Buffers: shared hit=13319
Planning:
  Buffers: shared hit=18 read=1
Planning Time: 1.392 ms
Execution Time: 357.509 ms
```

**Вывод по запросу 4:**  
Оператор смежности `-|-` выбирает небольшое количество строк (8603). GiST индекс даёт заметное ускорение: время выполнения снижается с 552 мс до 358 мс (примерно на 35%). Это демонстрирует эффективность индекса для операций, которые возвращают мало строк.

---

### Запрос 5: `location <@ box(point(50,50), point(100,100))`

#### До создания индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE location <@ box(point(50,50), point(100,100));
```
**Вывод:**
```
Gather  (cost=1000.00..30788.33 rows=1000 width=161) (actual time=0.972..282.054 rows=30886 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared read=24480
  ->  Parallel Seq Scan on customer  (cost=0.00..29688.33 rows=417 width=161) (actual time=0.565..275.872 rows=10295 loops=3)
"        Filter: (location <@ '(100,100),(50,50)'::box)"
        Rows Removed by Filter: 323038
        Buffers: shared read=24480
Planning Time: 0.064 ms
Execution Time: 283.558 ms
```

#### После создания GiST индекса

**EXPLAIN (ANALYZE, BUFFERS)**
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE location <@ box(point(50,50), point(100,100));
```
**Вывод:**
```
Bitmap Heap Scan on customer  (cost=44.03..3388.29 rows=1000 width=161) (actual time=68.258..2901.302 rows=30886 loops=1)
"  Recheck Cond: (location <@ '(100,100),(50,50)'::box)"
  Heap Blocks: exact=17713
  Buffers: shared hit=21 read=17980 written=4305
  ->  Bitmap Index Scan on idx_customer_location_gist  (cost=0.00..43.78 rows=1000 width=0) (actual time=64.977..64.977 rows=30886 loops=1)
"        Index Cond: (location <@ '(100,100),(50,50)'::box)"
        Buffers: shared read=288
Planning:
  Buffers: shared hit=3
Planning Time: 0.445 ms
Execution Time: 2907.221 ms
```

**Вывод по запросу 5:**  
Несмотря на использование GiST индекса, время выполнения катастрофически выросло (с 284 мс до 2907 мс). Причина – сильное расхождение между ожидаемым (1000) и фактическим (30886) числом строк, что привело к неэффективному плану с большим количеством операций перепроверки (Recheck Cond). Для данного типа запроса индекс оказался вреден.
