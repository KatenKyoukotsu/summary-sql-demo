SELECT 
    o.order_id AS 'Номер заказа',
    c.full_name AS 'Клиент',
    o.pickup_location AS 'Пункт отправления',
    o.delivery_location AS 'Пункт назначения',
    o.cargo_weight AS 'Вес груза (кг)',
    o.distance_km AS 'Расстояние (км)',
    o.total_price AS 'Стоимость доставки'
FROM Orders o
JOIN Clients c ON o.client_id = c.client_id;