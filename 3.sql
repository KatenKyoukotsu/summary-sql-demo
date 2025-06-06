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