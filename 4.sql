-- Резервное копирование базы BsAll
BACKUP DATABASE BsAll 
TO DISK = 'C:\Backup\BsAll.bak' 
WITH INIT, FORMAT, COMPRESSION;
GO