-- ============================================================================
-- CAFE & BUBBLE TEA MANAGEMENT SYSTEM (CBMS)
-- Full database schema + sample data for all project tasks
-- SQL Server, normalized to 3NF where practical
-- WARNING: this script recreates the CBMS database.
-- ============================================================================

USE master;
GO

IF DB_ID(N'CBMS') IS NOT NULL
BEGIN
    ALTER DATABASE CBMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CBMS;
END;
GO

CREATE DATABASE CBMS;
GO

USE CBMS;
GO

-- ============================================================================
-- 1. ACCOUNTS AND AUTHORIZATION
-- ============================================================================

CREATE TABLE dbo.Roles (
    role_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL CONSTRAINT UQ_Roles_RoleName UNIQUE,
    description NVARCHAR(255) NULL
);

CREATE TABLE dbo.Users (
    user_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    username VARCHAR(50) NOT NULL CONSTRAINT UQ_Users_Username UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL CONSTRAINT UQ_Users_Email UNIQUE,
    phone VARCHAR(15) NULL,
    address NVARCHAR(255) NULL,
    gender NVARCHAR(10) NULL,
    staff_position NVARCHAR(50) NULL,
    avatar_url VARCHAR(255) NULL,
    status BIT NOT NULL CONSTRAINT DF_Users_Status DEFAULT (1),
    points INT NOT NULL CONSTRAINT DF_Users_Points DEFAULT (0),
    role_id INT NOT NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (role_id) REFERENCES dbo.Roles(role_id),
    CONSTRAINT CK_Users_Gender CHECK (gender IS NULL OR gender IN (N'Nam', N'Ná»¯', N'KhÃ¡c')),
    CONSTRAINT CK_Users_Points CHECK (points >= 0)
);

CREATE INDEX IX_Users_RoleStatus ON dbo.Users(role_id, status);

-- ============================================================================
-- 2. MENU, TOPPINGS AND COMBOS
-- ============================================================================

CREATE TABLE dbo.Categories (
    category_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categories PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Categories_Name UNIQUE,
    description NVARCHAR(255) NULL,
    status BIT NOT NULL CONSTRAINT DF_Categories_Status DEFAULT (1)
);

CREATE TABLE dbo.Products (
    product_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    product_name NVARCHAR(150) NOT NULL CONSTRAINT UQ_Products_Name UNIQUE,
    category_id INT NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    image_url VARCHAR(255) NULL,
    description NVARCHAR(500) NULL,
    status BIT NOT NULL CONSTRAINT DF_Products_Status DEFAULT (1),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT (SYSDATETIME()),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_Products_UpdatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id),
    CONSTRAINT CK_Products_Price CHECK (price >= 0)
);

CREATE INDEX IX_Products_CategoryStatus ON dbo.Products(category_id, status);

CREATE TABLE dbo.Sizes (
    size_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sizes PRIMARY KEY,
    size_code VARCHAR(10) NOT NULL CONSTRAINT UQ_Sizes_Code UNIQUE,
    size_name NVARCHAR(50) NOT NULL,
    price_modifier DECIMAL(12,2) NOT NULL CONSTRAINT DF_Sizes_Modifier DEFAULT (0),
    status BIT NOT NULL CONSTRAINT DF_Sizes_Status DEFAULT (1)
);

CREATE TABLE dbo.Toppings (
    topping_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Toppings PRIMARY KEY,
    topping_name NVARCHAR(100) NOT NULL CONSTRAINT UQ_Toppings_Name UNIQUE,
    price DECIMAL(12,2) NOT NULL CONSTRAINT DF_Toppings_Price DEFAULT (0),
    status BIT NOT NULL CONSTRAINT DF_Toppings_Status DEFAULT (1),
    CONSTRAINT CK_Toppings_Price CHECK (price >= 0)
);

-- The junction limits which toppings are offered for each product.
CREATE TABLE dbo.ProductToppings (
    product_id INT NOT NULL,
    topping_id INT NOT NULL,
    CONSTRAINT PK_ProductToppings PRIMARY KEY (product_id, topping_id),
    CONSTRAINT FK_ProductToppings_Products FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id) ON DELETE CASCADE,
    CONSTRAINT FK_ProductToppings_Toppings FOREIGN KEY (topping_id) REFERENCES dbo.Toppings(topping_id)
);

CREATE TABLE dbo.Combos (
    combo_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Combos PRIMARY KEY,
    combo_name NVARCHAR(150) NOT NULL CONSTRAINT UQ_Combos_Name UNIQUE,
    combo_price DECIMAL(12,2) NOT NULL,
    image_url VARCHAR(255) NULL,
    description NVARCHAR(500) NULL,
    start_date DATETIME2(0) NULL,
    end_date DATETIME2(0) NULL,
    status BIT NOT NULL CONSTRAINT DF_Combos_Status DEFAULT (1),
    CONSTRAINT CK_Combos_Price CHECK (combo_price >= 0),
    CONSTRAINT CK_Combos_DateRange CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE dbo.ComboItems (
    combo_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CONSTRAINT DF_ComboItems_Quantity DEFAULT (1),
    CONSTRAINT PK_ComboItems PRIMARY KEY (combo_id, product_id),
    CONSTRAINT FK_ComboItems_Combos FOREIGN KEY (combo_id) REFERENCES dbo.Combos(combo_id) ON DELETE CASCADE,
    CONSTRAINT FK_ComboItems_Products FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id),
    CONSTRAINT CK_ComboItems_Quantity CHECK (quantity > 0)
);

-- ============================================================================
-- 3. VOUCHERS, ORDERS AND CHECKOUT
-- ============================================================================

