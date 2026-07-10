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
    CONSTRAINT CK_Users_Gender CHECK (gender IS NULL OR gender IN (N'Nam', N'Nữ', N'Khác')),
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
    CONSTRAINT CK_Orders_Status CHECK (status IN ('Pending','Approved','Processing','Ready','Delivering','Completed','Cancelled','Refunded')),
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
    CONSTRAINT CK_OrderStatusHistory_NewStatus CHECK (new_status IN ('Pending','Approved','Processing','Ready','Delivering','Completed','Cancelled','Refunded'))
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
-- 6. SAMPLE DATA - exported from local CBMS database
-- Default password for every sample account: 123456
-- ============================================================================

-- dbo.Roles
SET IDENTITY_INSERT dbo.[Roles] ON;
INSERT INTO dbo.[Roles] ([role_id], [role_name], [description]) VALUES (1, N'Manager', N'Quản lý cửa hàng và báo cáo');
INSERT INTO dbo.[Roles] ([role_id], [role_name], [description]) VALUES (2, N'Staff', N'Nhân viên thu ngân, pha chế hoặc giao hàng');
INSERT INTO dbo.[Roles] ([role_id], [role_name], [description]) VALUES (3, N'Customer', N'Khách hàng đặt món và tích điểm');
SET IDENTITY_INSERT dbo.[Roles] OFF;
GO

