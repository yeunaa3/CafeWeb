USE CBMS;
GO

IF COL_LENGTH('dbo.Users', 'staff_position') IS NULL
    ALTER TABLE dbo.Users ADD staff_position NVARCHAR(50) NULL;
GO

IF COL_LENGTH('dbo.Vouchers', 'owner_user_id') IS NULL
BEGIN
    ALTER TABLE dbo.Vouchers ADD owner_user_id INT NULL;
    ALTER TABLE dbo.Vouchers ADD CONSTRAINT FK_Vouchers_Owner
        FOREIGN KEY (owner_user_id) REFERENCES dbo.Users(user_id);
END;
GO

IF COL_LENGTH('dbo.Orders', 'points_awarded') IS NULL
BEGIN
    ALTER TABLE dbo.Orders ADD points_awarded BIT NOT NULL
        CONSTRAINT DF_Orders_PointsAwarded DEFAULT 0;
END;
GO

UPDATE dbo.Orders SET points_awarded = 1
WHERE status = N'Completed' AND points_awarded = 0;
GO

UPDATE dbo.Users SET staff_position = N'Manager'
WHERE role_id = 1 AND staff_position IS NULL;
UPDATE dbo.Users SET staff_position = N'Nhân viên'
WHERE role_id = 2 AND staff_position IS NULL;
GO
