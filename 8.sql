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