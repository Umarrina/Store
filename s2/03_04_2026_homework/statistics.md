# Статистика

## 1 запрос

### EXPLAIN
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161)
Index Cond: (id = 15000)
```

### EXPLAIN ANALYZE
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=6.891..6.898 rows=1 loops=1)
Index Cond: (id = 15000)
Planning Time: 0.314 ms
Execution Time: 7.015 ms
```

### EXPLAIN (ANALYZE, BUFFERS)
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=0.049..0.051 rows=1 loops=1)
Index Cond: (id = 15000)
Buffers: shared hit=4
Planning Time: 0.217 ms
Execution Time: 0.072 ms
```

### EXPLAIN c B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..8.44 rows=1 width=161)
  Index Cond: (id = 15000)
```

### EXPLAIN ANALYZE с B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=0.184..0.186 rows=1 loops=1)
  Index Cond: (id = 15000)
Planning Time: 0.265 ms
Execution Time: 0.214 ms
```

### EXPLAIN (ANALYZE, BUFFERS) с B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=0.062..0.065 rows=1 loops=1)
  Index Cond: (id = 15000)
  Buffers: shared hit=4
Planning Time: 0.358 ms
Execution Time: 0.098 ms
```

### EXPLAIN с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_hash on customer  (cost=0.00..8.02 rows=1 width=161)
  Index Cond: (id = 15000)
```

### EXPLAIN ANALYZE с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_hash on customer  (cost=0.00..8.02 rows=1 width=161) (actual time=0.230..0.247 rows=1 loops=1)
  Index Cond: (id = 15000)
Planning Time: 0.102 ms
Execution Time: 0.269 ms
```

### EXPLAIN (ANALYZE, BUFFERS) c Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
```
**Вывод:**
```
Index Scan using idx_customer_id_hash on customer  (cost=0.00..8.02 rows=1 width=161) (actual time=0.029..0.033 rows=1 loops=1)
  Index Cond: (id = 15000)
  Buffers: shared hit=3
Planning Time: 0.171 ms
Execution Time: 0.065 ms
```

**Вывод по запросу 1:**  
Для точного поиска по первичному ключу (id) используется Index Scan. После создания B‑tree и Hash индексов время выполнения сокращается незначительно, так как первичный ключ уже обеспечивает эффективный доступ. B‑tree и Hash показывают схожие результаты. В целом, для операций равенства оба типа индексов работают быстро, но B‑tree универсальнее.


## 2 запрос

### EXPLAIN
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161)
  Index Cond: (id > 200000)
```

### EXPLAIN ANALYZE
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=25.674..75.583 rows=50000 loops=1)
  Index Cond: (id > 200000)
Planning Time: 0.194 ms
Execution Time: 77.715 ms
```

### EXPLAIN (ANALYZE, BUFFERS)
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=0.036..10.033 rows=50000 loops=1)
  Index Cond: (id > 200000)
  Buffers: shared hit=1406
Planning Time: 0.117 ms
Execution Time: 12.775 ms
```

### EXPLAIN c B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161)
  Index Cond: (id > 200000)
```

### EXPLAIN ANALYZE с B-tree
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=0.213..42.558 rows=50000 loops=1)
  Index Cond: (id > 200000)
Planning Time: 0.108 ms
Execution Time: 44.520 ms
```

### EXPLAIN (ANALYZE, BUFFERS) с B-tree
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=0.029..7.810 rows=50000 loops=1)
  Index Cond: (id > 200000)
  Buffers: shared hit=1406
Planning Time: 0.096 ms
Execution Time: 10.074 ms
```

### EXPLAIN с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161)
  Index Cond: (id > 200000)
```

### EXPLAIN ANALYZE с Hash
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=0.055..9.286 rows=50000 loops=1)
  Index Cond: (id > 200000)
Planning Time: 0.107 ms
Execution Time: 11.303 ms
```

### EXPLAIN (ANALYZE, BUFFERS) c Hash
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id > 200000;
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..2659.41 rows=50114 width=161) (actual time=0.032..7.529 rows=50000 loops=1)
  Index Cond: (id > 200000)
  Buffers: shared hit=1406
Planning Time: 0.154 ms
Execution Time: 9.622 ms
```

**Вывод по запросу 2:**  
Для диапазонного условия используется Index Scan по первичному ключу. Создание дополнительных индексов не меняет план, так как первичный ключ уже является B‑tree и оптимален для диапазонов.

## 3 запрос

### EXPLAIN
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161)
  Workers Planned: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161)
        Filter: ((email)::text ~~ 'user150%'::text)
```

### EXPLAIN ANALYZE
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=25.948..207.409 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=42.133..141.293 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
Planning Time: 0.132 ms
Execution Time: 207.499 ms
```

### EXPLAIN (ANALYZE, BUFFERS)
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=0.786..34.686 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=1324 read=4797
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=6.701..16.675 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
        Buffers: shared hit=1324 read=4797
Planning Time: 0.178 ms
Execution Time: 34.781 ms

```

### EXPLAIN c B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161)
  Workers Planned: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161)
        Filter: ((email)::text ~~ 'user150%'::text)

```

### EXPLAIN ANALYZE с B-tree
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=23.369..59.872 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=6.870..25.267 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
Planning Time: 0.131 ms
Execution Time: 59.974 ms
```

### EXPLAIN (ANALYZE, BUFFERS) с B-tree
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=0.620..31.306 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=1676 read=4445
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=6.946..23.373 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
        Buffers: shared hit=1676 read=4445
Planning Time: 0.098 ms
Execution Time: 31.444 ms
```

### EXPLAIN с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161)
  Workers Planned: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161)
        Filter: ((email)::text ~~ 'user150%'::text)
