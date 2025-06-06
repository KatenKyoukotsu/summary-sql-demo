### Решение: Установка и настройка SQL Server с автоматизацией задач

#### Шаг 1: Установка SQL Server
1. **Выбор СУБД**: Microsoft SQL Server 2022 (Express Edition).
2. **Параметры установки**:
   - Имя сервера: `SQLServ_05` (где `05` — номер вашего рабочего места).
   - Режим аутентификации: **Смешанный (Windows + SQL Server)**.
   - Учетная запись `sa`: пароль `D_05` (замените `05` на ваш номер).

---

#### Шаг 2: Скрипт для автоматизации задач (выполнить в SQL Server Management Studio)
```sql
USE master;
GO

-- Параметры
DECLARE @workstation_id NVARCHAR(10) = '05'; -- Замените на ваш номер
DECLARE @i INT = 1;

-- Создание 14 пользователей, баз данных и настройка прав
WHILE @i <= 14
BEGIN
    -- Генерация случайного пароля (5 символов: буквы + цифры)
    DECLARE @password NVARCHAR(5) = LEFT(CAST(NEWID() AS NVARCHAR(36)), 5);
    
    -- Создание логина и пользователя
    DECLARE @login NVARCHAR(20) = CONCAT('user', @i);
    EXEC('CREATE LOGIN ' + @login + ' WITH PASSWORD = ''' + @password + ''', CHECK_POLICY = OFF');
    
    -- Создание базы данных
    DECLARE @db_name NVARCHAR(20) = CONCAT('Bs', @i);
    EXEC('CREATE DATABASE ' + @db_name);
    
    -- Назначение прав пользователю в своей БД
    EXEC('USE ' + @db_name + ';
          CREATE USER ' + @login + ' FOR LOGIN ' + @login + ';
          ALTER ROLE [db_owner] ADD MEMBER ' + @login + ';');
    
    -- Запрет создания БД и управления правами (серверный уровень)
    EXEC('DENY CREATE ANY DATABASE TO ' + @login + ';
          DENY CONTROL SERVER TO ' + @login + ';');
    
    -- Сохранение данных для таблицы Users
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BsAll')
        CREATE DATABASE BsAll;
    
    EXEC('USE BsAll;
          IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = ''Users'')
              CREATE TABLE Users (Username NVARCHAR(20), Password_Plain NVARCHAR(50), Password_Encrypted VARBINARY(MAX));');
    
    EXEC('USE BsAll;
          INSERT INTO Users (Username, Password_Plain) 
          VALUES (''' + @login + ''', ''' + @password + ''');');
    
    SET @i += 1;
END
GO

-- Шифрование паролей в таблице Users
USE BsAll;
GO

-- Создаем мастер-ключ, сертификат и симметричный ключ
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKeyPassword123!';
CREATE CERTIFICATE MyCert WITH SUBJECT = 'Password Encryption';
CREATE SYMMETRIC KEY MySymmetricKey 
    WITH ALGORITHM = AES_256 
    ENCRYPTION BY CERTIFICATE MyCert;

-- Шифруем пароли
OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCert;
UPDATE Users 
SET Password_Encrypted = ENCRYPTBYKEY(KEY_GUID('MySymmetricKey'), Password_Plain);
CLOSE SYMMETRIC KEY MySymmetricKey;

-- Удаляем незашифрованные пароли
ALTER TABLE Users DROP COLUMN Password_Plain;
GO

-- Скрипт для расшифровки паролей
CREATE PROCEDURE DecryptPasswords
AS
BEGIN
    OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCert;
    SELECT 
        Username, 
        CONVERT(NVARCHAR(50), DECRYPTBYKEY(Password_Encrypted)) AS DecryptedPassword
    FROM Users;
    CLOSE SYMMETRIC KEY MySymmetricKey;
END;
GO

-- Резервное копирование базы BsAll
BACKUP DATABASE BsAll 
TO DISK = 'C:\Backup\BsAll.bak' 
WITH INIT, FORMAT, COMPRESSION;
GO

-- Скрипт для восстановления из резервной копии
RESTORE DATABASE BsAll 
FROM DISK = 'C:\Backup\BsAll.bak' 
WITH REPLACE, RECOVERY;
GO
```

