CREATE DATABASE TransportCompany;
GO

USE TransportCompany;
GO

-- Таблица клиентов
CREATE TABLE Clients (
    client_id INT PRIMARY KEY IDENTITY(1,1),
    client_type VARCHAR(10) NOT NULL CHECK (client_type IN ('individual', 'legal')),
    full_name VARCHAR(100) NOT NULL,
    inn VARCHAR(12),
    kpp VARCHAR(9),
    email VARCHAR(50),
    phone VARCHAR(20) NOT NULL,
    passport_series VARCHAR(4),
    passport_number VARCHAR(6)
);
GO

-- Таблица транспортных средств
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY IDENTITY(1,1),
    brand VARCHAR(100) NOT NULL,
    license_plate VARCHAR(15) UNIQUE NOT NULL,
    fuel_consumption DECIMAL(5,1) NOT NULL,
    fuel_type VARCHAR(10) NOT NULL CHECK (fuel_type IN ('diesel', 'gasoline', 'gas')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'in_delivery', 'in_maintenance', 'broken')) DEFAULT 'available'
);
GO

-- Таблица заказов
CREATE TABLE Orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    client_id INT NOT NULL,
    pickup_location VARCHAR(100) NOT NULL,
    delivery_location VARCHAR(100) NOT NULL,
    cargo_weight DECIMAL(10,2) NOT NULL,
    distance_km INT NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE,
    payment_date DATE,
    total_price DECIMAL(12,2) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('created', 'paid', 'in_progress', 'completed', 'cancelled')) DEFAULT 'created',
    vehicle_id INT,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);
GO

-- Таблица услуг
CREATE TABLE Services (
    service_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(8,2) NOT NULL
);
GO

-- Связь заказов и услуг
CREATE TABLE OrderServices (
    order_service_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    service_id INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);
GO