```

### EXPLAIN ANALYZE с Hash
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=1.471..56.245 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=0.165..14.578 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
Planning Time: 0.162 ms
Execution Time: 56.389 ms
```

### EXPLAIN (ANALYZE, BUFFERS) c Hash
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=1.469..84.551 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=1836 read=4285
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=9.871..43.783 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
        Buffers: shared hit=1836 read=4285
Planning Time: 0.142 ms
Execution Time: 84.684 ms
```

Для префиксного поиска (`LIKE 'user150%'`) B‑tree индекс мог бы помочь, но в данном случае планировщик всё равно выбрал последовательное сканирование (Parallel Seq Scan). Это может быть связано с тем, что статистика показывает низкую селективность. Индекс на email не используетсяя. Создание индексов не изменило план, что говорит о том, что оптимизатор посчитал последовательное сканирование дешевле.

## 4 запрос

### EXPLAIN
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161)
Index Cond: (id = 15000)
```

### EXPLAIN ANALYZE
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=6.891..6.898 rows=1 loops=1)
Index Cond: (id = 15000)
Planning Time: 0.314 ms
Execution Time: 7.015 ms
```

### EXPLAIN (ANALYZE, BUFFERS)
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161) (actual time=0.049..0.051 rows=1 loops=1)
Index Cond: (id = 15000)
Buffers: shared hit=4
Planning Time: 0.217 ms
Execution Time: 0.072 ms
```

### EXPLAIN c B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161)
Workers Planned: 2
->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161)
Filter: ((email)::text ~~ 'user150%'::text)

```

### EXPLAIN ANALYZE с B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Gather  (cost=1000.00..8675.58 rows=2525 width=161)
  Workers Planned: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=1052 width=161)
        Filter: ((email)::text ~~ '%500%'::text)
```

### EXPLAIN (ANALYZE, BUFFERS) с B-tree
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
```
**Вывод:**
```
Gather  (cost=1000.00..8425.58 rows=25 width=161) (actual time=29.716..175.591 rows=1111 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=10 width=161) (actual time=24.784..112.748 rows=370 loops=3)
        Filter: ((email)::text ~~ 'user150%'::text)
        Rows Removed by Filter: 82963
Planning Time: 0.830 ms
Execution Time: 175.890 ms
```

### EXPLAIN с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..8.44 rows=1 width=161)
Index Cond: (id = 15000)
```

### EXPLAIN ANALYZE с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```         
Gather  (cost=1000.00..8675.58 rows=2525 width=161)
  Workers Planned: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=1052 width=161)
        Filter: ((email)::text ~~ '%500%'::text)                                                                                               
```

### EXPLAIN (ANALYZE, BUFFERS) c Hash
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
```
**Вывод:**
```
Gather  (cost=1000.00..8675.58 rows=2525 width=161) (actual time=1.885..67.138 rows=701 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  ->  Parallel Seq Scan on customer  (cost=0.00..7423.08 rows=1052 width=161) (actual time=1.404..50.833 rows=234 loops=3)
        Filter: ((email)::text ~~ '%500%'::text)
        Rows Removed by Filter: 83100
Planning Time: 0.080 ms
Execution Time: 67.298 ms
```

**Выводы по запросу 4:**
Поиск по подстроке (LIKE '%500%') не может использовать стандартные B‑tree или Hash индексы, поэтому всегда выполняется параллельное последовательное сканирование (Parallel Seq Scan). Время выполнения при первом запуске без кеша составляет около 67–175 мс, с кешем — около 30–35 мс. Создание индексов не влияет на план, что подтверждает ограниченность обычных индексов для таких условий.

## 5 запрос

### EXPLAIN
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
```

### EXPLAIN ANALYZE
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=25.652..29.988 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
Planning Time: 0.109 ms
Execution Time: 30.009 ms
```

### EXPLAIN (ANALYZE, BUFFERS)
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=0.052..0.154 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
  Buffers: shared hit=12
Planning:
  Buffers: shared hit=123
Planning Time: 1.179 ms
Execution Time: 0.283 ms
```

### EXPLAIN c B-tree
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..17.31 rows=3 width=161)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
```

### EXPLAIN ANALYZE с B-tree
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=0.373..0.405 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
Planning Time: 0.125 ms
Execution Time: 0.426 ms
```

### EXPLAIN (ANALYZE, BUFFERS) с B-tree
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using idx_customer_id_btree on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=0.039..0.058 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
  Buffers: shared hit=12
Planning Time: 0.141 ms
Execution Time: 0.082 ms
```

### EXPLAIN с Hash
```
EXPLAIN SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
```

### EXPLAIN ANALYZE с Hash
```
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=0.282..0.591 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
Planning Time: 0.355 ms
Execution Time: 0.619 ms
```

### EXPLAIN (ANALYZE, BUFFERS) c Hash
```
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
```
**Вывод:**
```
Index Scan using customer_pkey on customer  (cost=0.42..17.31 rows=3 width=161) (actual time=0.038..0.051 rows=3 loops=1)
"  Index Cond: (id = ANY ('{100000,150000,200000}'::integer[]))"
  Buffers: shared hit=12
Planning Time: 0.122 ms
Execution Time: 0.070 ms
```

**Вывод по запросу 5:**
Оператор IN для числового поля эффективно использует индекс (Index Scan). Первичный ключ и созданный B‑tree индекс показывают схожие результаты с временем выполнения после кеширования менее 0.1 мс. Hash‑индекс не был выбран планировщиком, использовался первичный ключ. Количество прочитанных буферов (12) одинаково для всех вариантов. Таким образом, для множественных значений IN индекс обязателен, и B‑tree справляется отлично.