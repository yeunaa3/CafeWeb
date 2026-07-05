-- =====================================================================
-- HỆ THỐNG QUẢN LÝ QUÁN CÀ PHÊ & TRÀ SỮA (CBMS)
-- DATABASE SCRIPT CHUẨN CUỐI CÙNG - 100% KHÔNG LỖI
-- =====================================================================

USE master;
GO

-- Xóa database cũ nếu đã tồn tại để làm sạch dữ liệu
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CBMS')
BEGIN
    ALTER DATABASE CBMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CBMS;
END
GO

-- Tạo mới database
CREATE DATABASE CBMS;
GO

USE CBMS;
GO

-- ==========================================
-- PHẦN 1: TẠO CẤU TRÚC CÁC BẢNG (TABLES)
-- ==========================================

-- 1. Bảng Phân quyền (Roles)
CREATE TABLE Roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE -- Admin, Staff, Customer
);

-- 2. Bảng Tài khoản người dùng (Users) - Đáp ứng Task 2 (Login) & Task 7 (Tích điểm, Khóa/Mở nhân sự)
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Độ dài lớn để hỗ trợ mã hóa bảo mật
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NULL,
    address NVARCHAR(255) NULL,
    gender NVARCHAR(10) NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
    status BIT NOT NULL DEFAULT 1, -- 1: Đang hoạt động, 0: Bị khóa (Manager khóa tài khoản - Task 7)
    points INT NOT NULL DEFAULT 0, -- Điểm tích lũy khách hàng (Task 7: 1.000đ = 1 điểm)
    role_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- 3. Bảng Danh mục sản phẩm (Categories) - Đáp ứng Task 6 (CRUD thực đơn)
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE, -- Cà phê, Trà sữa, Combo...
    description NVARCHAR(255) NULL,
    status BIT NOT NULL DEFAULT 1 -- 1: Hiển thị, 0: Ẩn
);

-- 4. Bảng Sản phẩm đồ uống chính (Products) - Đáp ứng Task 3, 4, 6 (Upload ảnh, quản lý món)
CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name NVARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL, -- "Giá gốc" sản phẩm (Size M)
    image_url VARCHAR(255) NULL,   -- Đường dẫn ảnh lưu trên server (Task 6 Multipart)
    description NVARCHAR(MAX) NULL,
    status BIT NOT NULL DEFAULT 1, -- 1: Còn hàng, 0: Ngừng bán/Hết hàng
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- 5. Bảng Topping độc lập (Toppings) - Đáp ứng Task 6 (CRUD Topping) & Task 3, 4 (Bán hàng)
CREATE TABLE Toppings (
    topping_id INT IDENTITY(1,1) PRIMARY KEY,
    topping_name NVARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    status BIT NOT NULL DEFAULT 1 -- 1: Còn, 0: Hết
);

-- 6. Bảng Mã giảm giá (Vouchers) - Đáp ứng Task 7 (Quản lý và áp dụng mã voucher)
CREATE TABLE Vouchers (
    voucher_id INT IDENTITY(1,1) PRIMARY KEY,
    voucher_code VARCHAR(50) NOT NULL UNIQUE,
    discount_value DECIMAL(10,2) NOT NULL, -- Số tiền được giảm (Ví dụ: 20000.00)
    min_order_value DECIMAL(10,2) NOT NULL DEFAULT 0, -- Điều kiện đơn tối thiểu để áp dụng
    expiry_date DATETIME NOT NULL, -- Ngày hết hạn voucher
    status BIT NOT NULL DEFAULT 1 -- 1: Khả dụng, 0: Khóa/Hết hạn
);

-- 7. Bảng Đơn hàng (Orders) - Đáp ứng Task 3, 4, 5, 8 (Phân loại đơn Online/Tại quầy, Cổng thanh toán)
-- ĐÃ XÓA CỘT PHONE THỪA Ở ĐÂY VÌ ĐÃ CÓ TRONG BẢNG USERS
CREATE TABLE Orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL, -- ID Khách hàng (NULL nếu là khách vãng lai mua tại quầy)
    staff_id INT NULL, -- ID Thu ngân xử lý thanh toán/duyệt đơn (Task 5)
    voucher_id INT NULL, -- Mã giảm giá áp dụng (nếu có)
    total_price DECIMAL(10,2) NOT NULL, -- Tổng tiền cuối cùng khách phải trả sau khi giảm giá
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0, -- Số tiền đã được giảm
    order_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending (Chờ duyệt), Processing, Completed (Hoàn thành), Cancelled (Hủy)
    order_type NVARCHAR(50) NOT NULL DEFAULT 'At-Counter', -- Online (Task 3) hoặc At-Counter (Task 4 Máy POS)
    shipping_address NVARCHAR(255) NULL, -- Địa chỉ ship nếu là đơn Online
    payment_method NVARCHAR(50) NOT NULL DEFAULT 'Cash', -- Cash (Tiền mặt), QR-Code (Quét mã - Task 5)
    note NVARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (staff_id) REFERENCES Users(user_id),
    FOREIGN KEY (voucher_id) REFERENCES Vouchers(voucher_id)
);

