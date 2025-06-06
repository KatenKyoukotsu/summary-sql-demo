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