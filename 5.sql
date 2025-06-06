-- Скрипт для восстановления из резервной копии
RESTORE DATABASE BsAll 
FROM DISK = 'C:\Backup\BsAll.bak' 
WITH REPLACE, RECOVERY;
GO