---

#### Шаг 3: Инструкция по выполнению
1. **Установите SQL Server** с указанными параметрами.
2. **Откройте SQL Server Management Studio (SSMS)** и подключитесь к вашему серверу `SQLServ_05`.
3. **Выполните скрипт выше** в новом запросе SSMS.
4. **Проверьте результаты**:
   - Базы данных: `Bs1`-`Bs14`, `BsAll`.
   - Пользователи: `user1`-`user14` (пароли сгенерированы автоматически).
   - Таблица `BsAll.dbo.Users` с зашифрованными паролями.
5. **Для просмотра паролей** выполните:
   ```sql
   USE BsAll;
   EXEC DecryptPasswords;
   ```

---

#### Шаг 4: Резервное копирование и восстановление
- **Бэкап**: Файл `BsAll.bak` создается в `C:\Backup\`.
- **Восстановление**: Скрипт `RESTORE DATABASE` в конце автоматически восстановит БД из бэкапа (заменит существующую).

---

### Пояснения:
1. **Простота**: Скрипт использует минимальный код без сложных конструкций.
2. **Безопасность**:
   - Пароли шифруются AES-256.
   - Расшифровка доступна через хранимую процедуру.
3. **Автоматизация**:
   - Все задачи выполняются одним скриптом.
   - Резервная копия создается автоматически.

> **Важно**: Замените `05` на ваш номер рабочего места. Для работы скрипта убедитесь, что путь `C:\Backup\` существует или измените его.


### Решение: Проектирование ER-диаграммы и реализация базы данных для транспортной компании

#### 2. Создание базы данных и таблиц
```sql
CREATE DATABASE TransportCompany;
GO

USE TransportCompany;
GO

-- Таблица клиентов
CREATE TABLE Clients (
    client_id INT PRIMARY KEY IDENTITY(1,1),
    client_type VARCHAR(10) NOT NULL CHECK (client_type IN ('individual', 'legal')),
    full_name VARCHAR(100) NOT NULL,
    inn VARCHAR(12),
    kpp VARCHAR(9),
    email VARCHAR(50),
    phone VARCHAR(20) NOT NULL,
    passport_series VARCHAR(4),
    passport_number VARCHAR(6)
);
GO

-- Таблица транспортных средств
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY IDENTITY(1,1),
    brand VARCHAR(100) NOT NULL,
    license_plate VARCHAR(15) UNIQUE NOT NULL,
    fuel_consumption DECIMAL(5,1) NOT NULL,
    fuel_type VARCHAR(10) NOT NULL CHECK (fuel_type IN ('diesel', 'gasoline', 'gas')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'in_delivery', 'in_maintenance', 'broken')) DEFAULT 'available'
);
GO

-- Таблица заказов
CREATE TABLE Orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    client_id INT NOT NULL,
    pickup_location VARCHAR(100) NOT NULL,
    delivery_location VARCHAR(100) NOT NULL,
    cargo_weight DECIMAL(10,2) NOT NULL,
    distance_km INT NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE,
    payment_date DATE,
    total_price DECIMAL(12,2) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('created', 'paid', 'in_progress', 'completed', 'cancelled')) DEFAULT 'created',
    vehicle_id INT,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);
GO

-- Таблица услуг
CREATE TABLE Services (
    service_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(8,2) NOT NULL
);
GO

-- Связь заказов и услуг
CREATE TABLE OrderServices (
    order_service_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    service_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);
GO
```

#### 3. Заполнение тестовыми данными
```sql
USE TransportCompany;
GO

