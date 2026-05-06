

## 7. Qdrant

**Задание** (из `hw.md`)

1. Склонировать репозиторий `https://github.com/ZhenShenITIS/hw-qdrant`
2. Запустить `docker compose up -d --build`
3. Подождать 5–10 минут (загрузка модели)
4. Открыть `http://localhost:8080/`
5. Вставить текст (пример с PostgreSQL-советами, разделённый `;`)
6. Попробовать семантический поиск (примеры: *"как искать по формам"*, *"как улучшить очистку данных"*, *"как увеличить настройку ОЗУ"*)
7. Перейти на `http://localhost:6333/dashboard` и посмотреть коллекцию `demo_collection`, выполнить пример запроса с LIMIT 15.

**Пояснение** (без прямого кода, так как проект готовый):
- Репозиторий содержит `docker-compose.yml` с Qdrant и сервисом для эмбеддингов.
- После вставки текста (например, 11 фраз про PostgreSQL) они преобразуются в векторы и сохраняются в Qdrant.
- Семантический поиск найдёт фразы, наиболее близкие по смыслу к запросу (не по ключевым словам).
- В дашборде Qdrant можно увидеть коллекцию, точки и их payload, а также выполнить поиск через GUI.

---

## 8. Neo4j

**Задание** (из `hw.md`)

1. Запустить Neo4j (docker-compose).
2. Создать граф: пользователи Alex, Maria, John, фильмы Inception, Matrix; связи FRIENDS между Alex и Maria, WATCHED от Alex к Inception.
3. Выполнить запросы:
    - найти всех друзей Алекса
    - найти фильмы, которые смотрели друзья Алекса, но не смотрел сам Алекс
4. Написать аналогичные запросы на SQL и сравнить сложность.

### Решение

**docker-compose.yml** (из `README.md`):

```yaml
version: '3.8'
services:
  neo4j:
    image: neo4j:5-enterprise
    container_name: neo4j
    ports:
      - "7474:7474"   # HTTP Browser
      - "7687:7687"   # Bolt
    environment:
      NEO4J_AUTH: neo4j/password123
      NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
    volumes:
      - ./neo4j/data:/data
```

Запуск: `docker compose up -d`.  
Открыть `http://localhost:7474`, войти `neo4j` / `password123`.

**Cypher-запросы**:

```cypher
// Создание узлов и связей
CREATE (alex:User {name: "Alex"}),
       (maria:User {name: "Maria"}),
       (john:User {name: "John"}),
       (inception:Movie {title: "Inception"}),
       (matrix:Movie {title: "The Matrix"})
CREATE (alex)-[:FRIENDS]->(maria)
CREATE (alex)-[:WATCHED {rating: 5}]->(inception)
// (При необходимости добавить другие связи: например, maria->matrix)
CREATE (maria)-[:WATCHED {rating: 4}]->(matrix)
RETURN *

// 1. Найти всех друзей Алекса
MATCH (alex:User {name: "Alex"})-[:FRIENDS]->(friend)
RETURN friend.name

// 2. Фильмы, которые смотрели друзья Алекса, но не смотрел сам Алекс
MATCH (alex:User {name: "Alex"})-[:FRIENDS]->(friend)-[:WATCHED]->(movie)
WHERE NOT EXISTS( (alex)-[:WATCHED]->(movie) )
RETURN DISTINCT movie.title
```

**Аналоги на SQL** (для гипотетических таблиц `users`, `friends`, `watched`):

```sql
-- Друзья Алекса
SELECT u2.name
FROM users u1
JOIN friends f ON u1.id = f.user_id
JOIN users u2 ON f.friend_id = u2.id
WHERE u1.name = 'Alex';

-- Фильмы друзей Алекса, не просмотренные Алексом
SELECT DISTINCT m.title
FROM users u1
JOIN friends f ON u1.id = f.user_id
JOIN users u2 ON f.friend_id = u2.id
JOIN watched w ON u2.id = w.user_id
JOIN movies m ON w.movie_id = m.id
WHERE u1.name = 'Alex'
  AND NOT EXISTS (
    SELECT 1 FROM watched w2
    WHERE w2.user_id = u1.id AND w2.movie_id = m.id
  );
```

**Сравнение сложности**:
- В Neo4j запросы короче, интуитивно понятны, не требуют множественных JOIN и подзапросов. Производительность при глубоких связях (друзья друзей и т.д.) остаётся линейной от числа обходов, тогда как в PostgreSQL число JOIN растёт экспоненциально.
- SQL-запрос становится громоздким при росте глубины связей (например, для “друзей друзей друзей” потребуется 3 JOIN и более сложная логика).

---

Все домашние задания решены. Для каждого решения приведены команды запуска, код запросов и пояснения. Студенту остаётся только выполнить их в своём окружении.