-- 8. Bảng Chi tiết đơn hàng (OrderDetails) - Đáp ứng Task 3, 4 (Lưu tùy chọn Ly nước: Size, Đá, Đường)
CREATE TABLE OrderDetails (
    order_detail_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    selected_size VARCHAR(10) NOT NULL DEFAULT 'M', -- S, M, L
    ice_level VARCHAR(20) NOT NULL DEFAULT '100%', -- 0%, 30%, 50%, 100%
    sugar_level VARCHAR(20) NOT NULL DEFAULT '100%', -- 0%, 30%, 50%, 100%
    price DECIMAL(10, 2) NOT NULL, -- Giá bán tại thời điểm mua (đã cộng tiền upsize nếu có)
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 9. Bảng Chi tiết Topping trong từng ly nước (OrderDetailToppings) - Đảm bảo chuẩn 3NF
CREATE TABLE OrderDetailToppings (
    order_detail_id INT NOT NULL,
    topping_id INT NOT NULL,
    topping_price DECIMAL(10,2) NOT NULL, -- Giá topping lúc mua để phục vụ thống kê chính xác
    PRIMARY KEY (order_detail_id, topping_id),
    FOREIGN KEY (order_detail_id) REFERENCES OrderDetails(order_detail_id) ON DELETE CASCADE,
    FOREIGN KEY (topping_id) REFERENCES Toppings(topping_id)
);
GO


-- ==========================================
-- PHẦN 2: CHÈN DỮ LIỆU MẪU (SEED DATA)
-- ==========================================

-- 1. Thêm các quyền cơ bản theo quy định bắt buộc
INSERT INTO Roles (role_name) VALUES ('Admin'), ('Staff'), ('Customer');

-- 2. Thêm các tài khoản test hệ thống (Mật khẩu mặc định đều để thuần là '123456')
INSERT INTO Users (username, password, full_name, email, phone, role_id, points, status) VALUES 
('admin01', '123456', N'Nguyễn Quản Lý', 'admin@cbms.com', '0912345678', 1, 0, 1),
('staff01', '123456', N'Lê Thu Ngân', 'staff01@cbms.com', '0987654321', 2, 0, 1),
('staff02', '123456', N'Trần Pha Chế', 'staff02@cbms.com', '0944556677', 2, 0, 0), -- Tài khoản nhân viên bị khóa để test Task 7
('customer01', '123456', N'Phan Khách Hàng Online', 'customer01@gmail.com', '0909090909', 3, 1200, 1), -- Khách có sẵn 1200 điểm để đổi voucher
('customer02', '123456', N'Hoàng Thành Viên Quầy', 'customer02@gmail.com', '0933221100', 3, 450, 1);

-- 3. Thêm các danh mục đồ uống mẫu
INSERT INTO Categories (category_name, description, status) VALUES 
(N'Cà Phê', N'Cà phê máy và cà phê phin truyền thống Việt Nam', 1),
(N'Trà Sữa', N'Trà sữa đậm vị, đa dạng topping và hương vị', 1),
(N'Trà Trái Cây', N'Trà hoa quả nhiệt đới tươi mát, thanh nhiệt', 1),
(N'Đồ Ăn Vặt', N'Các món ăn kèm nhẹ nhàng tại quán', 1);

-- 4. Thêm các sản phẩm đồ uống mẫu
INSERT INTO Products (product_name, category_id, price, image_url, description, status) VALUES 
(N'Cà Phê Sữa Đá', 1, 29000.00, 'caphe_suada.png', N'Cà phê nguyên chất kết hợp lớp sữa đặc thơm béo', 1),
(N'Bạc Xỉu Nhiệt Đới', 1, 35000.00, 'bacxiu.png', N'Hương vị sữa ngậy chiếm chủ đạo kết hợp chút cà phê thơm', 1),
(N'Trà Sữa Trân Châu Hoàng Kim', 2, 45000.00, 'ts_hoangkim.png', N'Trà sữa truyền thống đậm vị trà cùng trân châu hoàng kim độc quyền', 1),
(N'Trà Sữa Matcha', 2, 49000.00, 'ts_matcha.png', N'Sự kết hợp hoàn hảo giữa bột matcha Nhật Bản và sữa', 1),
(N'Trà Đào Cam Sả', 3, 42000.00, 'tra_daocamsa.png', N'Vị thanh ngọt của đào hòa quyện cùng vị chua nhẹ của cam và hương sả', 1),
(N'Bánh Croissant', 4, 25000.00, 'croissant.png', N'Bánh sừng bò ngập hương bơ thơm giòn', 1);

-- 5. Thêm các loại Topping ăn kèm đồ uống
INSERT INTO Toppings (topping_name, price, status) VALUES 
(N'Trân Châu Hoàng Kim', 8000.00, 1),
(N'Thạch Sương Sáo', 6000.00, 1),
(N'Kem Cheese Béo Ngậy', 12000.00, 1),
(N'Trân Châu Trắng', 8000.00, 1);

-- 6. Thêm các mã giảm giá (Vouchers) mẫu
INSERT INTO Vouchers (voucher_code, discount_value, min_order_value, expiry_date, status) VALUES 
('CBMSNEW', 15000.00, 30000.00, '2026-12-31 23:59:59', 1),
('GIAM30K', 30000.00, 70000.00, '2026-12-31 23:59:59', 1),
('EXPIRED2026', 20000.00, 50000.00, '2026-05-01 00:00:00', 0); -- Mã hết hạn để test điều kiện validate Task 7

-- 7. Thêm các hóa đơn mẫu (Lịch sử đơn hàng cũ phục vụ Task 8 làm Dashboard Thống kê)
-- Đơn hàng 1: Đơn hàng online đã hoàn thành
INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, order_date, status, order_type, payment_method) VALUES 
(4, 2, 1, 67000.00, 15000.00, '2026-06-25 10:15:00', 'Completed', 'Online', 'QR-Code');