-- dbo.Users
SET IDENTITY_INSERT dbo.[Users] ON;
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (1, N'admin01', N'123456', N'Nguyễn Quản Lý', N'admin@cbms.com', N'0912345678', N'Hà Nội', N'Nam', N'Manager', N'/images/avatars/uploads/avatar-1-1783652576762.png', 1, 0, 1, '2026-01-02 08:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (2, N'cashier01', N'123456', N'Lê Thu Ngân', N'cashier@cbms.com', N'0987654321', N'Hà Nội', N'Nữ', N'Thu ngân', N'/images/avatars/uploads/avatar-2-1783652661782.png', 1, 0, 2, '2026-01-05 08:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (3, N'barista01', N'123456', N'Trần Pha Chế', N'barista@cbms.com', N'0944556677', N'Hà Nội', N'Nam', N'Pha chế', NULL, 1, 0, 2, '2026-01-06 08:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (4, N'shipper01', N'123456', N'Phạm Giao Hàng', N'shipper@cbms.com', N'0966112233', N'Hà Nội', N'Nam', N'Giao hàng', NULL, 1, 0, 2, '2026-01-07 08:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (5, N'staff02', N'123456', N'Vũ Nhân Viên Nghỉ', N'staff02@cbms.com', N'0977001122', N'Hà Nội', N'Khác', N'Nhân viên', NULL, 0, 0, 2, '2026-01-08 08:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (6, N'customer01', N'123456', N'Phan Khách Hàng Online', N'customer01@gmail.com', N'0909090909', N'Thạch Thất', N'Nam', NULL, N'/images/avatars/uploads/avatar-6-1783652158236.png', 1, 2429, 3, '2026-02-01 09:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (7, N'customer02', N'123456', N'Hoàng Minh Anh', N'customer02@gmail.com', N'0933221100', N'Cầu Giấy', N'Nữ', NULL, NULL, 1, 1908, 3, '2026-02-05 09:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (8, N'customer03', N'123456', N'Đỗ Hải Nam', N'customer03@gmail.com', N'0922113344', N'Nam Từ Liêm', N'Nam', NULL, NULL, 1, 802, 3, '2026-02-10 09:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (9, N'customer04', N'123456', N'Bùi Thanh Hà', N'customer04@gmail.com', N'0955667788', N'Hoài Đức', N'Nữ', NULL, NULL, 1, 1200, 3, '2026-03-01 09:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (10, N'customer05', N'123456', N'Ngô Gia Bảo', N'customer05@gmail.com', N'0888999000', N'Hà Đông', N'Khác', NULL, NULL, 1, 540, 3, '2026-03-12 09:00:00', '2026-07-09 21:29:21');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (11, N'nhanvien01', N'123456', N'Cường Bùi', N'guildedguy582k6@gmail.com', N'0987654321', NULL, NULL, N'Thu ngân', N'/images/avatars/uploads/avatar-11-1783672034071.jpg', 1, 0, 2, '2026-07-10 15:26:07', '2026-07-10 15:26:07');
INSERT INTO dbo.[Users] ([user_id], [username], [password], [full_name], [email], [phone], [address], [gender], [staff_position], [avatar_url], [status], [points], [role_id], [created_at], [updated_at]) VALUES (12, N'nhanvien02', N'123456', N'cuongbui', N'guiedguy582k6@gmail.com', N'0987654321', N'', NULL, N'Thu ngân', N'/images/avatars/uploads/avatar-12-1783672633931.jpg', 1, 0, 2, '2026-07-10 15:35:19', '2026-07-10 15:35:19');
SET IDENTITY_INSERT dbo.[Users] OFF;
GO

-- dbo.Categories
SET IDENTITY_INSERT dbo.[Categories] ON;
INSERT INTO dbo.[Categories] ([category_id], [category_name], [description], [status]) VALUES (1, N'Cà phê', N'Cà phê máy và cà phê phin Việt Nam', 1);
INSERT INTO dbo.[Categories] ([category_id], [category_name], [description], [status]) VALUES (2, N'Trà sữa', N'Trà sữa và thức uống từ sữa', 1);
INSERT INTO dbo.[Categories] ([category_id], [category_name], [description], [status]) VALUES (3, N'Trà trái cây', N'Trà thanh mát kết hợp trái cây', 1);
INSERT INTO dbo.[Categories] ([category_id], [category_name], [description], [status]) VALUES (4, N'Nước ép', N'Nước ép trái cây tươi', 1);
INSERT INTO dbo.[Categories] ([category_id], [category_name], [description], [status]) VALUES (5, N'Đồ ăn nhẹ', N'Bánh và món ăn kèm', 1);
SET IDENTITY_INSERT dbo.[Categories] OFF;
GO

-- dbo.Products
SET IDENTITY_INSERT dbo.[Products] ON;
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (1, N'Cà phê sữa đá', 1, 29000, N'/images/products/uploads/product-1783652364053.jpg', N'Cà phê đậm vị cùng sữa đặc', 1, '2026-01-10 00:00:00', '2026-07-10 09:59:24');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (2, N'Bạc xỉu', 1, 32000, N'/images/products/uploads/product-1783652376341.jpg', N'Nhiều sữa, nhẹ vị cà phê', 1, '2026-01-10 00:00:00', '2026-07-10 09:59:36');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (3, N'Cappuccino', 1, 39000, N'/images/products/uploads/product-1783652386892.jpg', N'Espresso và bọt sữa mịn', 1, '2026-01-10 00:00:00', '2026-07-10 09:59:47');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (4, N'Trà sữa trân châu đường đen', 2, 45000, N'/images/products/uploads/product-1783652412242.jpg', N'Trà sữa cùng trân châu đường đen', 1, '2026-01-11 00:00:00', '2026-07-10 10:00:12');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (5, N'Trà sữa Matcha', 2, 47000, N'/images/products/uploads/product-1783652423318.jpg', N'Matcha Nhật Bản và sữa tươi', 1, '2026-01-11 00:00:00', '2026-07-10 10:00:23');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (6, N'Trà đào cam sả', 3, 42000, N'/images/products/uploads/product-1783652475947.jpg', N'Đào, cam và sả thanh mát', 1, '2026-01-12 00:00:00', '2026-07-10 10:01:16');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (7, N'Trà vải', 3, 39000, N'/images/products/uploads/product-1783652497062.jpg', N'Trà thơm kết hợp quả vải', 1, '2026-01-12 00:00:00', '2026-07-10 10:01:37');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (8, N'Nước ép cam', 4, 35000, N'/images/products/uploads/product-1783652520082.jpg', N'Nước cam ép nguyên chất', 1, '2026-01-13 00:00:00', '2026-07-10 10:02:00');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (9, N'Nước ép dưa hấu', 4, 35000, N'/images/products/uploads/product-1783652531970.jpg', N'Dưa hấu tươi mát', 1, '2026-01-13 00:00:00', '2026-07-10 10:02:12');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (10, N'Bánh Croissant', 5, 28000, N'/images/products/uploads/product-1783652557130.jpg', N'Bánh sừng bò thơm bơ', 1, '2026-01-14 00:00:00', '2026-07-10 10:02:37');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (12, N'Americano', 1, 37000, N'/images/products/uploads/product-1783671139443.jpg', NULL, 1, '2026-07-10 15:12:20', '2026-07-10 15:12:20');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (13, N'Cafe Trứng', 1, 40000, N'/images/products/uploads/product-1783671451182.jpg', NULL, 1, '2026-07-10 15:17:31', '2026-07-10 15:17:31');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (14, N'Caramel Macchicato', 1, 28000, N'/images/products/uploads/product-1783671502225.jpg', NULL, 1, '2026-07-10 15:18:23', '2026-07-10 15:18:23');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (17, N'EXpressso', 1, 21000, N'/images/products/uploads/product-1783671533128.jpg', NULL, 1, '2026-07-10 15:18:53', '2026-07-10 15:18:53');
INSERT INTO dbo.[Products] ([product_id], [product_name], [category_id], [price], [image_url], [description], [status], [created_at], [updated_at]) VALUES (18, N'Cold Brew', 1, 24000, N'/images/products/uploads/product-1783671575228.jpg', NULL, 1, '2026-07-10 15:19:35', '2026-07-10 15:19:35');
SET IDENTITY_INSERT dbo.[Products] OFF;
GO

-- dbo.Sizes
SET IDENTITY_INSERT dbo.[Sizes] ON;
INSERT INTO dbo.[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (1, N'S', N'Nhỏ', -3000, 1);
INSERT INTO dbo.[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (2, N'M', N'Vừa', 0, 1);
INSERT INTO dbo.[Sizes] ([size_id], [size_code], [size_name], [price_modifier], [status]) VALUES (3, N'L', N'Lớn', 5000, 1);
SET IDENTITY_INSERT dbo.[Sizes] OFF;
GO

-- dbo.Toppings
SET IDENTITY_INSERT dbo.[Toppings] ON;
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (1, N'Trân châu đen', 8000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (2, N'Trân châu trắng', 8000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (3, N'Thạch sương sáo', 6000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (4, N'Thạch trái cây', 7000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (5, N'Pudding trứng', 10000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (6, N'Kem cheese', 12000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (7, N'Nha đam', 7000, 1);
INSERT INTO dbo.[Toppings] ([topping_id], [topping_name], [price], [status]) VALUES (8, N'Hạt thủy tinh', 9000, 0);
SET IDENTITY_INSERT dbo.[Toppings] OFF;
GO

-- dbo.ProductToppings
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (1, 6);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (2, 6);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (3, 6);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (4, 1);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (4, 2);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (4, 5);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (4, 6);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (5, 2);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (5, 5);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (5, 6);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (6, 3);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (6, 4);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (6, 7);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (7, 3);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (7, 4);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (7, 7);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (8, 7);
INSERT INTO dbo.[ProductToppings] ([product_id], [topping_id]) VALUES (9, 4);
GO

-- dbo.Combos
SET IDENTITY_INSERT dbo.[Combos] ON;
INSERT INTO dbo.[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (1, N'Combo sáng tỉnh táo', 52000, N'combo-sang.png', N'Cà phê sữa đá và Croissant', '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1);
INSERT INTO dbo.[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (2, N'Combo đôi ngọt ngào', 82000, N'combo-doi.png', N'Hai ly trà sữa', '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1);
INSERT INTO dbo.[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (3, N'Combo văn phòng', 95000, N'combo-van-phong.png', N'Đồ uống cho nhóm nhỏ', '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1);
INSERT INTO dbo.[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (4, N'Combo trà chiều', 65000, N'combo-tra-chieu.png', N'Trà trái cây và bánh', '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1);
INSERT INTO dbo.[Combos] ([combo_id], [combo_name], [combo_price], [image_url], [description], [start_date], [end_date], [status]) VALUES (5, N'Combo năng lượng', 88000, N'combo-nang-luong.png', N'Cà phê và nước ép', '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1);
SET IDENTITY_INSERT dbo.[Combos] OFF;
GO

-- dbo.ComboItems
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 1, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (1, 10, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 4, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (2, 5, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 1, 2);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (3, 10, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 6, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (4, 10, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 3, 1);
INSERT INTO dbo.[ComboItems] ([combo_id], [product_id], [quantity]) VALUES (5, 8, 1);
GO

-- dbo.Vouchers
SET IDENTITY_INSERT dbo.[Vouchers] ON;
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (1, N'WELCOME15', 15000, 40000, 0, '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1, NULL, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (2, N'GIAM20K', 20000, 60000, 0, '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1, NULL, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (3, N'GIAM30K', 30000, 100000, 0, '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1, NULL, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (4, N'FREESHIP', 15000, 80000, 0, '2026-01-01 00:00:00', '2027-12-31 00:00:00', 1, NULL, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (5, N'EXPIRED10', 10000, 30000, 0, '2026-01-01 00:00:00', '2026-05-01 00:00:00', 0, NULL, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (6, N'POINT6A', 20000, 50000, 1000, '2026-06-01 00:00:00', '2027-06-01 00:00:00', 1, 6, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (7, N'POINT7A', 30000, 70000, 2000, '2026-06-05 00:00:00', '2027-06-05 00:00:00', 1, 7, NULL, '2026-07-09 21:29:22');
INSERT INTO dbo.[Vouchers] ([voucher_id], [voucher_code], [discount_value], [min_order_value], [points_cost], [start_date], [expiry_date], [status], [owner_user_id], [used_at], [created_at]) VALUES (8, N'USED6A', 20000, 50000, 1000, '2026-05-01 00:00:00', '2027-05-01 00:00:00', 0, 6, '2026-06-20 10:00:00', '2026-07-09 21:29:22');
SET IDENTITY_INSERT dbo.[Vouchers] OFF;
GO

-- dbo.Orders
SET IDENTITY_INSERT dbo.[Orders] ON;
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (1, 6, 2, 1, 70000, 15000, 15000, '2026-06-20 09:15:00', N'Completed', 1, N'Online', N'Thạch Thất, Hà Nội', N'0909090909', N'QR-Code', N'Gọi trước khi giao');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (2, 7, 2, NULL, 58000, 0, 0, '2026-06-21 10:30:00', N'Completed', 1, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (3, 8, NULL, NULL, 42000, 0, 15000, '2026-07-05 08:20:00', N'Completed', 1, N'Online', N'Nam Từ Liêm, Hà Nội', N'0922113344', N'Cash', N'Ít đá');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (4, 9, 2, 2, 84000, 20000, 0, '2026-07-05 09:05:00', N'Approved', 0, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (5, 10, 2, NULL, 89000, 0, 15000, '2026-07-05 09:45:00', N'Approved', 0, N'Online', N'Hà Đông, Hà Nội', N'0888999000', N'QR-Code', NULL);
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (6, 6, 2, 3, 120000, 30000, 0, '2026-06-25 14:10:00', N'Completed', 1, N'At-Counter', NULL, NULL, N'Cash', NULL);
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (7, 7, 2, NULL, 47000, 0, 15000, '2026-06-26 11:00:00', N'Cancelled', 0, N'Online', N'Cầu Giấy, Hà Nội', N'0933221100', N'QR-Code', N'Khách đổi ý');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (8, 8, 2, NULL, 64000, 0, 0, '2026-06-27 16:20:00', N'Approved', 0, N'At-Counter', NULL, NULL, N'Cash', N'Sản phẩm lỗi');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (9, 9, 2, 4, 69000, 15000, 15000, '2026-06-28 13:15:00', N'Cancelled', 0, N'Online', N'Hoài Đức, Hà Nội', N'0955667788', N'QR-Code', N'Không liên hệ được');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (10, 10, 2, NULL, 70000, 0, 0, '2026-06-29 18:40:00', N'Refunded', 0, N'At-Counter', NULL, NULL, N'Bank-Transfer', N'Hoàn theo yêu cầu');
INSERT INTO dbo.[Orders] ([order_id], [user_id], [staff_id], [voucher_id], [total_price], [discount_amount], [shipping_fee], [order_date], [status], [points_awarded], [order_type], [shipping_address], [shipping_phone], [payment_method], [note]) VALUES (11, 6, NULL, NULL, 39000, 0, 0, '2026-07-10 09:56:34', N'Completed', 1, N'Online', N'hai huong', N'0987654321', N'QR-Code', NULL);
SET IDENTITY_INSERT dbo.[Orders] OFF;
GO

-- dbo.OrderDetails
SET IDENTITY_INSERT dbo.[OrderDetails] ON;
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (1, 1, 4, 1, N'L', N'70%', N'70%', 50000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (2, 1, 6, 1, N'M', N'50%', N'70%', 42000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (3, 2, 1, 2, N'M', N'100%', N'100%', 29000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (4, 3, 6, 1, N'M', N'30%', N'70%', 42000, N'Ít đá');
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (5, 4, 4, 1, N'L', N'100%', N'100%', 50000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (6, 4, 5, 1, N'M', N'50%', N'70%', 47000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (7, 5, 7, 1, N'L', N'50%', N'50%', 44000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (8, 5, 8, 1, N'M', N'50%', N'100%', 35000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (9, 6, 3, 2, N'L', N'100%', N'100%', 44000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (10, 6, 10, 1, N'M', N'100%', N'100%', 28000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (11, 7, 5, 1, N'M', N'50%', N'50%', 47000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (12, 8, 2, 2, N'M', N'100%', N'100%', 32000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (13, 9, 6, 2, N'M', N'50%', N'70%', 42000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (14, 10, 8, 1, N'M', N'50%', N'100%', 35000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (15, 10, 9, 1, N'M', N'50%', N'100%', 35000, NULL);
INSERT INTO dbo.[OrderDetails] ([order_detail_id], [order_id], [product_id], [quantity], [selected_size], [ice_level], [sugar_level], [price], [note]) VALUES (16, 11, 3, 1, N'M', N'100%', N'100%', 39000, NULL);
SET IDENTITY_INSERT dbo.[OrderDetails] OFF;
GO

-- dbo.OrderDetailToppings
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 1, 1, 8000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (1, 6, 1, 12000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (2, 4, 1, 7000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (5, 2, 1, 8000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (6, 5, 1, 10000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (7, 7, 1, 7000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (9, 6, 1, 12000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (11, 5, 1, 10000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (13, 3, 2, 6000);
INSERT INTO dbo.[OrderDetailToppings] ([order_detail_id], [topping_id], [quantity], [topping_price]) VALUES (14, 7, 1, 7000);
GO

-- dbo.Payments
SET IDENTITY_INSERT dbo.[Payments] ON;
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (1, 1, N'QR-Code', 70000, 70000, 0, N'QR-20260620-001', N'Paid', '2026-06-20 09:17:00', '2026-06-20 09:16:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (2, 2, N'Cash', 58000, 100000, 42000, NULL, N'Paid', '2026-06-21 10:31:00', '2026-06-21 10:30:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (3, 4, N'Cash', 84000, 100000, 16000, NULL, N'Paid', '2026-07-05 09:06:00', '2026-07-05 09:05:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (4, 5, N'QR-Code', 89000, 89000, 0, N'QR-20260705-005', N'Paid', '2026-07-05 09:47:00', '2026-07-05 09:46:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (5, 6, N'Cash', 120000, 150000, 30000, NULL, N'Paid', '2026-06-25 14:11:00', '2026-06-25 14:10:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (6, 7, N'QR-Code', 47000, 47000, 0, N'QR-20260626-007', N'Refunded', '2026-06-26 11:02:00', '2026-06-26 11:01:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (7, 8, N'Cash', 64000, 100000, 36000, NULL, N'Refunded', '2026-06-27 16:21:00', '2026-06-27 16:20:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (8, 10, N'Bank-Transfer', 70000, 70000, 0, N'BANK-20260629-10', N'Refunded', '2026-06-29 18:42:00', '2026-06-29 18:41:00');
INSERT INTO dbo.[Payments] ([payment_id], [order_id], [payment_method], [amount], [amount_received], [change_amount], [transaction_code], [payment_status], [paid_at], [created_at]) VALUES (9, 11, N'QR-Code', 39000, 39000, 0, NULL, N'Paid', '2026-07-10 09:56:34', '2026-07-10 09:56:34');
SET IDENTITY_INSERT dbo.[Payments] OFF;
GO

-- dbo.Deliveries
SET IDENTITY_INSERT dbo.[Deliveries] ON;
INSERT INTO dbo.[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (1, 1, 4, N'Delivered', '2026-06-20 09:30:00', '2026-06-20 09:40:00', '2026-06-20 10:05:00', N'Đã giao tận tay');
INSERT INTO dbo.[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (2, 3, NULL, N'Waiting', NULL, NULL, NULL, N'Chờ duyệt đơn');
INSERT INTO dbo.[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (3, 5, 4, N'Delivering', '2026-07-05 10:00:00', '2026-07-05 10:10:00', NULL, N'Đang trên đường giao');
INSERT INTO dbo.[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (4, 7, 4, N'Cancelled', '2026-06-26 11:10:00', NULL, NULL, N'Khách hủy trước khi lấy món');
INSERT INTO dbo.[Deliveries] ([delivery_id], [order_id], [shipper_id], [delivery_status], [assigned_at], [picked_up_at], [delivered_at], [delivery_note]) VALUES (5, 9, 4, N'Failed', '2026-06-28 13:30:00', '2026-06-28 13:40:00', NULL, N'Không liên hệ được khách');
SET IDENTITY_INSERT dbo.[Deliveries] OFF;
GO

-- dbo.Refunds
SET IDENTITY_INSERT dbo.[Refunds] ON;
INSERT INTO dbo.[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (1, 7, 6, 7, 2, 47000, N'Khách đổi ý trước khi giao', N'Completed', '2026-06-26 11:05:00', '2026-06-26 11:20:00');
INSERT INTO dbo.[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (2, 8, 7, 8, 2, 64000, N'Sản phẩm không đúng yêu cầu', N'Completed', '2026-06-27 16:30:00', '2026-06-27 16:45:00');
INSERT INTO dbo.[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (3, 9, NULL, 9, 2, 69000, N'Không thể giao hàng', N'Approved', '2026-06-28 14:10:00', '2026-06-28 14:30:00');
INSERT INTO dbo.[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (4, 10, 8, 10, 1, 70000, N'Khách yêu cầu hoàn tiền', N'Completed', '2026-06-29 19:00:00', '2026-06-29 20:00:00');
INSERT INTO dbo.[Refunds] ([refund_id], [order_id], [payment_id], [requested_by], [processed_by], [refund_amount], [reason], [refund_status], [requested_at], [processed_at]) VALUES (5, 4, 3, 9, NULL, 84000, N'Yêu cầu hủy khi đang pha chế', N'Pending', '2026-07-05 09:15:00', NULL);
SET IDENTITY_INSERT dbo.[Refunds] OFF;
GO

-- dbo.OrderStatusHistory
SET IDENTITY_INSERT dbo.[OrderStatusHistory] ON;
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (1, 1, NULL, N'Pending', 6, '2026-06-20 09:15:00', N'Khách tạo đơn');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (2, 1, N'Pending', N'Approved', 2, '2026-06-20 09:20:00', N'Thu ngân duyệt');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (3, 1, N'Approved', N'Processing', 3, '2026-06-20 09:22:00', N'Bắt đầu pha chế');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (4, 1, N'Processing', N'Delivering', 4, '2026-06-20 09:40:00', N'Nhận đơn giao');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (5, 1, N'Delivering', N'Completed', 4, '2026-06-20 10:05:00', N'Giao thành công');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (6, 2, NULL, N'Processing', 2, '2026-06-21 10:30:00', N'Đơn tại quầy');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (7, 2, N'Processing', N'Completed', 2, '2026-06-21 10:35:00', N'Đã giao đồ uống');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (8, 3, NULL, N'Pending', 8, '2026-07-05 08:20:00', N'Khách tạo đơn');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (9, 4, NULL, N'Processing', 2, '2026-07-05 09:05:00', N'Đơn tại quầy');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (10, 5, NULL, N'Pending', 10, '2026-07-05 09:45:00', N'Khách tạo đơn');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (11, 5, N'Pending', N'Approved', 2, '2026-07-05 09:50:00', N'Đã duyệt');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (12, 5, N'Approved', N'Processing', 3, '2026-07-05 09:52:00', N'Đang pha chế');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (13, 5, N'Processing', N'Ready', 3, '2026-07-05 10:00:00', N'Đã pha xong');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (14, 5, N'Ready', N'Delivering', 4, '2026-07-05 10:10:00', N'Đang giao');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (15, 6, NULL, N'Processing', 2, '2026-06-25 14:10:00', N'Đơn tại quầy');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (16, 6, N'Processing', N'Completed', 2, '2026-06-25 14:20:00', N'Hoàn thành');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (17, 7, N'Pending', N'Cancelled', 2, '2026-06-26 11:05:00', N'Khách hủy');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (18, 8, N'Completed', N'Refunded', 2, '2026-06-27 16:45:00', N'Đã hoàn tiền');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (19, 9, N'Delivering', N'Cancelled', 2, '2026-06-28 14:30:00', N'Giao thất bại');
INSERT INTO dbo.[OrderStatusHistory] ([history_id], [order_id], [old_status], [new_status], [changed_by], [changed_at], [note]) VALUES (20, 10, N'Completed', N'Refunded', 1, '2026-06-29 20:00:00', N'Quản lý duyệt hoàn tiền');
SET IDENTITY_INSERT dbo.[OrderStatusHistory] OFF;
GO

-- dbo.PointTransactions
SET IDENTITY_INSERT dbo.[PointTransactions] ON;
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (1, 6, 1, NULL, 70, 2270, N'Earn', N'Cộng điểm đơn #1', '2026-06-20 10:05:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (2, 7, 2, NULL, 58, 1908, N'Earn', N'Cộng điểm đơn #2', '2026-06-21 10:35:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (3, 6, 6, NULL, 120, 2390, N'Earn', N'Cộng điểm đơn #6', '2026-06-25 14:20:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (4, 6, NULL, 6, -1000, 2200, N'Redeem', N'Đổi voucher POINT6A', '2026-06-01 09:00:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (5, 7, NULL, 7, -2000, 1850, N'Redeem', N'Đổi voucher POINT7A', '2026-06-05 09:00:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (6, 8, NULL, NULL, 100, 760, N'Adjust', N'Điểm khuyến mại khai trương', '2026-05-01 08:00:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (7, 9, NULL, NULL, 200, 1200, N'Adjust', N'Điểm sinh nhật', '2026-05-20 08:00:00');
INSERT INTO dbo.[PointTransactions] ([point_transaction_id], [user_id], [order_id], [voucher_id], [points_change], [balance_after], [transaction_type], [description], [created_at]) VALUES (8, 10, 10, NULL, -70, 540, N'Refund', N'Thu hồi điểm do hoàn đơn #10', '2026-06-29 20:00:00');
SET IDENTITY_INSERT dbo.[PointTransactions] OFF;
GO

-- dbo.Reviews
SET IDENTITY_INSERT dbo.[Reviews] ON;
INSERT INTO dbo.[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (1, 6, 1, 5, N'Trà sữa ngon, giao nhanh', 1, '2026-06-20 11:00:00');
INSERT INTO dbo.[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (2, 6, 2, 4, N'Trà đào thơm và vừa ngọt', 1, '2026-06-20 11:02:00');
INSERT INTO dbo.[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (3, 7, 3, 5, N'Cà phê đậm vị', 1, '2026-06-21 12:00:00');
INSERT INTO dbo.[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (4, 6, 9, 4, N'Cappuccino ổn, bọt sữa mịn', 1, '2026-06-25 15:00:00');
INSERT INTO dbo.[Reviews] ([review_id], [user_id], [order_detail_id], [rating], [comment], [status], [created_at]) VALUES (5, 6, 10, 5, N'Bánh giòn và thơm bơ', 1, '2026-06-25 15:02:00');
SET IDENTITY_INSERT dbo.[Reviews] OFF;
GO

-- dbo.Notifications
SET IDENTITY_INSERT dbo.[Notifications] ON;
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (1, 6, 1, N'Đơn hàng hoàn thành', N'Đơn #1 đã được giao thành công.', N'Order', 0, '2026-06-20 10:05:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (2, 6, 1, N'Đã cộng điểm', N'Bạn nhận được 70 điểm từ đơn #1.', N'Point', 0, '2026-06-20 10:06:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (3, 7, 2, N'Đơn hàng hoàn thành', N'Đơn #2 đã hoàn thành.', N'Order', 1, '2026-06-21 10:35:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (4, 8, 3, N'Đã tiếp nhận đơn', N'Đơn #3 đang chờ thu ngân duyệt.', N'Order', 0, '2026-07-05 08:20:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (5, 9, 4, N'Đơn đang pha chế', N'Đơn #4 đang được chuẩn bị.', N'Order', 0, '2026-07-05 09:06:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (6, 10, 5, N'Đơn đang giao', N'Shipper đang giao đơn #5 đến bạn.', N'Order', 0, '2026-07-05 10:10:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (7, 6, NULL, N'Voucher mới', N'Voucher POINT6A đã được thêm vào ví.', N'Voucher', 1, '2026-06-01 09:00:00');
INSERT INTO dbo.[Notifications] ([notification_id], [user_id], [order_id], [title], [message], [notification_type], [is_read], [created_at]) VALUES (8, 7, NULL, N'Voucher mới', N'Voucher POINT7A đã được thêm vào ví.', N'Voucher', 0, '2026-06-05 09:00:00');
SET IDENTITY_INSERT dbo.[Notifications] OFF;
GO

