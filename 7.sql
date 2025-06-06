USE TransportCompany;
GO

-- Клиенты
INSERT INTO Clients (client_type, full_name, inn, phone) 
VALUES 
('individual', 'Иванов Пётр Сергеевич', '770123456789', '+79161234567'),
('legal', 'ООО "Ромашка"', '772765432100', '88002000600'),
('individual', 'Сидорова Анна Викторовна', NULL, '+79269874563');
GO

-- Транспортные средства
INSERT INTO Vehicles (brand, license_plate, fuel_consumption, fuel_type) 
VALUES 
('ГАЗ-33104 "Валдай"', 'А123ВС77', 17.3, 'diesel'),
('КамАЗ-53212', 'В456ОР777', 26.4, 'diesel'),
('МАЗ-53366', 'Е789КХ190', 25.5, 'diesel');
GO

-- Услуги
INSERT INTO Services (name, description, price) 
VALUES 
('Срочная доставка', 'Экспресс-доставка грузов', 2000.00),
('Защитная упаковка', 'Пленочная упаковка груза', 5000.00),
('Погрузочные работы', 'Ручная погрузка/разгрузка', 1500.00);
GO

-- Заказы
INSERT INTO Orders (client_id, pickup_location, delivery_location, cargo_weight, distance_km, order_date, total_price, cost) 
VALUES 
(1, 'Москва', 'Санкт-Петербург', 1500.00, 700, '2025-03-01', 50000.00, 35000.00),
(2, 'Казань', 'Екатеринбург', 5000.00, 800, '2025-03-02', 75000.00, 55000.00),
(3, 'Новосибирск', 'Красноярск', 2500.00, 550, '2025-03-03', 42000.00, 30000.00);
GO

-- Связи заказов и услуг
INSERT INTO OrderServices (order_id, service_id) 
VALUES 
(1, 1), 
(2, 2), 
(3, 3);
GO