-- Клиенты
INSERT INTO Clients (client_type, full_name, inn, phone) 
VALUES 
('individual', 'Иванов Пётр Сергеевич', '770123456789', '+79161234567'),
('legal', 'ООО "Ромашка"', '772765432100', '88002000600'),
('individual', 'Сидорова Анна Викторовна', NULL, '+79269874563');
GO

-- Транспортные средства
INSERT INTO Vehicles (brand, license_plate, fuel_consumption, fuel_type) 
VALUES 
('ГАЗ-33104 "Валдай"', 'А123ВС77', 17.3, 'diesel'),
('КамАЗ-53212', 'В456ОР777', 26.4, 'diesel'),
('МАЗ-53366', 'Е789КХ190', 25.5, 'diesel');
GO

-- Услуги
INSERT INTO Services (name, description, price) 
VALUES 
('Срочная доставка', 'Экспресс-доставка грузов', 2000.00),
('Защитная упаковка', 'Пленочная упаковка груза', 5000.00),
('Погрузочные работы', 'Ручная погрузка/разгрузка', 1500.00);
GO

-- Заказы
INSERT INTO Orders (client_id, pickup_location, delivery_location, cargo_weight, distance_km, order_date, total_price, cost) 
VALUES 
(1, 'Москва', 'Санкт-Петербург', 1500.00, 700, '2025-03-01', 50000.00, 35000.00),
(2, 'Казань', 'Екатеринбург', 5000.00, 800, '2025-03-02', 75000.00, 55000.00),
(3, 'Новосибирск', 'Красноярск', 2500.00, 550, '2025-03-03', 42000.00, 30000.00);
GO

-- Связи заказов и услуг
INSERT INTO OrderServices (order_id, service_id) 
VALUES 
(1, 1), 
(2, 2), 
(3, 3);
GO
```

#### 4. Процедура для расчета метрик
```sql
CREATE PROCEDURE CalculateTransportMetrics
    @start_date DATE,
    @end_date DATE,
    @total_volume DECIMAL(15,2) OUTPUT,
    @avg_cost_per_ton_km DECIMAL(10,2) OUTPUT
AS
BEGIN
    -- Объем перевезенных грузов в тонно-километрах
    SELECT @total_volume = SUM(cargo_weight * distance_km)
    FROM Orders
    WHERE order_date BETWEEN @start_date AND @end_date
      AND status = 'completed';
    
    -- Средняя стоимость перевозки одного тоннокилометра
    SELECT @avg_cost_per_ton_km = SUM(cost) / SUM(cargo_weight * distance_km)
    FROM Orders
    WHERE order_date BETWEEN @start_date AND @end_date
      AND status = 'completed';
END;
GO
```

#### 5. Триггер для проверки доступности ТС
```sql
CREATE TRIGGER CheckVehicleAvailability
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @vehicle_status VARCHAR(20);
    
    IF EXISTS(SELECT 1 FROM inserted WHERE vehicle_id IS NOT NULL)
    BEGIN
        SELECT @vehicle_status = status 
        FROM Vehicles 
        WHERE vehicle_id = (SELECT vehicle_id FROM inserted);
        
        IF @vehicle_status <> 'available'
        BEGIN
            RAISERROR('Транспортное средство недоступно для заказа', 16, 1);
            RETURN;
        END
    END
    
    -- Если проверка пройдена, выполняем вставку
    INSERT INTO Orders (
        client_id, pickup_location, delivery_location, cargo_weight, 
        distance_km, order_date, delivery_date, payment_date, 
        total_price, cost, status, vehicle_id
    )
    SELECT 
        client_id, pickup_location, delivery_location, cargo_weight, 
        distance_km, order_date, delivery_date, payment_date, 
        total_price, cost, status, vehicle_id
    FROM inserted;
END;
GO
```

### Проверка работы триггера
```sql
-- Тест 1: Попытка назначить занятое ТС
UPDATE Vehicles SET status = 'in_delivery' WHERE vehicle_id = 1;

