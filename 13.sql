UPDATE Orders
SET total_price = total_price * 1.10
WHERE order_id IN (
    SELECT os.order_id
    FROM OrderServices os
    JOIN Services s ON os.service_id = s.service_id
    WHERE s.name = 'Срочная доставка'
);

-- Проверка результатов
SELECT 
    o.order_id AS 'Номер заказа',
    s.name AS 'Услуга',
    o.total_price AS 'Новая стоимость'
FROM Orders o
JOIN OrderServices os ON o.order_id = os.order_id
JOIN Services s ON os.service_id = s.service_id
WHERE s.name = 'Срочная доставка';