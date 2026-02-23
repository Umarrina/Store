# Инструкция по поднятию докера и исполнения миграций

## Удаление старого контейнера (если необходимо):

```
docker stop db_practice; docker rm db_practice
```

## Поднятие докера:

```
docker run --name db_practice -p 5432:5432 -e POSTGRES_USER=ваш_пользователь -e POSTGRES_PASSWORD=ваш_пароль -e POSTGRES_DB=db_store -d postgres:17
```

## Первая миграция:

```
docker cp "s2\02_16_2026_homework\migrations\V1_initial_schema.sql" db_practice:/tmp/V1.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/V1.sql
```

## Вторая миграция:

```
$envVars = @{}
Get-Content .env | ForEach-Object {
    $k,$v = $_ -split '=',2
    if ($k -and $v) { $envVars[$k] = $v.Trim() }
}

$template = Get-Content "s2\02_16_2026_homework\migrations\V2_create_role.sql" -Raw

$sql = $template
foreach ($key in $envVars.Keys) {
    $sql = $sql -replace "\$\{$key\}", $envVars[$key]
}

$tempFile = "V2_temp.sql"
$sql | Set-Content $tempFile -Encoding UTF8

docker cp $tempFile db_practice:/tmp/V2.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/V2.sql

Remove-Item $tempFile
```

## Третья миграция:

```
docker cp "s2\02_16_2026_homework\migrations\V3_alter_all_tables.sql" db_practice:/tmp/V3.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/V3.sql
```

## Четвертая миграция:

```
docker cp "s2\02_16_2026_homework\migrations\V4_seed_data.sql" db_practice:/tmp/V4.sql
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -f /tmp/V4.sql
```

## Проверка количества строк:

```
docker exec -it db_practice psql -U db_practice_umarrina -d db_store -c "
SELECT 'customer' AS table, COUNT(*) FROM warehouse.customer
UNION ALL
SELECT 'product_catalog', COUNT(*) FROM warehouse.product_catalog
UNION ALL
SELECT 'customer_order', COUNT(*) FROM warehouse.customer_order
UNION ALL
SELECT 'order_item', COUNT(*) FROM warehouse.order_item;"
```