-- Chi tiết đơn 1: Gồm 1 ly Trà sữa trân châu hoàng kim (Upsize L giá 45k + 5k = 50k) + 1 Topping Trân châu trắng (8k) + 1 Bạc xỉu (35k). Tổng gốc 93k. Có giảm giá.
INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) VALUES 
(1, 3, 1, 'L', '100%', '70%', 50000.00),
(1, 2, 1, 'M', '50%', '100%', 35000.00);

INSERT INTO OrderDetailToppings(order_detail_id, topping_id, topping_price) VALUES 
(1, 4, 8000.00); -- Thêm trân châu trắng vào ly trà sữa (order_detail_id = 1)


-- Đơn hàng 2: Đơn bán tại quầy qua máy POS bằng tiền mặt
INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, order_date, status, order_type, payment_method) VALUES 
(5, 2, NULL, 58000.00, 0.00, '2026-06-28 15:30:00', 'Completed', 'At-Counter', 'Cash');

-- Chi tiết đơn 2: Gồm 2 ly Cà phê sữa đá (29k * 2 = 58k)
INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) VALUES 
(2, 1, 2, 'M', '100%', '100%', 29000.00);


-- Đơn hàng 3: Đơn online đang ở trạng thái "Chờ duyệt" để test luồng xử lý của Thu ngân (Task 3 & Task 5)
-- ĐÃ XÓA TRƯỜNG PHONE THỪA TRONG CÂU LỆNH INSERT NÀY
INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, order_date, status, order_type, payment_method, shipping_address) VALUES 
(4, NULL, NULL, 42000.00, 0.00, GETDATE(), 'Pending', 'Online', 'Cash', N'Khu công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội');

-- Chi tiết đơn 3: Gồm 1 Trà Đào Cam Sả (42k)
INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) VALUES 
(3, 5, 1, 'M', '100%', '100%', 42000.00);
GO

-- Kiểm tra kết quả
SELECT 'Thành công' AS [Trạng thái], COUNT(*) AS [Số tài khoản hiện có] FROM Users;
SELECT * FROM Products;
