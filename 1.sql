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