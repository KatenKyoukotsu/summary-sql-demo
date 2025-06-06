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