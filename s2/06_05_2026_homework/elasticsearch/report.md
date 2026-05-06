# Домашнее задание №3: Elasticsearch

## Задание

1. Поднять Elasticsearch.
2. Создать индекс `first_index` с маппингом (title text с русским анализатором, price float, available boolean).
3. Заполнить данными (использовать Bulk из приложенной Postman коллекции или написать свои 10+ документов).
4. Написать 4 разных поисковых запроса:
    - `match` с опечаткой
    - `range` + `term`
    - `bool` с `must_not`
    - `match_phrase`

## Запуск

```bash
docker compose up -d
```

**Создание индекса**

![img.png](photo/img.png)

**Вставка документов**:

![img_1.png](photo/img_1.png)

**Создание документа**

![img_2.png](photo/img_2.png)

**Получение документа**

![img_3.png](photo/img_3.png)

**Поиск**

![img_4.png](photo/img_4.png)

**Insert**

![img_5.png](photo/img_5.png)

**Удаление документа**

![img_6.png](photo/img_6.png)

**match**

![img_7.png](photo/img_7.png)

**range + term**

![img_8.png](photo/img_8.png)

**bool**

![img_9.png](photo/img_9.png)

**match_phrase**

![img_10.png](photo/img_10.png)
