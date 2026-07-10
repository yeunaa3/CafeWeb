IF COL_LENGTH('dbo.Users', 'gender') IS NULL
    ALTER TABLE dbo.Users ADD gender NVARCHAR(10) NULL;
GO

IF COL_LENGTH('dbo.Users', 'staff_position') IS NULL
    ALTER TABLE dbo.Users ADD staff_position NVARCHAR(50) NULL;
GO

IF COL_LENGTH('dbo.Users', 'avatar_url') IS NULL
    ALTER TABLE dbo.Users ADD avatar_url VARCHAR(255) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE role_name = 'Manager')
    INSERT INTO dbo.Roles (role_name, description)
    VALUES ('Manager', N'Quản lý cửa hàng và báo cáo');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE role_name = 'Staff')
    INSERT INTO dbo.Roles (role_name, description)
    VALUES ('Staff', N'Nhân viên thu ngân, pha chế hoặc giao hàng');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE role_name = 'Customer')
    INSERT INTO dbo.Roles (role_name, description)
    VALUES ('Customer', N'Khách hàng đặt món và tích điểm');
GO

DECLARE @managerRole INT = (SELECT role_id FROM dbo.Roles WHERE role_name = 'Manager');
DECLARE @staffRole INT = (SELECT role_id FROM dbo.Roles WHERE role_name = 'Staff');
DECLARE @customerRole INT = (SELECT role_id FROM dbo.Roles WHERE role_name = 'Customer');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'admin01')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, staff_position, avatar_url, status, points, role_id, created_at)
    VALUES ('admin01', '123456', N'Nguyễn Quản Lý', 'admin@cbms.com', '0912345678', N'Hà Nội', N'Nam', N'Manager',
            '/images/avatars/uploads/avatar-1-1783652576762.png', 1, 0, @managerRole, '2026-01-02 08:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'cashier01')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, staff_position, avatar_url, status, points, role_id, created_at)
    VALUES ('cashier01', '123456', N'Lê Thu Ngân', 'cashier@cbms.com', '0987654321', N'Hà Nội', N'Nữ', N'Thu ngân',
            '/images/avatars/uploads/avatar-2-1783652661782.png', 1, 0, @staffRole, '2026-01-05 08:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'barista01')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, staff_position, status, points, role_id, created_at)
    VALUES ('barista01', '123456', N'Trần Pha Chế', 'barista@cbms.com', '0944556677', N'Hà Nội', N'Nam', N'Pha chế',
            1, 0, @staffRole, '2026-01-06 08:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'shipper01')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, staff_position, status, points, role_id, created_at)
    VALUES ('shipper01', '123456', N'Phạm Giao Hàng', 'shipper@cbms.com', '0966112233', N'Hà Nội', N'Nam', N'Giao hàng',
            1, 0, @staffRole, '2026-01-07 08:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'staff02')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, staff_position, status, points, role_id, created_at)
    VALUES ('staff02', '123456', N'Vũ Nhân Viên Nghỉ', 'staff02@cbms.com', '0977001122', N'Hà Nội', N'Khác', N'Nhân viên',
            0, 0, @staffRole, '2026-01-08 08:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'customer01')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, avatar_url, status, points, role_id, created_at)
    VALUES ('customer01', '123456', N'Phan Khách Hàng Online', 'customer01@gmail.com', '0909090909', N'Thạch Thất', N'Nam',
            '/images/avatars/uploads/avatar-6-1783652158236.png', 1, 2390, @customerRole, '2026-02-01 09:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'customer02')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, status, points, role_id, created_at)
    VALUES ('customer02', '123456', N'Hoàng Minh Anh', 'customer02@gmail.com', '0933221100', N'Cầu Giấy', N'Nữ',
            1, 1908, @customerRole, '2026-02-05 09:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'customer03')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, status, points, role_id, created_at)
    VALUES ('customer03', '123456', N'Đỗ Hải Nam', 'customer03@gmail.com', '0922113344', N'Nam Từ Liêm', N'Nam',
            1, 760, @customerRole, '2026-02-10 09:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'customer04')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, status, points, role_id, created_at)
    VALUES ('customer04', '123456', N'Bùi Thanh Hà', 'customer04@gmail.com', '0955667788', N'Hoài Đức', N'Nữ',
            1, 1200, @customerRole, '2026-03-01 09:00:00');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'customer05')
    INSERT INTO dbo.Users (username, password, full_name, email, phone, address, gender, status, points, role_id, created_at)
    VALUES ('customer05', '123456', N'Ngô Gia Bảo', 'customer05@gmail.com', '0888999000', N'Hà Đông', N'Khác',
            1, 540, @customerRole, '2026-03-12 09:00:00');
GO

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-1-1783652576762.png'
WHERE username = 'admin01' AND (avatar_url IS NULL OR avatar_url = '');

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-2-1783652661782.png'
WHERE username = 'cashier01' AND (avatar_url IS NULL OR avatar_url = '');

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-6-1783652158236.png'
WHERE username = 'customer01' AND (avatar_url IS NULL OR avatar_url = '');
GO
