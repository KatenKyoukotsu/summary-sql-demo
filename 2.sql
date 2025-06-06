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