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