BEGIN TRY
    INSERT INTO Orders (client_id, vehicle_id, pickup_location, delivery_location, 
                       cargo_weight, distance_km, order_date, total_price, cost) 
    VALUES (1, 1, 'Москва', 'Казань', 2000.00, 800, '2025-03-04', 60000.00, 45000.00);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE(); -- Ожидаем ошибку
END CATCH
GO

-- Тест 2: Успешное назначение доступного ТС
UPDATE Vehicles SET status = 'available' WHERE vehicle_id = 2;

INSERT INTO Orders (client_id, vehicle_id, pickup_location, delivery_location, 
                   cargo_weight, distance_km, order_date, total_price, cost) 
VALUES (1, 2, 'Москва', 'Казань', 2000.00, 800, '2025-03-04', 60000.00, 45000.00);
GO
```

### Вызов процедуры
```sql
DECLARE @volume DECIMAL(15,2), @avg_cost DECIMAL(10,2);

-- Обновим статус заказов для теста
UPDATE Orders SET status = 'completed' WHERE order_id IN (1,2,3);

EXEC CalculateTransportMetrics 
    @start_date = '2025-03-01',
    @end_date = '2025-03-31',
    @total_volume = @volume OUTPUT,
    @avg_cost_per_ton_km = @avg_cost OUTPUT;

SELECT 
    @volume AS total_ton_km,
    @avg_cost AS avg_cost_per_ton_km;
```

### Решение для SQL Server: Запросы к базе данных транспортной компании

#### 1. Список доставок с указанием стоимости (учитывая маршрут и вес)
```sql
SELECT 
    o.order_id AS 'Номер заказа',
    c.full_name AS 'Клиент',
    o.pickup_location AS 'Пункт отправления',
    o.delivery_location AS 'Пункт назначения',
    o.cargo_weight AS 'Вес груза (кг)',
    o.distance_km AS 'Расстояние (км)',
    o.total_price AS 'Стоимость доставки'
FROM Orders o
JOIN Clients c ON o.client_id = c.client_id;
```

#### 2. Увеличение стоимости ускоренных отправлений на 10%
```sql
-- Обновление стоимости для заказов с услугой "Срочная доставка"
UPDATE Orders
SET total_price = total_price * 1.10
WHERE order_id IN (
    SELECT os.order_id
    FROM OrderServices os
    JOIN Services s ON os.service_id = s.service_id
    WHERE s.name = 'Срочная доставка'
);

-- Проверка результатов
SELECT 
    o.order_id AS 'Номер заказа',
    s.name AS 'Услуга',
    o.total_price AS 'Новая стоимость'
FROM Orders o
JOIN OrderServices os ON o.order_id = os.order_id
JOIN Services s ON os.service_id = s.service_id
WHERE s.name = 'Срочная доставка';
```

### Пояснения:

1. **Первый запрос (SELECT)**:
   - Выводит ключевую информацию о доставках
   - Включает данные о клиенте, маршруте (откуда-куда), весе груза и расстоянии
   - Рассчитанная стоимость уже учитывает вес и расстояние (хранится в total_price)

2. **Второй запрос (UPDATE)**:
   - Увеличивает стоимость на 10% ТОЛЬКО для заказов с услугой "Срочная доставка"
   - Использует вложенный запрос для точного определения целевых заказов
   - После обновления выводит проверочную выборку

3. **Особенности реализации**:
   - Используется JOIN для связи таблиц
   - Точечное обновление только нужных записей
   - Проверка результатов после изменения данных

### Пример выполнения:
```sql
-- Перед обновлением
SELECT * FROM Orders WHERE order_id = 1;

-- Выполняем обновление
UPDATE Orders SET total_price = ... -- код выше

-- После обновления
SELECT * FROM Orders WHERE order_id = 1;
-- Стоимость должна увеличиться на 10%
```

> **Важно**: Эти запросы полностью соответствуют структуре созданной ранее базы данных и используют реальные названия таблиц и столбцов. Запросы можно выполнять непосредственно в SQL Server Management Studio.
