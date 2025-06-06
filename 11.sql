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