CREATE TABLE dbo.Vouchers (
    voucher_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Vouchers PRIMARY KEY,
    voucher_code VARCHAR(50) NOT NULL CONSTRAINT UQ_Vouchers_Code UNIQUE,
    discount_value DECIMAL(12,2) NOT NULL,
    min_order_value DECIMAL(12,2) NOT NULL CONSTRAINT DF_Vouchers_MinOrder DEFAULT (0),
    points_cost INT NOT NULL CONSTRAINT DF_Vouchers_PointsCost DEFAULT (0),
    start_date DATETIME2(0) NOT NULL CONSTRAINT DF_Vouchers_StartDate DEFAULT (SYSDATETIME()),
    expiry_date DATETIME2(0) NOT NULL,
    status BIT NOT NULL CONSTRAINT DF_Vouchers_Status DEFAULT (1),
    owner_user_id INT NULL,
    used_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Vouchers_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Vouchers_Owner FOREIGN KEY (owner_user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_Vouchers_Discount CHECK (discount_value > 0),
    CONSTRAINT CK_Vouchers_MinOrder CHECK (min_order_value >= 0),
    CONSTRAINT CK_Vouchers_PointsCost CHECK (points_cost >= 0),
    CONSTRAINT CK_Vouchers_DateRange CHECK (expiry_date >= start_date)
);

CREATE INDEX IX_Vouchers_Availability ON dbo.Vouchers(status, expiry_date, owner_user_id);

CREATE TABLE dbo.Orders (
    order_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    user_id INT NULL,
    staff_id INT NULL,
    voucher_id INT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL CONSTRAINT DF_Orders_Discount DEFAULT (0),
    shipping_fee DECIMAL(12,2) NOT NULL CONSTRAINT DF_Orders_ShippingFee DEFAULT (0),
    order_date DATETIME2(0) NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT (SYSDATETIME()),
    status VARCHAR(30) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('Pending'),
    points_awarded BIT NOT NULL CONSTRAINT DF_Orders_PointsAwarded DEFAULT (0),
    order_type VARCHAR(20) NOT NULL CONSTRAINT DF_Orders_Type DEFAULT ('At-Counter'),
    shipping_address NVARCHAR(255) NULL,
    shipping_phone VARCHAR(15) NULL,
    payment_method VARCHAR(30) NOT NULL CONSTRAINT DF_Orders_PaymentMethod DEFAULT ('Cash'),
    note NVARCHAR(500) NULL,
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Orders_Staff FOREIGN KEY (staff_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Orders_Vouchers FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(voucher_id),
    CONSTRAINT CK_Orders_Total CHECK (total_price >= 0),
    CONSTRAINT CK_Orders_Discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_Orders_ShippingFee CHECK (shipping_fee >= 0),
    CONSTRAINT CK_Orders_Status CHECK (status IN ('Pending','Approved','Completed','Cancelled')),
    CONSTRAINT CK_Orders_Type CHECK (order_type IN ('Online','At-Counter')),
    CONSTRAINT CK_Orders_PaymentMethod CHECK (payment_method IN ('Cash','QR-Code','Bank-Transfer')),
    CONSTRAINT CK_Orders_OnlineAddress CHECK (order_type = 'At-Counter' OR shipping_address IS NOT NULL)
);

CREATE INDEX IX_Orders_UserDate ON dbo.Orders(user_id, order_date DESC);
CREATE INDEX IX_Orders_StatusDate ON dbo.Orders(status, order_date DESC);

CREATE TABLE dbo.OrderDetails (
    order_detail_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OrderDetails PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    selected_size VARCHAR(10) NOT NULL CONSTRAINT DF_OrderDetails_Size DEFAULT ('M'),
    ice_level VARCHAR(20) NOT NULL CONSTRAINT DF_OrderDetails_Ice DEFAULT ('100%'),
    sugar_level VARCHAR(20) NOT NULL CONSTRAINT DF_OrderDetails_Sugar DEFAULT ('100%'),
    price DECIMAL(12,2) NOT NULL,
    note NVARCHAR(255) NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id),
    CONSTRAINT CK_OrderDetails_Quantity CHECK (quantity > 0),
    CONSTRAINT CK_OrderDetails_Price CHECK (price >= 0),
    CONSTRAINT CK_OrderDetails_Size CHECK (selected_size IN ('S','M','L')),
    CONSTRAINT CK_OrderDetails_Ice CHECK (ice_level IN ('0%','30%','50%','70%','100%')),
    CONSTRAINT CK_OrderDetails_Sugar CHECK (sugar_level IN ('0%','30%','50%','70%','100%'))
);

CREATE INDEX IX_OrderDetails_Order ON dbo.OrderDetails(order_id);
CREATE INDEX IX_OrderDetails_Product ON dbo.OrderDetails(product_id);

CREATE TABLE dbo.OrderDetailToppings (
    order_detail_id INT NOT NULL,
    topping_id INT NOT NULL,
    quantity INT NOT NULL CONSTRAINT DF_OrderDetailToppings_Quantity DEFAULT (1),
    topping_price DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_OrderDetailToppings PRIMARY KEY (order_detail_id, topping_id),
    CONSTRAINT FK_OrderDetailToppings_Details FOREIGN KEY (order_detail_id) REFERENCES dbo.OrderDetails(order_detail_id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetailToppings_Toppings FOREIGN KEY (topping_id) REFERENCES dbo.Toppings(topping_id),
    CONSTRAINT CK_OrderDetailToppings_Quantity CHECK (quantity > 0),
    CONSTRAINT CK_OrderDetailToppings_Price CHECK (topping_price >= 0)
);

-- ============================================================================
-- 4. PAYMENT, DELIVERY, REFUND AND ORDER AUDIT
-- ============================================================================

CREATE TABLE dbo.Payments (
    payment_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Payments PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    amount_received DECIMAL(12,2) NULL,
    change_amount DECIMAL(12,2) NOT NULL CONSTRAINT DF_Payments_Change DEFAULT (0),
    transaction_code VARCHAR(100) NULL,
    payment_status VARCHAR(20) NOT NULL CONSTRAINT DF_Payments_Status DEFAULT ('Pending'),
    paid_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT CK_Payments_Method CHECK (payment_method IN ('Cash','QR-Code','Bank-Transfer')),
    CONSTRAINT CK_Payments_Amount CHECK (amount >= 0),
    CONSTRAINT CK_Payments_Received CHECK (amount_received IS NULL OR amount_received >= 0),
    CONSTRAINT CK_Payments_Change CHECK (change_amount >= 0),
    CONSTRAINT CK_Payments_Status CHECK (payment_status IN ('Pending','Paid','Failed','Refunded'))
);

CREATE UNIQUE INDEX UX_Payments_TransactionCode ON dbo.Payments(transaction_code) WHERE transaction_code IS NOT NULL;
CREATE INDEX IX_Payments_Order ON dbo.Payments(order_id);

CREATE TABLE dbo.Deliveries (
    delivery_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Deliveries PRIMARY KEY,
    order_id INT NOT NULL CONSTRAINT UQ_Deliveries_Order UNIQUE,
    shipper_id INT NULL,
    delivery_status VARCHAR(20) NOT NULL CONSTRAINT DF_Deliveries_Status DEFAULT ('Waiting'),
    assigned_at DATETIME2(0) NULL,
    picked_up_at DATETIME2(0) NULL,
    delivered_at DATETIME2(0) NULL,
    delivery_note NVARCHAR(255) NULL,
    CONSTRAINT FK_Deliveries_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_Deliveries_Shippers FOREIGN KEY (shipper_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_Deliveries_Status CHECK (delivery_status IN ('Waiting','Assigned','Delivering','Delivered','Failed','Cancelled'))
);

CREATE TABLE dbo.Refunds (
    refund_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Refunds PRIMARY KEY,
    order_id INT NOT NULL,
    payment_id INT NULL,
    requested_by INT NULL,
    processed_by INT NULL,
    refund_amount DECIMAL(12,2) NOT NULL,
    reason NVARCHAR(255) NOT NULL,
    refund_status VARCHAR(20) NOT NULL CONSTRAINT DF_Refunds_Status DEFAULT ('Pending'),
    requested_at DATETIME2(0) NOT NULL CONSTRAINT DF_Refunds_RequestedAt DEFAULT (SYSDATETIME()),
    processed_at DATETIME2(0) NULL,
    CONSTRAINT FK_Refunds_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_Refunds_Payments FOREIGN KEY (payment_id) REFERENCES dbo.Payments(payment_id),
    CONSTRAINT FK_Refunds_Requester FOREIGN KEY (requested_by) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Refunds_Processor FOREIGN KEY (processed_by) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_Refunds_Amount CHECK (refund_amount > 0),
    CONSTRAINT CK_Refunds_Status CHECK (refund_status IN ('Pending','Approved','Rejected','Completed'))
);

CREATE TABLE dbo.OrderStatusHistory (
    history_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OrderStatusHistory PRIMARY KEY,
    order_id INT NOT NULL,
    old_status VARCHAR(30) NULL,
    new_status VARCHAR(30) NOT NULL,
    changed_by INT NULL,
    changed_at DATETIME2(0) NOT NULL CONSTRAINT DF_OrderStatusHistory_ChangedAt DEFAULT (SYSDATETIME()),
    note NVARCHAR(255) NULL,
    CONSTRAINT FK_OrderStatusHistory_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderStatusHistory_Users FOREIGN KEY (changed_by) REFERENCES dbo.Users(user_id),
    CONSTRAINT CK_OrderStatusHistory_NewStatus CHECK (new_status IN ('Pending','Approved','Completed','Cancelled'))
);

CREATE INDEX IX_OrderStatusHistory_OrderDate ON dbo.OrderStatusHistory(order_id, changed_at);

-- ============================================================================
-- 5. LOYALTY, REVIEWS AND NOTIFICATIONS
-- ============================================================================

CREATE TABLE dbo.PointTransactions (
    point_transaction_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_PointTransactions PRIMARY KEY,
    user_id INT NOT NULL,
    order_id INT NULL,
    voucher_id INT NULL,
    points_change INT NOT NULL,
    balance_after INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    description NVARCHAR(255) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_PointTransactions_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_PointTransactions_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_PointTransactions_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_PointTransactions_Vouchers FOREIGN KEY (voucher_id) REFERENCES dbo.Vouchers(voucher_id),
    CONSTRAINT CK_PointTransactions_Change CHECK (points_change <> 0),
    CONSTRAINT CK_PointTransactions_Balance CHECK (balance_after >= 0),
    CONSTRAINT CK_PointTransactions_Type CHECK (transaction_type IN ('Earn','Redeem','Adjust','Refund'))
);

CREATE INDEX IX_PointTransactions_UserDate ON dbo.PointTransactions(user_id, created_at DESC);

CREATE TABLE dbo.Reviews (
    review_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Reviews PRIMARY KEY,
    user_id INT NOT NULL,
    order_detail_id INT NOT NULL CONSTRAINT UQ_Reviews_OrderDetail UNIQUE,
    rating TINYINT NOT NULL,
    comment NVARCHAR(500) NULL,
    status BIT NOT NULL CONSTRAINT DF_Reviews_Status DEFAULT (1),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Reviews_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
    CONSTRAINT FK_Reviews_OrderDetails FOREIGN KEY (order_detail_id) REFERENCES dbo.OrderDetails(order_detail_id),
    CONSTRAINT CK_Reviews_Rating CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE dbo.Notifications (
    notification_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Notifications PRIMARY KEY,
    user_id INT NOT NULL,
    order_id INT NULL,
    title NVARCHAR(150) NOT NULL,
    message NVARCHAR(500) NOT NULL,
    notification_type VARCHAR(30) NOT NULL CONSTRAINT DF_Notifications_Type DEFAULT ('System'),
    is_read BIT NOT NULL CONSTRAINT DF_Notifications_IsRead DEFAULT (0),
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Notifications_Users FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_Notifications_Orders FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT CK_Notifications_Type CHECK (notification_type IN ('Order','Voucher','Point','System'))
);

CREATE INDEX IX_Notifications_UserReadDate ON dbo.Notifications(user_id, is_read, created_at DESC);
GO

-- ============================================================================
-- 6. SAMPLE DATA
-- Default password for every sample account: 123456
-- ============================================================================

INSERT INTO dbo.Roles (role_name, description) VALUES
('Manager', N'Quáº£n lÃ½ cá»­a hÃ ng vÃ  bÃ¡o cÃ¡o'),
('Staff', N'NhÃ¢n viÃªn thu ngÃ¢n, pha cháº¿ hoáº·c giao hÃ ng'),
('Customer', N'KhÃ¡ch hÃ ng Ä‘áº·t mÃ³n vÃ  tÃ­ch Ä‘iá»ƒm');

INSERT INTO dbo.Users
    (username, password, full_name, email, phone, address, gender, staff_position, status, points, role_id, created_at)
VALUES
('admin01',    '123456', N'Nguyá»…n Quáº£n LÃ½',       'admin@cbms.com',      '0912345678', N'HÃ  Ná»™i',         N'Nam',  N'Manager',   1,    0, 1, '2026-01-02 08:00:00'),
('cashier01',  '123456', N'LÃª Thu NgÃ¢n',           'cashier@cbms.com',    '0987654321', N'HÃ  Ná»™i',         N'Ná»¯',   N'Thu ngÃ¢n',  1,    0, 2, '2026-01-05 08:00:00'),
('barista01',  '123456', N'Tráº§n Pha Cháº¿',          'barista@cbms.com',    '0944556677', N'HÃ  Ná»™i',         N'Nam',  N'Pha cháº¿',   1,    0, 2, '2026-01-06 08:00:00'),
('shipper01',  '123456', N'Pháº¡m Giao HÃ ng',        'shipper@cbms.com',    '0966112233', N'HÃ  Ná»™i',         N'Nam',  N'Giao hÃ ng', 1,    0, 2, '2026-01-07 08:00:00'),
('staff02',    '123456', N'VÅ© NhÃ¢n ViÃªn Nghá»‰',     'staff02@cbms.com',    '0977001122', N'HÃ  Ná»™i',         N'KhÃ¡c', N'NhÃ¢n viÃªn', 0,    0, 2, '2026-01-08 08:00:00'),
('customer01', '123456', N'Phan KhÃ¡ch HÃ ng Online','customer01@gmail.com','0909090909', N'Tháº¡ch Tháº¥t',      N'Nam',  NULL,        1, 2390, 3, '2026-02-01 09:00:00'),
('customer02', '123456', N'HoÃ ng Minh Anh',        'customer02@gmail.com','0933221100', N'Cáº§u Giáº¥y',       N'Ná»¯',   NULL,        1, 1908, 3, '2026-02-05 09:00:00'),
('customer03', '123456', N'Äá»— Háº£i Nam',            'customer03@gmail.com','0922113344', N'Nam Tá»« LiÃªm',    N'Nam',  NULL,        1,  760, 3, '2026-02-10 09:00:00'),
('customer04', '123456', N'BÃ¹i Thanh HÃ ',          'customer04@gmail.com','0955667788', N'HoÃ i Äá»©c',       N'Ná»¯',   NULL,        1, 1200, 3, '2026-03-01 09:00:00'),
('customer05', '123456', N'NgÃ´ Gia Báº£o',           'customer05@gmail.com','0888999000', N'HÃ  ÄÃ´ng',        N'KhÃ¡c', NULL,        1,  540, 3, '2026-03-12 09:00:00');

UPDATE dbo.Users SET avatar_url = '/images/avatars/uploads/avatar-1-1783753731072.jpg' WHERE username = 'admin01';
UPDATE dbo.Users SET avatar_url = '/images/avatars/uploads/avatar-2-1783656457343.jpg' WHERE username = 'cashier01';
UPDATE dbo.Users SET avatar_url = '/images/avatars/uploads/avatar-6-1783742549197.jpg' WHERE username = 'customer01';

INSERT INTO dbo.Categories (category_name, description, status) VALUES
(N'CÃ  phÃª', N'CÃ  phÃª mÃ¡y vÃ  cÃ  phÃª phin Viá»‡t Nam', 1),
(N'TrÃ  sá»¯a', N'TrÃ  sá»¯a vÃ  thá»©c uá»‘ng tá»« sá»¯a', 1),
(N'TrÃ  trÃ¡i cÃ¢y', N'TrÃ  thanh mÃ¡t káº¿t há»£p trÃ¡i cÃ¢y', 1),
(N'NÆ°á»›c Ã©p', N'NÆ°á»›c Ã©p trÃ¡i cÃ¢y tÆ°Æ¡i', 1),
(N'Äá»“ Äƒn nháº¹', N'BÃ¡nh vÃ  mÃ³n Äƒn kÃ¨m', 1);

INSERT INTO dbo.Products (product_name, category_id, price, image_url, description, status, created_at) VALUES
(N'CÃ  phÃª sá»¯a Ä‘Ã¡',             1, 29000, '/images/products/uploads/product-1783652364053.jpg', N'CÃ  phÃª Ä‘áº­m vá»‹ cÃ¹ng sá»¯a Ä‘áº·c', 1, '2026-01-10'),
(N'Báº¡c xá»‰u',                    1, 32000, '/images/products/uploads/product-1783652376341.jpg', N'Nhiá»u sá»¯a, nháº¹ vá»‹ cÃ  phÃª', 1, '2026-01-10'),
(N'Cappuccino',                 1, 39000, '/images/products/uploads/product-1783652386892.jpg', N'Espresso vÃ  bá»t sá»¯a má»‹n', 1, '2026-01-10'),
(N'TrÃ  sá»¯a trÃ¢n chÃ¢u Ä‘Æ°á»ng Ä‘en',2, 45000, '/images/products/uploads/product-1783652412242.jpg', N'TrÃ  sá»¯a cÃ¹ng trÃ¢n chÃ¢u Ä‘Æ°á»ng Ä‘en', 1, '2026-01-11'),
(N'TrÃ  sá»¯a Matcha',             2, 47000, '/images/products/uploads/product-1783652423318.jpg', N'Matcha Nháº­t Báº£n vÃ  sá»¯a tÆ°Æ¡i', 1, '2026-01-11'),
(N'TrÃ  Ä‘Ã o cam sáº£',             3, 42000, '/images/products/uploads/product-1783652475947.jpg', N'ÄÃ o, cam vÃ  sáº£ thanh mÃ¡t', 1, '2026-01-12'),
(N'TrÃ  váº£i',                    3, 39000, '/images/products/uploads/product-1783652497062.jpg', N'TrÃ  thÆ¡m káº¿t há»£p quáº£ váº£i', 1, '2026-01-12'),
(N'NÆ°á»›c Ã©p cam',                4, 35000, '/images/products/uploads/product-1783652520082.jpg', N'NÆ°á»›c cam Ã©p nguyÃªn cháº¥t', 1, '2026-01-13'),
(N'NÆ°á»›c Ã©p dÆ°a háº¥u',            4, 35000, '/images/products/uploads/product-1783652531970.jpg', N'DÆ°a háº¥u tÆ°Æ¡i mÃ¡t', 1, '2026-01-13'),
(N'BÃ¡nh Croissant',             5, 28000, '/images/products/uploads/product-1783652557130.jpg', N'BÃ¡nh sá»«ng bÃ² thÆ¡m bÆ¡', 1, '2026-01-14'),
(N'Americano',                  1, 37000, '/images/products/uploads/product-1783671139443.jpg', NULL, 1, '2026-07-10'),
(N'CÃ  phÃª trá»©ng',               1, 40000, '/images/products/uploads/product-1783671451182.jpg', NULL, 1, '2026-07-10'),
(N'Caramel Macchiato',          1, 28000, '/images/products/uploads/product-1783671502225.jpg', NULL, 1, '2026-07-10'),
(N'Espresso',                   1, 21000, '/images/products/uploads/product-1783671533128.jpg', NULL, 1, '2026-07-10'),
(N'Cold Brew',                  1, 24000, '/images/products/uploads/product-1783671575228.jpg', NULL, 1, '2026-07-10');

INSERT INTO dbo.Sizes (size_code, size_name, price_modifier, status) VALUES
('S', N'Nhá»', -3000, 1),
('M', N'Vá»«a',     0, 1),
('L', N'Lá»›n',  5000, 1);

INSERT INTO dbo.Toppings (topping_name, price, status) VALUES
(N'TrÃ¢n chÃ¢u Ä‘en',       8000, 1),
(N'TrÃ¢n chÃ¢u tráº¯ng',     8000, 1),
(N'Tháº¡ch sÆ°Æ¡ng sÃ¡o',     6000, 1),
(N'Tháº¡ch trÃ¡i cÃ¢y',      7000, 1),
(N'Pudding trá»©ng',      10000, 1),
(N'Kem cheese',         12000, 1),
(N'Nha Ä‘am',             7000, 1),
(N'Háº¡t thá»§y tinh',       9000, 0);

INSERT INTO dbo.ProductToppings (product_id, topping_id) VALUES
(1,6),(2,6),(3,6),(4,1),(4,2),(4,5),(4,6),(5,2),(5,5),(5,6),
(6,3),(6,4),(6,7),(7,3),(7,4),(7,7),(8,7),(9,4);

INSERT INTO dbo.Combos (combo_name, combo_price, image_url, description, start_date, end_date, status) VALUES
(N'Combo sÃ¡ng tá»‰nh tÃ¡o', 52000, 'combo-sang.png', N'CÃ  phÃª sá»¯a Ä‘Ã¡ vÃ  Croissant', '2026-01-01', '2027-12-31', 1),
(N'Combo Ä‘Ã´i ngá»t ngÃ o', 82000, 'combo-doi.png', N'Hai ly trÃ  sá»¯a', '2026-01-01', '2027-12-31', 1),
(N'Combo vÄƒn phÃ²ng', 95000, 'combo-van-phong.png', N'Äá»“ uá»‘ng cho nhÃ³m nhá»', '2026-01-01', '2027-12-31', 1),
(N'Combo trÃ  chiá»u', 65000, 'combo-tra-chieu.png', N'TrÃ  trÃ¡i cÃ¢y vÃ  bÃ¡nh', '2026-01-01', '2027-12-31', 1),
(N'Combo nÄƒng lÆ°á»£ng', 88000, 'combo-nang-luong.png', N'CÃ  phÃª vÃ  nÆ°á»›c Ã©p', '2026-01-01', '2027-12-31', 1);

INSERT INTO dbo.ComboItems (combo_id, product_id, quantity) VALUES
(1,1,1),(1,10,1),(2,4,1),(2,5,1),(3,1,2),(3,10,1),(4,6,1),(4,10,1),(5,3,1),(5,8,1);

INSERT INTO dbo.Vouchers
    (voucher_code, discount_value, min_order_value, points_cost, start_date, expiry_date, status, owner_user_id, used_at)
VALUES
('WELCOME15', 15000,  40000,    0, '2026-01-01', '2027-12-31', 1, NULL, NULL),
('GIAM20K',   20000,  60000,    0, '2026-01-01', '2027-12-31', 1, NULL, NULL),
('GIAM30K',   30000, 100000,    0, '2026-01-01', '2027-12-31', 1, NULL, NULL),
('FREESHIP',  15000,  80000,    0, '2026-01-01', '2027-12-31', 1, NULL, NULL),
('EXPIRED10', 10000,  30000,    0, '2026-01-01', '2026-05-01', 0, NULL, NULL),
('POINT6A',   20000,  50000, 1000, '2026-06-01', '2027-06-01', 1, 6, NULL),
('POINT7A',   30000,  70000, 2000, '2026-06-05', '2027-06-05', 1, 7, NULL),
('USED6A',    20000,  50000, 1000, '2026-05-01', '2027-05-01', 0, 6, '2026-06-20 10:00:00');

INSERT INTO dbo.Orders
    (user_id, staff_id, voucher_id, total_price, discount_amount, shipping_fee, order_date, status, points_awarded, order_type, shipping_address, shipping_phone, payment_method, note)
VALUES
(6, 2, 1,  70000, 15000, 15000, '2026-06-20 09:15:00', 'Completed', 1, 'Online',    N'Tháº¡ch Tháº¥t, HÃ  Ná»™i',   '0909090909', 'QR-Code', N'Gá»i trÆ°á»›c khi giao'),
(7, 2, NULL,58000,     0,     0, '2026-06-21 10:30:00', 'Completed', 1, 'At-Counter',NULL,                    NULL,         'Cash',    NULL),
(8, NULL,NULL,42000,    0, 15000, '2026-07-05 08:20:00', 'Pending',   0, 'Online',    N'Nam Tá»« LiÃªm, HÃ  Ná»™i', '0922113344', 'Cash',    N'Ãt Ä‘Ã¡'),
(9, 2, 2,  84000, 20000,     0, '2026-07-05 09:05:00', 'Approved',  0, 'At-Counter',NULL,                    NULL,         'Cash',    NULL),
(10,2, NULL,89000,     0, 15000, '2026-07-05 09:45:00', 'Approved',  0, 'Online',    N'HÃ  ÄÃ´ng, HÃ  Ná»™i',      '0888999000', 'QR-Code', NULL),
(6, 2, 3, 120000, 30000,     0, '2026-06-25 14:10:00', 'Completed', 1, 'At-Counter',NULL,                    NULL,         'Cash',    NULL),
(7, 2, NULL,47000,     0, 15000, '2026-06-26 11:00:00', 'Cancelled', 0, 'Online',    N'Cáº§u Giáº¥y, HÃ  Ná»™i',     '0933221100', 'QR-Code', N'KhÃ¡ch Ä‘á»•i Ã½'),
(8, 2, NULL,64000,     0,     0, '2026-06-27 16:20:00', 'Cancelled', 0, 'At-Counter',NULL,                    NULL,         'Cash',    N'Sáº£n pháº©m lá»—i'),
(9, 2, 4,  69000, 15000, 15000, '2026-06-28 13:15:00', 'Cancelled', 0, 'Online',    N'HoÃ i Äá»©c, HÃ  Ná»™i',     '0955667788', 'QR-Code', N'KhÃ´ng liÃªn há»‡ Ä‘Æ°á»£c'),
(10,2, NULL,70000,     0,     0, '2026-06-29 18:40:00', 'Cancelled', 0, 'At-Counter',NULL,                    NULL,         'Bank-Transfer', N'HoÃ n theo yÃªu cáº§u');

INSERT INTO dbo.OrderDetails
    (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price, note)
VALUES
(1,4,1,'L','70%','70%',50000,NULL),
(1,6,1,'M','50%','70%',42000,NULL),
(2,1,2,'M','100%','100%',29000,NULL),
(3,6,1,'M','30%','70%',42000,N'Ãt Ä‘Ã¡'),
(4,4,1,'L','100%','100%',50000,NULL),
(4,5,1,'M','50%','70%',47000,NULL),
(5,7,1,'L','50%','50%',44000,NULL),
(5,8,1,'M','50%','100%',35000,NULL),
(6,3,2,'L','100%','100%',44000,NULL),
(6,10,1,'M','100%','100%',28000,NULL),
(7,5,1,'M','50%','50%',47000,NULL),
(8,2,2,'M','100%','100%',32000,NULL),
(9,6,2,'M','50%','70%',42000,NULL),
(10,8,1,'M','50%','100%',35000,NULL),
(10,9,1,'M','50%','100%',35000,NULL);

INSERT INTO dbo.OrderDetailToppings (order_detail_id, topping_id, quantity, topping_price) VALUES
(1,1,1,8000),(1,6,1,12000),(2,4,1,7000),(5,2,1,8000),(6,5,1,10000),
(7,7,1,7000),(9,6,1,12000),(11,5,1,10000),(13,3,2,6000),(14,7,1,7000);

INSERT INTO dbo.Payments
    (order_id, payment_method, amount, amount_received, change_amount, transaction_code, payment_status, paid_at, created_at)
VALUES
(1, 'QR-Code',      70000,  70000,     0, 'QR-20260620-001', 'Paid',     '2026-06-20 09:17:00', '2026-06-20 09:16:00'),
(2, 'Cash',         58000, 100000, 42000, NULL,               'Paid',     '2026-06-21 10:31:00', '2026-06-21 10:30:00'),
(4, 'Cash',         84000, 100000, 16000, NULL,               'Paid',     '2026-07-05 09:06:00', '2026-07-05 09:05:00'),
(5, 'QR-Code',      89000,  89000,     0, 'QR-20260705-005', 'Paid',     '2026-07-05 09:47:00', '2026-07-05 09:46:00'),
(6, 'Cash',        120000, 150000, 30000, NULL,               'Paid',     '2026-06-25 14:11:00', '2026-06-25 14:10:00'),
(7, 'QR-Code',      47000,  47000,     0, 'QR-20260626-007', 'Refunded', '2026-06-26 11:02:00', '2026-06-26 11:01:00'),
(8, 'Cash',         64000, 100000, 36000, NULL,               'Refunded', '2026-06-27 16:21:00', '2026-06-27 16:20:00'),
(10,'Bank-Transfer',70000,  70000,     0, 'BANK-20260629-10','Refunded', '2026-06-29 18:42:00', '2026-06-29 18:41:00');

INSERT INTO dbo.Deliveries
    (order_id, shipper_id, delivery_status, assigned_at, picked_up_at, delivered_at, delivery_note)
VALUES
(1, 4, 'Delivered',  '2026-06-20 09:30:00', '2026-06-20 09:40:00', '2026-06-20 10:05:00', N'ÄÃ£ giao táº­n tay'),
(3, NULL, 'Waiting', NULL,                  NULL,                  NULL,                  N'Chá» duyá»‡t Ä‘Æ¡n'),
(5, 4, 'Delivering', '2026-07-05 10:00:00', '2026-07-05 10:10:00', NULL,                  N'Äang trÃªn Ä‘Æ°á»ng giao'),
(7, 4, 'Cancelled',  '2026-06-26 11:10:00', NULL,                  NULL,                  N'KhÃ¡ch há»§y trÆ°á»›c khi láº¥y mÃ³n'),
(9, 4, 'Failed',     '2026-06-28 13:30:00', '2026-06-28 13:40:00', NULL,                  N'KhÃ´ng liÃªn há»‡ Ä‘Æ°á»£c khÃ¡ch');

INSERT INTO dbo.Refunds
    (order_id, payment_id, requested_by, processed_by, refund_amount, reason, refund_status, requested_at, processed_at)
VALUES
(7, 6, 7, 2, 47000, N'KhÃ¡ch Ä‘á»•i Ã½ trÆ°á»›c khi giao', 'Completed', '2026-06-26 11:05:00', '2026-06-26 11:20:00'),
(8, 7, 8, 2, 64000, N'Sáº£n pháº©m khÃ´ng Ä‘Ãºng yÃªu cáº§u', 'Completed', '2026-06-27 16:30:00', '2026-06-27 16:45:00'),
(9, NULL,9, 2, 69000, N'KhÃ´ng thá»ƒ giao hÃ ng', 'Approved', '2026-06-28 14:10:00', '2026-06-28 14:30:00'),
(10,8,10, 1, 70000, N'KhÃ¡ch yÃªu cáº§u hoÃ n tiá»n', 'Completed', '2026-06-29 19:00:00', '2026-06-29 20:00:00'),
(4, 3, 9, NULL, 84000, N'YÃªu cáº§u há»§y khi Ä‘ang pha cháº¿', 'Pending', '2026-07-05 09:15:00', NULL);

INSERT INTO dbo.OrderStatusHistory (order_id, old_status, new_status, changed_by, changed_at, note) VALUES
(1,NULL,'Pending',6,'2026-06-20 09:15:00',N'KhÃ¡ch táº¡o Ä‘Æ¡n'),
(1,'Pending','Approved',2,'2026-06-20 09:20:00',N'Thu ngÃ¢n duyá»‡t'),
(1,'Approved','Approved',3,'2026-06-20 09:22:00',N'Báº¯t Ä‘áº§u pha cháº¿'),
(1,'Approved','Approved',4,'2026-06-20 09:40:00',N'Nháº­n Ä‘Æ¡n giao'),
(1,'Approved','Completed',4,'2026-06-20 10:05:00',N'Giao thÃ nh cÃ´ng'),
(2,NULL,'Approved',2,'2026-06-21 10:30:00',N'ÄÆ¡n táº¡i quáº§y'),
(2,'Approved','Completed',2,'2026-06-21 10:35:00',N'ÄÃ£ giao Ä‘á»“ uá»‘ng'),
(3,NULL,'Pending',8,'2026-07-05 08:20:00',N'KhÃ¡ch táº¡o Ä‘Æ¡n'),
(4,NULL,'Approved',2,'2026-07-05 09:05:00',N'ÄÆ¡n táº¡i quáº§y'),
(5,NULL,'Pending',10,'2026-07-05 09:45:00',N'KhÃ¡ch táº¡o Ä‘Æ¡n'),
(5,'Pending','Approved',2,'2026-07-05 09:50:00',N'ÄÃ£ duyá»‡t'),
(5,'Approved','Approved',3,'2026-07-05 09:52:00',N'Äang pha cháº¿'),
(5,'Approved','Approved',3,'2026-07-05 10:00:00',N'ÄÃ£ pha xong'),
(5,'Approved','Approved',4,'2026-07-05 10:10:00',N'Äang giao'),
(6,NULL,'Approved',2,'2026-06-25 14:10:00',N'ÄÆ¡n táº¡i quáº§y'),
(6,'Approved','Completed',2,'2026-06-25 14:20:00',N'HoÃ n thÃ nh'),
(7,'Pending','Cancelled',2,'2026-06-26 11:05:00',N'KhÃ¡ch há»§y'),
(8,'Completed','Cancelled',2,'2026-06-27 16:45:00',N'ÄÃ£ hoÃ n tiá»n'),
(9,'Approved','Cancelled',2,'2026-06-28 14:30:00',N'Giao tháº¥t báº¡i'),
(10,'Completed','Cancelled',1,'2026-06-29 20:00:00',N'Quáº£n lÃ½ duyá»‡t hoÃ n tiá»n');

INSERT INTO dbo.PointTransactions
    (user_id, order_id, voucher_id, points_change, balance_after, transaction_type, description, created_at)
VALUES
(6,1,NULL, 70,2270,'Earn',  N'Cá»™ng Ä‘iá»ƒm Ä‘Æ¡n #1', '2026-06-20 10:05:00'),
(7,2,NULL, 58,1908,'Earn',  N'Cá»™ng Ä‘iá»ƒm Ä‘Æ¡n #2', '2026-06-21 10:35:00'),
(6,6,NULL,120,2390,'Earn',  N'Cá»™ng Ä‘iá»ƒm Ä‘Æ¡n #6', '2026-06-25 14:20:00'),
(6,NULL,6,-1000,2200,'Redeem',N'Äá»•i voucher POINT6A', '2026-06-01 09:00:00'),
(7,NULL,7,-2000,1850,'Redeem', N'Äá»•i voucher POINT7A', '2026-06-05 09:00:00'),
(8,NULL,NULL,100,760,'Adjust',N'Äiá»ƒm khuyáº¿n máº¡i khai trÆ°Æ¡ng', '2026-05-01 08:00:00'),
(9,NULL,NULL,200,1200,'Adjust',N'Äiá»ƒm sinh nháº­t', '2026-05-20 08:00:00'),
(10,10,NULL,-70,540,'Refund',N'Thu há»“i Ä‘iá»ƒm do hoÃ n Ä‘Æ¡n #10', '2026-06-29 20:00:00');

INSERT INTO dbo.Reviews (user_id, order_detail_id, rating, comment, status, created_at) VALUES
(6,1,5,N'TrÃ  sá»¯a ngon, giao nhanh',1,'2026-06-20 11:00:00'),
(6,2,4,N'TrÃ  Ä‘Ã o thÆ¡m vÃ  vá»«a ngá»t',1,'2026-06-20 11:02:00'),
(7,3,5,N'CÃ  phÃª Ä‘áº­m vá»‹',1,'2026-06-21 12:00:00'),
(6,9,4,N'Cappuccino á»•n, bá»t sá»¯a má»‹n',1,'2026-06-25 15:00:00'),
(6,10,5,N'BÃ¡nh giÃ²n vÃ  thÆ¡m bÆ¡',1,'2026-06-25 15:02:00');

INSERT INTO dbo.Notifications (user_id, order_id, title, message, notification_type, is_read, created_at) VALUES
(6,1,N'ÄÆ¡n hÃ ng hoÃ n thÃ nh',N'ÄÆ¡n #1 Ä‘Ã£ Ä‘Æ°á»£c giao thÃ nh cÃ´ng.','Order',0,'2026-06-20 10:05:00'),
(6,1,N'ÄÃ£ cá»™ng Ä‘iá»ƒm',N'Báº¡n nháº­n Ä‘Æ°á»£c 70 Ä‘iá»ƒm tá»« Ä‘Æ¡n #1.','Point',0,'2026-06-20 10:06:00'),
(7,2,N'ÄÆ¡n hÃ ng hoÃ n thÃ nh',N'ÄÆ¡n #2 Ä‘Ã£ hoÃ n thÃ nh.','Order',1,'2026-06-21 10:35:00'),
(8,3,N'ÄÃ£ tiáº¿p nháº­n Ä‘Æ¡n',N'ÄÆ¡n #3 Ä‘ang chá» thu ngÃ¢n duyá»‡t.','Order',0,'2026-07-05 08:20:00'),
(9,4,N'ÄÆ¡n Ä‘ang pha cháº¿',N'ÄÆ¡n #4 Ä‘ang Ä‘Æ°á»£c chuáº©n bá»‹.','Order',0,'2026-07-05 09:06:00'),
(10,5,N'ÄÆ¡n Ä‘ang giao',N'Shipper Ä‘ang giao Ä‘Æ¡n #5 Ä‘áº¿n báº¡n.','Order',0,'2026-07-05 10:10:00'),
(6,NULL,N'Voucher má»›i',N'Voucher POINT6A Ä‘Ã£ Ä‘Æ°á»£c thÃªm vÃ o vÃ­.','Voucher',1,'2026-06-01 09:00:00'),
(7,NULL,N'Voucher má»›i',N'Voucher POINT7A Ä‘Ã£ Ä‘Æ°á»£c thÃªm vÃ o vÃ­.','Voucher',0,'2026-06-05 09:00:00');
GO

-- ============================================================================
-- 7. REPORTING VIEWS FOR DASHBOARD TASK
-- ============================================================================

CREATE VIEW dbo.vw_DailyRevenue AS
SELECT CAST(order_date AS DATE) AS revenue_date,
       COUNT(*) AS completed_orders,
       SUM(total_price) AS revenue
FROM dbo.Orders
WHERE status = 'Completed'
GROUP BY CAST(order_date AS DATE);
GO

CREATE VIEW dbo.vw_MonthlyRevenue AS
SELECT YEAR(order_date) AS revenue_year,
       MONTH(order_date) AS revenue_month,
       COUNT(*) AS completed_orders,
       SUM(total_price) AS revenue
FROM dbo.Orders
WHERE status = 'Completed'
GROUP BY YEAR(order_date), MONTH(order_date);
GO

CREATE VIEW dbo.vw_TopSellingProducts AS
SELECT p.product_id, p.product_name,
       SUM(od.quantity) AS quantity_sold,
       SUM(od.quantity * od.price) AS product_revenue
FROM dbo.OrderDetails od
JOIN dbo.Orders o ON o.order_id = od.order_id
JOIN dbo.Products p ON p.product_id = od.product_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name;
GO

CREATE VIEW dbo.vw_OrderStatusSummary AS
SELECT status, COUNT(*) AS order_count, SUM(total_price) AS total_value
FROM dbo.Orders
GROUP BY status;
GO

CREATE VIEW dbo.vw_ToppingSales AS
SELECT t.topping_id, t.topping_name,
       SUM(odt.quantity * od.quantity) AS quantity_sold,
       SUM(odt.quantity * od.quantity * odt.topping_price) AS topping_revenue
FROM dbo.OrderDetailToppings odt
JOIN dbo.OrderDetails od ON od.order_detail_id = odt.order_detail_id
JOIN dbo.Orders o ON o.order_id = od.order_id
JOIN dbo.Toppings t ON t.topping_id = odt.topping_id
WHERE o.status = 'Completed'
GROUP BY t.topping_id, t.topping_name;
GO

-- ============================================================================
-- 8. VERIFICATION
-- ============================================================================

SELECT t.name AS table_name, SUM(p.rows) AS row_count
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;

SELECT TOP (5) * FROM dbo.vw_DailyRevenue ORDER BY revenue_date DESC;
SELECT TOP (5) * FROM dbo.vw_TopSellingProducts ORDER BY quantity_sold DESC, product_id;
GO

/* ======================================================================
   IMAGE URL ONLINE FIX 2026-07-12
   Äá»•i Ä‘Æ°á»ng dáº«n áº£nh local trong database sang raw GitHub URL Ä‘á»ƒ mÃ¡y khÃ¡c váº«n hiá»ƒn thá»‹ áº£nh.
   LÆ°u Ã½: cÃ¡c file áº£nh trong web/images pháº£i Ä‘Æ°á»£c commit vÃ  push lÃªn GitHub trÆ°á»›c.
   ====================================================================== */
DECLARE @ImageBase VARCHAR(255) = 'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web';

UPDATE dbo.Products
SET image_url = CASE
    WHEN image_url LIKE '/images/products/%' THEN @ImageBase + image_url
    WHEN image_url LIKE 'images/products/%' THEN @ImageBase + '/' + image_url
    WHEN image_url LIKE '/uploads/products/%' THEN @ImageBase + '/images/products' + image_url
    WHEN image_url LIKE 'uploads/products/%' THEN @ImageBase + '/images/products/' + image_url
    ELSE image_url
END
WHERE image_url IS NOT NULL
  AND image_url <> ''
  AND image_url NOT LIKE 'http://%'
  AND image_url NOT LIKE 'https://%';

UPDATE dbo.Users
SET avatar_url = CASE
    WHEN avatar_url LIKE '/images/avatars/%' THEN @ImageBase + avatar_url
    WHEN avatar_url LIKE 'images/avatars/%' THEN @ImageBase + '/' + avatar_url
    WHEN avatar_url LIKE '/uploads/avatars/%' THEN @ImageBase + '/images/avatars' + avatar_url
    WHEN avatar_url LIKE 'uploads/avatars/%' THEN @ImageBase + '/images/avatars/' + avatar_url
    ELSE avatar_url
END
WHERE avatar_url IS NOT NULL
  AND avatar_url <> ''
  AND avatar_url NOT LIKE 'http://%'
  AND avatar_url NOT LIKE 'https://%';

/* ======================================================================
   CBMS FULL DATA EXPORT - generated from local SQL Server on 2026-07-12
   Run after database/schema exists. This refreshes all table data.
   ====================================================================== */
SET NOCOUNT ON;
GO
USE [CBMS];
GO

EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

DELETE FROM [dbo].[Vouchers];
DELETE FROM [dbo].[Users];
DELETE FROM [dbo].[Toppings];
DELETE FROM [dbo].[Sizes];
DELETE FROM [dbo].[Roles];
DELETE FROM [dbo].[Reviews];
DELETE FROM [dbo].[Refunds];
DELETE FROM [dbo].[ProductToppings];
DELETE FROM [dbo].[Products];
DELETE FROM [dbo].[PointTransactions];
DELETE FROM [dbo].[Payments];
DELETE FROM [dbo].[OrderStatusHistory];
DELETE FROM [dbo].[Orders];
DELETE FROM [dbo].[OrderDetailToppings];
DELETE FROM [dbo].[OrderDetails];
DELETE FROM [dbo].[Notifications];
DELETE FROM [dbo].[Deliveries];
DELETE FROM [dbo].[Combos];
DELETE FROM [dbo].[ComboItems];
DELETE FROM [dbo].[Categories];
GO

/* [dbo].[Categories] - 5 rows */
SET IDENTITY_INSERT [dbo].[Categories] ON;
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (1, N'Cà phê', N'Cà phê máy và cà phê phin Việt Nam', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (2, N'Trà sữa', N'Trà sữa và thức uống từ sữa', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (3, N'Trà trái cây', N'Trà thanh mát kết hợp trái cây', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (4, N'Nước ép', N'Nước ép trái cây tươi', NULL);
INSERT INTO [dbo].[Categories] ([category_id], [category_name], [description], [status]) VALUES (5, N'Đồ ăn nhẹ', N'Bánh và món ăn kèm', NULL);
SET IDENTITY_INSERT [dbo].[Categories] OFF;
GO

/* [dbo].[ComboItems] - 10 rows */
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 1, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 4, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 5, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 1, 2);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 6, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 10, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 3, 1);
INSERT INTO [dbo].[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 8, 1);
GO

/* [dbo].[Combos] - 5 rows */
SET IDENTITY_INSERT [dbo].[Combos] ON;
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (1, N'Combo sáng tỉnh táo', 52000.00, N'combo-sang.png', N'Cà phê sữa đá và Croissant', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (2, N'Combo đôi ngọt ngào', 82000.00, N'combo-doi.png', N'Hai ly trà sữa', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (3, N'Combo văn phòng', 95000.00, N'combo-van-phong.png', N'Đồ uống cho nhóm nhỏ', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (4, N'Combo trà chiều', 65000.00, N'combo-tra-chieu.png', N'Trà trái cây và bánh', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
INSERT INTO [dbo].[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (5, N'Combo năng lượng', 88000.00, N'combo-nang-luong.png', N'Cà phê và nước ép', '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL);
SET IDENTITY_INSERT [dbo].[Combos] OFF;
GO

/* [dbo].[Deliveries] - 5 rows */
SET IDENTITY_INSERT [dbo].[Deliveries] ON;
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (1, 1, 4, N'Delivered', '2026-06-20T09:30:00.0000000', '2026-06-20T09:40:00.0000000', '2026-06-20T10:05:00.0000000', N'Đã giao tận tay');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (2, 3, NULL, N'Waiting', NULL, NULL, NULL, N'Chờ duyệt đơn');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (3, 5, 4, N'Delivering', '2026-07-05T10:00:00.0000000', '2026-07-05T10:10:00.0000000', NULL, N'Đang trên đường giao');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (4, 7, 4, N'Cancelled', '2026-06-26T11:10:00.0000000', NULL, NULL, N'Khách hủy trước khi lấy món');
INSERT INTO [dbo].[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (5, 9, 4, N'Failed', '2026-06-28T13:30:00.0000000', '2026-06-28T13:40:00.0000000', NULL, N'Không liên hệ được khách');
SET IDENTITY_INSERT [dbo].[Deliveries] OFF;
GO

/* [dbo].[Notifications] - 8 rows */
SET IDENTITY_INSERT [dbo].[Notifications] ON;
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (1, 6, 1, N'Đơn hàng hoàn thành', N'Đơn #1 đã được giao thành công.', N'Order', 0, '2026-06-20T10:05:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (2, 6, 1, N'Đã cộng điểm', N'Bạn nhận được 70 điểm từ đơn #1.', N'Point', 0, '2026-06-20T10:06:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (3, 7, 2, N'Đơn hàng hoàn thành', N'Đơn #2 đã hoàn thành.', N'Order', NULL, '2026-06-21T10:35:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (4, 8, 3, N'Đã tiếp nhận đơn', N'Đơn #3 đang chờ thu ngân duyệt.', N'Order', 0, '2026-07-05T08:20:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (5, 9, 4, N'Đơn đang pha chế', N'Đơn #4 đang được chuẩn bị.', N'Order', 0, '2026-07-05T09:06:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (6, 10, 5, N'Đơn đang giao', N'Shipper đang giao đơn #5 đến bạn.', N'Order', 0, '2026-07-05T10:10:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (7, 6, NULL, N'Voucher mới', N'Voucher POINT6A đã được thêm vào ví.', N'Voucher', NULL, '2026-06-01T09:00:00.0000000');
INSERT INTO [dbo].[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (8, 7, NULL, N'Voucher mới', N'Voucher POINT7A đã được thêm vào ví.', N'Voucher', 0, '2026-06-05T09:00:00.0000000');
SET IDENTITY_INSERT [dbo].[Notifications] OFF;
GO

/* [dbo].[OrderDetails] - 15 rows */
SET IDENTITY_INSERT [dbo].[OrderDetails] ON;
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (1, 1, 4, 1, N'L', N'70%', N'70%', 50000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (2, 1, 6, 1, N'M', N'50%', N'70%', 42000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (3, 2, 1, 2, N'M', N'100%', N'100%', 29000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (4, 3, 6, 1, N'M', N'30%', N'70%', 42000.00, N'Ít đá');
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (5, 4, 4, 1, N'L', N'100%', N'100%', 50000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (6, 4, 5, 1, N'M', N'50%', N'70%', 47000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (7, 5, 7, 1, N'L', N'50%', N'50%', 44000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (8, 5, 8, 1, N'M', N'50%', N'100%', 35000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (9, 6, 3, 2, N'L', N'100%', N'100%', 44000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (10, 6, 10, 1, N'M', N'100%', N'100%', 28000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (11, 7, 5, 1, N'M', N'50%', N'50%', 47000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (12, 8, 2, 2, N'M', N'100%', N'100%', 32000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (13, 9, 6, 2, N'M', N'50%', N'70%', 42000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (14, 10, 8, 1, N'M', N'50%', N'100%', 35000.00, NULL);
INSERT INTO [dbo].[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (15, 10, 9, 1, N'M', N'50%', N'100%', 35000.00, NULL);
SET IDENTITY_INSERT [dbo].[OrderDetails] OFF;
GO

/* [dbo].[OrderDetailToppings] - 10 rows */
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 1, 1, 8000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 6, 1, 12000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (2, 4, 1, 7000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (5, 2, 1, 8000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (6, 5, 1, 10000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (7, 7, 1, 7000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (9, 6, 1, 12000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (11, 5, 1, 10000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (13, 3, 2, 6000.00);
INSERT INTO [dbo].[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (14, 7, 1, 7000.00);
GO

/* [dbo].[Orders] - 10 rows */
SET IDENTITY_INSERT [dbo].[Orders] ON;
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (1, 6, 2, 1, 70000.00, 15000.00, 15000.00, '2026-06-20T09:15:00.0000000', N'Completed', NULL, N'Online', N'Thạch Thất, Hà Nội', N'0909090909', N'QR-Code', N'Gọi trước khi giao');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (2, 7, 2, NULL, 58000.00, 0.00, 0.00, '2026-06-21T10:30:00.0000000', N'Completed', NULL, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (3, 8, NULL, NULL, 42000.00, 0.00, 15000.00, '2026-07-05T08:20:00.0000000', N'Pending', 0, N'Online', N'Nam Từ Liêm, Hà Nội', N'0922113344', N'Cash', N'Ít đá');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (4, 9, 2, 2, 84000.00, 20000.00, 0.00, '2026-07-05T09:05:00.0000000', N'Approved', 0, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (5, 10, 2, NULL, 89000.00, 0.00, 15000.00, '2026-07-05T09:45:00.0000000', N'Approved', 0, N'Online', N'Hà Đông, Hà Nội', N'0888999000', N'QR-Code', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (6, 6, 2, 3, 120000.00, 30000.00, 0.00, '2026-06-25T14:10:00.0000000', N'Completed', NULL, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (7, 7, 2, NULL, 47000.00, 0.00, 15000.00, '2026-06-26T11:00:00.0000000', N'Cancelled', 0, N'Online', N'Cầu Giấy, Hà Nội', N'0933221100', N'QR-Code', N'Khách đổi ý');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (8, 8, 2, NULL, 64000.00, 0.00, 0.00, '2026-06-27T16:20:00.0000000', N'Cancelled', 0, N'At-Counter', NULL, NULL, N'Cash', N'Sản phẩm lỗi');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (9, 9, 2, 4, 69000.00, 15000.00, 15000.00, '2026-06-28T13:15:00.0000000', N'Cancelled', 0, N'Online', N'Hoài Đức, Hà Nội', N'0955667788', N'QR-Code', N'Không liên hệ được');
INSERT INTO [dbo].[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (10, 10, 2, NULL, 70000.00, 0.00, 0.00, '2026-06-29T18:40:00.0000000', N'Cancelled', 0, N'At-Counter', NULL, NULL, N'Bank-Transfer', N'Hoàn theo yêu cầu');
SET IDENTITY_INSERT [dbo].[Orders] OFF;
GO

/* [dbo].[OrderStatusHistory] - 20 rows */
SET IDENTITY_INSERT [dbo].[OrderStatusHistory] ON;
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (1, 1, NULL, N'Pending', 6, '2026-06-20T09:15:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (2, 1, N'Pending', N'Approved', 2, '2026-06-20T09:20:00.0000000', N'Thu ngân duyệt');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (3, 1, N'Approved', N'Approved', 3, '2026-06-20T09:22:00.0000000', N'Bắt đầu pha chế');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (4, 1, N'Approved', N'Approved', 4, '2026-06-20T09:40:00.0000000', N'Nhận đơn giao');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (5, 1, N'Approved', N'Completed', 4, '2026-06-20T10:05:00.0000000', N'Giao thành công');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (6, 2, NULL, N'Approved', 2, '2026-06-21T10:30:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (7, 2, N'Approved', N'Completed', 2, '2026-06-21T10:35:00.0000000', N'Đã giao đồ uống');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (8, 3, NULL, N'Pending', 8, '2026-07-05T08:20:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (9, 4, NULL, N'Approved', 2, '2026-07-05T09:05:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (10, 5, NULL, N'Pending', 10, '2026-07-05T09:45:00.0000000', N'Khách tạo đơn');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (11, 5, N'Pending', N'Approved', 2, '2026-07-05T09:50:00.0000000', N'Đã duyệt');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (12, 5, N'Approved', N'Approved', 3, '2026-07-05T09:52:00.0000000', N'Đang pha chế');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (13, 5, N'Approved', N'Approved', 3, '2026-07-05T10:00:00.0000000', N'Đã pha xong');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (14, 5, N'Approved', N'Approved', 4, '2026-07-05T10:10:00.0000000', N'Đang giao');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (15, 6, NULL, N'Approved', 2, '2026-06-25T14:10:00.0000000', N'Đơn tại quầy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (16, 6, N'Approved', N'Completed', 2, '2026-06-25T14:20:00.0000000', N'Hoàn thành');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (17, 7, N'Pending', N'Cancelled', 2, '2026-06-26T11:05:00.0000000', N'Khách hủy');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (18, 8, N'Completed', N'Cancelled', 2, '2026-06-27T16:45:00.0000000', N'Đã hoàn tiền');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (19, 9, N'Approved', N'Cancelled', 2, '2026-06-28T14:30:00.0000000', N'Giao thất bại');
INSERT INTO [dbo].[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (20, 10, N'Completed', N'Cancelled', 1, '2026-06-29T20:00:00.0000000', N'Quản lý duyệt hoàn tiền');
SET IDENTITY_INSERT [dbo].[OrderStatusHistory] OFF;
GO

/* [dbo].[Payments] - 8 rows */
SET IDENTITY_INSERT [dbo].[Payments] ON;
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (1, 1, N'QR-Code', 70000.00, 70000.00, 0.00, N'QR-20260620-001', N'Paid', '2026-06-20T09:17:00.0000000', '2026-06-20T09:16:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (2, 2, N'Cash', 58000.00, 100000.00, 42000.00, NULL, N'Paid', '2026-06-21T10:31:00.0000000', '2026-06-21T10:30:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (3, 4, N'Cash', 84000.00, 100000.00, 16000.00, NULL, N'Paid', '2026-07-05T09:06:00.0000000', '2026-07-05T09:05:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (4, 5, N'QR-Code', 89000.00, 89000.00, 0.00, N'QR-20260705-005', N'Paid', '2026-07-05T09:47:00.0000000', '2026-07-05T09:46:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (5, 6, N'Cash', 120000.00, 150000.00, 30000.00, NULL, N'Paid', '2026-06-25T14:11:00.0000000', '2026-06-25T14:10:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (6, 7, N'QR-Code', 47000.00, 47000.00, 0.00, N'QR-20260626-007', N'Refunded', '2026-06-26T11:02:00.0000000', '2026-06-26T11:01:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (7, 8, N'Cash', 64000.00, 100000.00, 36000.00, NULL, N'Refunded', '2026-06-27T16:21:00.0000000', '2026-06-27T16:20:00.0000000');
INSERT INTO [dbo].[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (8, 10, N'Bank-Transfer', 70000.00, 70000.00, 0.00, N'BANK-20260629-10', N'Refunded', '2026-06-29T18:42:00.0000000', '2026-06-29T18:41:00.0000000');
SET IDENTITY_INSERT [dbo].[Payments] OFF;
GO

/* [dbo].[PointTransactions] - 8 rows */
SET IDENTITY_INSERT [dbo].[PointTransactions] ON;
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (1, 6, 1, NULL, 70, 2270, N'Earn', N'Cộng điểm đơn #1', '2026-06-20T10:05:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (2, 7, 2, NULL, 58, 1908, N'Earn', N'Cộng điểm đơn #2', '2026-06-21T10:35:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (3, 6, 6, NULL, 120, 2390, N'Earn', N'Cộng điểm đơn #6', '2026-06-25T14:20:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (4, 6, NULL, 6, -1000, 2200, N'Redeem', N'Đổi voucher POINT6A', '2026-06-01T09:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (5, 7, NULL, 7, -2000, 1850, N'Redeem', N'Đổi voucher POINT7A', '2026-06-05T09:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (6, 8, NULL, NULL, 100, 760, N'Adjust', N'Điểm khuyến mại khai trương', '2026-05-01T08:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (7, 9, NULL, NULL, 200, 1200, N'Adjust', N'Điểm sinh nhật', '2026-05-20T08:00:00.0000000');
INSERT INTO [dbo].[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (8, 10, 10, NULL, -70, 540, N'Refund', N'Thu hồi điểm do hoàn đơn #10', '2026-06-29T20:00:00.0000000');
SET IDENTITY_INSERT [dbo].[PointTransactions] OFF;
GO

/* [dbo].[Products] - 15 rows */
SET IDENTITY_INSERT [dbo].[Products] ON;
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (1, N'Cà phê sữa đá', 1, 29000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652364053.jpg', N'Cà phê đậm vị cùng sữa đặc', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (2, N'Bạc xỉu', 1, 32000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652376341.jpg', N'Nhiều sữa, nhẹ vị cà phê', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (3, N'Cappuccino', 1, 39000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652386892.jpg', N'Espresso và bọt sữa mịn', NULL, '2026-01-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (4, N'Trà sữa trân châu đường đen', 2, 45000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652412242.jpg', N'Trà sữa cùng trân châu đường đen', NULL, '2026-01-11T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (5, N'Trà sữa Matcha', 2, 47000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652423318.jpg', N'Matcha Nhật Bản và sữa tươi', NULL, '2026-01-11T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (6, N'Trà đào cam sả', 3, 42000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652475947.jpg', N'Đào, cam và sả thanh mát', NULL, '2026-01-12T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (7, N'Trà vải', 3, 39000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652497062.jpg', N'Trà thơm kết hợp quả vải', NULL, '2026-01-12T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (8, N'Nước ép cam', 4, 35000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652520082.jpg', N'Nước cam ép nguyên chất', NULL, '2026-01-13T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (9, N'Nước ép dưa hấu', 4, 35000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652531970.jpg', N'Dưa hấu tươi mát', NULL, '2026-01-13T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (10, N'Bánh Croissant', 5, 28000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783652557130.jpg', N'Bánh sừng bò thơm bơ', NULL, '2026-01-14T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (11, N'Americano', 1, 37000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671139443.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (12, N'Cà phê trứng', 1, 40000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671451182.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (13, N'Caramel Macchiato', 1, 28000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671502225.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (14, N'Espresso', 1, 21000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671533128.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (15, N'Cold Brew', 1, 24000.00, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/products/uploads/product-1783671575228.jpg', NULL, NULL, '2026-07-10T00:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Products] OFF;
GO

/* [dbo].[ProductToppings] - 18 rows */
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (1, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (2, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (3, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 1);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 2);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 5);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (4, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 2);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 5);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (5, 6);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 3);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 4);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (6, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 3);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 4);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (7, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (8, 7);
INSERT INTO [dbo].[ProductToppings] ([product_id], [topping_id]) VALUES (9, 4);
GO

/* [dbo].[Refunds] - 5 rows */
SET IDENTITY_INSERT [dbo].[Refunds] ON;
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (1, 7, 6, 7, 2, 47000.00, N'Khách đổi ý trước khi giao', N'Completed', '2026-06-26T11:05:00.0000000', '2026-06-26T11:20:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (2, 8, 7, 8, 2, 64000.00, N'Sản phẩm không đúng yêu cầu', N'Completed', '2026-06-27T16:30:00.0000000', '2026-06-27T16:45:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (3, 9, NULL, 9, 2, 69000.00, N'Không thể giao hàng', N'Approved', '2026-06-28T14:10:00.0000000', '2026-06-28T14:30:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (4, 10, 8, 10, 1, 70000.00, N'Khách yêu cầu hoàn tiền', N'Completed', '2026-06-29T19:00:00.0000000', '2026-06-29T20:00:00.0000000');
INSERT INTO [dbo].[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (5, 4, 3, 9, NULL, 84000.00, N'Yêu cầu hủy khi đang pha chế', N'Pending', '2026-07-05T09:15:00.0000000', NULL);
SET IDENTITY_INSERT [dbo].[Refunds] OFF;
GO

/* [dbo].[Reviews] - 5 rows */
SET IDENTITY_INSERT [dbo].[Reviews] ON;
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (1, 6, 1, 5, N'Trà sữa ngon, giao nhanh', NULL, '2026-06-20T11:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (2, 6, 2, 4, N'Trà đào thơm và vừa ngọt', NULL, '2026-06-20T11:02:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (3, 7, 3, 5, N'Cà phê đậm vị', NULL, '2026-06-21T12:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (4, 6, 9, 4, N'Cappuccino ổn, bọt sữa mịn', NULL, '2026-06-25T15:00:00.0000000');
INSERT INTO [dbo].[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (5, 6, 10, 5, N'Bánh giòn và thơm bơ', NULL, '2026-06-25T15:02:00.0000000');
SET IDENTITY_INSERT [dbo].[Reviews] OFF;
GO

/* [dbo].[Roles] - 3 rows */
SET IDENTITY_INSERT [dbo].[Roles] ON;
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (1, N'Manager', N'Quản lý cửa hàng và báo cáo');
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (2, N'Staff', N'Nhân viên thu ngân, pha chế hoặc giao hàng');
INSERT INTO [dbo].[Roles] ([role_id], [role_name], [description]) VALUES (3, N'Customer', N'Khách hàng đặt món và tích điểm');
SET IDENTITY_INSERT [dbo].[Roles] OFF;
GO

/* [dbo].[Sizes] - 3 rows */
SET IDENTITY_INSERT [dbo].[Sizes] ON;
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (1, N'S', N'Nhỏ', -3000.00, NULL);
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (2, N'M', N'Vừa', 0.00, NULL);
INSERT INTO [dbo].[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (3, N'L', N'Lớn', 5000.00, NULL);
SET IDENTITY_INSERT [dbo].[Sizes] OFF;
GO

/* [dbo].[Toppings] - 8 rows */
SET IDENTITY_INSERT [dbo].[Toppings] ON;
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (1, N'Trân châu đen', 8000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (2, N'Trân châu trắng', 8000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (3, N'Thạch sương sáo', 6000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (4, N'Thạch trái cây', 7000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (5, N'Pudding trứng', 10000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (6, N'Kem cheese', 12000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (7, N'Nha đam', 7000.00, NULL);
INSERT INTO [dbo].[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (8, N'Hạt thủy tinh', 9000.00, 0);
SET IDENTITY_INSERT [dbo].[Toppings] OFF;
GO

/* [dbo].[Users] - 10 rows */
SET IDENTITY_INSERT [dbo].[Users] ON;
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (1, N'admin01', N'123456', N'Nguyễn Quản Lý', N'admin@cbms.com', N'0912345678', N'Hà Nội', N'Nam', N'Manager', N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-1-1783753731072.jpg', NULL, 0, 1, '2026-01-02T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (2, N'cashier01', N'123456', N'Lê Thu Ngân', N'cashier@cbms.com', N'0987654321', N'Hà Nội', N'Nữ', N'Thu ngân', N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-2-1783656457343.jpg', NULL, 0, 2, '2026-01-05T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (3, N'barista01', N'123456', N'Trần Pha Chế', N'barista@cbms.com', N'0944556677', N'Hà Nội', N'Nam', N'Pha chế', NULL, NULL, 0, 2, '2026-01-06T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (4, N'shipper01', N'123456', N'Phạm Giao Hàng', N'shipper@cbms.com', N'0966112233', N'Hà Nội', N'Nam', N'Giao hàng', NULL, NULL, 0, 2, '2026-01-07T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (5, N'staff02', N'123456', N'Vũ Nhân Viên Nghỉ', N'staff02@cbms.com', N'0977001122', N'Hà Nội', N'Khác', N'Nhân viên', NULL, 0, 0, 2, '2026-01-08T08:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (6, N'customer01', N'123456', N'Phan Khách Hàng Online', N'customer01@gmail.com', N'0909090909', N'Thạch Thất', N'Nam', NULL, N'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web/images/avatars/uploads/avatar-6-1783742549197.jpg', NULL, 2390, 3, '2026-02-01T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (7, N'customer02', N'123456', N'Hoàng Minh Anh', N'customer02@gmail.com', N'0933221100', N'Cầu Giấy', N'Nữ', NULL, NULL, NULL, 1908, 3, '2026-02-05T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (8, N'customer03', N'123456', N'Đỗ Hải Nam', N'customer03@gmail.com', N'0922113344', N'Nam Từ Liêm', N'Nam', NULL, NULL, NULL, 760, 3, '2026-02-10T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (9, N'customer04', N'123456', N'Bùi Thanh Hà', N'customer04@gmail.com', N'0955667788', N'Hoài Đức', N'Nữ', NULL, NULL, NULL, 1200, 3, '2026-03-01T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (10, N'customer05', N'123456', N'Ngô Gia Bảo', N'customer05@gmail.com', N'0888999000', N'Hà Đông', N'Khác', NULL, NULL, NULL, 540, 3, '2026-03-12T09:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Users] OFF;
GO

/* [dbo].[Vouchers] - 8 rows */
SET IDENTITY_INSERT [dbo].[Vouchers] ON;
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (1, N'WELCOME15', 15000.00, 40000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (2, N'GIAM20K', 20000.00, 60000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (3, N'GIAM30K', 30000.00, 100000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (4, N'FREESHIP', 15000.00, 80000.00, 0, '2026-01-01T00:00:00.0000000', '2027-12-31T00:00:00.0000000', NULL, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (5, N'EXPIRED10', 10000.00, 30000.00, 0, '2026-01-01T00:00:00.0000000', '2026-05-01T00:00:00.0000000', 0, NULL, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (6, N'POINT6A', 20000.00, 50000.00, 1000, '2026-06-01T00:00:00.0000000', '2027-06-01T00:00:00.0000000', NULL, 6, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (7, N'POINT7A', 30000.00, 70000.00, 2000, '2026-06-05T00:00:00.0000000', '2027-06-05T00:00:00.0000000', NULL, 7, NULL, '2026-07-12T19:55:45.0000000');
INSERT INTO [dbo].[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (8, N'USED6A', 20000.00, 50000.00, 1000, '2026-05-01T00:00:00.0000000', '2027-05-01T00:00:00.0000000', 0, 6, '2026-06-20T10:00:00.0000000', '2026-07-12T19:55:45.0000000');
SET IDENTITY_INSERT [dbo].[Vouchers] OFF;
GO

EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO
SET NOCOUNT OFF;
GO

/* Run after data import so image paths are shareable across machines. */
/* ======================================================================
   IMAGE URL ONLINE FIX 2026-07-12
   Äá»•i Ä‘Æ°á»ng dáº«n áº£nh local trong database sang raw GitHub URL Ä‘á»ƒ mÃ¡y khÃ¡c váº«n hiá»ƒn thá»‹ áº£nh.
   LÆ°u Ã½: cÃ¡c file áº£nh trong web/images pháº£i Ä‘Æ°á»£c commit vÃ  push lÃªn GitHub trÆ°á»›c.
   ====================================================================== */
DECLARE @ImageBase VARCHAR(255) = 'https://raw.githubusercontent.com/yeunaa3/CafeWeb/Khanh/web';

UPDATE dbo.Products
SET image_url = CASE
    WHEN image_url LIKE '/images/products/%' THEN @ImageBase + image_url
    WHEN image_url LIKE 'images/products/%' THEN @ImageBase + '/' + image_url
    WHEN image_url LIKE '/uploads/products/%' THEN @ImageBase + '/images/products' + image_url
    WHEN image_url LIKE 'uploads/products/%' THEN @ImageBase + '/images/products/' + image_url
    ELSE image_url
END
WHERE image_url IS NOT NULL
  AND image_url <> ''
  AND image_url NOT LIKE 'http://%'
  AND image_url NOT LIKE 'https://%';

UPDATE dbo.Users
SET avatar_url = CASE
    WHEN avatar_url LIKE '/images/avatars/%' THEN @ImageBase + avatar_url
    WHEN avatar_url LIKE 'images/avatars/%' THEN @ImageBase + '/' + avatar_url
    WHEN avatar_url LIKE '/uploads/avatars/%' THEN @ImageBase + '/images/avatars' + avatar_url
    WHEN avatar_url LIKE 'uploads/avatars/%' THEN @ImageBase + '/images/avatars/' + avatar_url
    ELSE avatar_url
END
WHERE avatar_url IS NOT NULL
  AND avatar_url <> ''
  AND avatar_url NOT LIKE 'http://%'
  AND avatar_url NOT LIKE 'https://%';
GO

